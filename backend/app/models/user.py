from sqlalchemy import Column, Integer, String, DateTime, func, Enum as SQLAlchemyEnum, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship
import enum

from app.db.base import Base
from .follower import followers
from .content_interactions import content_likes, content_bookmarks, user_follows

class UserRole(str, enum.Enum):
    USER = "USER"
    VIP = "VIP"
    ADMIN = "ADMIN"

class User(Base):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(SQLAlchemyEnum(UserRole), default=UserRole.USER, nullable=False)
    is_active = Column(Boolean(), default=True)
    is_superuser = Column(Boolean(), default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    bio = Column(Text, nullable=True)
    full_name = Column(String(100), nullable=True)
    
    department_id = Column(Integer, ForeignKey("department.id"))
    department = relationship("Department", back_populates="users")

    # 统一的内容关系
    contents = relationship("ContentBase", back_populates="owner", cascade="all, delete-orphan")
    
    # 为了向后兼容，保留images和galleries的属性访问
    @property
    def images(self):
        """获取用户的所有图片"""
        return [content for content in self.contents if content.content_type == 'image']
    
    @property  
    def galleries(self):
        """获取用户的所有图集"""
        return [content for content in self.contents if content.content_type == 'gallery']

    # 评论关系
    comments = relationship("Comment", back_populates="owner", cascade="all, delete-orphan")

    # 关注关系
    following = relationship(
        "User", 
        secondary=user_follows,
        primaryjoin=id == user_follows.c.follower_id,
        secondaryjoin=id == user_follows.c.followed_id,
        back_populates="followers"
    )

    followers = relationship(
        "User", 
        secondary=user_follows,
        primaryjoin=id == user_follows.c.followed_id,
        secondaryjoin=id == user_follows.c.follower_id,
        back_populates="following"
    )
    
    # 统一的交互关系
    liked_contents = relationship("ContentBase", secondary=content_likes, back_populates="liked_by_users")
    bookmarked_contents = relationship("ContentBase", secondary=content_bookmarks, back_populates="bookmarked_by_users")

    def __repr__(self):
        return f"<User(username='{self.username}', email='{self.email}')>" 