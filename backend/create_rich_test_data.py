#!/usr/bin/env python3
"""
创建丰富的测试数据
"""
import random
import hashlib
import time
from datetime import datetime, timedelta
from pathlib import Path

from sqlalchemy.orm import Session
from PIL import Image as PILImage, ImageDraw, ImageFont

from app.db.session import SessionLocal
from app import crud, schemas
from app.models.user import User, UserRole
from app.models.category import Category
from app.models.department import Department  
from app.models.tag import Tag
from app.core.security import get_password_hash


def create_placeholder_image(filename: str, title: str, width: int = 800, height: int = 600) -> str:
    """创建占位符图片"""
    upload_dir = Path("uploads")
    upload_dir.mkdir(exist_ok=True)
    
    filepath = upload_dir / filename
    
    if filepath.exists():
        return str(filepath)
    
    color = (random.randint(50, 200), random.randint(50, 200), random.randint(50, 200))
    img = PILImage.new('RGB', (width, height), color=color)
    draw = ImageDraw.Draw(img)
    
    try:
        font = ImageFont.truetype("arial.ttf", 24)
    except (OSError, IOError):
        font = ImageFont.load_default()
    
    # 绘制标题
    text = title[:20] + "..." if len(title) > 20 else title
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = (width - text_width) / 2
    text_y = (height - text_height) / 2
    draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)
    
    img.save(filepath)
    return str(filepath)


def create_test_users(db: Session, count: int = 25):
    """创建测试用户"""
    print(f"创建 {count} 个测试用户...")
    
    departments = db.query(Department).all()
    
    names = [
        "张伟", "李娜", "王芳", "刘强", "陈静", "杨洋", "赵雷", "黄敏", "周杰", "吴丽",
        "徐明", "朱红", "林峰", "何超", "郭宁", "马丽", "孙涛", "韩雪", "梁斌", "谢娟",
        "罗华", "高鹏", "郑霞", "梁宇", "谭婷"
    ]
    
    roles = ["摄影师", "设计师", "艺术家", "爱好者", "创作者"]
    
    users = []
    
    for i in range(count):
        username = f"user{i+1:03d}"
        email = f"user{i+1:03d}@gallery.com"
        
        # 检查用户是否已存在
        existing_user = crud.user.get_by_email(db, email=email)
        if existing_user:
            users.append(existing_user)
            continue
        
        display_name = f"{names[i % len(names)]}{random.choice(roles)}"
        
        user_create = schemas.UserCreate(
            username=username,
            email=email,
            password="password123"
        )
        
        user = crud.user.create(db, obj_in=user_create)
        
        # 更新额外信息
        user.bio = f"我是{display_name}，热爱摄影和艺术创作。"
        if departments:
            user.department_id = random.choice(departments).id
        
        db.add(user)
        users.append(user)
    
    db.commit()
    
    for user in users:
        db.refresh(user)
    
    print(f"创建了 {len(users)} 个用户")
    return users


def create_test_images(db: Session, users, images_per_user: int = 5):
    """创建测试图片"""
    print(f"为每个用户创建 {images_per_user} 张图片...")
    
    categories = db.query(Category).all()
    tags = db.query(Tag).all()
    
    titles = [
        "美丽的日出", "城市夜景", "森林小径", "海边漫步", "山峰云海", "花园春色",
        "古建筑风采", "现代艺术", "街头摄影", "自然风光", "人物肖像", "动物世界",
        "美食诱惑", "运动瞬间", "旅行记忆", "家庭时光"
    ]
    
    descriptions = [
        "这是一张精心拍摄的照片，展现了独特的美感。",
        "通过巧妙的构图和光影运用，创造出令人印象深刻的视觉效果。",
        "捕捉到了完美的瞬间，每一个细节都经过精心考虑。",
        "运用了先进的拍摄技巧，呈现出专业级的摄影作品。"
    ]
    
    images = []
    
    for user in users:
        for i in range(images_per_user):
            timestamp = int(time.time() * 1000000) + random.randint(1, 1000)
            title = f"{random.choice(titles)} {timestamp}"
            filename = f"img_{timestamp}_{user.id}_{i}.jpg"
            
            # 创建占位符图片
            filepath = create_placeholder_image(filename, title)
            
            # 使用crud创建图片
            image_create = schemas.ImageCreate(
                title=title,
                description=random.choice(descriptions),
                file_hash=hashlib.md5(filename.encode()).hexdigest()
            )
            
            image = crud.image.create_with_owner(
                db=db,
                obj_in=image_create,
                owner_id=user.id
            )
            
            # 更新图片信息
            image.filename = filename
            image.filepath = filepath
            image.width = random.choice([800, 1024, 1200])
            image.height = random.choice([600, 768, 900])
            image.file_size = random.randint(100000, 1000000)
            image.file_type = "image/jpeg"
            image.ai_status = "completed"
            
            if categories:
                image.category_id = random.choice(categories).id
            
            db.add(image)
            images.append(image)
    
    db.commit()
    
    for image in images:
        db.refresh(image)
    
    print(f"创建了 {len(images)} 张图片")
    return images


