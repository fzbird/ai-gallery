from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app import crud, models, schemas
from app.api.v1 import dependencies

router = APIRouter()

@router.get("/count")
def get_departments_count(
    db: Session = Depends(dependencies.get_db),
):
    """
    Get total count of departments.
    """
    total = crud.department.count(db)
    return {"total": total}

@router.get("/", response_model=List[schemas.Department])
def read_departments(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = 100,
):
    """
    Retrieve all departments. Public access for frontend navigation.
    """
    departments = crud.department.get_multi(db, skip=skip, limit=limit, with_users=True)
    return departments

@router.get("/stats")
def get_departments_stats(
    db: Session = Depends(dependencies.get_db),
):
    """
    Get statistics for all departments (gallery counts through users).
    """
    # 获取每个部门下的图集数量（通过用户和统一内容表）
    stats = db.query(
        models.User.department_id,
        func.count(models.ContentBase.id).label('gallery_count')
    ).join(
        models.ContentBase, models.ContentBase.owner_id == models.User.id
    ).filter(
        models.ContentBase.content_type == 'gallery'
    ).group_by(models.User.department_id).all()
    
    # 转换为字典格式
    stats_dict = {}
    for stat in stats:
        if stat.department_id:  # 排除没有部门的用户
            stats_dict[stat.department_id] = stat.gallery_count
    
    return stats_dict

@router.post("/", response_model=schemas.Department, status_code=status.HTTP_201_CREATED)
def create_department(
    *,
    db: Session = Depends(dependencies.get_db),
    department_in: schemas.DepartmentCreate,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Create a new department. Superuser only.
    """
    department = crud.department.create(db=db, obj_in=department_in)
    return department

@router.get("/{department_id}", response_model=schemas.Department)
def read_department(
    *,
    db: Session = Depends(dependencies.get_db),
    department_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Get a specific department by ID. Superuser only.
    """
    department = crud.department.get(db=db, id=department_id, with_users=True)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    return department

@router.get("/{department_id}/deletion-check", response_model=schemas.DepartmentDeletionCheck)
def check_department_deletion_eligibility(
    *,
    db: Session = Depends(dependencies.get_db),
    department_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Check if a department can be safely deleted.
    Returns detailed information about deletion eligibility.
    """
    department = crud.department.get(db=db, id=department_id, with_users=True)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    
    admin_users = [user for user in department.users if user.is_superuser]
    regular_users = [user for user in department.users if not user.is_superuser]
    
    reasons_preventing_deletion = []
    can_delete = True
    
    if admin_users:
        can_delete = False
        reasons_preventing_deletion.append(
            f"Contains {len(admin_users)} administrator(s): {', '.join([user.username for user in admin_users])}"
        )
    
    if regular_users:
        can_delete = False
        reasons_preventing_deletion.append(
            f"Contains {len(regular_users)} regular user(s) that need to be reassigned"
        )
    
    return schemas.DepartmentDeletionCheck(
        can_delete=can_delete,
        department_id=department_id,
        department_name=department.name,
        total_users=len(department.users),
        admin_users=[schemas.UserReference(id=user.id, username=user.username) for user in admin_users],
        regular_users=[schemas.UserReference(id=user.id, username=user.username) for user in regular_users],
        reasons_preventing_deletion=reasons_preventing_deletion
    )

@router.put("/{department_id}", response_model=schemas.Department)
def update_department(
    *,
    db: Session = Depends(dependencies.get_db),
    department_id: int,
    department_in: schemas.DepartmentUpdate,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Update a department. Superuser only.
    """
    department = crud.department.get(db=db, id=department_id)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    department = crud.department.update(db=db, db_obj=department, obj_in=department_in)
    return department

@router.delete("/{department_id}", response_model=schemas.Department)
def delete_department(
    *,
    db: Session = Depends(dependencies.get_db),
    department_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Delete a department. Superuser only.
    Cannot delete departments that contain users, especially administrators.
    """
    department = crud.department.get(db=db, id=department_id, with_users=True)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    
    # Check if department has any users
    if department.users:
        # Check if any of the users are administrators/superusers
        admin_users = [user for user in department.users if user.is_superuser]
        if admin_users:
            admin_usernames = [user.username for user in admin_users]
            raise HTTPException(
                status_code=400, 
                detail=f"Cannot delete department containing administrators: {', '.join(admin_usernames)}. "
                       "Please reassign administrators to other departments before deletion."
            )
        
        # If there are regular users (non-admins), also prevent deletion for data integrity
        regular_users = [user for user in department.users if not user.is_superuser]
        if regular_users:
            raise HTTPException(
                status_code=400, 
                detail=f"Cannot delete department containing {len(regular_users)} user(s). "
                       "Please reassign all users to other departments before deletion."
            )
    
    department = crud.department.remove(db=db, id=department_id)
    return department 