#!/bin/bash

# 数据库初始化验证脚本
# 检查数据库是否正确初始化

echo "🧪 Gallery 数据库初始化验证脚本"
echo "================================"

# 检查后端容器是否运行
if ! docker ps | grep -q "gallery_backend"; then
    echo "❌ 后端容器未运行"
    echo "💡 请先运行: ./deploy_linux.sh"
    exit 1
fi

echo "📊 正在检查数据库状态..."

# 执行数据验证
docker exec gallery_backend python -c "
import sys
from app.db.session import SessionLocal
from app.models.user import User
from app.models.image import Image
from app.models.gallery import Gallery
from app.models.category import Category
from app.models.topic import Topic
from app.models.tag import Tag
from app.models.department import Department
import os

def check_database():
    print('🔍 连接数据库...')
    db = SessionLocal()
    
    try:
        # 统计数据
        stats = {
            'users': db.query(User).count(),
            'images': db.query(Image).count(),
            'galleries': db.query(Gallery).count(),
            'categories': db.query(Category).count(),
            'topics': db.query(Topic).count(),
            'tags': db.query(Tag).count(),
            'departments': db.query(Department).count(),
        }
        
        print('📈 数据统计:')
        for key, value in stats.items():
            status = '✅' if value > 0 else '❌'
            print(f'  {status} {key}: {value}')
        
        # 检查管理员用户
        admin = db.query(User).filter(User.email == 'admin@gallery.com').first()
        if admin:
            print('✅ 管理员账户存在')
        else:
            print('❌ 管理员账户不存在')
            
        # 检查示例用户
        sample_users = db.query(User).filter(User.email.like('%@gallery.com')).count()
        print(f'✅ 示例用户数量: {sample_users}')
        
        # 检查上传目录
        uploads_dir = '/app/uploads'
        if os.path.exists(uploads_dir):
            images_dir = os.path.join(uploads_dir, 'images')
            if os.path.exists(images_dir):
                image_files = len([f for f in os.listdir(images_dir) if f.endswith('.jpg')])
                print(f'✅ 图片文件数量: {image_files}')
            else:
                print('❌ 图片目录不存在')
        else:
            print('❌ 上传目录不存在')
            
        # 检查图片和图集的关联
        images_with_gallery = db.query(Image).filter(Image.gallery_id.isnot(None)).count()
        print(f'✅ 已分配到图集的图片: {images_with_gallery}')
        
        # 检查分类层级
        root_categories = db.query(Category).filter(Category.level == 0).count()
        sub_categories = db.query(Category).filter(Category.level == 1).count()
        print(f'✅ 根分类: {root_categories}, 子分类: {sub_categories}')
        
        # 总体评估
        critical_counts = [stats['users'], stats['images'], stats['galleries'], stats['categories']]
        if all(count > 0 for count in critical_counts) and admin:
            print('')
            print('🎉 数据库初始化验证通过！')
            print('💡 您可以使用以下账户登录:')
            print('   管理员: admin@gallery.com / admin123456')
            print('   用户: user001@gallery.com / password123')
            return True
        else:
            print('')
            print('❌ 数据库初始化不完整')
            print('💡 建议重新运行初始化: ./manual_init_database.sh')
            return False
            
    except Exception as e:
        print(f'❌ 数据库检查失败: {e}')
        return False
    finally:
        db.close()

if __name__ == '__main__':
    success = check_database()
    sys.exit(0 if success else 1)
"

# 检查返回值
if [ $? -eq 0 ]; then
    echo ""
    echo "🌐 建议测试以下功能:"
    echo "1. 访问前端页面，查看图片和图集显示"
    echo "2. 登录不同用户账户"
    echo "3. 测试图片上传功能"
    echo "4. 测试图集创建和编辑"
    echo ""
    echo "📊 查看实时日志:"
    echo "   docker logs -f gallery_backend"
    echo "   docker logs -f gallery_frontend"
else
    echo ""
    echo "🔧 问题排查建议:"
    echo "1. 检查容器状态: docker ps"
    echo "2. 查看后端日志: docker logs gallery_backend"
    echo "3. 重新初始化: ./manual_init_database.sh"
    echo "4. 完全重新部署: ./deploy_linux.sh"
fi 