def create_test_galleries(db: Session, users, images):
    """创建测试图集"""
    print("创建测试图集...")
    
    categories = db.query(Category).all()
    
    gallery_titles = [
        "自然风光系列", "城市印象集", "人文纪实", "艺术创作集", "旅行摄影",
        "生活记录", "创意摄影", "黑白作品", "色彩实验", "街头摄影集"
    ]
    
    # 按用户分组图片
    user_images = {}
    for image in images:
        if image.owner_id not in user_images:
            user_images[image.owner_id] = []
        user_images[image.owner_id].append(image)
    
    galleries = []
    
    for user in users:
        user_image_list = user_images.get(user.id, [])
        
        if len(user_image_list) >= 3:  # 只有有足够图片的用户才创建图集
            timestamp = int(time.time() * 1000000) + random.randint(1, 1000)
            title = f"{random.choice(gallery_titles)} {timestamp}"
            
            gallery_create = schemas.GalleryCreate(
                title=title,
                description="这是一个精美的图集，收录了多张精选图片。"
            )
            
            gallery = crud.gallery.create_with_owner(
                db=db,
                obj_in=gallery_create,
                owner_id=user.id
            )
            
            if categories:
                gallery.category_id = random.choice(categories).id
            
            # 随机选择3-5张图片加入图集
            images_for_gallery = random.sample(user_image_list, min(random.randint(3, 5), len(user_image_list)))
            
            for idx, image in enumerate(images_for_gallery):
                image.gallery_id = gallery.id
                if idx == 0:  # 第一张作为封面
                    gallery.cover_image_id = image.id
            
            gallery.image_count = len(images_for_gallery)
            db.add(gallery)
            galleries.append(gallery)
    
    db.commit()
    
    for gallery in galleries:
        db.refresh(gallery)
    
    print(f"创建了 {len(galleries)} 个图集")
    return galleries


def main():
    """主函数"""
    print("开始生成丰富的测试数据...")
    
    # 配置参数
    USER_COUNT = 25
    IMAGES_PER_USER = 5
    
    print(f"配置: {USER_COUNT} 用户, {IMAGES_PER_USER} 图片/用户")
    
    db = SessionLocal()
    try:
        # 检查基础数据
        categories = db.query(Category).all()
        departments = db.query(Department).all()
        tags = db.query(Tag).all()
        
        if not categories:
            print("警告: 缺少分类数据，请先运行 create_test_data.py")
            return
        
        print(f"找到 {len(categories)} 个分类, {len(departments)} 个部门, {len(tags)} 个标签")
        
        # 1. 创建用户
        users = create_test_users(db, USER_COUNT)
        
        # 2. 创建图片
        images = create_test_images(db, users, IMAGES_PER_USER)
        
        # 3. 创建图集
        galleries = create_test_galleries(db, users, images)
        
        print("\n" + "="*50)
        print("测试数据生成完成！")
        print(f"用户数量: {len(users)}")
        print(f"图片数量: {len(images)}")
        print(f"图集数量: {len(galleries)}")
        print("\n登录信息:")
        print("账号格式: user001@gallery.com ~ user025@gallery.com")
        print("统一密码: password123")
        print("="*50)
        
    except Exception as e:
        print(f"生成测试数据时出错: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main() 