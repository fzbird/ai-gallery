from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form
from sqlalchemy.orm import Session
import shutil
import uuid
import logging
from pathlib import Path

from app import crud, models, schemas
from app.api.v1.dependencies import get_db, get_current_active_user
from app.schemas.topic import TopicCreate, TopicUpdate, TopicPage
from app.core.image_utils import generate_image_url, compress_image, add_watermark
from app.api.v1.endpoints.galleries import _add_image_urls_to_gallery
from app.core.config import settings

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/admin/all", response_model=TopicPage, summary="获取所有专题（管理员）")
def read_all_topics_admin(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="跳过的项目数"),
    limit: int = Query(10, ge=1, le=100, description="每页的项目数"),
    search: str = Query("", description="搜索关键词"),
    status: str = Query("", description="状态筛选：active, inactive"),
    sort: str = Query("id", description="排序字段：id, name"),
    order: str = Query("desc", description="排序方向：asc, desc"),
    current_user: models.User = Depends(get_current_active_user)
):
    """
    获取所有专题，支持搜索和筛选，并附带图集数量统计。
    仅限管理员访问。
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足，需要管理员权限")

    # 构建基础查询
    from sqlalchemy import func
    query = db.query(models.Topic)
    
    # 搜索条件
    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            models.Topic.name.ilike(search_pattern) |
            models.Topic.description.ilike(search_pattern)
        )
    
    # 状态筛选
    if status == "active":
        query = query.filter(models.Topic.is_active == True)
    elif status == "inactive":
        query = query.filter(models.Topic.is_active == False)
    
    # 排序
    if sort == "name":
        if order.lower() == "desc":
            query = query.order_by(models.Topic.name.desc())
        else:
            query = query.order_by(models.Topic.name.asc())
    else:
        # 默认按ID排序
        if order.lower() == "desc":
            query = query.order_by(models.Topic.id.desc())
        else:
            query = query.order_by(models.Topic.id.asc())
    
    # 获取总数
    total = query.count()
    
    # 应用分页
    topics = query.offset(skip).limit(limit).all()
    
    # 为每个专题计算图集数量
    results = []
    for topic in topics:
        gallery_count = len(getattr(topic, 'galleries', []))
        results.append((topic, gallery_count))
    
    # 格式化响应数据
    items = []
    for topic, count in results:
        item = schemas.TopicListItem.from_orm(topic)
        item.galleries_count = count or 0
        if topic.cover_image:
            item.cover_image_url = generate_image_url(topic.cover_image)
        items.append(item)
    
    return {"items": items, "total": total}


@router.get("/", response_model=List[schemas.TopicListItem])
def read_topics(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    featured_only: bool = Query(default=False, description="只返回推荐专题")
) -> Any:
    """
    获取专题列表
    """
    topics = crud.topic.get_active_topics(
        db, skip=skip, limit=limit, featured_only=featured_only
    )
    return topics


@router.get("/count")
def count_topics(
    db: Session = Depends(get_db),
    featured_only: bool = Query(default=False, description="只计算推荐专题")
) -> Any:
    """
    获取专题总数
    """
    count = crud.topic.count_active_topics(
        db, featured_only=featured_only
    )
    return {"total": count}

@router.get("/stats")
def get_topics_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_active_user)
) -> Any:
    """
    Get statistics for all topics.
    Admin only.
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足")
    
    # 基础专题统计
    total_topics = db.query(models.Topic).count()
    active_topics = db.query(models.Topic).filter(models.Topic.is_active == True).count()
    inactive_topics = total_topics - active_topics
    
    # 获取所有专题进行Python统计
    all_topics = db.query(models.Topic).all()
    
    # 统计专题图集数量
    topic_gallery_counts = {}
    total_galleries_in_topics = 0
    
    for topic in all_topics:
        # 获取专题下的图集数量
        gallery_count = len(getattr(topic, 'galleries', []))
        topic_gallery_counts[topic.name] = gallery_count
        total_galleries_in_topics += gallery_count
    
    # 转换为前端格式 - 按图集数量排序
    topic_data = []
    for name, count in topic_gallery_counts.items():
        topic_data.append({"name": name, "count": count})
    
    topic_data.sort(key=lambda x: x["count"], reverse=True)
    
    # 最受欢迎专题（按图集数量）
    top_topics_data = topic_data[:5]
    
    return {
        "total_topics": total_topics,
        "active_topics": active_topics,
        "inactive_topics": inactive_topics,
        "total_galleries_in_topics": total_galleries_in_topics,
        "topics_by_galleries": topic_data,
        "top_topics": top_topics_data
    }


