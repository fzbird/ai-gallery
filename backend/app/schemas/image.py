from __future__ import annotations

from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List, Any, TYPE_CHECKING
from datetime import datetime
from .tag import Tag
from .category import Category
from .user import UserSimple

if TYPE_CHECKING:
    from .comment import Comment
    from .gallery import Gallery

# --- Base Schema ---
class ImageBase(BaseModel):
    title: str
    description: Optional[str] = None
    topic_id: Optional[int] = None

# --- Schema for Creating Data ---
class ImageCreate(ImageBase):
    file_hash: Optional[str] = Field(None, description="File hash for creation, optional for instant upload")
    # Tags and category are handled directly in the endpoint/crud, not in this schema

# --- Schema for Updating Data ---
class ImageUpdate(ImageBase):
    tags: Optional[List[str]] = None
    category_id: Optional[int] = None
    ai_status: Optional[str] = None
    ai_description: Optional[str] = None
    ai_tags: Optional[List[str]] = None

# --- Schema for Reading Data (API Response) ---
class Image(ImageBase):
    id: int
    filename: str
    image_url: Optional[str] = None
    created_at: datetime
    owner_id: int
    owner: UserSimple
    ai_status: str
    ai_description: Optional[str] = None
    ai_tags: Optional[List[Any]] = None
    tags: List[Tag] = []
    category: Optional[Category] = None
    gallery: Optional["Gallery"] = None
    likes_count: int = Field(0, alias='likes_count')
    bookmarks_count: int = Field(0, alias='bookmarks_count')
    views_count: int = Field(0, alias='views_count')
    liked_by_current_user: bool = False
    bookmarked_by_current_user: bool = False
    is_cover_image: Optional[bool] = False
    comments: List["Comment"] = []

    model_config = ConfigDict(from_attributes=True) 