#!/bin/sh

# Go to the app directory
cd /app

# Wait for the database to be ready
echo "⏳ 等待数据库连接..."
sleep 15

# Run database migrations
echo "🔧 运行数据库迁移..."
alembic upgrade head

# Check if database initialization is needed
echo "🔍 检查是否需要初始化数据..."
python -c "
from app.db.session import SessionLocal
from app.models.user import User
db = SessionLocal()
try:
    user_count = db.query(User).count()
    if user_count == 0:
        print('需要初始化数据库')
        exit(0)
    else:
        print(f'数据库已有 {user_count} 个用户，跳过初始化')
        exit(1)
except Exception as e:
    print('数据库连接失败，跳过初始化')
    exit(1)
finally:
    db.close()
"

# Run database initialization if needed
if [ $? -eq 0 ]; then
    echo "🚀 开始初始化数据库..."
    python init_database_with_demo.py
    if [ $? -eq 0 ]; then
        echo "✅ 数据库初始化完成"
    else
        echo "❌ 数据库初始化失败，但继续启动服务"
    fi
else
    echo "📊 数据库已初始化，直接启动服务"
fi

echo "🌟 启动应用服务..."
# Start the application
uvicorn app.main:app --host 0.0.0.0 --port 8000 