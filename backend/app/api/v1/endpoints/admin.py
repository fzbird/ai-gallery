from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import func, or_, desc
from typing import Any, Dict, List, Optional
import uuid
import shutil
from pathlib import Path

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.core.config import settings

router = APIRouter()

@router.get("/stats", response_model=Dict[str, Any])
def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Get dashboard statistics. Superuser only.
    """
    # 基础统计数据
    total_users = crud.user.get_total_count(db)
    total_images = crud.image.get_total_count(db)
    total_comments = crud.comment.get_total_count(db)
    
    # 新增统计数据
    total_galleries = db.query(models.Gallery).count()
    total_topics = db.query(models.Topic).count()
    
    # 图集相关统计 - 使用更安全的查询
    total_gallery_likes = db.query(func.coalesce(func.sum(models.Gallery.likes_count), 0)).scalar()
    total_gallery_bookmarks = db.query(func.coalesce(func.sum(models.Gallery.bookmarks_count), 0)).scalar()
    total_gallery_views = db.query(func.coalesce(func.sum(models.Gallery.views_count), 0)).scalar()
    
    # 图片相关统计（保持兼容）
    total_likes = crud.image.get_total_likes_count(db)
    
    # 分类分布统计
    images_by_category = crud.image.get_count_by_category(db)
    
    # 图集按分类分布 - 简化查询
    try:
        galleries_by_category_raw = (
            db.query(models.Category.name.label('category_name'), func.count(models.Gallery.id).label('gallery_count'))
            .outerjoin(models.Gallery, models.Category.id == models.Gallery.category_id)
            .group_by(models.Category.name)
            .all()
        )
        galleries_by_category_data = [{"name": row.category_name, "count": row.gallery_count} for row in galleries_by_category_raw]
    except Exception as e:
        print(f"Error fetching galleries by category: {e}")
        galleries_by_category_data = []
    
    # 图集按专题分布 - 简化查询
    try:
        galleries_by_topic_raw = (
            db.query(models.Topic.name.label('topic_name'), func.count(models.Gallery.id).label('gallery_count'))
            .outerjoin(models.Gallery, models.Topic.id == models.Gallery.topic_id)
            .group_by(models.Topic.name)
            .all()
        )
        galleries_by_topic_data = [{"name": row.topic_name, "count": row.gallery_count} for row in galleries_by_topic_raw]
    except Exception as e:
        print(f"Error fetching galleries by topic: {e}")
        galleries_by_topic_data = []
    
    # 用户活跃度统计
    active_users = db.query(models.User).filter(models.User.is_active == True).count()
    superusers_count = db.query(models.User).filter(models.User.is_superuser == True).count()

    return {
        # 基础统计
        "total_users": total_users,
        "total_images": total_images,
        "total_likes": total_likes,
        "total_comments": total_comments,
        
        # 新增统计
        "total_galleries": total_galleries,
        "total_topics": total_topics,
        "total_gallery_likes": int(total_gallery_likes) if total_gallery_likes else 0,
        "total_gallery_bookmarks": int(total_gallery_bookmarks) if total_gallery_bookmarks else 0,
        "total_gallery_views": int(total_gallery_views) if total_gallery_views else 0,
        
        # 用户统计
        "active_users": active_users,
        "superusers_count": superusers_count,
        
        # 分布统计
        "images_by_category": images_by_category,
        "galleries_by_category": galleries_by_category_data,
        "galleries_by_topic": galleries_by_topic_data,
    }


@router.get("/settings", response_model=Dict[str, Any])
def get_system_settings(
    db: Session = Depends(get_db),
):
    """
    Get all system settings. Public access for system name, etc.
    """
    settings = crud.settings.get_all_settings(db)
    # Convert value types as needed, e.g., for numbers
    if 'max_upload_size_mb' in settings:
        settings['max_upload_size_mb'] = int(settings.get('max_upload_size_mb', 50))
    return settings


@router.put("/settings", response_model=Dict[str, Any])
def update_system_settings(
    settings_in: Dict[str, Any],
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Update system settings. Superuser only.
    """
    for key, value in settings_in.items():
        crud.settings.update_setting(db, key=key, value=str(value))
    
    updated_settings = crud.settings.get_all_settings(db)
    # Ensure correct types are returned
    if 'max_upload_size_mb' in updated_settings:
        updated_settings['max_upload_size_mb'] = int(updated_settings.get('max_upload_size_mb', 50))
    return updated_settings


