# Import all schemas to make them accessible from app.schemas
from .category import Category, CategoryCreate, CategoryUpdate, CategoryTreeNode, CategoryPath, CategoryStats
from .comment import Comment, CommentCreate, CommentUpdate
from .content import (
    Content, ContentFeed, Image as ContentImage, Gallery as ContentGallery, 
    ImageCreate as ContentImageCreate, GalleryCreate as ContentGalleryCreate, 
    ImageUpdate as ContentImageUpdate, GalleryUpdate as ContentGalleryUpdate, 
    ContentCreate, ContentUpdate, LikeResponse, BookmarkResponse, ContentType
)
from .department import (
    Department,
    DepartmentCreate,
    DepartmentInDBBase,
    DepartmentPublic,
    DepartmentUpdate,
    DepartmentDeletionCheck,
    UserReference,
)
from .image import Image, ImageCreate, ImageUpdate, ImageSimple
from .gallery import Gallery, GalleryCreate, GalleryUpdate, GalleryWithImages, GalleryStats, GallerySimple
from .link import Link, LinkCreate, LinkUpdate
from .tag import Tag, TagCreate
from .token import Token, TokenData, TokenPayload
from .topic import (
    Topic, TopicCreate, TopicUpdate, TopicDetail, TopicListItem,
    GalleryInTopic
)
from .user import (
    NewPassword,
    PasswordUpdate,
    User,
    UserCreate,
    UserInDBBase,
    UserPublic,
    UserSimple,
    UserUpdate,
    UserUpdateAdmin,
)

# Rebuild models to resolve forward references
Image.model_rebuild()
ImageSimple.model_rebuild()
Gallery.model_rebuild()
GalleryWithImages.model_rebuild()
GallerySimple.model_rebuild()