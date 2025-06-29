from typing import List, Optional
from sqlalchemy.orm import Session, joinedload, subqueryload
from sqlalchemy import desc, asc, func

from app.crud.base import CRUDBase
from app.models.topic import Topic
from app.models.gallery import Gallery
from app.schemas.topic import TopicCreate, TopicUpdate


class CRUDTopic(CRUDBase[Topic, TopicCreate, TopicUpdate]):
    def get_all_with_gallery_count(self, db: Session, *, skip: int = 0, limit: int = 100):
        """
        获取所有专题，包含图集数量，支持分页
        """
        # 子查询，计算每个专题的图集数量
        gallery_count_subquery = (
            db.query(
                Gallery.topic_id,
                func.count(Gallery.id).label("gallery_count")
            )
            .group_by(Gallery.topic_id)
            .subquery()
        )

        # 主查询，左连接子查询
        query = (
            db.query(
                Topic,
                gallery_count_subquery.c.gallery_count
            )
            .outerjoin(gallery_count_subquery, Topic.id == gallery_count_subquery.c.topic_id)
            .options(joinedload(Topic.cover_image))
            .order_by(desc(Topic.created_at))
        )
        
        # 获取总数用于分页
        total = query.count()

        # 应用分页
        results = query.offset(skip).limit(limit).all()

        return results, total

    def get_by_slug(self, db: Session, *, slug: str) -> Optional[Topic]:
        """根据slug获取专题"""
        return db.query(Topic).filter(Topic.slug == slug).first()

    def get_active_topics(
        self, 
        db: Session, 
        *, 
        skip: int = 0, 
        limit: int = 100,
        featured_only: bool = False
    ) -> List[Topic]:
        """获取活跃的专题列表"""
        query = db.query(Topic).filter(Topic.is_active.is_(True))
        
        if featured_only:
            query = query.filter(Topic.is_featured.is_(True))
            
        return query.order_by(desc(Topic.created_at)).offset(skip).limit(limit).all()

    def count_active_topics(
        self, 
        db: Session, 
        *,
        featured_only: bool = False
    ) -> int:
        """获取活跃专题的总数"""
        query = db.query(Topic).filter(Topic.is_active.is_(True))
        
        if featured_only:
            query = query.filter(Topic.is_featured.is_(True))
            
        return query.count()

    def get_topic_galleries(
        self, 
        db: Session, 
        *, 
        topic_id: int,
        skip: int = 0,
        limit: int = 100,
        sort: str = "created_at",
        order: str = "desc"
    ) -> List[Gallery]:
        """获取专题下的图集列表"""
        query = (
            db.query(Gallery)
            .options(
                joinedload(Gallery.images),
                joinedload(Gallery.cover_image),
                joinedload(Gallery.category),
                joinedload(Gallery.owner),
                joinedload(Gallery.tags)
            )
            .filter(Gallery.topic_id == topic_id)
        )
        
        # 根据排序字段排序
        if sort == "created_at":
            order_field = Gallery.created_at
        elif sort == "views_count":
            order_field = Gallery.views_count
        elif sort == "likes_count":
            order_field = Gallery.likes_count
        elif sort == "bookmarks_count":
            order_field = Gallery.bookmarks_count
        else:
            order_field = Gallery.created_at
        
        # 根据排序方向排序
        if order == "asc":
            query = query.order_by(asc(order_field))
        else:
            query = query.order_by(desc(order_field))
        
        return query.offset(skip).limit(limit).all()

    def search_topics(
        self, 
        db: Session, 
        *, 
        query: str,
        skip: int = 0,
        limit: int = 100
    ) -> List[Topic]:
        """搜索专题"""
        return (
            db.query(Topic)
            .filter(
                Topic.is_active.is_(True),
                Topic.name.contains(query)
            )
            .order_by(desc(Topic.created_at))
            .offset(skip)
            .limit(limit)
            .all()
        )

    def count_all_topics(self, db: Session) -> int:
        """获取所有专题的总数"""
        return db.query(Topic).count()


topic = CRUDTopic(Topic) 