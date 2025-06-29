from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship

from app.models.content_base import ContentBase, ContentType


class Gallery(ContentBase):
    """
    图集模型，继承ContentBase，获得统一的交互功能
    """
    __tablename__ = 'gallery'

    id = Column(Integer, ForeignKey('content.id'), primary_key=True)
    
    # Gallery特有字段
    image_count = Column(Integer, default=0)
    cover_image_id = Column(Integer, ForeignKey("image.id"), nullable=True)

    # 与图片的关系 - 明确指定foreign_keys
    images = relationship("Image", back_populates="gallery", foreign_keys="Image.gallery_id")
    cover_image = relationship("Image", foreign_keys=[cover_image_id])

    # 多态映射配置
    __mapper_args__ = {
        'polymorphic_identity': ContentType.GALLERY,
    } 