@router.get("/search", response_model=List[schemas.TopicListItem])
def search_topics(
    q: str = Query(..., min_length=1, description="搜索关键词"),
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = Query(default=100, le=100)
) -> Any:
    """
    搜索专题
    """
    topics = crud.topic.search_topics(
        db, query=q, skip=skip, limit=limit
    )
    return topics


@router.get("/{topic_id}", response_model=schemas.TopicDetail)
def read_topic(
    *,
    db: Session = Depends(get_db),
    topic_id: int
) -> Any:
    """
    获取专题详情
    """
    topic = crud.topic.get(db=db, id=topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="专题不存在")
    
    if not topic.is_active:
        raise HTTPException(status_code=404, detail="专题不可用")
    
    return topic


@router.get("/{topic_id}/galleries", response_model=List[schemas.Gallery])
def read_topic_galleries(
    *,
    db: Session = Depends(get_db),
    topic_id: int,
    skip: int = 0,
    limit: int = Query(default=100, le=100),
    sort: str = Query(default="created_at", description="排序字段: created_at, views_count, likes_count, bookmarks_count"),
    order: str = Query(default="desc", description="排序方向: asc, desc")
) -> Any:
    """
    获取专题下的图集列表
    """
    topic = crud.topic.get(db=db, id=topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="专题不存在")
    
    if not topic.is_active:
        raise HTTPException(status_code=404, detail="专题不可用")
    
    galleries = crud.topic.get_topic_galleries(
        db=db, topic_id=topic_id, skip=skip, limit=limit, sort=sort, order=order
    )
    
    # 为图集及其图片动态添加可访问的URL
    for gallery in galleries:
        _add_image_urls_to_gallery(gallery)
        
    return galleries


@router.get("/slug/{slug}", response_model=schemas.TopicDetail)
def read_topic_by_slug(
    *,
    db: Session = Depends(get_db),
    slug: str
) -> Any:
    """
    根据slug获取专题详情
    """
    topic = crud.topic.get_by_slug(db=db, slug=slug)
    if not topic:
        raise HTTPException(status_code=404, detail="专题不存在")
    
    if not topic.is_active:
        raise HTTPException(status_code=404, detail="专题不可用")
    
    return topic


@router.post("/", response_model=schemas.Topic)
def create_topic(
    *,
    db: Session = Depends(get_db),
    topic_in: schemas.TopicCreate,
    current_user: models.User = Depends(get_current_active_user)
) -> Any:
    """
    创建新专题（需要管理员权限）
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足")
    
    # 检查slug是否已存在
    if crud.topic.get_by_slug(db=db, slug=topic_in.slug):
        raise HTTPException(status_code=400, detail="Slug已存在")
    
    # 检查名称是否已存在
    existing_topic = db.query(models.Topic).filter(models.Topic.name == topic_in.name).first()
    if existing_topic:
        raise HTTPException(status_code=400, detail="专题名称已存在")
    
    topic = crud.topic.create(db=db, obj_in=topic_in)
    return topic


@router.put("/{topic_id}", response_model=schemas.Topic)
def update_topic(
    *,
    db: Session = Depends(get_db),
    topic_id: int,
    topic_in: schemas.TopicUpdate,
    current_user: models.User = Depends(get_current_active_user)
) -> Any:
    """
    更新专题（需要管理员权限）
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足")
    
    topic = crud.topic.get(db=db, id=topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="专题不存在")
    
    # 如果更新slug，检查是否已存在
    if topic_in.slug and topic_in.slug != topic.slug:
        if crud.topic.get_by_slug(db=db, slug=topic_in.slug):
            raise HTTPException(status_code=400, detail="Slug已存在")
    
    # 如果更新名称，检查是否已存在
    if topic_in.name and topic_in.name != topic.name:
        existing_topic = db.query(models.Topic).filter(models.Topic.name == topic_in.name).first()
        if existing_topic:
            raise HTTPException(status_code=400, detail="专题名称已存在")
    
    # 处理封面图片URL到ID的转换
    update_data = topic_in.dict(exclude_unset=True)
    if topic_in.cover_image_url is not None:
        # 根据URL查找对应的图片ID
        if topic_in.cover_image_url.strip():  # 如果URL不为空
            # 从URL中提取文件名
            from urllib.parse import urlparse
            import os
            
            url_path = urlparse(topic_in.cover_image_url).path
            filename = os.path.basename(url_path)
            
            # 查找对应的图片记录
            image = db.query(models.Image).filter(models.Image.filename == filename).first()
            if image:
                update_data['cover_image_id'] = image.id
                logger.info(f"Found image ID {image.id} for URL {topic_in.cover_image_url}")
            else:
                logger.warning(f"No image found for URL {topic_in.cover_image_url}")
                # 如果找不到对应的图片，将cover_image_id设为None
                update_data['cover_image_id'] = None
        else:
            # 如果URL为空，清除封面图片
            update_data['cover_image_id'] = None
        
        # 移除cover_image_url字段，因为数据库不存储这个字段
        update_data.pop('cover_image_url', None)
    
    # 使用处理后的数据字典进行更新
    topic = crud.topic.update(db=db, db_obj=topic, obj_in=update_data)
    return topic


