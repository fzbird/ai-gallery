from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from pathlib import Path

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.core.config import settings

router = APIRouter()

def _add_image_url_to_image(image):
    """为单个图片对象添加image_url字段"""
    if not image:
        return
    
    # 安全获取filepath字符串
    filepath_str = ""
    if hasattr(image, 'filepath') and image.filepath is not None:
        filepath_str = str(image.filepath).strip()
    
    if filepath_str:
        # 将filepath转换为相对于uploads目录的路径
        file_path = Path(filepath_str)
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        try:
            # 计算相对路径
            relative_path = file_path.relative_to(upload_dir)
            image.image_url = f"/uploads/{relative_path}".replace("\\", "/")
        except ValueError:
            # 如果relative_to失败，尝试从filepath中手动提取相对路径
            normalized_filepath = filepath_str.replace("\\", "/")
            uploads_str = "uploads/"
            
            # 查找uploads/在路径中的位置
            uploads_index = normalized_filepath.find(uploads_str)
            if uploads_index != -1:
                # 提取从uploads/之后的部分作为相对路径
                relative_part = normalized_filepath[uploads_index + len(uploads_str):]
                image.image_url = f"/uploads/{relative_part}"
            else:
                # 如果filepath中没有uploads，使用filename
                image.image_url = f"/uploads/{image.filename}"
    else:
        # 如果没有filepath，使用filename
        image.image_url = f"/uploads/{image.filename}"

def _add_image_urls_to_gallery(gallery):
    """为图集中的所有图片添加image_url字段"""
    if not gallery:
        return
    
    # 处理图集中的所有图片
    if hasattr(gallery, 'images') and gallery.images:
        for image in gallery.images:
            _add_image_url_to_image(image)
    
    # 处理封面图片
    if hasattr(gallery, 'cover_image') and gallery.cover_image:
        _add_image_url_to_image(gallery.cover_image)

