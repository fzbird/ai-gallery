from sqlalchemy import Column, Integer, String, DateTime, func, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base import Base

class Comment(Base):
    __tablename__ = 'comment'

    id = Column(Integer, primary_key=True, index=True)
    content = Column(String(1000), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关联到统一的内容系统
    content_id = Column(Integer, ForeignKey('content.id'), nullable=False)
    owner_id = Column(Integer, ForeignKey('user.id'), nullable=False)

    # 关系
    content_item = relationship("ContentBase", back_populates="comments")
    owner = relationship("User", back_populates="comments")
    
    # 为了向后兼容，保留image关系（通过content_item间接访问）
    @property
    def image(self):
        """如果评论的是图片，返回图片对象"""
        if self.content_item and self.content_item.content_type == 'image':
            return self.content_item
        return None 