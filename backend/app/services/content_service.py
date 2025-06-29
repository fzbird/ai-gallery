from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import and_, func

from app.models.content_base import ContentBase
from app.models.content_interactions import content_likes, content_bookmarks, content_tags
from app.models.user import User
from app.models.tag import Tag

class ContentService:
    """
    统一的内容服务，处理所有内容类型的交互功能
    包括点赞、收藏、标签等操作
    """
    
    @staticmethod
    def like_content(db: Session, content_id: int, user_id: int) -> bool:
        """点赞内容"""
        # 检查是否已经点赞
        existing = db.execute(
            content_likes.select().where(
                and_(content_likes.c.content_id == content_id, 
                     content_likes.c.user_id == user_id)
            )
        ).first()
        
        if existing:
            return False  # 已经点赞
        
        # 添加点赞记录
        db.execute(
            content_likes.insert().values(content_id=content_id, user_id=user_id)
        )
        
        # 更新点赞计数
        content = db.query(ContentBase).filter(ContentBase.id == content_id).first()
        if content:
            content.likes_count = content.likes_count + 1
            db.commit()
        
        return True
    
    @staticmethod
    def unlike_content(db: Session, content_id: int, user_id: int) -> bool:
        """取消点赞"""
        result = db.execute(
            content_likes.delete().where(
                and_(content_likes.c.content_id == content_id,
                     content_likes.c.user_id == user_id)
            )
        )
        
        if result.rowcount > 0:
            # 更新点赞计数
            content = db.query(ContentBase).filter(ContentBase.id == content_id).first()
            if content:
                content.likes_count = max(0, content.likes_count - 1)
                db.commit()
            return True
        
        return False
    
    @staticmethod
    def bookmark_content(db: Session, content_id: int, user_id: int) -> bool:
        """收藏内容"""
        # 检查是否已经收藏
        existing = db.execute(
            content_bookmarks.select().where(
                and_(content_bookmarks.c.content_id == content_id,
                     content_bookmarks.c.user_id == user_id)
            )
        ).first()
        
        if existing:
            return False  # 已经收藏
        
        # 添加收藏记录
        db.execute(
            content_bookmarks.insert().values(content_id=content_id, user_id=user_id)
        )
        
        # 更新收藏计数
        content = db.query(ContentBase).filter(ContentBase.id == content_id).first()
        if content:
            content.bookmarks_count = content.bookmarks_count + 1
            db.commit()
        
        return True
    
    @staticmethod
    def unbookmark_content(db: Session, content_id: int, user_id: int) -> bool:
        """取消收藏"""
        result = db.execute(
            content_bookmarks.delete().where(
                and_(content_bookmarks.c.content_id == content_id,
                     content_bookmarks.c.user_id == user_id)
            )
        )
        
        if result.rowcount > 0:
            # 更新收藏计数
            content = db.query(ContentBase).filter(ContentBase.id == content_id).first()
            if content:
                content.bookmarks_count = max(0, content.bookmarks_count - 1)
                db.commit()
            return True
        
        return False
    
    @staticmethod
    def add_tag_to_content(db: Session, content_id: int, tag_id: int) -> bool:
        """为内容添加标签"""
        # 检查是否已经有该标签
        existing = db.execute(
            content_tags.select().where(
                and_(content_tags.c.content_id == content_id,
                     content_tags.c.tag_id == tag_id)
            )
        ).first()
        
        if existing:
            return False  # 已经有该标签
        
        # 添加标签关联
        db.execute(
            content_tags.insert().values(content_id=content_id, tag_id=tag_id)
        )
        db.commit()
        return True
    
    @staticmethod
    def remove_tag_from_content(db: Session, content_id: int, tag_id: int) -> bool:
        """移除内容标签"""
        result = db.execute(
            content_tags.delete().where(
                and_(content_tags.c.content_id == content_id,
                     content_tags.c.tag_id == tag_id)
            )
        )
        
        if result.rowcount > 0:
            db.commit()
            return True
        
        return False
    
    @staticmethod
    def get_user_liked_contents(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List[ContentBase]:
        """获取用户点赞的内容"""
        return (
            db.query(ContentBase)
            .join(content_likes, ContentBase.id == content_likes.c.content_id)
            .filter(content_likes.c.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    @staticmethod
    def get_user_bookmarked_contents(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List[ContentBase]:
        """获取用户收藏的内容"""
        return (
            db.query(ContentBase)
            .join(content_bookmarks, ContentBase.id == content_bookmarks.c.content_id)
            .filter(content_bookmarks.c.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    @staticmethod
    def check_user_liked(db: Session, content_id: int, user_id: int) -> bool:
        """检查用户是否点赞了内容"""
        result = db.execute(
            content_likes.select().where(
                and_(content_likes.c.content_id == content_id,
                     content_likes.c.user_id == user_id)
            )
        ).first()
        return result is not None
    
    @staticmethod
    def check_user_bookmarked(db: Session, content_id: int, user_id: int) -> bool:
        """检查用户是否收藏了内容"""
        result = db.execute(
            content_bookmarks.select().where(
                and_(content_bookmarks.c.content_id == content_id,
                     content_bookmarks.c.user_id == user_id)
            )
        ).first()
        return result is not None 