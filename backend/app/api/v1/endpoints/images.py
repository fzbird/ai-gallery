import shutil
import uuid
from pathlib import Path
from typing import List, Any, Optional

from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status, BackgroundTasks
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import or_

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.core.config import settings
from app.core.image_utils import compress_image, add_watermark, generate_image_url
from app.models.content_interactions import content_tags
from app.crud.crud_gallery import gallery as crud_gallery
from app.services.background_tasks import background_task_manager
from pydantic import BaseModel
from app.models import Gallery

router = APIRouter()

def trigger_ai_analysis_background(image_id: int):
    """
    后台任务，用于触发对新上传图片的AI分析。
    """
    from app.db.session import SessionLocal
    from app.services.ai_service import aianalysis
    from app.services.background_tasks import background_task_manager
    from app.core.config import settings
    import logging

    logger = logging.getLogger(__name__)

    # 使用后台任务管理器来执行
    @background_task_manager.task
    def task():
        db = SessionLocal()
        try:
            logger.info(f"Starting AI analysis for image {image_id}")
            aianalysis.start_image_analysis(
                db=db, 
                image_id=image_id, 
                confidence_threshold=settings.AI_CONFIDENCE_THRESHOLD
            )
            logger.info(f"AI analysis task for image {image_id} completed.")
        except Exception as e:
            logger.error(f"Error during AI analysis for image {image_id}: {e}")
        finally:
            db.close()

    try:
        task()
    except Exception as e:
        logger.error(f"Failed to add AI analysis task for image {image_id}: {e}")

def _map_image_to_schema(db: Session, image: models.Image, user_id: Optional[int]) -> schemas.Image:
    """
    Maps a database Image object to a Pydantic Image schema object.
    Includes dynamic fields like image_url and user-specific interactions.
    """
    if not image:
        return None

    # 创建基础 schema 对象
    image_schema = schemas.Image.model_validate(image)

    # 1. 添加图片URL
    if image.filepath and str(image.filepath).strip():
        file_path = Path(str(image.filepath))
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        try:
            relative_path = file_path.relative_to(upload_dir)
            image_schema.image_url = f"/uploads/{relative_path}".replace("\\", "/")
        except ValueError:
            image_schema.image_url = f"/uploads/{image.filename}"
    else:
        image_schema.image_url = f"/uploads/{image.filename}"

    # 2. 添加用户交互信息
    if user_id:
        image_schema.liked_by_current_user = crud.image.is_liked_by_user(db=db, image_id=image.id, user_id=user_id)
        image_schema.bookmarked_by_current_user = crud.image.is_bookmarked_by_user(db=db, image_id=image.id, user_id=user_id)
    else:
        image_schema.liked_by_current_user = False
        image_schema.bookmarked_by_current_user = False

    # 3. 检查是否为封面图片
    is_cover = db.query(Gallery).filter(Gallery.cover_image_id == image.id).first()
    image_schema.is_cover_image = is_cover is not None

    return image_schema

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
    background_tasks: BackgroundTasks,
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
            
            # 复用原图片的AI分析结果（避免重复分析，节省算力）
            ai_status = getattr(existing_image, 'ai_status', None)
            ai_description = getattr(existing_image, 'ai_description', None)
            ai_tags = getattr(existing_image, 'ai_tags', None)
            
            if ai_status == 'completed' and ai_description:
                update_data = {
                    'ai_status': ai_status,
                    'ai_description': ai_description,
                    'ai_tags': ai_tags
                }
                crud.image.update(db, db_obj=new_image, obj_in=update_data)
                # 如果原图有AI标签，也复制过来
                if ai_tags and isinstance(ai_tags, list):
                    from app.crud.crud_tag import get_or_create_tags
                    try:
                        tag_objects = get_or_create_tags(db, tags=ai_tags)
                        existing_tags = list(new_image.tags)
                        for tag in tag_objects:
                            if tag not in existing_tags:
                                existing_tags.append(tag)
                        new_image.tags = existing_tags
                        db.commit()
                        db.refresh(new_image)
                    except Exception as e:
                        print(f"Failed to copy AI tags: {e}")
            else:
                # 原图没有AI分析结果，或分析未完成，则进行新的AI分析
                background_tasks.add_task(trigger_ai_analysis_background, new_image.id)
            
            # 更新图集统计信息
            crud_gallery.update_image_count(db, gallery_id=gallery_id)
            
            return _map_image_to_schema(db, new_image, current_user.id)
        else:
            # 不关联图集时，直接返回现有图片
            return _map_image_to_schema(db, existing_image, current_user.id)

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

    # 将AI分析任务添加到后台任务（上传成功后异步执行）
    background_tasks.add_task(trigger_ai_analysis_background, image.id)

    return _map_image_to_schema(db, image, current_user.id)

