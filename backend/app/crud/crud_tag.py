from sqlalchemy.orm import Session
from typing import List

from app.models.tag import Tag

def get_or_create_tags(db: Session, *, tags: List[str]) -> List[Tag]:
    db_tags = []
    if not tags:
        return db_tags
        
    for tag_name in tags:
        tag_name = tag_name.strip()
        if not tag_name:
            continue
        
        tag = db.query(Tag).filter(Tag.name == tag_name).first()
        if not tag:
            tag = Tag(name=tag_name)
            db.add(tag)
            db.commit()
            db.refresh(tag)
        db_tags.append(tag)
    return db_tags 