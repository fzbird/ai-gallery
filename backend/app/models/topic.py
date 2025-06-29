from sqlalchemy import Column, Integer, String, Text, DateTime, func, Boolean, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base import Base


class Topic(Base):
    """
    专题模型 - 类似于分类，用于跨分类组织图集内容
    """
    __tablename__ = 'topic'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, index=True, nullable=False)
    slug = Column(String(100), unique=True, index=True, nullable=False)  # URL友好的标识符
    description = Column(Text, nullable=True)
    cover_image_id = Column(Integer, ForeignKey("image.id"), nullable=True)  # 专题封面图片ID
    
    # 状态字段
    is_active = Column(Boolean, default=True, index=True)
    is_featured = Column(Boolean, default=False, index=True)  # 是否为推荐专题
    
    # 时间字段
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # 与内容的关系 - 通过content表的topic_id字段
    contents = relationship("ContentBase", back_populates="topic")
    
    # 与封面图片的关系
    cover_image = relationship("Image", foreign_keys=[cover_image_id])
    
    # 为了方便访问，提供属性方法
    @property
    def galleries(self):
        """获取专题下的所有图集"""
        return [content for content in self.contents if content.content_type == 'GALLERY']
    
    @property
    def galleries_count(self):
        """获取专题下的图集数量"""
        return len(self.galleries)
    
    @property
    def cover_image_url(self):
        """获取封面图片URL，兼容前端"""
        if self.cover_image:
            return f"/uploads/{self.cover_image.filename}"
        return "/uploads/default_topic_cover.jpg"  # 返回默认图片

    def __repr__(self):
        return f"<Topic(id={self.id}, name='{self.name}', galleries_count={self.galleries_count})>" 