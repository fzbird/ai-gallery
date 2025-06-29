from __future__ import annotations

from pydantic import BaseModel, ConfigDict
from typing import Optional, List

# Simple user info for department responses (avoiding circular import)
class UserSimpleForDepartment(BaseModel):
    id: int
    username: str
    
    model_config = ConfigDict(from_attributes=True)

# Base schema for Department
class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None


# Schema for creating a new department
class DepartmentCreate(DepartmentBase):
    pass


# Schema for updating a department
class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None


# Base schema for department data stored in the database
class DepartmentInDBBase(DepartmentBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


# Schema for API responses, including a list of users
class Department(DepartmentInDBBase):
    users: List[UserSimpleForDepartment] = []


# Schema for public-facing department info
class DepartmentPublic(BaseModel):
    id: int
    name: str

    model_config = ConfigDict(from_attributes=True)


# Schema for department deletion eligibility check
class UserReference(BaseModel):
    id: int
    username: str

class DepartmentDeletionCheck(BaseModel):
    can_delete: bool
    department_id: int
    department_name: str
    total_users: int
    admin_users: List[UserReference]
    regular_users: List[UserReference]
    reasons_preventing_deletion: List[str] 