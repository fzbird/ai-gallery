from __future__ import annotations

from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional, List
from datetime import datetime
from app.models.user import UserRole

# Shared properties
class UserBase(BaseModel):
    email: EmailStr
    username: str
    is_active: Optional[bool] = True
    is_superuser: Optional[bool] = False
    bio: Optional[str] = None
    role: Optional[str] = None
    department_id: Optional[int] = None
    
    model_config = ConfigDict(from_attributes=True)

# Properties to receive via API on creation
class UserCreate(UserBase):
    password: str
    is_superuser: bool = False

# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str] = None
    bio: Optional[str] = None

class UserUpdateAdmin(UserUpdate):
    is_superuser: Optional[bool] = None
    role: Optional[UserRole] = None

# Simple department info for user responses (avoiding circular import)
class DepartmentSimple(BaseModel):
    id: int
    name: str
    
    model_config = ConfigDict(from_attributes=True)

# Properties shared by models stored in DB
class UserInDBBase(UserBase):
    id: int
    is_superuser: bool
    created_at: datetime
    role: UserRole
    department: Optional[DepartmentSimple] = None

    model_config = ConfigDict(from_attributes=True)

# --- Schema for Reading Data (API Response) ---
class User(UserInDBBase):
    pass  # Inherits all fields from UserInDBBase

# Public user model
class UserPublic(BaseModel):
    id: int
    username: str
    bio: Optional[str] = None
    role: Optional[str] = None
    followers_count: Optional[int] = 0
    following_count: Optional[int] = 0
    uploads_count: Optional[int] = 0  # 添加作品数量字段
    is_following: Optional[bool] = False
    department: Optional[DepartmentSimple] = None
    created_at: Optional[datetime] = None
    
    model_config = ConfigDict(from_attributes=True)

# Additional properties stored in DB
class UserInDB(UserInDBBase):
    hashed_password: str

# --- Simple Schema for nested responses ---
class UserSimple(BaseModel):
    id: int
    username: str

    model_config = ConfigDict(from_attributes=True)

# Properties to receive via API on password update
class PasswordUpdate(BaseModel):
    current_password: str
    new_password: str

# Properties to return after password reset
class NewPassword(BaseModel):
    new_password: str 