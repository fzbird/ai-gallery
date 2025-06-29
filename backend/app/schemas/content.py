from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Union
from datetime import datetime
from enum import Enum

from .user import UserSimple
from .category import Category

class ContentType(str, Enum):
    IMAGE = "image"
    GALLERY = "gallery"

# --- Base Content Schema ---
class ContentBase(BaseModel):
    title: str
    description: Optional[str] = None
    category_id: Optional[int] = None

class ContentCreate(ContentBase):
    content_type: ContentType

class ContentUpdate(ContentBase):
    title: Optional[str] = None

# --- Generic Content Response ---
class Content(ContentBase):
    id: int
    content_type: ContentType
    created_at: datetime
    updated_at: datetime
    owner_id: int
    owner: UserSimple
    category: Optional[Category] = None
    views_count: int = 0
    likes_count: int = 0
    bookmarks_count: int = 0
    comments_count: int = 0
    liked_by_current_user: bool = False
    bookmarked_by_current_user: bool = False

    model_config = ConfigDict(from_attributes=True)

# --- Image-specific schemas ---
class ImageCreate(ContentCreate):
    content_type: ContentType = ContentType.IMAGE
    filename: str
    filepath: str
    file_hash: Optional[str] = None
    gallery_id: Optional[int] = None

class ImageUpdate(ContentUpdate):
    gallery_id: Optional[int] = None
    ai_status: Optional[str] = None

class Image(Content):
    content_type: ContentType = ContentType.IMAGE
    filename: str
    filepath: str
    file_hash: Optional[str] = None
    gallery_id: Optional[int] = None
    ai_status: str = "pending"
    ai_description: Optional[str] = None
    ai_tags: Optional[dict] = None

# --- Gallery-specific schemas ---
class GalleryCreate(ContentCreate):
    content_type: ContentType = ContentType.GALLERY

class GalleryUpdate(ContentUpdate):
    pass

class Gallery(Content):
    content_type: ContentType = ContentType.GALLERY
    image_count: int = 0

class GalleryWithImages(Gallery):
    images: List[Image] = []

# --- Interaction schemas ---
class ContentInteractionBase(BaseModel):
    content_id: int

class LikeResponse(BaseModel):
    liked: bool
    likes_count: int

class BookmarkResponse(BaseModel):
    bookmarked: bool
    bookmarks_count: int

class TagAssignment(BaseModel):
    content_id: int
    tag_id: int

# --- Feed and listing schemas ---
class ContentFeed(BaseModel):
    items: List[Union[Image, Gallery]]
    total: int
    page: int
    size: int
    has_next: bool 