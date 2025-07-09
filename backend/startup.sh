#!/bin/bash

# Startup script to ensure entrypoint.sh has correct permissions
# This script fixes permission issues when volume mounts override container permissions

echo "🔧 检查并修复 entrypoint.sh 权限..."

# Fix permissions silently
chmod +x /app/entrypoint.sh 2>/dev/null || true

# If entrypoint.sh is still not executable, restore from backup
if [ ! -x /app/entrypoint.sh ]; then
    echo "⚠️  修复 entrypoint.sh 权限..."
    if [ -f /app/entrypoint_backup.sh ]; then
        cp /app/entrypoint_backup.sh /app/entrypoint.sh
        chmod +x /app/entrypoint.sh
        echo "✅ 权限已从备份恢复"
    else
        echo "❌ 无法找到备份文件，尝试强制修复..."
        chmod +x /app/entrypoint.sh
    fi
fi

# Final check
if [ -x /app/entrypoint.sh ]; then
    echo "✅ entrypoint.sh 权限正常"
else
    echo "❌ entrypoint.sh 权限修复失败"
    exit 1
fi

# Execute the entrypoint script with all arguments
echo "🚀 启动应用..."
exec /app/entrypoint.sh "$@" 