@router.get("/feed", response_model=List[schemas.Image])
def read_images_feed(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Retrieve images for the current user's feed (following users' images).
    """
    images = crud.image.get_multi(db, skip=skip, limit=limit)
    return [_map_image_to_schema(db, image, current_user.id) for image in images]

@router.get("/", response_model=List[schemas.Image])
def read_images(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[int] = None,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    Retrieve all images with optional category filtering.
    """
    if category_id:
        images = crud.image.get_multi(db, skip=skip, limit=limit)  # 简化为基础查询
    else:
        images = crud.image.get_multi(db, skip=skip, limit=limit)
    
    user_id = current_user.id if current_user else None
    return [_map_image_to_schema(db, image, user_id) for image in images]

@router.get("/search", response_model=List[schemas.Image])
def search_images(
    q: str,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    Search images by title, description, or tags.
    """
    # 简化搜索实现
    images = crud.image.get_multi(db, skip=skip, limit=limit)
    user_id = current_user.id if current_user else None
    return [_map_image_to_schema(db, image, user_id) for image in images]

@router.get("/{image_id}", response_model=schemas.Image)
def read_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
):
    """
    Get a specific image by ID.
    """
    image = crud.image.get_with_relations(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # Increment view count - simple implementation
    if hasattr(image, 'views_count'):
        image.views_count = (image.views_count or 0) + 1
        db.commit()
        db.refresh(image)
    
    user_id = current_user.id if current_user else None
    return _map_image_to_schema(db, image, user_id)

@router.put("/{image_id}", response_model=schemas.Image)
def update_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    image_in: schemas.ImageUpdate,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Update an image.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    if image.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    image = crud.image.update(db=db, db_obj=image, obj_in=image_in)
    return _map_image_to_schema(db, image, current_user.id)

@router.delete("/{image_id}", response_model=schemas.Image)
def delete_image(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Delete an image.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    if image.owner_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    
    # 在删除之前映射对象，以避免DetachedInstanceError
    image_to_return = _map_image_to_schema(db, image, current_user.id)
    
    crud.image.remove(db=db, id=image_id)
    
    return image_to_return

@router.post("/{image_id}/like")
def toggle_image_like(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Toggle like status for an image.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    is_liked = crud.image.is_liked_by_user(db, image_id=image_id, user_id=current_user.id)
    
    if is_liked:
        updated_image = crud.image.unlike(db, image=image, user=current_user)
        liked = False
    else:
        updated_image = crud.image.like(db, image=image, user=current_user)
        liked = True
    
    # 直接从更新后的image对象获取计数
    likes_count = updated_image.likes_count or 0
    
    return {"liked": liked, "likes_count": likes_count}

@router.post("/{image_id}/bookmark")
def toggle_image_bookmark(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    Toggle bookmark status for an image.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    is_bookmarked = crud.image.is_bookmarked_by_user(db, image_id=image_id, user_id=current_user.id)
    
    if is_bookmarked:
        updated_image = crud.image.unbookmark(db, image=image, user=current_user)
        bookmarked = False
    else:
        updated_image = crud.image.bookmark(db, image=image, user=current_user)
        bookmarked = True
    
    # 直接从更新后的image对象获取计数
    bookmarks_count = updated_image.bookmarks_count or 0
    
    return {"bookmarked": bookmarked, "bookmarks_count": bookmarks_count}

@router.get("/{image_id}/file")
def get_image_file(
    *,
    image_id: int,
    db: Session = Depends(get_db),
):
    """
    Serve the actual image file.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    file_path = Path(image.filepath)
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Image file not found")
    
    return FileResponse(file_path, media_type="image/jpeg")