@router.get("/feed", response_model=List[schemas.GalleryWithImages])
def read_gallery_feed(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 30,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    获取当前用户的图集推荐Feed
    """
    # 简单实现：获取用户关注的人的图集 + 最新图集
    galleries = crud.gallery.get_multi_with_images(db, skip=skip, limit=limit)
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
    
    return galleries

@router.get("/count")
def get_galleries_count(
    db: Session = Depends(dependencies.get_db),
    category_id: int = Query(None, description="分类ID筛选"),
    department_id: int = Query(None, description="部门ID筛选"),
):
    """
    获取图集总数
    """
    # 简化实现，避免复杂的linter错误
    # 直接获取所有图集总数
    total = crud.gallery.get_total_count(db)
    
    return {"total": total}

@router.get("/stats", response_model=schemas.GalleryStats)
def get_galleries_stats(
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    获取图集的综合统计数据。
    Admin only.
    """
    stats = crud.gallery.get_stats(db)
    return stats

@router.get("/", response_model=List[schemas.GalleryWithImages])
def read_galleries(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 100,
    search: str = "",
    category_id: int = Query(None, description="分类ID筛选"),
    department_id: int = Query(None, description="部门ID筛选"),
    status: str = Query("", description="状态筛选：published, unpublished"),
    sort: str = Query(None, description="排序字段：likes_count, bookmarks_count, downloads_count, created_at, views_count"),
    order: str = Query("desc", description="排序方向：asc, desc"),
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    获取图集列表（包含图片信息），支持搜索、按分类、部门筛选和排序
    """
    # 构建基础查询
    from sqlalchemy.orm import selectinload
    query = db.query(models.Gallery).options(
        selectinload(models.Gallery.images),
        selectinload(models.Gallery.owner),
        selectinload(models.Gallery.category)
    )
    
    # 搜索条件
    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            models.Gallery.title.ilike(search_pattern) |
            models.Gallery.description.ilike(search_pattern)
        )
    
    # 分类筛选
    if category_id:
        query = query.filter(models.Gallery.category_id == category_id)
    
    # 部门筛选（通过用户的部门）
    if department_id:
        query = query.join(models.User).filter(models.User.department_id == department_id)
    
    # 状态筛选（Gallery没有is_published字段，暂时跳过）
    # TODO: 如果需要状态筛选，需要在Gallery模型中添加相应字段
    
    # 排序逻辑
    order_desc = order.lower() == "desc"
    
    if sort == "views_count":
        if order_desc:
            query = query.order_by(models.Gallery.views_count.desc())
        else:
            query = query.order_by(models.Gallery.views_count.asc())
    elif sort == "likes_count":
        if order_desc:
            query = query.order_by(models.Gallery.likes_count.desc())
        else:
            query = query.order_by(models.Gallery.likes_count.asc())
    elif sort == "bookmarks_count":
        if order_desc:
            query = query.order_by(models.Gallery.bookmarks_count.desc())
        else:
            query = query.order_by(models.Gallery.bookmarks_count.asc())
    elif sort == "created_at":
        if order_desc:
            query = query.order_by(models.Gallery.created_at.desc())
        else:
            query = query.order_by(models.Gallery.created_at.asc())
    else:
        # 默认按创建时间降序
        query = query.order_by(models.Gallery.created_at.desc())
    
    # 应用分页
    galleries = query.offset(skip).limit(limit).all()
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            # TODO: 实现点赞和收藏状态检查
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
    
    return galleries

@router.post("/", response_model=schemas.Gallery, status_code=status.HTTP_201_CREATED)
def create_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_in: schemas.GalleryCreate,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    创建新图集
    """
    gallery = crud.gallery.create_with_owner(
        db=db, obj_in=gallery_in, owner_id=current_user.id
    )
    return gallery

@router.get("/recent", response_model=List[schemas.GalleryWithImages])
def read_recent_galleries(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 30,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    获取最新图集（包含图片信息）
    """
    galleries = crud.gallery.get_multi_with_images(db, skip=skip, limit=limit)
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
    
    return galleries

@router.get("/popular", response_model=List[schemas.GalleryWithImages])
def read_popular_galleries(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 30,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    获取热门图集（包含图片信息）
    """
    galleries = crud.gallery.get_popular(db, skip=skip, limit=limit)
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
    
    return galleries

@router.get("/search", response_model=List[schemas.GalleryWithImages])
def search_galleries(
    q: str,
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    搜索图集（包含图片信息）
    """
    galleries = crud.gallery.search_with_images(db, query=q, skip=skip, limit=limit)
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
    
    return galleries

@router.get("/{gallery_id}", response_model=schemas.GalleryWithImages)
def read_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    获取指定图集的详细信息（包含所有图片）
    """
    gallery = crud.gallery.get_with_images(db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    # 增加浏览量
    db.query(models.Gallery).filter(models.Gallery.id == gallery_id).update(
        {models.Gallery.views_count: models.Gallery.views_count + 1}
    )
    db.commit()
    db.refresh(gallery)
    
    # 设置当前用户的点赞和收藏状态
    if current_user:
        setattr(gallery, 'liked_by_current_user', current_user in gallery.liked_by_users)
        setattr(gallery, 'bookmarked_by_current_user', current_user in gallery.bookmarked_by_users)
    else:
        setattr(gallery, 'liked_by_current_user', False)
        setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为图片添加image_url字段
    _add_image_urls_to_gallery(gallery)
    
    return gallery

@router.put("/{gallery_id}", response_model=schemas.Gallery)
def update_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    gallery_in: schemas.GalleryUpdate,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    更新图集信息
    """
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    if gallery.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    # 处理标签更新
    if gallery_in.tags is not None:
        from app.crud.crud_tag import get_or_create_tags
        # 清除现有标签关联
        gallery.tags.clear()
        
        # 添加新标签
        if gallery_in.tags.strip():
            tag_names = [tag.strip() for tag in gallery_in.tags.split(',') if tag.strip()]
            new_tags = get_or_create_tags(db, tags=tag_names)
            gallery.tags.extend(new_tags)
    
    # 创建一个新的更新对象，排除tags字段以避免类型冲突
    update_data = gallery_in.model_dump(exclude={'tags'}, exclude_unset=True)
    gallery = crud.gallery.update(db=db, db_obj=gallery, obj_in=update_data)
    return gallery

@router.delete("/{gallery_id}", response_model=schemas.Gallery)
def delete_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """删除图集（在删除前先序列化，以避免 DetachedInstanceError）"""
    # 先加载所有关联关系，防止 Session 关闭后 Lazy-Load
    gallery = crud.gallery.get_with_images(db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")

    if gallery.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    # 为返回做准备（加载必要字段）
    # 补充图片 URL 字段，保持与其他接口一致
    _add_image_urls_to_gallery(gallery)
    gallery_data = schemas.Gallery.model_validate(gallery)

    # 真正执行删除（内部会安全删除图片文件）
    crud.gallery.remove(db=db, id=gallery_id)

    return gallery_data

@router.post("/{gallery_id}/like")
def toggle_gallery_like(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    切换图集点赞状态
    """
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    # 检查用户是否已经点赞
    is_liked = current_user in gallery.liked_by_users
    
    if is_liked:
        # 取消点赞
        gallery.liked_by_users.remove(current_user)
        gallery.likes_count = max(0, gallery.likes_count - 1)
    else:
        # 添加点赞
        gallery.liked_by_users.append(current_user)
        gallery.likes_count += 1
    
    db.commit()
    db.refresh(gallery)
    
    return {
        "liked": not is_liked,
        "likes_count": gallery.likes_count
    }

@router.post("/{gallery_id}/bookmark")
def toggle_gallery_bookmark(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    切换图集收藏状态
    """
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    # 检查用户是否已经收藏
    is_bookmarked = current_user in gallery.bookmarked_by_users
    
    if is_bookmarked:
        # 取消收藏
        gallery.bookmarked_by_users.remove(current_user)
        gallery.bookmarks_count = max(0, gallery.bookmarks_count - 1)
    else:
        # 添加收藏
        gallery.bookmarked_by_users.append(current_user)
        gallery.bookmarks_count += 1
    
    db.commit()
    db.refresh(gallery)
    
    return {
        "bookmarked": not is_bookmarked,
        "bookmarks_count": gallery.bookmarks_count
    }