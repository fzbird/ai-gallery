from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel, Field, computed_field


class TopicBase(BaseModel):
    name: str = Field(..., max_length=100, description="专题名称")
    slug: str = Field(..., max_length=100, description="URL友好的标识符")
    description: Optional[str] = Field(None, description="专题描述")
    cover_image_id: Optional[int] = Field(None, description="专题封面图片ID")
    is_active: bool = Field(True, description="是否活跃")
    is_featured: bool = Field(False, description="是否为推荐专题")


class TopicCreate(TopicBase):
    pass


class TopicUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="专题名称")
    slug: Optional[str] = Field(None, max_length=100, description="URL友好的标识符")
    description: Optional[str] = Field(None, description="专题描述")
    cover_image_id: Optional[int] = Field(None, description="专题封面图片ID")
    cover_image_url: Optional[str] = Field(None, description="专题封面图片URL（将自动转换为图片ID）")
    is_active: Optional[bool] = Field(None, description="是否活跃")
    is_featured: Optional[bool] = Field(None, description="是否为推荐专题")


class TopicInDBBase(TopicBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class Topic(TopicInDBBase):
    """返回给客户端的专题信息"""
    galleries_count: int = 0  # 计算属性
    cover_image_url: Optional[str] = None  # 兼容前端的计算属性


class TopicInDB(TopicInDBBase):
    """数据库中的专题信息"""
    pass


# 专题列表项
class TopicListItem(BaseModel):
    id: int
    name: str
    slug: str
    description: Optional[str]
    cover_image_id: Optional[int]
    cover_image_url: Optional[str] = None  # 兼容前端
    galleries_count: int = 0
    is_active: bool
    is_featured: bool
    created_at: datetime

    class Config:
        from_attributes = True


# 专题详情（简化版，不包含图集列表）
class TopicDetail(Topic):
    pass


# 专题分页响应模型
class TopicPage(BaseModel):
    items: List[TopicListItem]
    total: int


# 图集在专题中的简化信息
class GalleryInTopic(BaseModel):
    id: int
    title: str
    description: Optional[str]
    image_count: int
    views_count: int
    likes_count: int
    bookmarks_count: int
    created_at: datetime
    cover_image: Optional[dict] = None
    category: Optional[dict] = None
    owner: Optional[dict] = None

    class Config:
        from_attributes = True

 