from typing import List, Optional, Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.models.content_base import ContentType
from app.schemas.content import Content, Image, Gallery

router = APIRouter()

@router.get("/me/contents")
def get_my_contents(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    获取当前用户的内容列表 - 简化版本
    """
    try:
        contents = crud.content.get_multi_with_relations(
        db, skip=skip, limit=limit, content_type=content_type, owner_id=current_user.id
    )
        
        # 简化返回，避免schema问题
        result = []
        for content in contents:
            item = {
                "id": content.id,
                "title": content.title,
                "description": content.description,
                "content_type": content.content_type,
                "created_at": content.created_at.isoformat() if content.created_at else None,
                "views_count": content.views_count,
                "likes_count": content.likes_count,
                "bookmarks_count": content.bookmarks_count,
                "owner": {
                    "id": content.owner.id,
                    "username": content.owner.username
                } if content.owner else None
            }
            result.append(item)
        
        return {"items": result, "total": len(result)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.get("/me/liked")
def get_my_liked_contents(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    获取当前用户点赞的内容列表 - 简化版本
    """
    try:
        contents = crud.content.get_user_liked_contents(
        db, user_id=current_user.id, skip=skip, limit=limit, content_type=content_type
    )
        
        # 简化返回
        result = []
        for content in contents:
            item = {
                "id": content.id,
                "title": content.title,
                "description": content.description,
                "content_type": content.content_type,
                "created_at": content.created_at.isoformat() if content.created_at else None,
                "likes_count": content.likes_count,
                "owner": {
                    "id": content.owner.id,
                    "username": content.owner.username
                } if content.owner else None
            }
            result.append(item)
        
        return {"items": result, "total": len(result)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.get("/me/bookmarked")
def get_my_bookmarked_contents(
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    获取当前用户收藏的内容列表 - 简化版本
    """
    try:
        contents = crud.content.get_user_bookmarked_contents(
        db, user_id=current_user.id, skip=skip, limit=limit, content_type=content_type
    )
        
        # 简化返回
        result = []
        for content in contents:
            item = {
                "id": content.id,
                "title": content.title,
                "description": content.description,
                "content_type": content.content_type,
                "created_at": content.created_at.isoformat() if content.created_at else None,
                "bookmarks_count": content.bookmarks_count,
                "owner": {
                    "id": content.owner.id,
                    "username": content.owner.username
                } if content.owner else None
            }
            result.append(item)
        
        return {"items": result, "total": len(result)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.get("/{user_id}/contents")
def get_user_contents(
    user_id: int,
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(30, ge=1, le=100),
    content_type: Optional[ContentType] = Query(None),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    获取指定用户的公开内容列表 - 简化版本
    """
    try:
        # 检查用户是否存在
        user = crud.user.get(db, id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        # 获取用户内容
        user_session_id = current_user.id if current_user else None
        contents = crud.content.get_multi_with_relations(
            db, skip=skip, limit=limit, content_type=content_type, 
            owner_id=user_id, user_id=user_session_id
        )
        
        # 简化返回
        result = []
        for content in contents:
            item = {
                "id": content.id,
                "title": content.title,
                "description": content.description,
                "content_type": content.content_type,
                "created_at": content.created_at.isoformat() if content.created_at else None,
                "likes_count": content.likes_count,
                "owner": {
                    "id": content.owner.id,
                    "username": content.owner.username
                } if content.owner else None
            }
            result.append(item)
        
        return {"items": result, "total": len(result)}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.delete("/me/contents/{content_id}")
def delete_my_content(
    content_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    删除当前用户的内容
    """
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    if content.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    crud.content.remove(db, id=content_id)
    return {"message": "Content deleted successfully"}

@router.put("/me/contents/{content_id}")
def update_my_content(
    content_id: int,
    content_in: schemas.ContentUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user),
):
    """
    更新当前用户的内容
    """
    content = crud.content.get(db, id=content_id)
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    if content.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    updated_content = crud.content.update(db, db_obj=content, obj_in=content_in)
    
    # 简化返回
    return {
        "id": updated_content.id,
        "title": updated_content.title,
        "description": updated_content.description,
        "content_type": updated_content.content_type,
        "message": "Content updated successfully"
    } 