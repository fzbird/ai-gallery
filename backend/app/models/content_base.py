from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey, Text, Enum as SQLAlchemyEnum
from sqlalchemy.orm import relationship
import enum

from app.db.base import Base
from app.models.content_interactions import content_likes, content_bookmarks, content_tags

class ContentType(str, enum.Enum):
    IMAGE = "IMAGE"
    GALLERY = "GALLERY"
    # 未来可以扩展：VIDEO = "video", ARTICLE = "article" 等

class ContentBase(Base):
    """
    统一的内容基础模型，所有可被点赞、收藏、评论、标记的内容都继承自此模型
    这样可以统一处理likes、bookmarks、comments、tags等功能
    """
    __tablename__ = 'content'

    id = Column(Integer, primary_key=True, index=True)
    content_type = Column(SQLAlchemyEnum(ContentType), nullable=False, index=True)
    title = Column(String(200), nullable=False, index=True)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    owner_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("category.id"), nullable=True)
    topic_id = Column(Integer, ForeignKey("topic.id"), nullable=True)  # 专题ID，可选
    
    # 统计字段
    views_count = Column(Integer, default=0)
    likes_count = Column(Integer, default=0)
    bookmarks_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)

    # 基础关系
    owner = relationship("User", back_populates="contents")
    category = relationship("Category", back_populates="contents")
    topic = relationship("Topic", back_populates="contents")
    comments = relationship("Comment", back_populates="content_item", cascade="all, delete-orphan")
    
    # 交互关系
    liked_by_users = relationship("User", secondary=content_likes, back_populates="liked_contents")
    bookmarked_by_users = relationship("User", secondary=content_bookmarks, back_populates="bookmarked_contents")  
    tags = relationship("Tag", secondary=content_tags, back_populates="contents")

    # 使用多态映射
    __mapper_args__ = {
        'polymorphic_identity': 'content',
        'polymorphic_on': content_type,
        'with_polymorphic': '*'
    } 