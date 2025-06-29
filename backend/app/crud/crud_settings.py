from sqlalchemy.orm import Session
from typing import Dict, Optional

from app.models.setting import Setting
from app.crud.base import CRUDBase

class CRUDSettings(CRUDBase[Setting, None, None]):
    def get_setting(self, db: Session, *, key: str) -> Optional[Setting]:
        return db.query(Setting).filter(Setting.key == key).first()

    def get_all_settings(self, db: Session) -> Dict[str, str]:
        settings = db.query(Setting).all()
        return {s.key: s.value for s in settings}

    def update_setting(self, db: Session, *, key: str, value: str) -> Setting:
        db_obj = self.get_setting(db, key=key)
        if db_obj:
            db_obj.value = value
        else:
            db_obj = Setting(key=key, value=value)
            db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

settings = CRUDSettings(Setting) 