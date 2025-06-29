from pydantic import BaseModel, Field
from typing import Optional, List

class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None
    level: Optional[int] = Field(default=0, description="分类层级，0为根级")
    sort_order: Optional[int] = Field(default=0, description="同级排序")

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(CategoryBase):
    pass

# 分类树节点（用于前端树形展示）
class CategoryTreeNode(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    parent_id: Optional[int] = None
    level: int = 0
    sort_order: int = 0
    full_path: Optional[str] = None
    content_count: int = 0
    all_content_count: int = 0  # 包含子分类的内容总数
    children: List['CategoryTreeNode'] = []
    
    class Config:
        from_attributes = True

class Category(CategoryBase):
    id: int
    parent_id: Optional[int] = None
    level: int = 0
    sort_order: int = 0
    
    # 计算属性
    full_path: Optional[str] = None
    content_count: Optional[int] = None
    all_content_count: Optional[int] = None
    has_children: Optional[bool] = None
    is_root: Optional[bool] = None
    
    class Config:
        from_attributes = True

# 分类路径（面包屑导航用）
class CategoryPath(BaseModel):
    id: int
    name: str
    level: int

# 分类统计
class CategoryStats(BaseModel):
    total_categories: int
    max_level: int
    root_categories: int
    categories_with_content: int 