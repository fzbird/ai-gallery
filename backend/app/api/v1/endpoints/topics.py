from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api.v1.dependencies import get_db, get_current_active_user
from app.schemas.topic import TopicCreate, TopicUpdate, TopicPage
from app.core.image_utils import generate_image_url
from app.api.v1.endpoints.galleries import _add_image_urls_to_gallery

router = APIRouter()


@router.get("/admin/all", response_model=TopicPage, summary="获取所有专题（管理员）")
def read_all_topics_admin(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0, description="跳过的项目数"),
    limit: int = Query(10, ge=1, le=100, description="每页的项目数"),
    current_user: models.User = Depends(get_current_active_user)
):
    """
    获取所有专题，包括禁用的专题，并附带图集数量统计。
    仅限管理员访问。
    """
    if not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="权限不足，需要管理员权限")

    results, total = crud.topic.get_all_with_gallery_count(db=db, skip=skip, limit=limit)
    
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
    
    topic = crud.topic.update(db=db, db_obj=topic, obj_in=topic_in)
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

 