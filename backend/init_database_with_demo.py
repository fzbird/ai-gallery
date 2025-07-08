#!/usr/bin/env python3
"""
Gallery 数据库初始化脚本
- 创建完整的数据库结构
- 生成基础数据（分类、标签、部门、主题）
- 从网络下载真实图片
- 生成示例用户、图片、图集数据
"""
import os
import random
import hashlib
import time
import uuid

from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional
from urllib.parse import urlparse

from sqlalchemy.orm import Session
from sqlalchemy import text
from PIL import Image as PILImage
import requests

from app.db.session import SessionLocal
from app import crud, schemas
from app.models.user import User, UserRole
from app.models.category import Category
from app.models.department import Department
from app.models.tag import Tag
from app.models.topic import Topic
from app.models.image import Image
from app.models.gallery import Gallery
from app.models.content_base import ContentBase
from app.core.security import get_password_hash

# 配置
CONFIG = {
    'USERS_COUNT': 20,
    'IMAGES_PER_USER': 8,
    'GALLERIES_PER_USER': 2,
    'DOWNLOAD_TIMEOUT': 30,
    'IMAGE_QUALITY': 85,
    'MAX_IMAGE_SIZE': (1200, 1200),
    'UPLOADS_DIR': Path('uploads'),
    'DEMO_IMAGE_SOURCES': [
        'https://picsum.photos',  # Lorem Picsum
        'https://source.unsplash.com',  # Unsplash
    ]
}

# 示例数据定义
DEMO_DATA = {
    'departments': [
        {'name': '摄影部', 'description': '专业摄影创作团队'},
        {'name': '设计部', 'description': '平面设计与视觉创作'},
        {'name': '艺术部', 'description': '艺术作品创作与展示'},
        {'name': '媒体部', 'description': '数字媒体与影像制作'},
        {'name': '策划部', 'description': '活动策划与内容运营'},
    ],
    
    'root_categories': [
        {'name': '摄影作品', 'description': '各类摄影作品展示'},
        {'name': '设计作品', 'description': '平面设计和创意作品'},
        {'name': '艺术创作', 'description': '绘画、雕塑等艺术作品'},
        {'name': '数字媒体', 'description': '数字艺术和多媒体作品'},
        {'name': '生活记录', 'description': '日常生活和旅行记录'},
    ],
    
    'sub_categories': {
        '摄影作品': [
            {'name': '风光摄影', 'description': '自然风光和景观摄影'},
            {'name': '人像摄影', 'description': '人物肖像和写真摄影'},
            {'name': '街头摄影', 'description': '街头纪实和城市摄影'},
            {'name': '建筑摄影', 'description': '建筑和空间摄影'},
            {'name': '微距摄影', 'description': '微距和细节摄影'},
        ],
        '设计作品': [
            {'name': '海报设计', 'description': '宣传海报和广告设计'},
            {'name': 'UI设计', 'description': '用户界面和交互设计'},
            {'name': '品牌设计', 'description': '品牌形象和标识设计'},
            {'name': '包装设计', 'description': '产品包装和展示设计'},
        ],
        '艺术创作': [
            {'name': '油画作品', 'description': '油画创作和展示'},
            {'name': '水彩画', 'description': '水彩画作品'},
            {'name': '素描作品', 'description': '素描和速写作品'},
            {'name': '数字绘画', 'description': '数字艺术创作'},
        ],
        '数字媒体': [
            {'name': '3D渲染', 'description': '三维建模和渲染作品'},
            {'name': '动画作品', 'description': '动画和动态图形'},
            {'name': '视频制作', 'description': '视频编辑和制作'},
        ],
        '生活记录': [
            {'name': '旅行摄影', 'description': '旅行和探索记录'},
            {'name': '美食摄影', 'description': '美食和餐饮摄影'},
            {'name': '宠物摄影', 'description': '宠物和动物摄影'},
            {'name': '家庭摄影', 'description': '家庭和亲子摄影'},
        ],
    },
    
    'tags': [
        '风景', '人像', '黑白', '彩色', '夜景', '日出', '日落', '城市', '乡村', '海边',
        '山景', '森林', '花卉', '建筑', '现代', '古典', '抽象', '写实', '创意', '艺术',
        '时尚', '复古', '简约', '温馨', '浪漫', '神秘', '震撼', '宁静', '活力', '优雅',
        '专业', '业余', '手机', '相机', '后期', '原片', '高清', '4K', '全景', '特写',
    ],
    
    'topics': [
        {
            'name': '春日物语',
            'slug': 'spring-stories',
            'description': '捕捉春天的美好时光，记录生机盎然的春日景象',
        },
        {
            'name': '城市印象',
            'slug': 'city-impressions',
            'description': '现代城市的多样面貌，建筑与人文的交融',
        },
        {
            'name': '人像艺术',
            'slug': 'portrait-art',
            'description': '人物肖像的艺术表达，情感与美的结合',
        },
        {
            'name': '自然之美',
            'slug': 'natural-beauty',
            'description': '大自然的壮丽景色，风光摄影的极致展现',
        },
        {
            'name': '创意设计',
            'slug': 'creative-design',
            'description': '设计师的创意作品，视觉艺术的无限可能',
        },
        {
            'name': '黑白世界',
            'slug': 'black-and-white',
            'description': '黑白摄影的独特魅力，经典与现代的碰撞',
        },
    ],
    
    'user_profiles': [
        {
            'username': 'photographer_zhang',
            'email': 'zhang@gallery.com',
            'name': '张伟',
            'role': '风光摄影师',
            'bio': '专注于风光摄影10年，擅长捕捉自然之美。作品曾在多个摄影展览中展出。',
            'department': '摄影部',
        },
        {
            'username': 'designer_li',
            'email': 'li@gallery.com',
            'name': '李娜',
            'role': '平面设计师',
            'bio': '创意设计师，专注于品牌视觉设计。喜欢用色彩和创意传达情感。',
            'department': '设计部',
        },
        {
            'username': 'artist_wang',
            'email': 'wang@gallery.com',
            'name': '王芳',
            'role': '数字艺术家',
            'bio': '数字艺术创作者，擅长3D建模和数字绘画。热爱探索艺术与技术的结合。',
            'department': '艺术部',
        },
        {
            'username': 'street_photographer',
            'email': 'liu@gallery.com',
            'name': '刘强',
            'role': '街头摄影师',
            'bio': '街头摄影爱好者，善于捕捉城市生活的真实瞬间。',
            'department': '媒体部',
        },
        {
            'username': 'portrait_master',
            'email': 'chen@gallery.com',
            'name': '陈静',
            'role': '人像摄影师',
            'bio': '专业人像摄影师，擅长捕捉人物的情感表达和内在美。',
            'department': '摄影部',
        },
    ],
}

