from typing import List
from sqlalchemy.orm import Session, selectinload
from typing import Any, Dict, Optional, Union

from app.models.user import User
from app.schemas import UserCreate, UserUpdateAdmin
from app.core.security import get_password_hash, verify_password
from app.crud.base import CRUDBase


class CRUDUser(CRUDBase[User, UserCreate, UserUpdateAdmin]):
    def get(self, db: Session, id: Any, *, options: Optional[List] = None) -> Optional[User]:
        query = db.query(self.model).filter(self.model.id == id)
        if options:
            query = query.options(*options)
        return query.first()

    def get_multi(self, db: Session, *, skip: int = 0, limit: int = 100, options: Optional[List] = None) -> List[User]:
        query = db.query(self.model)
        if options:
            query = query.options(*options)
        return query.offset(skip).limit(limit).all()

    def get_by_email(self, db: Session, *, email: str) -> Optional[User]:
        return db.query(self.model).filter(self.model.email == email).first()

    def get_by_username(self, db: Session, *, username: str) -> Optional[User]:
        return (
            db.query(User)
            .options(selectinload(User.followers), selectinload(User.following))
            .filter(User.username == username)
            .first()
        )
    
    def get_by_id(self, db: Session, *, user_id: int) -> Optional[User]:
        return db.query(self.model).filter(self.model.id == user_id).first()

    def create(self, db: Session, *, obj_in: UserCreate) -> User:
        create_data = obj_in.dict()
        create_data.pop("password")
        db_obj = User(
            **create_data,
            hashed_password=get_password_hash(obj_in.password),
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update(self, db: Session, *, db_obj: User, obj_in: Union[UserUpdateAdmin, Dict[str, Any]]) -> User:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.dict(exclude_unset=True)
            
        if "password" in update_data and update_data["password"]:
            hashed_password = get_password_hash(update_data["password"])
            del update_data["password"]
            update_data["hashed_password"] = hashed_password
            
        return super().update(db, db_obj=db_obj, obj_in=update_data)

    def update_password(self, db: Session, *, db_obj: User, new_password: str) -> User:
        db_obj.hashed_password = get_password_hash(new_password)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_total_count(self, db: Session) -> int:
        return db.query(self.model).count()

    def follow(self, db: Session, *, follower: User, followed: User) -> None:
        follower.followed.append(followed)
        db.commit()

    def unfollow(self, db: Session, *, follower: User, followed: User) -> None:
        follower.followed.remove(followed)
        db.commit()

user = CRUDUser(User)

def get_multi(db: Session, *, skip: int = 0, limit: int = 100) -> List[User]:
    return db.query(User).offset(skip).limit(limit).all()

def remove(db: Session, *, user: User) -> User:
    db.delete(user)
    db.commit()
    return user 