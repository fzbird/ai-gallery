from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import Any

from app import crud, models, schemas
from app.api.v1 import dependencies
from app.core.security import create_access_token, verify_password
from app.db.session import get_db
from app.schemas.token import Token

router = APIRouter()

@router.post("/login/access-token", response_model=Token)
def login_access_token(
    db: Session = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends()
):
    """
    OAuth2 compatible token login, get an access token for future requests.
    """
    # Try to get user by email first, then by username
    user = crud.user.get_by_email(db, email=form_data.username)
    if not user:
        user = crud.user.get_by_username(db, username=form_data.username)
    
    if not user or not verify_password(form_data.password, str(user.hashed_password)):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not bool(user.is_active):
        raise HTTPException(status_code=400, detail="Inactive user")
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"} 

@router.get("/me", response_model=schemas.User)
def read_current_user(
    current_user: models.User = Depends(dependencies.get_current_user),
):
    """
    Get current user info via auth token.
    """
    return current_user