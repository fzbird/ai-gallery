from typing import List, Optional, Union, Dict, Any
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, and_, desc, or_

from app.crud.base import CRUDBase
from app.models.content_base import ContentBase, ContentType
from app.models.image import Image
from app.models.gallery import Gallery
from app.models.content_interactions import content_likes, content_bookmarks, content_tags
from app.schemas.content import ContentCreate, ContentUpdate
from app.services.content_service import ContentService

class CRUDContent(CRUDBase[ContentBase, ContentCreate, ContentUpdate]):
    def create_with_owner(self, db: Session, *, obj_in: ContentCreate, owner_id: int) -> ContentBase:
        """创建内容，指定拥有者"""
        obj_in_data = obj_in.model_dump()
        obj_in_data['owner_id'] = owner_id
        
        # 根据内容类型创建相应的模型实例
        if obj_in.content_type == ContentType.IMAGE:
            db_obj = Image(**obj_in_data)
        elif obj_in.content_type == ContentType.GALLERY:
            db_obj = Gallery(**obj_in_data)
        else:
            db_obj = ContentBase(**obj_in_data)
        
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_multi_with_relations(
        self, 
        db: Session, 
        *,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None,
        category_id: Optional[int] = None,
        owner_id: Optional[int] = None,
        user_id: Optional[int] = None
    ) -> List[ContentBase]:
        """获取内容列表，包含关联信息"""
        query = (
            db.query(self.model)
            .options(
                joinedload(ContentBase.owner),
                joinedload(ContentBase.category)
            )
        )
        
        # 过滤条件
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        if category_id:
            query = query.filter(ContentBase.category_id == category_id)
        if owner_id:
            query = query.filter(ContentBase.owner_id == owner_id)
        
        contents = query.order_by(desc(ContentBase.created_at)).offset(skip).limit(limit).all()
        
        # 如果有用户ID，添加用户交互状态
        if user_id:
            for content in contents:
                content.liked_by_current_user = ContentService.check_user_liked(db, content.id, user_id)
                content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, user_id)
        
        return contents

    def get_popular(
        self, 
        db: Session, 
        *,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None
    ) -> List[ContentBase]:
        """获取热门内容（按点赞数和浏览数排序）"""
        query = (
            db.query(self.model)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        
        return (
            query
            .order_by(
                desc(ContentBase.likes_count),
                desc(ContentBase.views_count),
                desc(ContentBase.created_at)
            )
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_recent(
        self, 
        db: Session, 
        *,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None
    ) -> List[ContentBase]:
        """获取最新内容"""
        query = (
            db.query(self.model)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        
        return (
            query
            .order_by(desc(ContentBase.created_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def search(
        self, 
        db: Session, 
        *,
        query_str: str,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None
    ) -> List[ContentBase]:
        """搜索内容"""
        query = (
            db.query(self.model)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        # 搜索条件
        search_filter = or_(
            ContentBase.title.ilike(f"%{query_str}%"),
            ContentBase.description.ilike(f"%{query_str}%")
        )
        query = query.filter(search_filter)
        
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        
        return (
            query
            .order_by(desc(ContentBase.created_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_user_liked_contents(
        self, 
        db: Session, 
        *,
        user_id: int,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None
    ) -> List[ContentBase]:
        """获取用户点赞的内容"""
        query = (
            db.query(self.model)
            .join(content_likes, ContentBase.id == content_likes.c.content_id)
            .filter(content_likes.c.user_id == user_id)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        
        return query.offset(skip).limit(limit).all()

    def get_user_bookmarked_contents(
        self, 
        db: Session, 
        *,
        user_id: int,
        skip: int = 0, 
        limit: int = 100,
        content_type: Optional[ContentType] = None
    ) -> List[ContentBase]:
        """获取用户收藏的内容"""
        query = (
            db.query(self.model)
            .join(content_bookmarks, ContentBase.id == content_bookmarks.c.content_id)
            .filter(content_bookmarks.c.user_id == user_id)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        if content_type:
            query = query.filter(ContentBase.content_type == content_type)
        
        return query.offset(skip).limit(limit).all()

    def increment_views(self, db: Session, *, content_id: int) -> bool:
        """增加浏览量"""
        content = db.query(self.model).filter(self.model.id == content_id).first()
        if content:
            content.views_count += 1
            db.commit()
            return True
        return False

    def get_content_stats(self, db: Session, *, content_id: int) -> Optional[Dict[str, Any]]:
        """获取内容统计信息"""
        content = db.query(self.model).filter(self.model.id == content_id).first()
        if not content:
            return None
        
        return {
            "id": content.id,
            "content_type": content.content_type,
            "views_count": content.views_count,
            "likes_count": content.likes_count,
            "bookmarks_count": content.bookmarks_count,
            "comments_count": content.comments_count,
        }

    def get_feed(
        self, 
        db: Session, 
        *,
        user_id: Optional[int] = None,
        skip: int = 0, 
        limit: int = 100
    ) -> Dict[str, Any]:
        """获取个性化内容feed"""
        # 基础查询
        query = (
            db.query(self.model)
            .options(joinedload(ContentBase.owner), joinedload(ContentBase.category))
        )
        
        # 如果有用户ID，可以基于用户偏好进行排序（简化版本）
        if user_id:
            # 这里可以实现更复杂的推荐算法
            # 目前简单按照热门度和新鲜度排序
            query = query.order_by(
                desc(ContentBase.likes_count * 0.3 + ContentBase.views_count * 0.1),
                desc(ContentBase.created_at)
            )
        else:
            query = query.order_by(desc(ContentBase.created_at))
        
        # 计算总数
        total = query.count()
        
        # 获取内容
        contents = query.offset(skip).limit(limit).all()
        
        # 添加用户交互状态
        if user_id:
            for content in contents:
                content.liked_by_current_user = ContentService.check_user_liked(db, content.id, user_id)
                content.bookmarked_by_current_user = ContentService.check_user_bookmarked(db, content.id, user_id)
        
        return {
            "items": contents,
            "total": total,
            "page": skip // limit + 1,
            "size": len(contents),
            "has_next": skip + limit < total
        }


content = CRUDContent(ContentBase) 