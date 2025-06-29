import asyncio
import random
import logging

# Set up basic logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# This is a standalone script, so we need to add the project root to the python path
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parents[2]))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app import crud, schemas
from app.core.config import settings

# Sample data
USER_COUNT = 10
IMAGES_PER_USER = 5
CATEGORIES = ["自然", "城市", "人像", "动物", "艺术"]
TAG_POOL = ["风景", "旅行", "日落", "街拍", "美食", "家庭", "宠物", "黑白", "抽象"]

async def seed_data():
    db: Session = SessionLocal()
    try:
        logger.info("--- Seeding database ---")

        # 1. Create Categories
        logger.info("Creating categories...")
        db_categories = []
        for cat_name in CATEGORIES:
            category = crud.category.get_by_name(db, name=cat_name)
            if not category:
                category = crud.category.create(db, obj_in=schemas.CategoryCreate(name=cat_name))
            db_categories.append(category)
        logger.info(f"Created/found {len(db_categories)} categories.")

        # 2. Create Users
        logger.info("Creating users...")
        db_users = []
        for i in range(USER_COUNT):
            username = f"user{i+1}"
            email = f"user{i+1}@example.com"
            password = "password"
            user = crud.user.get_by_username(db, username=username)
            if not user:
                user_in = schemas.UserCreate(username=username, email=email, password=password)
                user = crud.user.create(db, obj_in=user_in)
            db_users.append(user)
        logger.info(f"Created/found {len(db_users)} users.")

        # 3. Create Images with Tags
        logger.info("Creating images and tags...")
        db_images = []
        for user in db_users:
            for i in range(IMAGES_PER_USER):
                image_in = schemas.ImageCreate(
                    title=f"{user.username}的图片 {i+1}",
                    description=f"这是由{user.username}上传的一张美丽的图片。",
                )
                tags_to_add = random.sample(TAG_POOL, k=random.randint(1, 4))
                category = random.choice(db_categories)
                # Assuming crud.image.create_with_owner_and_tags exists and works like this
                image = crud.image.create_with_owner_and_category(
                    db=db, obj_in=image_in, owner_id=user.id, category_id=category.id, tags=tags_to_add
                )
                db_images.append(image)
        logger.info(f"Created {len(db_images)} images.")

        # 4. Create Relationships (Follows, Likes, Bookmarks)
        logger.info("Creating relationships...")
        for user in db_users:
            # Follows
            users_to_follow = random.sample([u for u in db_users if u.id != user.id], k=random.randint(0, USER_COUNT // 2))
            for target_user in users_to_follow:
                if target_user not in user.followed:
                    crud.user.follow(db, follower=user, followed=target_user)
            
            # Likes and Bookmarks
            images_to_like = random.sample(db_images, k=random.randint(0, len(db_images) // 2))
            images_to_bookmark = random.sample(db_images, k=random.randint(0, len(db_images) // 2))
            for image in images_to_like:
                crud.image.like(db, image=image, user=user)
            for image in images_to_bookmark:
                crud.image.bookmark(db, image=image, user=user)

        logger.info("Created relationships.")

        # 5. Create Comments
        logger.info("Creating comments...")
        for image in db_images:
            for _ in range(random.randint(0, 3)): # 0 to 3 top-level comments per image
                commenter = random.choice(db_users)
                comment_in = schemas.CommentCreate(content=f"太棒了！来自{commenter.username}的评论。")
                
                top_level_comment = crud.comment.create_comment(
                    db=db, obj_in=comment_in, image_id=image.id, owner_id=commenter.id
                )
                
                # Create a few replies
                if random.choice([True, False]):
                    for _ in range(random.randint(0, 2)):
                        reply_commenter = random.choice(db_users)
                        reply_in = schemas.CommentCreate(
                            content=f"回复@{commenter.username}: 我同意！",
                            parent_id=top_level_comment.id
                        )
                        crud.comment.create_comment(
                            db=db, obj_in=reply_in, image_id=image.id, owner_id=reply_commenter.id
                        )
        logger.info("Created comments.")

        logger.info("--- Database seeding finished successfully! ---")
    
    except Exception as e:
        logger.error(f"An error occurred during seeding: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()


if __name__ == "__main__":
    # In some environments, a new event loop is needed for standalone async scripts.
    asyncio.run(seed_data()) 