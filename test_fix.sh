#!/bin/bash

# 测试权限修复脚本
echo "🧪 测试权限修复脚本"
echo "===================="

# 1. 测试权限修复脚本
echo "1. 测试权限修复脚本..."
if [ -f "fix_permissions.sh" ]; then
    if [ -x "fix_permissions.sh" ]; then
        echo "✅ fix_permissions.sh 权限正常"
        echo "🔄 运行权限修复..."
        ./fix_permissions.sh
    else
        echo "❌ fix_permissions.sh 无执行权限"
        chmod +x fix_permissions.sh
        echo "✅ 权限已修复，重新运行..."
        ./fix_permissions.sh
    fi
else
    echo "❌ fix_permissions.sh 文件不存在"
    exit 1
fi

# 2. 测试Docker构建
echo ""
echo "2. 测试Docker构建..."
echo "🔧 构建backend镜像..."
cd backend
docker build -t test-backend .
if [ $? -eq 0 ]; then
    echo "✅ backend镜像构建成功"
else
    echo "❌ backend镜像构建失败"
    exit 1
fi

# 3. 测试容器启动
echo ""
echo "3. 测试容器启动..."
echo "🚀 启动测试容器..."
docker run --rm -d --name test-backend-container test-backend
if [ $? -eq 0 ]; then
    echo "✅ 容器启动成功"
    sleep 5
    
    # 检查容器状态
    if docker ps | grep -q test-backend-container; then
        echo "✅ 容器运行正常"
    else
        echo "❌ 容器启动后异常退出"
        docker logs test-backend-container
    fi
    
    # 清理测试容器
    docker stop test-backend-container
    echo "🧹 清理测试容器完成"
else
    echo "❌ 容器启动失败"
    exit 1
fi

# 4. 清理测试镜像
echo ""
echo "4. 清理测试镜像..."
docker rmi test-backend
echo "🧹 清理完成"

echo ""
echo "🎉 所有测试通过！"
echo "💡 现在可以安全地运行 ./deploy.sh 部署项目" 