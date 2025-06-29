from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.models.content_base import ContentType
from app.schemas.content import (
    Content, ContentFeed, Image, Gallery, ImageCreate, GalleryCreate,
    ImageUpdate, GalleryUpdate, LikeResponse, BookmarkResponse
)
from app.services.content_service import ContentService

router = APIRouter()

# === 统一内容端点 ===

@router.get("/feed", response_model=ContentFeed)
def get_content_feed(
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取内容feed（图片和图集混合）
    """
    user_id = current_user.id if current_user else None
    
    if content_type:
        contents = crud.content.get_multi_with_relations(
            db, skip=skip, limit=limit, content_type=content_type, user_id=user_id
        )
        total = len(contents)  # 简化实现
        has_next = len(contents) == limit
    else:
        feed_data = crud.content.get_feed(db, user_id=user_id, skip=skip, limit=limit)
        contents = feed_data["items"]
        total = feed_data["total"]
        has_next = feed_data["has_next"]
    
    return ContentFeed(
        items=contents,
        total=total,
        page=skip // limit + 1,
        size=len(contents),
        has_next=has_next
    )

@router.get("/popular", response_model=List[Content])
def get_popular_content(
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取热门内容
    """
    contents = crud.content.get_popular(db, skip=skip, limit=limit, content_type=content_type)
    
    # 添加用户交互状态
    if current_user:
        for content in contents:
            content.liked_by_current_user = ContentService.check_user_liked(db, content.id, current_user.id)
            content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, current_user.id)
    
    return contents

@router.get("/recent", response_model=List[Content])
def get_recent_content(
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取最新内容
    """
    contents = crud.content.get_recent(db, skip=skip, limit=limit, content_type=content_type)
    
    # 添加用户交互状态
    if current_user:
        for content in contents:
            content.liked_by_current_user = ContentService.check_user_liked(db, content.id, current_user.id)
            content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, current_user.id)
    
    return contents

@router.get("/search", response_model=List[Content])
def search_content(
    q: str = Query(..., min_length=1),
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    搜索内容
    """
    contents = crud.content.search(db, query_str=q, skip=skip, limit=limit, content_type=content_type)
    
    # 添加用户交互状态
    if current_user:
        for content in contents:
            content.liked_by_current_user = ContentService.check_user_liked(db, content.id, current_user.id)
            content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, current_user.id)
    
    return contents

@router.get("/{content_id}", response_model=Content)
def get_content(
    content_id: int,
    db: Session = Depends(dependencies.get_db),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取单个内容详情
    """
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    # 增加浏览量
    crud.content.increment_views(db, content_id=content_id)
    
    # 添加用户交互状态
    if current_user:
        content.liked_by_current_user = ContentService.check_user_liked(db, content.id, current_user.id)
        content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, current_user.id)
    
    return content

# === 交互端点 ===

@router.post("/{content_id}/like", response_model=LikeResponse)
def like_content(
    content_id: int,
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    点赞内容
    """
    # 检查内容是否存在
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    liked = ContentService.like_content(db, content_id, current_user.id)
    
    # 获取最新的点赞数
    updated_content = crud.content.get(db, id=content_id)
    
    return LikeResponse(
        liked=liked,
        likes_count=updated_content.likes_count
    )

@router.delete("/{content_id}/like", response_model=LikeResponse)
def unlike_content(
    content_id: int,
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    取消点赞内容
    """
    # 检查内容是否存在
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    unliked = ContentService.unlike_content(db, content_id, current_user.id)
    
    # 获取最新的点赞数
    updated_content = crud.content.get(db, id=content_id)
    
    return LikeResponse(
        liked=not unliked,
        likes_count=updated_content.likes_count
    )

@router.post("/{content_id}/bookmark", response_model=BookmarkResponse)
def bookmark_content(
    content_id: int,
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    收藏内容
    """
    # 检查内容是否存在
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    bookmarked = ContentService.bookmark_content(db, content_id, current_user.id)
    
    # 获取最新的收藏数
    updated_content = crud.content.get(db, id=content_id)
    
    return BookmarkResponse(
        bookmarked=bookmarked,
        bookmarks_count=updated_content.bookmarks_count
    )

@router.delete("/{content_id}/bookmark", response_model=BookmarkResponse)
def unbookmark_content(
    content_id: int,
    db: Session = Depends(dependencies.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    取消收藏内容
    """
    # 检查内容是否存在
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    unbookmarked = ContentService.unbookmark_content(db, content_id, current_user.id)
    
    # 获取最新的收藏数
    updated_content = crud.content.get(db, id=content_id)
    
    return BookmarkResponse(
        bookmarked=not unbookmarked,
        bookmarks_count=updated_content.bookmarks_count
    )

# === 图片特定端点 ===

@router.post("/images", response_model=Image, status_code=status.HTTP_201_CREATED)
def create_image(
    *,
    db: Session = Depends(dependencies.get_db),
    image_in: ImageCreate,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    创建新图片
    """
    image = crud.content.create_with_owner(db=db, obj_in=image_in, owner_id=current_user.id)
    return image

@router.get("/images", response_model=List[Image])
def get_images(
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    gallery_id: Optional[int] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取图片列表
    """
    user_id = current_user.id if current_user else None
    
    if gallery_id:
        # 获取特定图集的图片
        images = crud.content.get_multi_with_relations(
            db, skip=skip, limit=limit, content_type=ContentType.IMAGE, user_id=user_id
        )
        # 过滤出属于指定图集的图片
        images = [img for img in images if hasattr(img, 'gallery_id') and img.gallery_id == gallery_id]
    else:
        images = crud.content.get_multi_with_relations(
            db, skip=skip, limit=limit, content_type=ContentType.IMAGE, user_id=user_id
        )
    
    return images

# === 图集特定端点 ===

@router.post("/galleries", response_model=Gallery, status_code=status.HTTP_201_CREATED)
def create_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_in: GalleryCreate,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    创建新图集
    """
    gallery = crud.content.create_with_owner(db=db, obj_in=gallery_in, owner_id=current_user.id)
    return gallery

@router.get("/galleries", response_model=List[Gallery])
def get_galleries(
    db: Session = Depends(dependencies.get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取图集列表
    """
    user_id = current_user.id if current_user else None
    galleries = crud.content.get_multi_with_relations(
        db, skip=skip, limit=limit, content_type=ContentType.GALLERY, user_id=user_id
    )
    return galleries 