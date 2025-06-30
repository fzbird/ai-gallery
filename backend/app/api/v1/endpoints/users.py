from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session, selectinload, with_parent
from typing import Any, List, Optional
import secrets
import string

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.db.session import get_db
from app.api.v1.endpoints.images import _map_image_to_schema
from app.schemas.user import UserSimple
from app.core.security import verify_password

router = APIRouter()

@router.get("/count")
def get_users_count(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
    search: str = "",
):
    """
    Get total count of users.
    Admin only.
    """
    query = db.query(models.User)
    
    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            models.User.username.ilike(search_pattern) |
            models.User.bio.ilike(search_pattern)
        )
    
    total = query.count()
    return {"total": total}

@router.get("/stats")
def get_users_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Get statistics for all users.
    Admin only.
    """
    from sqlalchemy import func
    
    # 基础用户统计
    total_users = db.query(models.User).count()
    active_users = db.query(models.User).filter(models.User.is_active == True).count()
    superusers = db.query(models.User).filter(models.User.is_superuser == True).count()
    inactive_users = total_users - active_users
    
    # 用户按部门统计 - 简化查询逻辑
    # 获取所有用户并在Python中统计
    all_users = db.query(models.User).options(selectinload(models.User.department)).all()
    department_counts = {}
    
    for user in all_users:
        if user.department:
            dept_name = user.department.name
            department_counts[dept_name] = department_counts.get(dept_name, 0) + 1
        else:
            department_counts["未分配"] = department_counts.get("未分配", 0) + 1
    
    # 转换为前端可用的格式
    department_data = [{"name": name, "count": count} for name, count in department_counts.items()]
    
    # 最活跃用户（按图集数量）
    top_gallery_creators = db.query(
        models.User.username,
        func.count(models.Gallery.id).label('gallery_count')
    ).outerjoin(
        models.Gallery, models.User.id == models.Gallery.owner_id
    ).group_by(
        models.User.id, models.User.username
    ).order_by(
        func.count(models.Gallery.id).desc()
    ).limit(5).all()
    
    top_creators_data = [{"username": row.username, "count": row.gallery_count} for row in top_gallery_creators]
    
    return {
        "total_users": total_users,
        "active_users": active_users,
        "inactive_users": inactive_users,
        "superusers": superusers,
        "users_by_department": department_data,
        "top_gallery_creators": top_creators_data
    }

@router.get("/", response_model=List[schemas.UserPublic])
def read_users_public(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    search: str = "",
    sort: str = "created_at",
    order: str = "desc",
):
    """
    Retrieve all users (public info only) with search and sorting.
    """
    try:
        # 构建基础查询，预加载关系数据
        query = (
            db.query(models.User)
            .options(
                selectinload(models.User.department),
                selectinload(models.User.followers),
                selectinload(models.User.following),
                selectinload(models.User.contents)
            )
            .filter(models.User.is_active == True)
        )
        
        # 添加搜索条件
        if search:
            search_pattern = f"%{search}%"
            query = query.filter(
                models.User.username.ilike(search_pattern) |
                models.User.bio.ilike(search_pattern)
            )
        
        # 添加排序
        order_by_field = None
        if sort == "username":
            order_by_field = models.User.username
        elif sort == "created_at":
            order_by_field = models.User.created_at
        elif sort == "followers":
            # 对于复杂的排序，我们先按创建时间排序
            order_by_field = models.User.created_at
        elif sort == "uploads":
            # 对于复杂的排序，我们先按创建时间排序
            order_by_field = models.User.created_at
        else:
            order_by_field = models.User.created_at
            
        if order_by_field is not None:
            if order.lower() == "desc":
                query = query.order_by(order_by_field.desc())
            else:
                query = query.order_by(order_by_field.asc())
        
        # 应用分页
        users = query.offset(skip).limit(limit).all()
        
        # 转换为公开格式
        result = []
        for user in users:
            try:
                followers_count = len(user.followers) if hasattr(user, 'followers') and user.followers else 0
                following_count = len(user.following) if hasattr(user, 'following') and user.following else 0
                
                # 计算用户的作品数量（图片数量）
                uploads_count = 0
                try:
                    # 直接查询图片表，这样更可靠
                    uploads_count = db.query(models.Image).filter(models.Image.owner_id == user.id).count()
                except Exception as e:
                    print(f"Error calculating uploads count for user {user.id}: {e}")
                    uploads_count = 0
                    
            except:
                followers_count = 0
                following_count = 0
                uploads_count = 0
                
            user_dict = {
                'id': user.id,
                'username': user.username,
                'bio': user.bio,
                'role': user.role.value if user.role else None,
                'followers_count': followers_count,
                'following_count': following_count,
                'uploads_count': uploads_count,  # 添加作品数量
                'is_following': False,  # 默认值，未登录时
                'created_at': user.created_at,
                'department': None  # 暂时不包含部门信息，避免循环导入
            }
            result.append(schemas.UserPublic(**user_dict))
        
        return result
        
    except Exception as e:
        print(f"Error in read_users_public: {e}")
        return []

@router.get("/admin", response_model=List[schemas.User])
def read_users_admin(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Retrieve all users. Only for superusers.
    """
    users = crud.user.get_multi(db, skip=skip, limit=limit, options=[selectinload(models.User.department)])
    return users

