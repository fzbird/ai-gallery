from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.schemas.token import Message

router = APIRouter()

@router.post("/", response_model=schemas.Category, dependencies=[Depends(dependencies.get_current_active_superuser)])
def create_category(
    *,
    db: Session = Depends(get_db),
    category_in: schemas.CategoryCreate,
):
    """
    Create new category. (Admin only)
    支持创建多级分类，如果指定了parent_id，会自动计算层级
    """
    # 检查父分类是否存在
    if category_in.parent_id:
        parent = crud.category.get(db, id=category_in.parent_id)
        if not parent:
            raise HTTPException(
                status_code=404,
                detail="Parent category not found"
            )
    
    # 检查同名分类（在同一父级下）
    existing = db.query(models.Category).filter(
        models.Category.name == category_in.name,
        models.Category.parent_id == category_in.parent_id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Category with this name already exists under the same parent"
        )
    
    category = crud.category.create_with_parent(db=db, obj_in=category_in)
    return category

@router.get("/", response_model=List[schemas.Category])
def read_categories(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    parent_id: Optional[int] = Query(None, description="父分类ID，为空时获取根分类"),
    include_children: bool = Query(False, description="是否包含子分类信息"),
):
    """
    Retrieve categories. 
    支持按父分类筛选，获取指定层级的分类
    """
    if parent_id is not None:
        # 获取指定父分类的子分类
        categories = crud.category.get_children(db, parent_id=parent_id)
    else:
        # 获取所有分类或根分类
        categories = crud.category.get_multi(db, skip=skip, limit=limit)
    
    # 如果需要包含计算属性，进行处理
    result = []
    for category in categories:
        category_dict = {
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "parent_id": category.parent_id,
            "level": category.level,
            "sort_order": category.sort_order,
            "full_path": category.get_full_path(),
            "content_count": len(category.contents),
            "all_content_count": category.get_all_content_count(),
            "has_children": category.has_children,
            "is_root": category.is_root,
        }
        result.append(schemas.Category(**category_dict))
    
    return result

@router.get("/tree", response_model=List[schemas.CategoryTreeNode])
def get_category_tree(
    db: Session = Depends(get_db),
    max_level: Optional[int] = Query(None, description="最大层级深度"),
):
    """
    Get category tree structure.
    返回完整的分类树形结构，用于前端树形组件展示
    """
    return crud.category.get_tree(db, max_level=max_level)

@router.get("/roots", response_model=List[schemas.Category])
def get_root_categories(db: Session = Depends(get_db)):
    """
    Get all root categories (categories without parent).
    获取所有根分类
    """
    categories = crud.category.get_root_categories(db)
    result = []
    for category in categories:
        category_dict = {
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "parent_id": category.parent_id,
            "level": category.level,
            "sort_order": category.sort_order,
            "full_path": category.get_full_path(),
            "content_count": len(category.contents),
            "all_content_count": category.get_all_content_count(),
            "has_children": category.has_children,
            "is_root": category.is_root,
        }
        result.append(schemas.Category(**category_dict))
    
    return result

@router.get("/{category_id}/children", response_model=List[schemas.Category])
def get_category_children(
    category_id: int,
    db: Session = Depends(get_db),
):
    """
    Get direct children of a category.
    获取指定分类的直接子分类
    """
    categories = crud.category.get_children(db, parent_id=category_id)
    result = []
    for category in categories:
        category_dict = {
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "parent_id": category.parent_id,
            "level": category.level,
            "sort_order": category.sort_order,
            "full_path": category.get_full_path(),
            "content_count": len(category.contents),
            "all_content_count": category.get_all_content_count(),
            "has_children": category.has_children,
            "is_root": category.is_root,
        }
        result.append(schemas.Category(**category_dict))
    
    return result

@router.get("/{category_id}/ancestors", response_model=List[schemas.CategoryPath])
def get_category_ancestors(
    category_id: int,
    db: Session = Depends(get_db),
):
    """
    Get ancestors path of a category (for breadcrumb navigation).
    获取分类的祖先路径，用于面包屑导航
    """
    ancestors = crud.category.get_ancestors(db, category_id=category_id)
    return [
        schemas.CategoryPath(id=cat.id, name=cat.name, level=cat.level)
        for cat in ancestors
    ]

@router.put("/{category_id}/move", response_model=schemas.Category, dependencies=[Depends(dependencies.get_current_active_superuser)])
def move_category(
    category_id: int,
    new_parent_id: Optional[int],
    db: Session = Depends(get_db),
):
    """
    Move category to a new parent. (Admin only)
    移动分类到新的父分类下
    """
    try:
        category = crud.category.move_category(db, category_id=category_id, new_parent_id=new_parent_id)
        
        # 返回更新后的分类信息
        category_dict = {
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "parent_id": category.parent_id,
            "level": category.level,
            "sort_order": category.sort_order,
            "full_path": category.get_full_path(),
            "content_count": len(category.contents),
            "all_content_count": category.get_all_content_count(),
            "has_children": category.has_children,
            "is_root": category.is_root,
        }
        return schemas.Category(**category_dict)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/stats")
