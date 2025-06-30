from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any

from app import models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.services.background_tasks import background_task_manager
from app.crud.crud_image import image as crud_image

router = APIRouter()

@router.post("/{image_id}/analyze")
async def trigger_ai_analysis(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user),
) -> Dict[str, Any]:
    """
    手动触发图片AI分析
    """
    # 检查图片是否存在
    image = crud_image.get(db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # 检查权限（图片所有者或管理员）
    owner_id = getattr(image, 'owner_id', None)
    user_id = getattr(current_user, 'id', None)
    is_superuser = getattr(current_user, 'is_superuser', False)
    
    if owner_id != user_id and not is_superuser:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    # 检查当前状态
    ai_status = getattr(image, 'ai_status', 'pending')
    if ai_status == "processing":
        return {"message": "AI分析正在进行中", "status": "processing"}
    
    # 添加AI分析任务
    await background_task_manager.add_ai_analysis_task(image_id)
    
    return {"message": "AI分析任务已添加", "status": "pending"}

@router.get("/{image_id}/ai-status")
def get_ai_analysis_status(
    *,
    db: Session = Depends(get_db),
    image_id: int,
    current_user: models.User = Depends(dependencies.get_current_user_optional),
) -> Dict[str, Any]:
    """
    获取图片AI分析状态
    """
    image = crud_image.get(db, id=image_id)
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return {
        "image_id": image_id,
        "ai_status": image.ai_status,
        "ai_description": image.ai_description,
        "ai_tags": image.ai_tags
    } 