from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, func
from app.db.base import Base

class Link(Base):
    __tablename__ = 'link'

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(100), nullable=False, comment="链接标题")
    url = Column(String(255), nullable=False, comment="链接地址")
    description = Column(Text, nullable=True, comment="链接描述")
    is_active = Column(Boolean, default=True, comment="是否启用")
    sort_order = Column(Integer, default=0, comment="排序权重，数字越大越靠前")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now()) 