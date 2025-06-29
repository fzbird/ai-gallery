from __future__ import annotations

from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional, List

# Simple user schema for comment responses (avoiding circular import)
class UserSimpleForComment(BaseModel):
    id: int
    username: str
    
    model_config = ConfigDict(from_attributes=True)

# Base schema for Comment
class CommentBase(BaseModel):
    content: str

# Schema for creating a new comment
class CommentCreate(CommentBase):
    pass

# Schema for updating a comment
class CommentUpdate(CommentBase):
    pass

# Schema for API responses
class Comment(CommentBase):
    id: int
    created_at: datetime
    owner_id: int
    owner: UserSimpleForComment
    children: List[Comment] = []

    model_config = ConfigDict(from_attributes=True) 