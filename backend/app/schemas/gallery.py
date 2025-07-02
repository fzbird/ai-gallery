from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, TYPE_CHECKING, Dict, Any
from datetime import datetime
from .tag import Tag
from .category import Category
from .user import UserSimple

if TYPE_CHECKING:
    from .image import Image
    from .comment import Comment

class GalleryStats(BaseModel):
    total_galleries: int
    published_galleries: int
    draft_galleries: int
    total_images: int
    top_liked_galleries: List[Dict[str, Any]] = []

# --- Base Schema ---
class GalleryBase(BaseModel):
    title: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = None
    topic_id: Optional[int] = None

# --- Schema for Creating Data ---
class GalleryCreate(GalleryBase):
    category_id: Optional[int] = None

# --- Schema for Updating Data ---
class GalleryUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    topic_id: Optional[int] = None
    category_id: Optional[int] = None
    cover_image_id: Optional[int] = None
    tags: Optional[str] = None  # 标签字符串（逗号分隔）

# --- Schema for Reading Data (API Response) ---
class Gallery(GalleryBase):
    id: int
    created_at: datetime
    updated_at: datetime
    owner_id: int
    owner: UserSimple
    category: Optional[Category] = None
    tags: List[Tag] = []
    images: List["Image"] = []
    cover_image: Optional["Image"] = None
    comments: List["Comment"] = []
    image_count: int = 0
    views_count: int = 0
    likes_count: int = 0
    bookmarks_count: int = 0
    liked_by_current_user: bool = False
    bookmarked_by_current_user: bool = False

    model_config = ConfigDict(from_attributes=True)

# --- Gallery with Images ---
class GalleryWithImages(Gallery):
    images: List["Image"] = []
    comments: List["Comment"] = [] 