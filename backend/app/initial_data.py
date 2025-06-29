print("--- Running initial_data.py ---")
import logging
import os
import sys

# Add the project root directory to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.crud.crud_user import user as crud_user
from app.db.session import SessionLocal
from app.schemas.user import UserCreate
from app.core.config import settings
from app.models.user import UserRole

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def init_db() -> None:
    db = SessionLocal()

    user = crud_user.get_by_email(db, email=settings.FIRST_SUPERUSER_EMAIL)
    if not user:
        logger.info("Creating first superuser")
        user_in = UserCreate(
            username=settings.FIRST_SUPERUSER,
            email=settings.FIRST_SUPERUSER_EMAIL,
            password=settings.FIRST_SUPERUSER_PASSWORD,
            is_superuser=True,
        )
        user = crud_user.create(db=db, obj_in=user_in)
        user.role = UserRole.ADMIN
        db.add(user)
        db.commit()
        db.refresh(user)
        logger.info("First superuser created")
    else:
        logger.info("Superuser already exists in database, skipping creation")

if __name__ == "__main__":
    logger.info("Creating initial data")
    init_db()
    logger.info("Initial data created") 