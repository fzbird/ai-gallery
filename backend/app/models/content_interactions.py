from sqlalchemy import Column, Integer, ForeignKey, DateTime, func, Table
from app.db.base import Base

# 用户关注表
user_follows = Table(
    'user_follows',
    Base.metadata,
    Column('follower_id', Integer, ForeignKey('user.id'), primary_key=True),
    Column('followed_id', Integer, ForeignKey('user.id'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)

# 统一的内容点赞表
content_likes = Table(
    'content_likes',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('user.id'), primary_key=True),
    Column('content_id', Integer, ForeignKey('content.id'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)

# 统一的内容收藏表
content_bookmarks = Table(
    'content_bookmarks', 
    Base.metadata,
    Column('user_id', Integer, ForeignKey('user.id'), primary_key=True),
    Column('content_id', Integer, ForeignKey('content.id'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)

# 统一的内容标签表
content_tags = Table(
    'content_tags',
    Base.metadata,
    Column('content_id', Integer, ForeignKey('content.id'), primary_key=True),
    Column('tag_id', Integer, ForeignKey('tag.id'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
) 