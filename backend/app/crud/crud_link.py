from sqlalchemy.orm import Session
from typing import List

from app.models.link import Link
from app.schemas.link import LinkCreate, LinkUpdate
from app.crud.base import CRUDBase

class CRUDLink(CRUDBase[Link, LinkCreate, LinkUpdate]):
    def get_active_links(self, db: Session, *, limit: int = 50) -> List[Link]:
        """获取启用的友情链接，按排序权重倒序"""
        return (
            db.query(Link)
            .filter(Link.is_active == True)
            .order_by(Link.sort_order.desc(), Link.created_at.desc())
            .limit(limit)
            .all()
        )

link = CRUDLink(Link) 