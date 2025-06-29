from typing import List, Optional
from sqlalchemy.orm import Session, selectinload

from app.crud.base import CRUDBase
from app.models.department import Department
from app.schemas.department import DepartmentCreate, DepartmentUpdate


class CRUDDepartment(CRUDBase[Department, DepartmentCreate, DepartmentUpdate]):
    def get(self, db: Session, id: int, *, with_users: bool = True) -> Optional[Department]:
        query = db.query(self.model).filter(self.model.id == id)
        if with_users:
            query = query.options(selectinload(Department.users))
        return query.first()

    def get_multi(self, db: Session, *, skip: int = 0, limit: int = 100, with_users: bool = True) -> List[Department]:
        query = db.query(self.model)
        if with_users:
            query = query.options(selectinload(Department.users))
        return query.offset(skip).limit(limit).all()

    def count(self, db: Session) -> int:
        """获取部门总数"""
        return db.query(self.model).count()


department = CRUDDepartment(Department) 