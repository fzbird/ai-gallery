import shutil
import uuid
from pathlib import Path
from typing import List, Any, Optional

from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import or_

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.core.config import settings
from app.core.image_utils import compress_image, add_watermark
from app.models.content_interactions import content_tags
from app.crud.crud_gallery import gallery as crud_gallery
from pydantic import BaseModel

router = APIRouter()


def _map_image_to_schema(image: models.Image, current_user_id: Optional[int] = None) -> schemas.Image:
    """Helper to map SQLAlchemy model to Pydantic schema with like counts."""
    # Create the base Pydantic model from the SQLAlchemy model attributes
    image_data = schemas.Image.model_validate(image).model_dump()
    
    # Manually add fields that might not be loaded or need calculation
    image_data['likes_count'] = len(image.liked_by_users)
    image_data['bookmarks_count'] = len(image.bookmarked_by_users)
    image_data['views_count'] = image.views_count or 0
    image_data['liked_by_current_user'] = any(user.id == current_user_id for user in image.liked_by_users) if current_user_id else False
    image_data['bookmarked_by_current_user'] = any(user.id == current_user_id for user in image.bookmarked_by_users) if current_user_id else False
    
    # 添加图片访问URL - 基于filepath构建正确的URL
    if image.filepath and str(image.filepath).strip():
        # 将filepath转换为相对于uploads目录的路径
        # 例如: "E:/Cursor/Gallery/backend/uploads/gallery_56/filename.jpg" -> "gallery_56/filename.jpg"
        from pathlib import Path
        file_path = Path(str(image.filepath))
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        try:
            # 计算相对路径
            relative_path = file_path.relative_to(upload_dir)
            image_data['image_url'] = f"/uploads/{relative_path}".replace("\\", "/")
        except ValueError:
            # 如果filepath不在uploads目录下，使用filename
            image_data['image_url'] = f"/uploads/{image.filename}"
    else:
        # 如果没有filepath，使用filename
        image_data['image_url'] = f"/uploads/{image.filename}"
    
    # Add comments data if loaded
    if hasattr(image, 'comments') and image.comments is not None:
        from app.schemas.comment import Comment
        image_data['comments'] = [Comment.model_validate(comment) for comment in image.comments]
    else:
        image_data['comments'] = []
    
    return schemas.Image(**image_data)


# New schema for the hash check endpoint
class HashCheckRequest(BaseModel):
    hashes: List[str]

@router.post("/check-hashes", response_model=List[str])
def check_image_hashes(
    *,
    db: Session = Depends(get_db),
    request_body: HashCheckRequest,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Check which file hashes already exist in the database.
    """
    existing_hashes = crud.image.get_existing_hashes(db, hashes=request_body.hashes)
    return existing_hashes


@router.post("/", response_model=schemas.Image)
def upload_image(
    *,
    db: Session = Depends(get_db),
    title: str = Form(...),
    description: Optional[str] = Form(None),
    tags: Optional[str] = Form(None),
    category_id: Optional[int] = Form(None),
    topic_id: Optional[int] = Form(None),
    gallery_id: Optional[int] = Form(None),
    gallery_folder: Optional[str] = Form(None),
    file_hash: str = Form(...),
    file: UploadFile = File(...),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Upload an image for the current user after checking its hash.
    Supports gallery folder organization and duplicate file detection (fast upload).
    """
    # Final check for duplicates before saving the file (秒传功能)
    existing_image = crud.image.get_by_hash(db, file_hash=file_hash)
    if existing_image:
        # 秒传逻辑：不修改原有图片，而是创建新的数据库记录
        if gallery_id:
            # 为新记录生成唯一的文件名，避免数据库约束冲突
            new_filename = f"{uuid.uuid4()}.jpg"
            
            # 创建新的图片记录，复用文件路径但有独立的文件名和空的file_hash
            tag_list = [tag.strip() for tag in tags.split(",")] if tags else []
            image_in = schemas.ImageCreate(
                title=title, 
                description=description, 
                topic_id=topic_id,
                file_hash=None  # 秒传记录不保存file_hash，避免唯一约束冲突
            )
            new_image = crud.image.create(
                db=db, 
                obj_in=image_in, 
                owner_id=current_user.id, 
                filename=new_filename,  # 使用新的唯一文件名
                filepath=str(existing_image.filepath),  # 复用文件路径
                tags=tag_list,
                category_id=category_id,
                gallery_id=gallery_id
            )
            
            # 更新图集统计信息
            crud_gallery.update_image_count(db, gallery_id=gallery_id)
            
            return _map_image_to_schema(new_image, current_user.id)
        else:
            # 不关联图集时，直接返回现有图片
            return _map_image_to_schema(existing_image, current_user.id)

    # Ensure the upload directory exists
    upload_dir = Path(settings.UPLOAD_DIRECTORY)
    
    # 如果指定了图集文件夹，创建对应目录
    if gallery_folder:
        gallery_dir = upload_dir / gallery_folder
        gallery_dir.mkdir(parents=True, exist_ok=True)
        target_dir = gallery_dir
    else:
        upload_dir.mkdir(parents=True, exist_ok=True)
        target_dir = upload_dir

    # Force .jpg extension as we convert to JPEG
    unique_filename = f"{uuid.uuid4()}.jpg"
    file_path = target_dir / unique_filename

    try:
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="There was an error uploading the file.",
        )
    finally:
        file.file.close()
    
    # Process the image
    compress_image(file_path)
    add_watermark(file_path)

    tag_list = [tag.strip() for tag in tags.split(",")] if tags else []
    image_in = schemas.ImageCreate(
        title=title, 
        description=description, 
        topic_id=topic_id,
        file_hash=file_hash
    )
    image = crud.image.create(
        db=db, 
        obj_in=image_in, 
        owner_id=current_user.id, 
        filename=unique_filename,
        filepath=str(file_path),
        tags=tag_list,
        category_id=category_id,
        gallery_id=gallery_id
    )

    # 如果关联了图集，更新图集统计信息
    if gallery_id:
        crud_gallery.update_image_count(db, gallery_id=gallery_id)

    return _map_image_to_schema(image, current_user.id)


