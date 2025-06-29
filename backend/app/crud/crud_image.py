from sqlalchemy.orm import Session
from sqlalchemy import func, text
from typing import List, Union, Dict, Any, Optional
import os

from app.models.image import Image
from app.models.content_interactions import content_likes
from app.schemas.image import ImageCreate, ImageUpdate
from app.crud.base import CRUDBase
from app.models.user import User
from app.models.tag import Tag

class CRUDImage(CRUDBase[Image, ImageCreate, ImageUpdate]):
    def create(
        self, 
        db: Session, 
        *, 
        obj_in: ImageCreate, 
        owner_id: int, 
        filename: str, 
        filepath: str,
        tags: Optional[List[str]] = None,
        category_id: Optional[int] = None,
        gallery_id: Optional[int] = None
    ) -> Image:
        db_obj = Image(
            title=obj_in.title,
            description=obj_in.description,
            filename=filename,
            filepath=filepath,
            file_hash=obj_in.file_hash,
            owner_id=owner_id,
            topic_id=obj_in.topic_id
        )
        
        # Handle tags
        if tags:
            tag_objects = []
            for tag_name in tags:
                tag = db.query(Tag).filter(Tag.name == tag_name).first()
                if not tag:
                    tag = Tag(name=tag_name)
                    db.add(tag)
                tag_objects.append(tag)
            db_obj.tags = tag_objects

        # Handle category
        if category_id:
            db_obj.category_id = category_id
            
        # Handle gallery
        if gallery_id:
            db_obj.gallery_id = gallery_id
            
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def get_by_hash(self, db: Session, *, file_hash: str) -> Image:
        return db.query(Image).filter(Image.file_hash == file_hash).first()

    def get_existing_hashes(self, db: Session, *, hashes: List[str]) -> List[str]:
        if not hashes:
            return []
        existing_hashes = db.query(Image.file_hash).filter(Image.file_hash.in_(hashes)).all()
        return [h for h, in existing_hashes]

    def get_total_count(self, db: Session) -> int:
        return db.query(self.model).count()

    def get_count_by_category(self, db: Session) -> List[Dict[str, Any]]:
        from app.models.category import Category
        results = (
            db.query(Category.name, func.count(Image.id))
            .join(Image, Category.id == Image.category_id)
            .group_by(Category.name)
            .all()
        )
        return [{"name": name, "count": count} for name, count in results]

    def get_total_likes_count(self, db: Session) -> int:
        # Querying the association table directly for efficiency
        return db.query(func.count(content_likes.c.user_id)).filter(
            content_likes.c.content_id.in_(
                db.query(Image.id).subquery()
            )
        ).scalar()

    def update(self, db: Session, *, db_obj: Image, obj_in: Union[ImageUpdate, Dict[str, Any]]) -> Image:
        update_data = obj_in if isinstance(obj_in, dict) else obj_in.dict(exclude_unset=True)

        if "tags" in update_data:
            tag_names = update_data.pop("tags")
            tags = []
            for tag_name in tag_names:
                tag = db.query(Tag).filter(Tag.name == tag_name).first()
                if not tag:
                    tag = Tag(name=tag_name)
                    db.add(tag)
                tags.append(tag)
            db_obj.tags = tags

        return super().update(db, db_obj=db_obj, obj_in=update_data)

    def create_with_owner_and_category(
        self, db: Session, *, obj_in: ImageCreate, owner_id: int, category_id: int, tags: List[str]
    ) -> Image:
        dummy_filename = f"seed_{owner_id}_{obj_in.title.replace(' ', '_')}.jpg"
        dummy_filepath = f"/app/uploads/{dummy_filename}"
        
        db_obj = Image(
            title=obj_in.title,
            description=obj_in.description,
            filename=dummy_filename,
            filepath=dummy_filepath,
            owner_id=owner_id,
            category_id=category_id,
        )
        
        if tags:
            db_tags = []
            for tag_name in tags:
                tag = db.query(Tag).filter(Tag.name == tag_name).first()
                if not tag:
                    tag = Tag(name=tag_name)
                    db.add(tag)
                db_tags.append(tag)
            db_obj.tags = db_tags
            
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def remove(self, db: Session, *, id: int) -> Image:
        obj = db.query(self.model).get(id)
        if not obj:
            return None
            
        # Also remove file from filesystem
        if obj.filepath and os.path.exists(obj.filepath):
            try:
                os.remove(obj.filepath)
            except OSError as e:
                # Log the error but don't fail the deletion
                print(f"Warning: Could not delete file {obj.filepath}: {e}")
                
        db.delete(obj)
        db.commit()
        return obj

    def like(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user not in db_image.liked_by_users:
            db_image.liked_by_users.append(db_user)
            db.commit()
            db.refresh(db_image)
        return db_image

    def unlike(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user in db_image.liked_by_users:
            db_image.liked_by_users.remove(db_user)
            db.commit()
            db.refresh(db_image)
        return db_image

    def bookmark(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user not in db_image.bookmarked_by_users:
            db_image.bookmarked_by_users.append(db_user)
            db.commit()
            db.refresh(db_image)
        return db_image

    def unbookmark(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user in db_image.bookmarked_by_users:
            db_image.bookmarked_by_users.remove(db_user)
            db.commit()
            db.refresh(db_image)
        return db_image

image = CRUDImage(Image) 