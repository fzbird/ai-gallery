#!/bin/bash

# Gallery 自动部署脚本
# 解决跨服务器访问问题

echo "🚀 Gallery 自动部署脚本"
echo "=========================="

# 获取服务器IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "📍 检测到服务器IP: $SERVER_IP"

# 询问用户选择部署方式
echo ""
echo "请选择部署方式："
echo "1. 反向代理模式（推荐，生产环境）"
echo "2. 环境变量模式（开发/测试环境）"
echo "3. 自定义域名模式"
echo ""
read -p "请输入选择 (1-3): " choice

case $choice in
    1)
        echo "✅ 选择：反向代理模式"
        echo "🔧 配置反向代理..."
        
        # 确保使用标准端口
        if ! grep -q "80:80" docker-compose.yml; then
            echo "⚠️  添加标准端口映射到 docker-compose.yml"
            echo "请手动添加 '- \"80:80\"' 到前端端口配置"
        fi
        
        # 创建生产环境配置（使用相对路径）
        echo "# 反向代理模式配置" > frontend/.env.production
        echo "VITE_API_URL=" >> frontend/.env.production
        
        echo "📝 配置完成！"
        echo "🌐 访问地址: http://$SERVER_IP/"
        echo "🔗 API地址: http://$SERVER_IP/api/"
        ;;
        
    2)
        echo "✅ 选择：环境变量模式"
        echo "🔧 配置环境变量..."
        
        # 创建环境变量配置
        echo "# 环境变量模式配置" > frontend/.env.production
        echo "VITE_API_URL=http://$SERVER_IP:8000" >> frontend/.env.production
        
        echo "📝 配置完成！"
        echo "🌐 前端访问地址: http://$SERVER_IP:3300/"
        echo "🔗 后端API地址: http://$SERVER_IP:8000/"
        ;;
        
    3)
        echo "✅ 选择：自定义域名模式"
        read -p "🌐 请输入您的域名（如: example.com）: " domain
        
        if [ -z "$domain" ]; then
            echo "❌ 域名不能为空！"
            exit 1
        fi
        
        echo "🔧 配置自定义域名..."
        
        # 询问是否使用HTTPS
        read -p "🔒 是否使用HTTPS？(y/n): " use_https
        
        if [[ $use_https =~ ^[Yy]$ ]]; then
            echo "# 自定义域名配置 (HTTPS)" > frontend/.env.production
            echo "VITE_API_URL=https://$domain:8000" >> frontend/.env.production
            echo "🌐 访问地址: https://$domain:3300/"
        else
            echo "# 自定义域名配置 (HTTP)" > frontend/.env.production
            echo "VITE_API_URL=http://$domain:8000" >> frontend/.env.production
            echo "🌐 访问地址: http://$domain:3300/"
        fi
        
        echo "📝 配置完成！"
        echo "⚠️  请确保域名已正确解析到服务器IP: $SERVER_IP"
        ;;
        
    *)
        echo "❌ 无效选择！"
        exit 1
        ;;
esac

echo ""
echo "🏗️  开始构建和部署..."

# 停止现有容器
echo "⏹️  停止现有容器..."
docker-compose down

# 重新构建和启动
echo "🔄 重新构建容器..."
docker-compose up -d --build

# 等待容器启动
echo "⏳ 等待容器启动..."
sleep 10

# 检查容器状态
echo "📊 检查容器状态..."
docker ps --filter "name=gallery" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎉 部署完成！"
echo ""
echo "📋 访问信息："

case $choice in
    1)
        echo "🌐 前端: http://$SERVER_IP/"
        echo "🔗 API文档: http://$SERVER_IP/api/v1/docs"
        echo "📊 后端状态: http://$SERVER_IP/api/v1/health"
        ;;
    2)
        echo "🌐 前端: http://$SERVER_IP:3300/"
        echo "🔗 API文档: http://$SERVER_IP:8000/docs"
        echo "📊 后端状态: http://$SERVER_IP:8000/api/v1/health"
        ;;
    3)
        if [[ $use_https =~ ^[Yy]$ ]]; then
            echo "🌐 前端: https://$domain:3300/"
            echo "🔗 API文档: https://$domain:8000/docs"
        else
            echo "🌐 前端: http://$domain:3300/"
            echo "🔗 API文档: http://$domain:8000/docs"
        fi
        ;;
esac

echo ""
echo "🛠️  故障排除："
echo "- 查看日志: docker logs gallery_frontend"
echo "- 查看日志: docker logs gallery_backend"
echo "- 重新部署: ./deploy.sh"
echo ""
echo "📖 详细说明请查看: DEPLOYMENT_GUIDE.md"

# 测试连接
echo ""
echo "🧪 测试连接..."

case $choice in
    1)
        if curl -s "http://$SERVER_IP/api/v1/docs" > /dev/null; then
            echo "✅ 反向代理连接正常"
        else
            echo "❌ 反向代理连接失败，请检查配置"
        fi
        ;;
    2)
        if curl -s "http://$SERVER_IP:8000/docs" > /dev/null; then
            echo "✅ 后端连接正常"
        else
            echo "❌ 后端连接失败，请检查配置"
        fi
        ;;
esac

echo ""
echo "🎯 部署脚本执行完成！" 