@router.get("/all", response_model=List[schemas.Image])
def read_images(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    Retrieve images. Publicly accessible.
    Can be filtered by category.
    If authenticated, will show user-specific data (likes, bookmarks).
    """
    images = crud.image.get_multi(db, skip=skip, limit=limit)
    
    current_user_id = current_user.id if current_user else None
    return [_map_image_to_schema(img, current_user_id) for img in images]


@router.get("/feed", response_model=List[schemas.Image])
def get_user_feed(
    *,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Get the feed of images from users the current user follows.
    Includes the user's own images.
    """
    followed_user_ids = [user.id for user in current_user.followed]
    # Also include the current user's own ID in the feed
    followed_user_ids.append(current_user.id)

    images_query = (
        db.query(models.Image)
        .filter(models.Image.owner_id.in_(followed_user_ids))
        .options(selectinload(models.Image.liked_by_users), selectinload(models.Image.bookmarked_by_users))
        .order_by(models.Image.created_at.desc())
    )

    images = images_query.offset(skip).limit(limit).all()

    return [_map_image_to_schema(img, current_user.id) for img in images]


@router.get("/{image_id}", response_model=schemas.Image)
def read_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
) -> Any:
    """
    Get image by ID.
    This endpoint is public and does not require authentication.
    增加浏览量统计。
    """
    # 预加载关系数据，确保可以正确计算点赞和收藏状态
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category),
        selectinload(models.Image.comments)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # 增加浏览量
    db.query(models.Image).filter(models.Image.id == image_id).update(
        {models.Image.views_count: models.Image.views_count + 1}
    )
    db.commit()
    db.refresh(image)
    
    current_user_id = current_user.id if current_user else None
    return _map_image_to_schema(image, current_user_id)


@router.get("/{image_id}/file")
def read_image_file(
    *,
    db: Session = Depends(get_db),
    image_id: int,
) -> Any:
    """
    Get the image file itself.
    This endpoint is public for direct linking.
    """
    image = crud.image.get(db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    file_path = Path(image.filepath)
    if not file_path.is_file():
         raise HTTPException(status_code=404, detail="Image file not found on server")

    return FileResponse(file_path)


@router.put("/{image_id}", response_model=schemas.Image)
def update_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    image_in: schemas.ImageUpdate,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Update an image.
    """
    image = crud.image.get(db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    if image.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    image = crud.image.update(db=db, db_obj=image, obj_in=image_in)
    return _map_image_to_schema(image, current_user.id)


@router.delete("/{image_id}", response_model=schemas.Image)
def delete_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Delete an image.
    """
    # Get image with related data for response mapping
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    if image.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    # Get image data before deletion for response
    image_response = _map_image_to_schema(image, current_user.id)
    
    # Delete the image (this also removes the file)
    crud.image.remove(db=db, id=image_id)
    
    return image_response


@router.get("/search/", response_model=List[schemas.Image])
def search_images(
    *,
    db: Session = Depends(get_db),
    q: str = "",
    skip: int = 0,
    limit: int = 100,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
) -> Any:
    """
    Search for images by a query string.
    Searches in title, description, tags, and owner's username.
    """
    if not q:
        return []

    search_term = f"%{q.lower()}%"

    images_query = (
        db.query(models.Image)
        .join(models.User, models.Image.owner_id == models.User.id)
        .outerjoin(content_tags)
        .outerjoin(models.Tag, content_tags.c.tag_id == models.Tag.id)
        .filter(
            or_(
                models.Image.title.ilike(search_term),
                models.Image.description.ilike(search_term),
                models.Tag.name.ilike(search_term),
                models.User.username.ilike(search_term)
            )
        )
        .group_by(models.Image.id)
        .options(selectinload(models.Image.liked_by_users), selectinload(models.Image.bookmarked_by_users))
        .order_by(models.Image.created_at.desc())
    )
    
    images = images_query.offset(skip).limit(limit).all()
    current_user_id = current_user.id if current_user else None
    
    return [_map_image_to_schema(img, current_user_id) for img in images]


@router.post("/{image_id}/like", response_model=schemas.Image)
def like_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Like an image.
    """
    # 预加载关系数据
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    image = crud.image.like(db=db, user=current_user, image=image)
    return _map_image_to_schema(image, current_user.id)


@router.delete("/{image_id}/like", response_model=schemas.Image)
def unlike_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Unlike an image.
    """
    # 预加载关系数据
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
        
    image = crud.image.unlike(db=db, user=current_user, image=image)
    return _map_image_to_schema(image, current_user.id)


@router.post("/{image_id}/bookmark", response_model=schemas.Image)
def bookmark_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Bookmark an image.
    """
    # 预加载关系数据
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    image = crud.image.bookmark(db=db, user=current_user, image=image)
    return _map_image_to_schema(image, current_user.id)


@router.delete("/{image_id}/bookmark", response_model=schemas.Image)
def unbookmark_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Unbookmark an image.
    """
    # 预加载关系数据
    image = db.query(models.Image).options(
        selectinload(models.Image.liked_by_users),
        selectinload(models.Image.bookmarked_by_users),
        selectinload(models.Image.owner),
        selectinload(models.Image.tags),
        selectinload(models.Image.category)
    ).filter(models.Image.id == image_id).first()
    
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    image = crud.image.unbookmark(db=db, user=current_user, image=image)
    return _map_image_to_schema(image, current_user.id)