def get_categories_stats(db: Session = Depends(get_db)):
    """
    Get statistics for all categories.
    获取分类统计信息，包括多级分类的统计
    """
    # 获取基础统计
    basic_stats = crud.category.get_category_stats(db)
    
    # 获取原有的图集统计（向后兼容）
    categories = db.query(models.Category).all()
    galleries = db.query(models.Gallery).all()
    
    # 统计每个分类的图集数量
    category_counts = {}
    for gallery in galleries:
        if gallery.category_id is not None:
            category_counts[gallery.category_id] = category_counts.get(gallery.category_id, 0) + 1
    
    # 转换为前端可用的格式
    category_gallery_stats = []
    for category in categories:
        count = category_counts.get(category.id, 0)
        all_count = category.get_all_content_count()  # 包含子分类的总数
        
        category_gallery_stats.append({
            "id": category.id,
            "name": category.name,
            "full_path": category.get_full_path(),
            "level": category.level,
            "gallery_count": count,
            "all_gallery_count": all_count,
            "has_children": category.has_children
        })
    
    return {
        "category_gallery_stats": category_gallery_stats,
        "category_stats": basic_stats
    }

@router.get("/{category_id}", response_model=schemas.Category)
def read_category(
    *,
    db: Session = Depends(get_db),
    category_id: int,
):
    """
    Get category by ID.
    获取指定分类的详细信息，包括计算属性
    """
    category = crud.category.get(db, id=category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    category_dict = {
        "id": category.id,
        "name": category.name,
        "description": category.description,
        "parent_id": category.parent_id,
        "level": category.level,
        "sort_order": category.sort_order,
        "full_path": category.get_full_path(),
        "content_count": len(category.contents),
        "all_content_count": category.get_all_content_count(),
        "has_children": category.has_children,
        "is_root": category.is_root,
    }
    return schemas.Category(**category_dict)

@router.put("/{category_id}", response_model=schemas.Category, dependencies=[Depends(dependencies.get_current_active_superuser)])
def update_category(
    *,
    db: Session = Depends(get_db),
    category_id: int,
    category_in: schemas.CategoryUpdate,
):
    """
    Update an existing category. (Admin only)
    更新分类信息
    """
    category = crud.category.get(db, id=category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    
    # 如果要修改父分类，需要验证
    if category_in.parent_id is not None and category_in.parent_id != category.parent_id:
        if category_in.parent_id == category_id:
            raise HTTPException(status_code=400, detail="Category cannot be its own parent")
        
        # 检查是否会创建循环引用
        descendants = category.get_descendants()
        if any(desc.id == category_in.parent_id for desc in descendants):
            raise HTTPException(status_code=400, detail="Cannot move category to its descendant")
        
        # 使用移动方法更新
        category = crud.category.move_category(db, category_id=category_id, new_parent_id=category_in.parent_id)
    
    # 更新其他字段
    category = crud.category.update(db=db, db_obj=category, obj_in=category_in)
    
    category_dict = {
        "id": category.id,
        "name": category.name,
        "description": category.description,
        "parent_id": category.parent_id,
        "level": category.level,
        "sort_order": category.sort_order,
        "full_path": category.get_full_path(),
        "content_count": len(category.contents),
        "all_content_count": category.get_all_content_count(),
        "has_children": category.has_children,
        "is_root": category.is_root,
    }
    return schemas.Category(**category_dict)

@router.delete("/{category_id}", response_model=Message, dependencies=[Depends(dependencies.get_current_active_superuser)])
def delete_category(
    *,
    db: Session = Depends(get_db),
    category_id: int,
    move_content_to: Optional[int] = Query(None, description="移动内容到指定分类ID"),
):
    """
    Delete a category. (Admin only)
    提供一个可选参数，可以将该分类下的内容移动到另一个分类
    """
    # 1. 查找要删除的分类
    category_to_delete = crud.category.get(db, id=category_id)
    if not category_to_delete:
        raise HTTPException(status_code=404, detail="Category not found")
        
    # 2. 在删除前获取完整路径和名称，用于返回信息
    name_to_delete = category_to_delete.name
    path_to_delete = category_to_delete.get_full_path()

    # 3. 检查是否有子分类
    if crud.category.has_children(db, category_id=category_id):
        raise HTTPException(
            status_code=400,
            detail="Cannot delete category with children. Please move or delete children first."
        )
        
    # 4. 如果需要移动内容，检查目标分类是否存在
    if move_content_to is not None:
        target_category = crud.category.get(db, id=move_content_to)
        if not target_category:
            raise HTTPException(status_code=404, detail="Target category for moving content not found")
        if target_category.id == category_id:
            raise HTTPException(status_code=400, detail="Cannot move content to the same category.")
    
    # 5. 执行删除和移动操作
    crud.category.remove(db=db, id=category_id, move_content_to=move_content_to)

    # 6. 返回成功信息（只用本地变量）
    return {
        "message": f"Category '{name_to_delete}' (Path: {path_to_delete}) and its content have been successfully handled.",
    } 