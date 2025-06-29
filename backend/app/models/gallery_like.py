from sqlalchemy import Column, Integer, ForeignKey, DateTime, func, Table
from app.db.base import Base

gallery_likes = Table(
    'gallery_likes',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('user.id'), primary_key=True),
    Column('gallery_id', Integer, ForeignKey('gallery.id'), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
) 