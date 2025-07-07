#!/bin/bash

# 手动数据库初始化脚本
# 用于在已部署的系统中手动初始化数据库

echo "🗃️  Gallery 数据库手动初始化脚本"
echo "================================="

# 检查Docker容器是否运行
if ! docker ps | grep -q "gallery_backend"; then
    echo "❌ 后端容器未运行，请先启动服务"
    echo "💡 运行: ./deploy_linux.sh 或 docker-compose up -d"
    exit 1
fi

echo "📋 当前容器状态:"
docker ps --filter "name=gallery" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "⚠️  警告: 此操作将初始化数据库，可能会影响现有数据"
read -p "🤔 确认继续？(y/n): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ 操作已取消"
    exit 0
fi

echo ""
echo "🔧 选择初始化模式:"
echo "1. 🔄 完全重新初始化（清空并重建所有数据）"
echo "2. 📊 仅添加示例数据（保留现有用户）"
echo "3. 🖼️  仅重新下载图片（保留其他数据）"
echo ""
read -p "请选择模式 (1-3): " mode

case $mode in
    1)
        echo "⚠️  完全重新初始化将删除所有现有数据！"
        read -p "🚨 再次确认？(yes/no): " final_confirm
        if [[ $final_confirm != "yes" ]]; then
            echo "❌ 操作已取消"
            exit 0
        fi
        
        echo "🗑️  清空数据库..."
        docker exec gallery_backend python -c "
from app.db.session import SessionLocal
from app.models import *
from app.db.base import Base
from sqlalchemy import text
import shutil
import os

# 删除上传文件
uploads_dir = '/app/uploads'
if os.path.exists(uploads_dir):
    for item in os.listdir(uploads_dir):
        item_path = os.path.join(uploads_dir, item)
        if os.path.isdir(item_path):
            shutil.rmtree(item_path)
        else:
            os.remove(item_path)
    print('已清空上传目录')

# 清空数据库
db = SessionLocal()
try:
    # 删除所有表数据（保留表结构）
    meta = Base.metadata
    for table in reversed(meta.sorted_tables):
        db.execute(text(f'DELETE FROM {table.name}'))
    db.commit()
    print('已清空数据库表')
except Exception as e:
    print(f'清空数据库失败: {e}')
    db.rollback()
finally:
    db.close()
"
        
        echo "🚀 运行完整初始化..."
        docker exec gallery_backend python init_database_with_demo.py
        ;;
        
    2)
        echo "📊 添加示例数据..."
        docker exec gallery_backend python -c "
# 检查现有数据
from app.db.session import SessionLocal
from app.models.user import User
from app.models.image import Image
from app.models.gallery import Gallery

db = SessionLocal()
try:
    user_count = db.query(User).count()
    image_count = db.query(Image).count()
    gallery_count = db.query(Gallery).count()
    
    print(f'当前数据: {user_count} 用户, {image_count} 图片, {gallery_count} 图集')
    
    if image_count > 0:
        print('检测到现有图片数据，建议选择模式1进行完全重置')
        exit(1)
    
except Exception as e:
    print(f'检查数据失败: {e}')
    exit(1)
finally:
    db.close()
"
        
        if [ $? -eq 0 ]; then
            docker exec gallery_backend python init_database_with_demo.py
        else
            echo "❌ 检测到现有数据，请选择模式1"
            exit 1
        fi
        ;;
        
    3)
        echo "🖼️  重新下载图片..."
        docker exec gallery_backend python -c "
import os
import shutil
from pathlib import Path

# 删除现有图片文件
uploads_dir = Path('/app/uploads')
images_dir = uploads_dir / 'images'

if images_dir.exists():
    shutil.rmtree(images_dir)
    images_dir.mkdir(exist_ok=True)
    print('已清空图片目录')

# 更新数据库中的图片文件路径
from app.db.session import SessionLocal
from app.models.image import Image

db = SessionLocal()
try:
    images = db.query(Image).all()
    for image in images:
        # 标记需要重新下载
        image.filepath = ''
        image.ai_status = 'pending'
    db.commit()
    print(f'已标记 {len(images)} 张图片需要重新下载')
except Exception as e:
    print(f'更新数据库失败: {e}')
    db.rollback()
finally:
    db.close()
"
        
        # 这里可以添加重新下载图片的逻辑
        echo "⚠️  图片重新下载功能需要重启容器来触发"
        echo "💡 建议运行: docker restart gallery_backend"
        ;;
        
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 初始化操作完成！"

# 检查结果
echo "📊 检查初始化结果..."
docker exec gallery_backend python -c "
from app.db.session import SessionLocal
from app.models.user import User
from app.models.image import Image
from app.models.gallery import Gallery
from app.models.category import Category
from app.models.topic import Topic

db = SessionLocal()
try:
    stats = {
        'users': db.query(User).count(),
        'images': db.query(Image).count(),
        'galleries': db.query(Gallery).count(),
        'categories': db.query(Category).count(),
        'topics': db.query(Topic).count(),
    }
    
    print('当前数据统计:')
    for key, value in stats.items():
        print(f'  {key}: {value}')
        
except Exception as e:
    print(f'统计失败: {e}')
finally:
    db.close()
"

echo ""
echo "🎉 数据库初始化完成！"
echo "🌐 您现在可以访问系统查看数据了" 