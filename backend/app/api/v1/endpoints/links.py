from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db

router = APIRouter()

@router.get("/", response_model=List[schemas.Link])
def read_links(
    db: Session = Depends(get_db),
    limit: int = 50,
):
    """
    获取启用的友情链接列表，公开访问
    """
    links = crud.link.get_active_links(db, limit=limit)
    return links

@router.post("/", response_model=schemas.Link, dependencies=[Depends(dependencies.get_current_active_superuser)])
def create_link(
    *,
    db: Session = Depends(get_db),
    link_in: schemas.LinkCreate,
):
    """
    创建友情链接（仅管理员）
    """
    link = crud.link.create(db=db, obj_in=link_in)
    return link

@router.put("/{link_id}", response_model=schemas.Link, dependencies=[Depends(dependencies.get_current_active_superuser)])
def update_link(
    *,
    db: Session = Depends(get_db),
    link_id: int,
    link_in: schemas.LinkUpdate,
):
    """
    更新友情链接（仅管理员）
    """
    link = crud.link.get(db, id=link_id)
    if not link:
        raise HTTPException(status_code=404, detail="Link not found")
    link = crud.link.update(db=db, db_obj=link, obj_in=link_in)
    return link

@router.delete("/{link_id}", dependencies=[Depends(dependencies.get_current_active_superuser)])
def delete_link(
    *,
    db: Session = Depends(get_db),
    link_id: int,
):
    """
    删除友情链接（仅管理员）
    """
    link = crud.link.get(db, id=link_id)
    if not link:
        raise HTTPException(status_code=404, detail="Link not found")
    crud.link.remove(db=db, id=link_id)
    return {"message": "Link deleted successfully"} 