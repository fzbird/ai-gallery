#!/bin/bash

# Gallery 权限修复脚本
# 用于修复在不同操作系统间git clone时可能出现的文件权限问题

echo "🔧 Gallery 权限修复脚本"
echo "=========================="

# 检查是否在项目根目录
if [ ! -f "docker-compose.yml" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    echo "💡 使用方法：./fix_permissions.sh"
    exit 1
fi

echo "📍 当前目录: $(pwd)"

# 修复 entrypoint.sh 权限
echo ""
echo "🔍 检查 entrypoint.sh 权限..."
if [ -f "backend/entrypoint.sh" ]; then
    # 显示当前权限
    current_perms=$(ls -l backend/entrypoint.sh)
    echo "当前权限: $current_perms"
    
    # 修复权限
    chmod +x backend/entrypoint.sh
    
    # 验证修复结果
    if [ -x "backend/entrypoint.sh" ]; then
        echo "✅ entrypoint.sh 权限已修复"
    else
        echo "❌ 权限修复失败"
        exit 1
    fi
else
    echo "❌ 找不到 backend/entrypoint.sh 文件"
    exit 1
fi

# 修复换行符问题（Windows/Linux兼容）
echo ""
echo "🔄 修复换行符格式..."
if command -v dos2unix >/dev/null 2>&1; then
    dos2unix backend/entrypoint.sh 2>/dev/null
    echo "✅ 使用 dos2unix 修复换行符"
elif command -v sed >/dev/null 2>&1; then
    sed -i 's/\r$//' backend/entrypoint.sh 2>/dev/null
    echo "✅ 使用 sed 修复换行符"
else
    echo "⚠️  未找到 dos2unix 或 sed，跳过换行符修复"
fi

# 修复 deploy.sh 权限
echo ""
echo "🔍 检查 deploy.sh 权限..."
if [ -f "deploy.sh" ]; then
    chmod +x deploy.sh
    if [ -x "deploy.sh" ]; then
        echo "✅ deploy.sh 权限已修复"
    else
        echo "❌ deploy.sh 权限修复失败"
    fi
else
    echo "⚠️  未找到 deploy.sh 文件"
fi

# 修复 deploy_linux.sh 权限
if [ -f "deploy_linux.sh" ]; then
    chmod +x deploy_linux.sh
    if [ -x "deploy_linux.sh" ]; then
        echo "✅ deploy_linux.sh 权限已修复"
    else
        echo "❌ deploy_linux.sh 权限修复失败"
    fi
fi

# 显示最终状态
echo ""
echo "📋 最终权限状态:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -la backend/entrypoint.sh
[ -f "deploy.sh" ] && ls -la deploy.sh
[ -f "deploy_linux.sh" ] && ls -la deploy_linux.sh

echo ""
echo "🎉 权限修复完成！"
echo "💡 现在可以运行 ./deploy.sh 来部署项目"
echo ""
echo "📚 如果仍有问题，请检查："
echo "   1. Docker是否正常运行"
echo "   2. 是否有足够的磁盘空间"
echo "   3. 网络连接是否正常" 