@router.post("/", response_model=schemas.User)
def create_user(
    *,
    db: Session = Depends(get_db),
    user_in: schemas.UserCreate,
):
    """
    Create new user.
    """
    # 检查是否开放注册
    from app import crud
    enable_registration_setting = crud.settings.get_setting(db, key="enable_registration")
    if enable_registration_setting and enable_registration_setting.value.lower() == "false":
        raise HTTPException(
            status_code=403,
            detail="Registration is currently disabled by the administrator.",
        )
    
    user = crud.user.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    user = crud.user.get_by_username(db, username=user_in.username)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system.",
        )
    user = crud.user.create(db=db, obj_in=user_in)
    return user

@router.get("/me", response_model=schemas.User)
def read_user_me(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get current user.
    """
    # Safely load department data
    try:
        db.refresh(current_user, attribute_names=['department'])
    except Exception:
        # If refresh fails, just return the user without department data
        pass
    return current_user

@router.put("/me/password", status_code=status.HTTP_204_NO_CONTENT)
def update_password_me(
    *,
    db: Session = Depends(get_db),
    password_update: schemas.PasswordUpdate,
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Update own password.
    """
    if not verify_password(password_update.current_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect password")
    if len(password_update.new_password) < 8:
         raise HTTPException(status_code=400, detail="New password must be at least 8 characters long")
    crud.user.update_password(db, db_obj=current_user, new_password=password_update.new_password)

@router.put("/{user_id}", response_model=schemas.User)
def update_user(
    *,
    db: Session = Depends(get_db),
    user_id: int,
    user_in: schemas.UserUpdateAdmin,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Update a user.
    """
    user = crud.user.get(db, id=user_id, options=[selectinload(models.User.department)])
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this username does not exist.",
        )
    
    if user.id == current_user.id:
        if user_in.is_active is False or user_in.is_superuser is False:
             raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Superusers cannot deactivate themselves or remove their own superuser status.",
            )

    user = crud.user.update(db, db_obj=user, obj_in=user_in)
    return user

@router.get("/{username}", response_model=schemas.UserPublic)
def read_user_by_username(
    username: str,
    db: Session = Depends(get_db),
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    Get a specific user by username.
    """
    try:
        user = crud.user.get_by_username(db, username=username)
        if user is None:
            raise HTTPException(
                status_code=404,
                detail="The user with this username does not exist.",
            )
        
        # 简化关注状态检查
        is_following = False
        
        # 简化数据获取，避免复杂的关系查询
        followers_count = 0
        following_count = 0
        
        try:
            if hasattr(user, 'followers') and user.followers:
                followers_count = len(user.followers)
        except:
            pass
            
        try:
            if hasattr(user, 'following') and user.following:
                following_count = len(user.following)
        except:
            pass
        
        # 计算作品数量
        uploads_count = 0
        try:
            uploads_count = db.query(models.Image).filter(models.Image.owner_id == user.id).count()
        except:
            uploads_count = 0
        
        # 创建用户字典
        user_dict = {
            'id': user.id,
            'username': user.username,
            'bio': user.bio,
            'role': user.role.value if user.role else None,
            'followers_count': followers_count,
            'following_count': following_count,
            'uploads_count': uploads_count,
            'is_following': is_following,
            'created_at': user.created_at,
            'department': None
        }

        return schemas.UserPublic(**user_dict)
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in read_user_by_username: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )

@router.delete("/{user_id}", response_model=schemas.User)
def delete_user(
    *,
    db: Session = Depends(get_db),
    user_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Delete a user.
    """
    user = crud.user.get(db, id=user_id, options=[selectinload(models.User.department)])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Superusers cannot delete themselves")
    
    crud.user.remove(db=db, id=user_id)
    return user

@router.get("/me/test")
def test_endpoint():
    """
    简单的测试端点
    """
    return {"message": "test endpoint working", "status": "ok"}

@router.get("/me/likes", response_model=List[schemas.Image])
def read_user_me_likes(
    *,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get all images liked by the current user.
    """
    # 使用content_likes表查询用户点赞的图片
    from app.models.content_interactions import content_likes
    
    try:
        liked_images = (
            db.query(models.Image)
            .join(content_likes, models.Image.id == content_likes.c.content_id)
            .filter(content_likes.c.user_id == current_user.id)
            .options(selectinload(models.Image.liked_by_users), selectinload(models.Image.bookmarked_by_users))
            .order_by(models.Image.created_at.desc())
            .all()
        )
        
        return [_map_image_to_schema(img, current_user.id) for img in liked_images]
    except Exception as e:
        # 如果查询失败，返回空列表
        return []

@router.get("/{username}/galleries", response_model=List[schemas.GalleryWithImages])
def read_galleries_by_user(
    username: str,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    Retrieve galleries for a specific user by username.
    """
    user = crud.user.get_by_username(db, username=username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 获取用户的图集
    galleries = crud.gallery.get_by_owner(db, owner_id=user.id, skip=skip, limit=limit)
    
    # 为每个gallery添加当前用户相关信息
    if current_user:
        for gallery in galleries:
            setattr(gallery, 'liked_by_current_user', False)
            setattr(gallery, 'bookmarked_by_current_user', False)
    
    # 为所有图集的图片添加image_url字段
    for gallery in galleries:
        if hasattr(gallery, 'images') and gallery.images:
            for image in gallery.images:
                from app.core.image_utils import generate_image_url
                setattr(image, 'image_url', generate_image_url(image))
    
    return galleries

@router.get("/{username}/images", response_model=List[schemas.Image])
def read_images_by_user(
    username: str,
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
):
    """
    Retrieve images for a specific user by username.
    """
    user = crud.user.get_by_username(db, username=username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    images_query = (
        db.query(models.Image)
        .filter(models.Image.owner_id == user.id)
        .options(selectinload(models.Image.liked_by_users), selectinload(models.Image.bookmarked_by_users))
        .order_by(models.Image.created_at.desc())
    )

    images = images_query.offset(skip).limit(limit).all()
    
    current_user_id = current_user.id if current_user else None
    return [_map_image_to_schema(img, current_user_id) for img in images]

@router.get("/{username}/likes", response_model=List[schemas.Image])
def read_liked_images_by_user(
    *,
    db: Session = Depends(get_db),
    username: str,
    skip: int = 0,
    limit: int = 100,
    current_user: Optional[models.User] = Depends(dependencies.get_current_user_optional),
) -> Any:
    """
    Get images liked by a specific user.
    """
    user = crud.user.get_by_username(db, username=username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 使用新的统一content_likes表查询用户点赞的图片
    from app.models.content_interactions import content_likes
    
    try:
        liked_images = (
            db.query(models.Image)
            .join(content_likes, models.Image.id == content_likes.c.content_id)
            .filter(content_likes.c.user_id == user.id)
            .options(
                selectinload(models.Image.liked_by_users), 
                selectinload(models.Image.bookmarked_by_users),
                selectinload(models.Image.comments).selectinload(models.Comment.owner)
            )
            .order_by(models.Image.created_at.desc())
            .offset(skip)
            .limit(limit)
            .all()
        )
        
        current_user_id = current_user.id if current_user else None
        return [_map_image_to_schema(img, current_user_id) for img in liked_images]
    except Exception as e:
        print(f"Error in read_liked_images_by_user: {e}")
        # 如果查询失败，返回空列表
        return []

@router.get("/me/bookmarks", response_model=List[schemas.Image])
def read_user_me_bookmarks(
    *,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get all images bookmarked by the current user.
    """
    # 使用新的统一content_bookmarks表查询用户收藏的图片
    from app.models.content_interactions import content_bookmarks
    
    try:
        bookmarked_images = (
            db.query(models.Image)
            .join(content_bookmarks, models.Image.id == content_bookmarks.c.content_id)
            .filter(content_bookmarks.c.user_id == current_user.id)
            .options(selectinload(models.Image.liked_by_users), selectinload(models.Image.bookmarked_by_users))
            .order_by(models.Image.created_at.desc())
            .all()
        )
        
        return [_map_image_to_schema(img, current_user.id) for img in bookmarked_images]
    except Exception as e:
        # 如果查询失败，返回空列表
        return []

@router.post("/{user_id}/follow", status_code=status.HTTP_204_NO_CONTENT)
def follow_user(
    user_id: int,
    *,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Follow a user.
    """
    user_to_follow = crud.user.get(db, id=user_id)
    if not user_to_follow:
        raise HTTPException(status_code=404, detail="User not found")
    if user_to_follow == current_user:
        raise HTTPException(status_code=400, detail="You cannot follow yourself")
    if user_to_follow in current_user.followers:
        raise HTTPException(status_code=400, detail="You are already following this user")
    
    crud.user.follow(db, follower=current_user, followed=user_to_follow)

@router.delete("/{user_id}/follow", status_code=status.HTTP_204_NO_CONTENT)
def unfollow_user(
    user_id: int,
    *,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Unfollow a user.
    """
    user_to_unfollow = crud.user.get(db, id=user_id)
    if not user_to_unfollow:
        raise HTTPException(status_code=404, detail="User not found")
    if user_to_unfollow not in current_user.followers:
        raise HTTPException(status_code=400, detail="You are not following this user")
        
    crud.user.unfollow(db, follower=current_user, followed=user_to_unfollow)

@router.get("/{user_id}/followers", response_model=List[UserSimple])
def get_user_followers(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get a list of followers for a specific user.
    """
    user = crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return [UserSimple.model_validate(u) for u in user.followers]

@router.get("/{user_id}/following", response_model=List[UserSimple])
def get_user_following(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get a list of users that a specific user is following.
    """
    user = crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return [UserSimple.model_validate(u) for u in user.followers]

@router.post("/{user_id}/reset-password", response_model=schemas.NewPassword)
def reset_user_password(
    *,
    db: Session = Depends(get_db),
    user_id: int,
    current_user: models.User = Depends(dependencies.get_current_active_superuser),
):
    """
    Reset a user's password. Superuser only.
    Generates a new random password and returns it.
    """
    user = crud.user.get(db, id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Generate a random 8-character password
    alphabet = string.ascii_letters + string.digits + string.punctuation
    new_password = ''.join(secrets.choice(alphabet) for i in range(8))
    
    # Update user with new hashed password
    crud.user.update(db, db_obj=user, obj_in={"password": new_password})
    
    # Here you would ideally trigger an email to the user with their new password
    # For now, we return it directly to the admin in the response.
    
    return {"new_password": new_password} 