# === 评论管理接口 ===

@router.get("/comments", response_model=List[schemas.Comment])
def get_all_comments(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = Query(None, description="搜索评论内容或用户名"),
    content_type: Optional[str] = Query(None, description="内容类型：image, gallery"),
    sort: str = Query("created_at", description="排序字段：created_at, owner_id"),
    order: str = Query("desc", description="排序方向：asc, desc")
):
    """
    获取所有评论列表，支持搜索和筛选。仅限超级管理员。
    """
    query = db.query(models.Comment).join(models.User, models.Comment.owner_id == models.User.id)
    
    # 搜索功能
    if search:
        search_filter = or_(
            models.Comment.content.ilike(f"%{search}%"),
            models.User.username.ilike(f"%{search}%")
        )
        query = query.filter(search_filter)
    
    # 内容类型筛选
    if content_type:
        # 通过content表进行筛选
        query = query.join(models.ContentBase, models.Comment.content_id == models.ContentBase.id)
        query = query.filter(models.ContentBase.content_type == content_type)
    
    # 排序
    if sort == "created_at":
        sort_column = models.Comment.created_at
    elif sort == "owner_id":
        sort_column = models.Comment.owner_id
    else:
        sort_column = models.Comment.created_at
    
    if order == "desc":
        query = query.order_by(desc(sort_column))
    else:
        query = query.order_by(sort_column)
    
    # 分页
    comments = query.offset(skip).limit(limit).all()
    return comments


