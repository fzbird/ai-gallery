from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, desc, text
from typing import List

from app import schemas
from app.db.session import get_db
from app.models.tag import Tag
from app.models.content_base import ContentBase, ContentType
from app.models.content_interactions import content_tags

router = APIRouter()

@router.get("/", response_model=List[schemas.Tag])
def read_tags(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve all tags.
    """
    tags = db.query(Tag).offset(skip).limit(limit).all()
    return tags

@router.get("/popular", response_model=List[schemas.Tag])
def read_popular_tags(
    db: Session = Depends(get_db),
    limit: int = 25,
):
    """
    获取热门标签，按照在图集和图片中的使用数量倒序排列
    """
    # 使用原生SQL查询来统计标签使用数量
    sql = text("""
        SELECT t.id, t.name, COUNT(ct.content_id) as usage_count
        FROM tag t
        LEFT JOIN content_tags ct ON t.id = ct.tag_id
        LEFT JOIN content c ON ct.content_id = c.id
        GROUP BY t.id, t.name
        HAVING COUNT(ct.content_id) > 0
        ORDER BY usage_count DESC
        LIMIT :limit
    """)
    
    results = db.execute(sql, {"limit": limit}).fetchall()
    
    # 转换为Tag对象
    popular_tags = []
    for row in results:
        tag = schemas.Tag(id=row.id, name=row.name)
        popular_tags.append(tag)
    
    return popular_tags 