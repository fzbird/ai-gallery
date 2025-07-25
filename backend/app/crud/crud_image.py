from sqlalchemy.orm import Session
from sqlalchemy import func, text
from typing import List, Union, Dict, Any, Optional
import os

from app import crud
from app.models.image import Image
from app.models.content_interactions import content_likes, content_bookmarks
from app.schemas.image import ImageCreate, ImageUpdate
from app.crud.base import CRUDBase
from app.models.user import User
from app.models.tag import Tag
from app.core.image_utils import safe_delete_image_file
from app.models.comment import Comment

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

    def count_filepath_references(self, db: Session, *, filepath: str) -> int:
        """统计指定文件路径被多少个图片记录引用"""
        return db.query(Image).filter(Image.filepath == filepath).count()

    def get_existing_hashes(self, db: Session, *, hashes: List[str]) -> List[str]:
        if not hashes:
            return []
        existing_hashes = db.query(Image.file_hash).filter(Image.file_hash.in_(hashes)).all()
        return [h for h, in existing_hashes]

    def get_multi_by_owner(self, db: Session, *, owner_id: int, skip: int = 0, limit: int = 100) -> List[Image]:
        """
        Get all images for a specific owner.
        """
        return (
            db.query(self.model)
            .filter(self.model.owner_id == owner_id)
            .order_by(self.model.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )

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
        """
        删除一个图片记录，并安全地处理关联的物理文件。
        如果图片属于某个图集，则更新该图集的图片数量。
        在删除前先清理所有外键引用。
        """
        obj = db.query(self.model).get(id)
        if not obj:
            return None
        
        filepath = obj.filepath
        gallery_id = obj.gallery_id
        
        # 关键步骤：在删除图片前，先清理所有外键引用
        self._clear_foreign_key_references(db, image_id=id)
        
        # 先删除数据库记录
        db.delete(obj)
        db.commit()
        
        # 如果图片属于图集，更新图集计数
        if gallery_id:
            crud.gallery.update_image_count(db, gallery_id=gallery_id)
            
        # 在记录删除后，再检查并安全地删除物理文件
        if filepath:
            safe_delete_image_file(db, filepath)
            
        return obj
    
    def _clear_foreign_key_references(self, db: Session, *, image_id: int) -> None:
        """
        清理所有引用指定图片的外键关系，防止删除时出现约束错误
        """
        # 1. 清理 Gallery 表的 cover_image_id 外键
        from app.models.gallery import Gallery
        db.query(Gallery).filter(Gallery.cover_image_id == image_id).update({
            Gallery.cover_image_id: None
        })
        
        # 2. 清理 Topic 表的 cover_image_id 外键
        from app.models.topic import Topic
        db.query(Topic).filter(Topic.cover_image_id == image_id).update({
            Topic.cover_image_id: None
        })
        
        # 3. 如果以后还有其他表引用Image，也在这里添加清理逻辑
        # 例如：用户头像、分类封面等
        
        # 提交这些更改
        db.commit()

    def is_liked_by_user(self, db: Session, *, image_id: int, user_id: int) -> bool:
        return db.query(content_likes).filter(
            content_likes.c.content_id == image_id,
            content_likes.c.user_id == user_id
        ).first() is not None

    def is_bookmarked_by_user(self, db: Session, *, image_id: int, user_id: int) -> bool:
        return db.query(content_bookmarks).filter(
            content_bookmarks.c.content_id == image_id,
            content_bookmarks.c.user_id == user_id
        ).first() is not None
    
    def like(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user not in db_image.liked_by_users:
            db_image.liked_by_users.append(db_user)
            # 同时更新计数字段
            db_image.likes_count = (db_image.likes_count or 0) + 1
            db.commit()
            db.refresh(db_image)
        return db_image

    def unlike(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user in db_image.liked_by_users:
            db_image.liked_by_users.remove(db_user)
            # 同时更新计数字段
            db_image.likes_count = max(0, (db_image.likes_count or 0) - 1)
            db.commit()
            db.refresh(db_image)
        return db_image

    def bookmark(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user not in db_image.bookmarked_by_users:
            db_image.bookmarked_by_users.append(db_user)
            # 同时更新计数字段
            db_image.bookmarks_count = (db_image.bookmarks_count or 0) + 1
            db.commit()
            db.refresh(db_image)
        return db_image

    def unbookmark(self, db: Session, *, user: User, image: Image) -> Image:
        # 确保user和image都在同一个会话中
        db_user = db.merge(user)
        db_image = db.merge(image)
        
        if db_user in db_image.bookmarked_by_users:
            db_image.bookmarked_by_users.remove(db_user)
            # 同时更新计数字段
            db_image.bookmarks_count = max(0, (db_image.bookmarks_count or 0) - 1)
            db.commit()
            db.refresh(db_image)
        return db_image

    def get_with_relations(self, db: Session, *, id: int) -> Optional[Image]:
        """获取图片及其关系数据（点赞、收藏、所有者、图集等）"""
        from sqlalchemy.orm import joinedload, selectinload
        return (
            db.query(self.model)
            .options(
                selectinload(self.model.liked_by_users),
                selectinload(self.model.bookmarked_by_users),
                joinedload(self.model.owner),
                joinedload(self.model.category),
                joinedload(self.model.tags),
                joinedload(self.model.gallery),
                selectinload(self.model.comments).joinedload(Comment.owner)
            )
            .filter(self.model.id == id)
            .first()
        )

image = CRUDImage(Image) 