@router.delete("/comments/{comment_id}", response_model=Dict[str, Any])
def delete_comment_by_admin(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    管理员删除评论。仅限超级管理员。
    """
    comment = crud.comment.get_comment(db=db, comment_id=comment_id)
    if not comment:
        raise HTTPException(status_code=404, detail="评论不存在")
    
    # 保存评论信息用于返回
    comment_info = {
        "id": comment.id,
        "content": comment.content,
        "owner_username": comment.owner.username,
        "created_at": comment.created_at
    }
    
    # 删除评论
    crud.comment.remove_comment(db=db, comment_id=comment_id)
    
    return {
        "message": "评论删除成功",
        "deleted_comment": comment_info
    }


@router.get("/comments/stats", response_model=Dict[str, Any])
def get_comments_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    获取评论统计信息。仅限超级管理员。
    """
    # 总评论数
    total_comments = db.query(models.Comment).count()
    
    # 今日评论数
    from datetime import datetime, timedelta
    today = datetime.now().date()
    today_comments = db.query(models.Comment).filter(
        func.date(models.Comment.created_at) == today
    ).count()
    
    # 按内容类型分组
    try:
        comments_by_type = (
            db.query(
                models.ContentBase.content_type.label('content_type'),
                func.count(models.Comment.id).label('comment_count')
            )
            .join(models.ContentBase, models.Comment.content_id == models.ContentBase.id)
            .group_by(models.ContentBase.content_type)
            .all()
        )
        comments_by_type_data = [
            {"type": row.content_type, "count": row.comment_count} 
            for row in comments_by_type
        ]
    except Exception as e:
        print(f"Error fetching comments by type: {e}")
        comments_by_type_data = []
    
    # 最活跃的评论用户（前5名）
    try:
        top_commenters = (
            db.query(
                models.User.username.label('username'),
                func.count(models.Comment.id).label('comment_count')
            )
            .join(models.Comment, models.User.id == models.Comment.owner_id)
            .group_by(models.User.username)
            .order_by(desc(func.count(models.Comment.id)))
            .limit(5)
            .all()
        )
        top_commenters_data = [
            {"username": row.username, "count": row.comment_count}
            for row in top_commenters
        ]
    except Exception as e:
        print(f"Error fetching top commenters: {e}")
        top_commenters_data = []
    
    return {
        "total_comments": total_comments,
        "today_comments": today_comments,
        "comments_by_type": comments_by_type_data,
        "top_commenters": top_commenters_data
    } 


@router.post("/upload-logo", response_model=Dict[str, Any])
def upload_logo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    上传系统Logo并更新系统设置。仅限超级管理员。
    """
    # 验证文件类型
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="不支持的文件类型。仅支持 JPEG, PNG, GIF, WebP 格式。"
        )
    
    # 验证文件大小 (2MB限制)
    max_size = 2 * 1024 * 1024  # 2MB
    if hasattr(file, 'size') and file.size > max_size:
        raise HTTPException(
            status_code=400,
            detail="文件太大。Logo文件不能超过2MB。"
        )
    
    try:
        # 确保logos目录存在
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        logos_dir = upload_dir / "logos"
        logos_dir.mkdir(parents=True, exist_ok=True)
        
        # 生成唯一文件名，保持原始扩展名
        file_extension = Path(file.filename).suffix
        if not file_extension:
            file_extension = ".png"  # 默认扩展名
        
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = logos_dir / unique_filename
        
        # 保存文件
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # 构建相对URL路径
        logo_url = f"/uploads/logos/{unique_filename}"
        
        # 更新系统设置中的site_logo
        crud.settings.update_setting(db, key="site_logo", value=logo_url)
        
        return {
            "message": "Logo上传成功",
            "logo_url": logo_url,
            "filename": unique_filename
        }
        
    except Exception as e:
        # 如果出错，尝试删除已上传的文件
        if 'file_path' in locals() and file_path.exists():
            try:
                file_path.unlink()
            except:
                pass
        
        raise HTTPException(
            status_code=500,
            detail=f"上传Logo时发生错误: {str(e)}"
        )
    finally:
        file.file.close() 


@router.get("/daily-stats", response_model=Dict[str, Any])
def get_daily_stats(
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    Get daily statistics for today's content.
    """
    from datetime import datetime, date
    from sqlalchemy import func
    
    today = date.today()
    
    # 今日新增图集数量
    today_galleries = db.query(func.count(models.Gallery.id)).filter(
        func.date(models.Gallery.created_at) == today
    ).scalar()
    
    # 今日新增图片数量
    today_images = db.query(func.count(models.Image.id)).filter(
        func.date(models.Image.created_at) == today
    ).scalar()
    
    # 今日获得的总点赞数（图集 + 图片）
    today_gallery_likes = db.query(func.coalesce(func.sum(models.Gallery.likes_count), 0)).filter(
        func.date(models.Gallery.created_at) == today
    ).scalar()
    
    today_image_likes = db.query(func.coalesce(func.sum(models.Image.likes_count), 0)).filter(
        func.date(models.Image.created_at) == today
    ).scalar()
    
    total_today_likes = (today_gallery_likes or 0) + (today_image_likes or 0)
    
    # 今日获得的总收藏数（图集 + 图片）
    today_gallery_bookmarks = db.query(func.coalesce(func.sum(models.Gallery.bookmarks_count), 0)).filter(
        func.date(models.Gallery.created_at) == today
    ).scalar()
    
    today_image_bookmarks = db.query(func.coalesce(func.sum(models.Image.bookmarks_count), 0)).filter(
        func.date(models.Image.created_at) == today
    ).scalar()
    
    total_today_bookmarks = (today_gallery_bookmarks or 0) + (today_image_bookmarks or 0)
    
    return {
        "today_galleries": today_galleries or 0,
        "today_images": today_images or 0,
        "today_likes": total_today_likes,
        "today_bookmarks": total_today_bookmarks,
        "date": today.isoformat()
    } 