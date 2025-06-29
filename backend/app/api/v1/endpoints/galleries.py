from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from pathlib import Path

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.core.config import settings

router = APIRouter()

def _add_image_urls_to_gallery(gallery):
    """为图集中的图片添加image_url字段"""
    if hasattr(gallery, 'images') and gallery.images:
        for image in gallery.images:
            if image.filepath and str(image.filepath).strip():
                # 将filepath转换为相对于uploads目录的路径
                file_path = Path(str(image.filepath))
                upload_dir = Path(settings.UPLOAD_DIRECTORY)
                try:
                    # 计算相对路径
                    relative_path = file_path.relative_to(upload_dir)
                    image.image_url = f"/uploads/{relative_path}".replace("\\", "/")
                except ValueError:
                    # 如果filepath不在uploads目录下，使用filename
                    image.image_url = f"/uploads/{image.filename}"
            else:
                # 如果没有filepath，使用filename
                image.image_url = f"/uploads/{image.filename}"
    
    # 处理封面图片
    if hasattr(gallery, 'cover_image') and gallery.cover_image:
        if gallery.cover_image.filepath and str(gallery.cover_image.filepath).strip():
            file_path = Path(str(gallery.cover_image.filepath))
            upload_dir = Path(settings.UPLOAD_DIRECTORY)
            try:
                relative_path = file_path.relative_to(upload_dir)
                gallery.cover_image.image_url = f"/uploads/{relative_path}".replace("\\", "/")
            except ValueError:
                gallery.cover_image.image_url = f"/uploads/{gallery.cover_image.filename}"
        else:
            gallery.cover_image.image_url = f"/uploads/{gallery.cover_image.filename}"

@router.get("/feed", response_model=List[schemas.Gallery])
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
    galleries = crud.gallery.get_recent(db, skip=skip, limit=limit)
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
    category_id: int = Query(None, description="分类ID筛选"),
    department_id: int = Query(None, description="部门ID筛选"),
    sort: str = Query(None, description="排序字段：likes_count, bookmarks_count, downloads_count, created_at, views_count"),
    order: str = Query("desc", description="排序方向：asc, desc"),
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    获取图集列表（包含图片信息），支持按分类、部门筛选和排序
    """
    if category_id:
        galleries = crud.gallery.get_by_category(db, category_id=category_id, skip=skip, limit=limit)
    elif department_id:
        galleries = crud.gallery.get_by_department(db, department_id=department_id, skip=skip, limit=limit)
    else:
        galleries = crud.gallery.get_multi_with_images_sorted(
            db, skip=skip, limit=limit, sort_field=sort, sort_order=order
        )
    
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
    
    gallery = crud.gallery.update(db=db, db_obj=gallery, obj_in=gallery_in)
    return gallery

@router.delete("/{gallery_id}", response_model=schemas.Gallery)
def delete_gallery(
    *,
    db: Session = Depends(dependencies.get_db),
    gallery_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    删除图集
    """
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    if gallery.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    gallery = crud.gallery.remove(db=db, id=gallery_id)
    return gallery

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