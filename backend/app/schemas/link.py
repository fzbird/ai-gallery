from pydantic import BaseModel, HttpUrl
from typing import Optional
from datetime import datetime

class LinkBase(BaseModel):
    title: str
    url: str
    description: Optional[str] = None
    is_active: bool = True
    sort_order: int = 0

class LinkCreate(LinkBase):
    pass

class LinkUpdate(BaseModel):
    title: Optional[str] = None
    url: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None

class Link(LinkBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True 