@router.delete("/{topic_id}")
def delete_topic(
    *,
    db: Session = Depends(get_db),
    topic_id: int,
    current_user: models.User = Depends(get_current_active_user)
) -> Any:
    """
    删除专题（需要管理员权限）
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足")
    
    topic = crud.topic.get(db=db, id=topic_id)
    if not topic:
        raise HTTPException(status_code=404, detail="专题不存在")
    
    crud.topic.remove(db=db, id=topic_id)
    return {"message": "专题删除成功"}


@router.post("/{topic_id}/upload-cover", summary="上传专题封面图片")
def upload_topic_cover(
    *,
    db: Session = Depends(get_db),
    topic_id: int,
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_active_user)
) -> Any:
    """
    上传专题封面图片（需要管理员权限）
    """
    try:
        logger.info(f"开始上传专题封面，topic_id: {topic_id}, user_id: {current_user.id}")
        logger.info(f"文件信息: filename={file.filename}, content_type={file.content_type}")
        
        if not current_user.is_superuser:
            logger.warning(f"用户 {current_user.id} 尝试上传专题封面但权限不足")
            raise HTTPException(status_code=403, detail="权限不足")
        
        # 检查专题是否存在
        topic = crud.topic.get(db=db, id=topic_id)
        if not topic:
            logger.error(f"专题 {topic_id} 不存在")
            raise HTTPException(status_code=404, detail="专题不存在")
        
        # 检查文件类型
        if not file.content_type or not file.content_type.startswith("image/"):
            logger.error(f"文件类型错误: {file.content_type}")
            raise HTTPException(status_code=400, detail="文件必须是图片格式")
            
    except HTTPException as e:
        logger.error(f"上传专题封面失败: {str(e)}")
        raise e
    except Exception as e:
        logger.error(f"上传专题封面过程中发生未知错误: {str(e)}")
        raise HTTPException(status_code=500, detail=f"服务器内部错误: {str(e)}")
    
    # 创建专题图片目录
    upload_dir = Path(settings.UPLOAD_DIRECTORY) / "topics"
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # 生成唯一文件名
    file_extension = file.filename.split(".")[-1] if file.filename and "." in file.filename else "jpg"
    unique_filename = f"topic_{topic_id}_{uuid.uuid4()}.{file_extension}"
    file_path = upload_dir / unique_filename
    
    try:
        # 保存文件
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"文件上传失败: {str(e)}"
        )
    finally:
        file.file.close()
    
    try:
        # 处理图片（压缩和水印）
        compress_image(file_path)
        add_watermark(file_path)
    except Exception as e:
        # 如果图片处理失败，删除文件并返回错误
        if file_path.exists():
            file_path.unlink()
        raise HTTPException(
            status_code=400,
            detail=f"图片处理失败: {str(e)}"
        )
    
    # 创建图片记录
    try:
        image_in = schemas.ImageCreate(
            title=f"{topic.name}的封面图片",
            description=f"专题「{topic.name}」的封面图片",
            file_hash=None  # 专题封面不需要hash检查
        )
        
        image = crud.image.create(
            db=db,
            obj_in=image_in,
            owner_id=current_user.id,
            filename=unique_filename,
            filepath=str(file_path),
            tags=["专题封面"],
            category_id=None
        )
        
        # 更新专题的封面图片ID
        update_data = {"cover_image_id": image.id}
        crud.topic.update(db=db, db_obj=topic, obj_in=update_data)
        
        # 返回图片信息和访问URL
        return {
            "message": "专题封面上传成功",
            "image_id": image.id,
            "cover_image_url": f"/uploads/topics/{unique_filename}",
            "filename": unique_filename
        }
        
    except Exception as e:
        # 如果数据库操作失败，删除已上传的文件
        if file_path.exists():
            file_path.unlink()
        raise HTTPException(
            status_code=500,
            detail=f"保存图片记录失败: {str(e)}"
        )

 