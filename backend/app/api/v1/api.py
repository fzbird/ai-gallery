from fastapi import APIRouter

from app.api.v1.endpoints import (
    auth, users, images, tags, comments, admin, categories, departments, galleries, contents, user_contents, links, topics, ai_analysis
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(user_contents.router, prefix="/users", tags=["user-contents"])
api_router.include_router(departments.router, prefix="/departments", tags=["departments"])
api_router.include_router(contents.router, prefix="/contents", tags=["contents"])
api_router.include_router(images.router, prefix="/images", tags=["images"])
api_router.include_router(galleries.router, prefix="/galleries", tags=["galleries"])
api_router.include_router(topics.router, prefix="/topics", tags=["topics"])
api_router.include_router(tags.router, prefix="/tags", tags=["tags"])
api_router.include_router(links.router, prefix="/links", tags=["links"])
api_router.include_router(comments.router, tags=["comments"])
api_router.include_router(categories.router, prefix="/categories", tags=["categories"])
api_router.include_router(ai_analysis.router, prefix="/ai", tags=["ai-analysis"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"]) 