from sqlalchemy.orm import Session
from typing import List

from app import models, schemas
from app.crud.base import CRUDBase

def create_comment(db: Session, *, obj_in: schemas.CommentCreate, content_id: int, owner_id: int) -> models.Comment:
    # 创建评论对象
    comment_data = obj_in.model_dump()
    db_obj = models.Comment(
        **comment_data, 
        content_id=content_id, 
        owner_id=owner_id
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def get_comments_by_content(db: Session, *, content_id: int, skip: int = 0, limit: int = 100) -> List[models.Comment]:
    return (
        db.query(models.Comment)
        .filter(models.Comment.content_id == content_id)
        .offset(skip)
        .limit(limit)
        .all()
    )

def get_comment(db: Session, *, comment_id: int) -> models.Comment:
    return db.query(models.Comment).filter(models.Comment.id == comment_id).first()

def update_comment(db: Session, *, db_obj: models.Comment, obj_in: schemas.CommentUpdate) -> models.Comment:
    db_obj.content = obj_in.content
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def remove_comment(db: Session, *, comment_id: int):
    db_obj = db.query(models.Comment).filter(models.Comment.id == comment_id).first()
    if db_obj:
        db.delete(db_obj)
        db.commit()
    return db_obj

def get_total_count(db: Session) -> int:
    return db.query(models.Comment).count()

class CRUDComment(CRUDBase[models.Comment, None, None]):
    pass

comment_crud = CRUDComment(models.Comment) 