from sqlalchemy import Column, Integer, String, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.types import JSON

from app.models.content_base import ContentBase, ContentType


class Image(ContentBase):
    __tablename__ = 'image'
    
    id = Column(Integer, ForeignKey('content.id'), primary_key=True)
    
    # 图片特有字段
    filename = Column(String(255), nullable=False, unique=True)
    filepath = Column(String(500), nullable=False)
    file_hash = Column(String(64), nullable=True, index=True, unique=True)  # SHA-256 hash
    file_size = Column(Integer)
    file_type = Column(String(50))
    width = Column(Integer)
    height = Column(Integer)
    
    # 图集关联
    gallery_id = Column(Integer, ForeignKey("gallery.id"), nullable=True)
    
    # AI相关字段
    ai_status = Column(String(50), default='pending', nullable=False, index=True)  # pending, processing, completed, failed
    ai_description = Column(Text, nullable=True)
    ai_tags = Column(JSON, nullable=True)
    
    # 关系 - 明确指定foreign_keys
    gallery = relationship("Gallery", back_populates="images", foreign_keys=[gallery_id])

    # 多态映射配置
    __mapper_args__ = {
        'polymorphic_identity': ContentType.IMAGE
    }