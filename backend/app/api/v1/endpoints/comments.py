from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.models.user import UserRole
from app.api.v1 import dependencies
from app.db.session import get_db

router = APIRouter()

@router.post("/images/{image_id}/comments", response_model=schemas.Comment)
def create_comment_for_image(
    image_id: int,
    *,
    db: Session = Depends(get_db),
    comment_in: schemas.CommentCreate,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Create a new comment for an image.
    """
    # 检查是否开放评论
    enable_comments_setting = crud.settings.get_setting(db, key="enable_comments")
    if enable_comments_setting and enable_comments_setting.value.lower() == "false":
        raise HTTPException(
            status_code=403,
            detail="Comments are currently disabled by the administrator.",
        )
    
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # 图片作为内容存储在content表中，使用相同的ID
    comment = crud.comment.create_comment(
        db=db, obj_in=comment_in, content_id=image_id, owner_id=current_user.id
    )
    return comment

@router.get("/images/{image_id}/comments", response_model=List[schemas.Comment])
def read_comments_for_image(
    image_id: int,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve comments for an image.
    """
    image = crud.image.get(db=db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # 图片作为内容存储在content表中，使用相同的ID
    comments = crud.comment.get_comments_by_content(
        db=db, content_id=image_id, skip=skip, limit=limit
    )
    return comments

@router.put("/comments/{comment_id}", response_model=schemas.Comment)
def update_comment(
    comment_id: int,
    *,
    db: Session = Depends(get_db),
    comment_in: schemas.CommentUpdate,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Update a comment.
    """
    comment = crud.comment.get_comment(db=db, comment_id=comment_id)
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")
    if comment.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    comment = crud.comment.update_comment(db=db, db_obj=comment, obj_in=comment_in)
    return comment

@router.delete("/comments/{comment_id}", response_model=schemas.Comment)
def delete_comment(
    comment_id: int,
    *,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Delete a comment.
    """
    comment = crud.comment.get_comment(db=db, comment_id=comment_id)
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")
    
    # Allow admin to delete any comment, or owner to delete their own
    if comment.owner_id != current_user.id and current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    # 删除评论前先保存返回值
    comment_to_return = {
        "id": comment.id,
        "content": comment.content,
        "created_at": comment.created_at,
        "owner_id": comment.owner_id,
        "owner": {
            "id": comment.owner.id,
            "username": comment.owner.username
        },
        "children": []
    }
    
    crud.comment.remove_comment(db=db, comment_id=comment_id)
    return comment_to_return

@router.post("/galleries/{gallery_id}/comments", response_model=schemas.Comment)
def create_comment_for_gallery(
    gallery_id: int,
    *,
    db: Session = Depends(get_db),
    comment_in: schemas.CommentCreate,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Create a new comment for a gallery.
    """
    # 检查是否开放评论
    enable_comments_setting = crud.settings.get_setting(db, key="enable_comments")
    if enable_comments_setting and enable_comments_setting.value.lower() == "false":
        raise HTTPException(
            status_code=403,
            detail="Comments are currently disabled by the administrator.",
        )
    
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    # 图集作为内容存储在content表中，使用相同的ID
    comment = crud.comment.create_comment(
        db=db, obj_in=comment_in, content_id=gallery_id, owner_id=current_user.id
    )
    return comment

@router.get("/galleries/{gallery_id}/comments", response_model=List[schemas.Comment])
def read_comments_for_gallery(
    gallery_id: int,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve comments for a gallery.
    """
    gallery = crud.gallery.get(db=db, id=gallery_id)
    if not gallery:
        raise HTTPException(status_code=404, detail="Gallery not found")
    
    # 图集作为内容存储在content表中，使用相同的ID
    comments = crud.comment.get_comments_by_content(
        db=db, content_id=gallery_id, skip=skip, limit=limit
    )
    return comments 