# 图片主题和关键词映射
IMAGE_THEMES = {
    '风光摄影': {
        'keywords': ['landscape', 'nature', 'mountain', 'ocean', 'forest', 'sunset', 'sunrise'],
        'tags': ['风景', '自然', '山景', '海边', '森林', '日出', '日落'],
        'topics': ['春日物语', '自然之美'],
    },
    '人像摄影': {
        'keywords': ['portrait', 'people', 'person', 'face', 'model', 'beauty'],
        'tags': ['人像', '肖像', '美女', '时尚', '艺术'],
        'topics': ['人像艺术'],
    },
    '街头摄影': {
        'keywords': ['street', 'urban', 'city', 'architecture', 'building'],
        'tags': ['街头', '城市', '建筑', '现代', '生活'],
        'topics': ['城市印象'],
    },
    '建筑摄影': {
        'keywords': ['architecture', 'building', 'urban', 'modern', 'structure'],
        'tags': ['建筑', '现代', '结构', '设计', '城市'],
        'topics': ['城市印象'],
    },
    '微距摄影': {
        'keywords': ['macro', 'close-up', 'detail', 'flower', 'insect'],
        'tags': ['微距', '特写', '细节', '花卉', '昆虫'],
        'topics': ['自然之美'],
    },
}


class DatabaseInitializer:
    def __init__(self):
        self.db = SessionLocal()
        self.uploads_dir = CONFIG['UPLOADS_DIR']
        self.uploads_dir.mkdir(exist_ok=True)
        
        # 创建子目录
        for subdir in ['images', 'galleries', 'topics', 'temp']:
            (self.uploads_dir / subdir).mkdir(exist_ok=True)
    
    def __del__(self):
        if hasattr(self, 'db'):
            self.db.close()
    
    def init_database(self):
        """完整的数据库初始化流程"""
        print("🚀 开始数据库初始化...")
        
        try:
            # 1. 创建基础数据
            self._create_base_data()
            
            # 2. 创建用户
            users = self._create_users()
            
            # 3. 下载并创建图片
            self._create_images_with_download(users)
            
            # 4. 创建图集
            self._create_galleries()
            
            # 5. 创建互动数据
            self._create_interactions()
            
            # 6. 更新统计数据
            self._update_statistics()
            
            print("\n🎉 数据库初始化完成！")
            self._print_summary()
            
        except Exception as e:
            print(f"❌ 数据库初始化失败: {e}")
            import traceback
            traceback.print_exc()
            self.db.rollback()
            raise
    
    def _create_base_data(self):
        """创建基础数据：部门、分类、标签、主题"""
        print("\n📁 创建基础数据...")
        
        # 创建部门
        departments = []
        for dept_data in DEMO_DATA['departments']:
            dept = self.db.query(Department).filter(Department.name == dept_data['name']).first()
            if not dept:
                dept = Department(**dept_data)
                self.db.add(dept)
                departments.append(dept)
        
        self.db.commit()
        print(f"  ✅ 创建了 {len(DEMO_DATA['departments'])} 个部门")
        
        # 创建根分类
        root_categories = {}
        for cat_data in DEMO_DATA['root_categories']:
            cat = self.db.query(Category).filter(Category.name == cat_data['name']).first()
            if not cat:
                cat = Category(**cat_data, level=0)
                self.db.add(cat)
                root_categories[cat_data['name']] = cat
        
        self.db.commit()
        
        # 创建子分类
        sub_count = 0
        for parent_name, sub_cats in DEMO_DATA['sub_categories'].items():
            parent_cat = self.db.query(Category).filter(Category.name == parent_name).first()
            if parent_cat:
                for sub_data in sub_cats:
                    sub_cat = self.db.query(Category).filter(Category.name == sub_data['name']).first()
                    if not sub_cat:
                        sub_cat = Category(**sub_data, parent_id=parent_cat.id, level=1)
                        self.db.add(sub_cat)
                        sub_count += 1
        
        self.db.commit()
        print(f"  ✅ 创建了 {len(DEMO_DATA['root_categories'])} 个根分类和 {sub_count} 个子分类")
        
        # 创建标签
        tags = []
        for tag_name in DEMO_DATA['tags']:
            tag = self.db.query(Tag).filter(Tag.name == tag_name).first()
            if not tag:
                tag = Tag(name=tag_name)
                self.db.add(tag)
                tags.append(tag)
        
        self.db.commit()
        print(f"  ✅ 创建了 {len(DEMO_DATA['tags'])} 个标签")
        
        # 创建主题
        topics = []
        for topic_data in DEMO_DATA['topics']:
            topic = self.db.query(Topic).filter(Topic.name == topic_data['name']).first()
            if not topic:
                topic = Topic(**topic_data)
                self.db.add(topic)
                topics.append(topic)
        
        self.db.commit()
        print(f"  ✅ 创建了 {len(DEMO_DATA['topics'])} 个主题")
    
    def _create_users(self) -> List[User]:
        """创建用户"""
        print("\n👥 创建用户...")
        
        users = []
        departments = self.db.query(Department).all()
        
        # 创建管理员
        admin_email = "admin@gallery.com"
        admin = self.db.query(User).filter(User.email == admin_email).first()
        if not admin:
            admin_create = schemas.UserCreate(
                username="admin",
                email=admin_email,
                password="admin123456"
            )
            admin = crud.user.create(self.db, obj_in=admin_create)
            admin.role = UserRole.ADMIN
            admin.is_active = True
            admin.bio = "系统管理员"
            self.db.add(admin)
            users.append(admin)
        
        # 创建预定义用户
        for profile in DEMO_DATA['user_profiles']:
            user = self.db.query(User).filter(User.email == profile['email']).first()
            if not user:
                user_create = schemas.UserCreate(
                    username=profile['username'],
                    email=profile['email'],
                    password="password123"
                )
                user = crud.user.create(self.db, obj_in=user_create)
                user.bio = profile['bio']
                
                # 设置部门
                dept = self.db.query(Department).filter(Department.name == profile['department']).first()
                if dept:
                    user.department_id = dept.id
                
                self.db.add(user)
                users.append(user)
        
        # 创建随机用户
        for i in range(CONFIG['USERS_COUNT'] - len(users)):
            username = f"user_{i+1:03d}"
            email = f"user{i+1:03d}@gallery.com"
            
            user = self.db.query(User).filter(User.email == email).first()
            if not user:
                user_create = schemas.UserCreate(
                    username=username,
                    email=email,
                    password="password123"
                )
                user = crud.user.create(self.db, obj_in=user_create)
                user.bio = f"摄影爱好者，热爱记录生活中的美好瞬间。"
                
                if departments:
                    user.department_id = random.choice(departments).id
                
                self.db.add(user)
                users.append(user)
        
        self.db.commit()
        print(f"  ✅ 创建了 {len(users)} 个用户")
        return users
    
    def _download_image(self, url: str, filepath: Path) -> bool:
        """下载图片"""
        try:
            response = requests.get(url, timeout=CONFIG['DOWNLOAD_TIMEOUT'], stream=True)
            response.raise_for_status()
            
            with open(filepath, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            # 验证图片并调整大小
            try:
                with PILImage.open(filepath) as img:
                    # 转换为RGB（如果需要）
                    if img.mode in ('RGBA', 'LA', 'P'):
                        img = img.convert('RGB')
                    
                    # 调整大小
                    img.thumbnail(CONFIG['MAX_IMAGE_SIZE'], PILImage.Resampling.LANCZOS)
                    
                    # 保存优化后的图片
                    img.save(filepath, 'JPEG', quality=CONFIG['IMAGE_QUALITY'], optimize=True)
                    
                    return True
            except Exception as e:
                print(f"    ⚠️ 图片处理失败: {e}")
                filepath.unlink(missing_ok=True)
                return False
                
        except Exception as e:
            print(f"    ⚠️ 下载失败: {e}")
            return False
    
    def _create_images_with_download(self, users: List[User]):
        """创建图片（从网络下载）"""
        print("\n🖼️  创建图片并下载...")
        
        categories = self.db.query(Category).filter(Category.level == 1).all()  # 只获取子分类
        topics = self.db.query(Topic).all()
        tags = self.db.query(Tag).all()
        
        image_sources = [
            'https://picsum.photos/1200/800',  # Lorem Picsum
            'https://source.unsplash.com/1200x800',  # Unsplash
        ]
        
        total_images = len(users) * CONFIG['IMAGES_PER_USER']
        created_images = 0
        failed_downloads = 0
        
        for user in users:
            print(f"  👤 为用户 {user.username} 创建图片...")
            
            for i in range(CONFIG['IMAGES_PER_USER']):
                try:
                    # 生成唯一文件名
                    timestamp = int(time.time() * 1000000) + random.randint(1, 1000)
                    filename = f"img_{timestamp}_{user.id}_{i}.jpg"
                    filepath = self.uploads_dir / 'images' / filename
                    
                    # 选择图片主题
                    category = random.choice(categories) if categories else None
                    category_name = category.name if category else '其他'
                    
                    # 根据分类选择图片主题
                    theme_data = IMAGE_THEMES.get(category_name, {
                        'keywords': ['nature', 'art', 'photography'],
                        'tags': ['摄影', '艺术'],
                        'topics': ['创意设计'],
                    })
                    
                    # 尝试下载图片
                    download_success = False
                    for source in image_sources:
                        try:
                            # 为Unsplash添加关键词
                            if 'unsplash.com' in source:
                                keyword = random.choice(theme_data['keywords'])
                                url = f"https://source.unsplash.com/1200x800/?{keyword}"
                            else:
                                url = source
                            
                            if self._download_image(url, filepath):
                                download_success = True
                                break
                        except Exception as e:
                            continue
                    
                    if not download_success:
                        print(f"    ⚠️ 无法下载图片，跳过...")
                        failed_downloads += 1
                        continue
                    
                    # 获取图片信息
                    file_size = filepath.stat().st_size
                    file_hash = hashlib.sha256(filepath.read_bytes()).hexdigest()
                    
                    with PILImage.open(filepath) as img:
                        width, height = img.size
                    
                    # 生成标题和描述
                    title_templates = [
                        f"精美的{category_name}作品",
                        f"{category_name}系列 - {random.choice(['春日', '夏日', '秋日', '冬日'])}",
                        f"创意{category_name}",
                        f"{category_name}摄影作品",
                    ]
                    title = random.choice(title_templates)
                    
                    description_templates = [
                        f"这是一幅精心创作的{category_name}作品，展现了独特的艺术魅力。",
                        f"通过巧妙的构图和光影运用，这幅{category_name}作品呈现出令人印象深刻的视觉效果。",
                        f"捕捉到了{category_name}的精髓，每一个细节都经过精心雕琢。",
                        f"这幅作品展示了{category_name}的独特美感和艺术价值。",
                    ]
                    description = random.choice(description_templates)
                    
                    # 创建图片记录
                    image_create = schemas.ImageCreate(
                        title=title,
                        description=description,
                        file_hash=file_hash
                    )
                    
                    # 准备标签数据
                    selected_tags = []
                    if theme_data['tags']:
                        selected_tags = random.sample(
                            theme_data['tags'], 
                            min(random.randint(2, 4), len(theme_data['tags']))
                        )
                    
                    # 准备主题ID
                    topic_id = None
                    if theme_data['topics']:
                        topic_name = random.choice(theme_data['topics'])
                        topic = self.db.query(Topic).filter(Topic.name == topic_name).first()
                        if topic:
                            topic_id = topic.id
                    
                    # 更新图片创建对象以包含主题
                    image_create = schemas.ImageCreate(
                        title=title,
                        description=description,
                        file_hash=file_hash,
                        topic_id=topic_id
                    )
                    
                    # 使用正确的创建方法
                    image = crud.image.create(
                        db=self.db,
                        obj_in=image_create,
                        owner_id=user.id,
                        filename=filename,
                        filepath=str(filepath),
                        tags=selected_tags,
                        category_id=category.id if category else None
                    )
                    
                    # 更新图片详细信息
                    image.file_size = file_size
                    image.file_type = "image/jpeg"
                    image.width = width
                    image.height = height
                    image.ai_status = "completed"
                    image.ai_description = f"这是一幅{category_name}作品，具有很高的艺术价值。"
                    
                    # 随机添加一些交互数据
                    image.views_count = random.randint(10, 500)
                    image.likes_count = random.randint(0, 50)
                    image.bookmarks_count = random.randint(0, 20)
                    
                    self.db.add(image)
                    created_images += 1
                    
                    if created_images % 10 == 0:
                        print(f"    📊 已创建 {created_images}/{total_images} 张图片...")
                        
                except Exception as e:
                    print(f"    ❌ 创建图片失败: {e}")
                    failed_downloads += 1
                    continue
        
        self.db.commit()
        print(f"  ✅ 成功创建 {created_images} 张图片")
        if failed_downloads > 0:
            print(f"  ⚠️ 跳过 {failed_downloads} 张图片（下载失败）")
    
    def _create_galleries(self):
        """创建图集"""
        print("\n📚 创建图集...")
        
        # 获取所有有图片的用户
        users_with_images = self.db.query(User).join(Image).group_by(User.id).all()
        categories = self.db.query(Category).filter(Category.level == 1).all()
        topics = self.db.query(Topic).all()
        
        gallery_count = 0
        
        for user in users_with_images:
            # 获取用户的图片
            user_images = self.db.query(Image).filter(
                Image.owner_id == user.id,
                Image.gallery_id.is_(None)  # 只获取还没有分配到图集的图片
            ).all()
            
            if len(user_images) < 3:
                continue
            
            # 为每个用户创建1-2个图集
            for g in range(random.randint(1, CONFIG['GALLERIES_PER_USER'])):
                try:
                    # 选择图集图片（3-6张）
                    available_images = [img for img in user_images if img.gallery_id is None]
                    if len(available_images) < 3:
                        break
                    
                    gallery_image_count = min(random.randint(3, 6), len(available_images))
                    selected_images = random.sample(available_images, gallery_image_count)
                    
                    # 生成图集标题
                    gallery_titles = [
                        f"{user.username}的摄影集",
                        f"创意作品集 - {random.choice(['春', '夏', '秋', '冬'])}",
                        f"精选作品集",
                        f"个人摄影作品",
                        f"艺术创作合集",
                        f"摄影实验作品",
                    ]
                    
                    title = random.choice(gallery_titles)
                    description = f"这是{user.username}精心策划的作品集，收录了{gallery_image_count}张精选图片。"
                    
                    # 创建图集
                    gallery_create = schemas.GalleryCreate(
                        title=title,
                        description=description
                    )
                    
                    gallery = crud.gallery.create_with_owner(
                        db=self.db,
                        obj_in=gallery_create,
                        owner_id=user.id
                    )
                    
                    # 设置分类和主题
                    if categories:
                        gallery.category_id = random.choice(categories).id
                    
                    if topics:
                        gallery.topic_id = random.choice(topics).id
                    
                    # 添加图片到图集
                    for idx, image in enumerate(selected_images):
                        image.gallery_id = gallery.id
                        if idx == 0:  # 第一张作为封面
                            gallery.cover_image_id = image.id
                    
                    gallery.image_count = len(selected_images)
                    
                    # 添加一些交互数据
                    gallery.views_count = random.randint(20, 300)
                    gallery.likes_count = random.randint(0, 40)
                    gallery.bookmarks_count = random.randint(0, 15)
                    
                    self.db.add(gallery)
                    gallery_count += 1
                    
                except Exception as e:
                    print(f"    ❌ 创建图集失败: {e}")
                    continue
        
        self.db.commit()
        print(f"  ✅ 创建了 {gallery_count} 个图集")
    
    def _create_interactions(self):
        """创建用户互动数据"""
        print("\n💝 创建用户互动数据...")
        
        users = self.db.query(User).all()
        images = self.db.query(Image).all()
        galleries = self.db.query(Gallery).all()
        
        # 创建点赞数据
        like_count = 0
        bookmark_count = 0
        
        for user in users:
            # 获取可以点赞的内容（不包括自己的）
            available_images = [img for img in images if img.owner_id != user.id]
            available_galleries = [gal for gal in galleries if gal.owner_id != user.id]
            
            # 随机点赞一些图片
            if available_images:
                liked_count = min(random.randint(3, 15), len(available_images))
                liked_images = random.sample(available_images, liked_count)
                for image in liked_images:
                    # 检查是否已经点赞过，避免重复
                    if image not in user.liked_contents:
                        user.liked_contents.append(image)
                        like_count += 1
            
            # 随机收藏一些图片和图集
            available_contents = available_images + available_galleries
            if available_contents:
                bookmark_count_per_user = min(random.randint(1, 8), len(available_contents))
                bookmarked_items = random.sample(available_contents, bookmark_count_per_user)
                for item in bookmarked_items:
                    # 检查是否已经收藏过，避免重复
                    if item not in user.bookmarked_contents:
                        user.bookmarked_contents.append(item)
                        bookmark_count += 1
        
        self.db.commit()
        print(f"  ✅ 创建了 {like_count} 个点赞和 {bookmark_count} 个收藏")
    
    def _update_statistics(self):
        """更新统计数据"""
        print("\n📊 更新统计数据...")
        
        # 更新图片统计计数
        images = self.db.query(Image).filter(Image.id.isnot(None)).all()
        for image in images:
            image.likes_count = len(image.liked_by_users)
            image.bookmarks_count = len(image.bookmarked_by_users)
        
        # 更新图集统计计数
        galleries = self.db.query(Gallery).filter(Gallery.id.isnot(None)).all()
        for gallery in galleries:
            gallery.likes_count = len(gallery.liked_by_users)
            gallery.bookmarks_count = len(gallery.bookmarked_by_users)
        
        self.db.commit()
        print("  ✅ 统计数据更新完成")
    
    def _print_summary(self):
        """打印初始化总结"""
        print("\n" + "="*60)
        print("🎉 数据库初始化完成!")
        print("="*60)
        
        # 统计数据
        stats = {}
        stats['users'] = self.db.query(User).count()
        stats['departments'] = self.db.query(Department).count()
        stats['categories'] = self.db.query(Category).count()
        stats['tags'] = self.db.query(Tag).count()
        stats['topics'] = self.db.query(Topic).count()
        stats['images'] = self.db.query(Image).count()
        stats['galleries'] = self.db.query(Gallery).count()
        
        # 打印统计信息
        print(f"👥 用户数量: {stats['users']}")
        print(f"🏢 部门数量: {stats['departments']}")
        print(f"📁 分类数量: {stats['categories']}")
        print(f"🏷️  标签数量: {stats['tags']}")
        print(f"🎯 主题数量: {stats['topics']}")
        print(f"🖼️  图片数量: {stats['images']}")
        print(f"📚 图集数量: {stats['galleries']}")
        
        print("\n🔐 登录信息:")
        print("管理员: admin@gallery.com / admin123456")
        print("用户: user001@gallery.com ~ user{:03d}@gallery.com / password123".format(CONFIG['USERS_COUNT']))
        print("预设用户: zhang@gallery.com, li@gallery.com, wang@gallery.com 等 / password123")
        
        print("\n📁 上传目录:")
        print(f"图片目录: {self.uploads_dir / 'images'}")
        print(f"图集目录: {self.uploads_dir / 'galleries'}")
        
        print("="*60)


def main():
    """主函数"""
    initializer = DatabaseInitializer()
    initializer.init_database()


if __name__ == "__main__":
    main() 