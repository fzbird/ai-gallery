#!/bin/bash

# Gallery Linux 部署脚本 - Ubuntu Server 24.04.2 专用版本
# 解决权限问题和Linux环境特有的配置需求

echo "🐧 Gallery Linux 部署脚本 v1.0"
echo "🎯 专为 Ubuntu Server 24.04.2 优化"
echo "======================================"

# 检查是否以root用户运行
check_root_permission() {
    if [ "$EUID" -eq 0 ]; then
        echo "⚠️  检测到root用户运行"
        read -p "🔐 是否继续使用root用户部署？(不推荐，建议使用普通用户) (y/n): " continue_root
        if [[ ! $continue_root =~ ^[Yy]$ ]]; then
            echo "❌ 请使用普通用户运行此脚本"
            echo "💡 建议: sudo usermod -aG docker \$USER && newgrp docker"
            exit 1
        fi
    fi
}

# 检查系统要求
check_system_requirements() {
    echo "🔍 检查系统要求..."
    
    # 检查操作系统
    if [[ ! -f /etc/os-release ]]; then
        echo "❌ 无法检测操作系统版本"
        exit 1
    fi
    
    . /etc/os-release
    echo "📋 操作系统: $NAME $VERSION"
    
    # 检查Ubuntu版本
    if [[ "$NAME" =~ "Ubuntu" ]]; then
        if [[ "$VERSION_ID" < "20.04" ]]; then
            echo "⚠️  Ubuntu版本较低，建议使用20.04+，当前版本: $VERSION_ID"
        else
            echo "✅ Ubuntu版本兼容: $VERSION_ID"
        fi
    else
        echo "⚠️  未检测到Ubuntu系统，脚本主要针对Ubuntu优化"
    fi
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker未安装"
        echo "📖 安装指南: https://docs.docker.com/engine/install/ubuntu/"
        exit 1
    fi
    
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    echo "✅ Docker版本: $DOCKER_VERSION"
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose未安装"
        echo "📖 安装Docker Compose: sudo apt install docker-compose-plugin"
        exit 1
    fi
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        COMPOSE_COMMAND="docker-compose"
    else
        COMPOSE_VERSION=$(docker compose version | cut -d' ' -f3)
        COMPOSE_COMMAND="docker compose"
    fi
    echo "✅ Docker Compose版本: $COMPOSE_VERSION"
    echo "🔧 使用命令: $COMPOSE_COMMAND"
    
    # 检查Docker daemon状态
    if ! docker info &> /dev/null; then
        echo "❌ Docker daemon未运行或当前用户无权限访问"
        echo "💡 解决方案:"
        echo "   1. 启动Docker: sudo systemctl start docker"
        echo "   2. 添加用户到docker组: sudo usermod -aG docker \$USER"
        echo "   3. 重新登录或执行: newgrp docker"
        exit 1
    fi
    
    echo "✅ Docker daemon运行正常"
}

# 获取服务器IP - Linux优化版本
get_server_ip() {
    local ip=""
    
    # 方法1: 使用 ip route (Linux推荐)
    if command -v ip >/dev/null 2>&1; then
        ip=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' | head -1 2>/dev/null)
    fi
    
    # 方法2: 使用 hostname -I (Linux标准)
    if [ -z "$ip" ] && command -v hostname >/dev/null 2>&1; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}' 2>/dev/null)
    fi
    
    # 方法3: 检查网络接口
    if [ -z "$ip" ]; then
        # 获取默认路由接口
        local interface=$(ip route | awk '/default/ {print $5}' | head -1)
        if [ -n "$interface" ]; then
            ip=$(ip addr show "$interface" 2>/dev/null | grep -E "inet [0-9]" | head -1 | awk '{print $2}' | cut -d/ -f1)
        fi
    fi
    
    # 方法4: 使用 ifconfig (备选)
    if [ -z "$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig 2>/dev/null | grep -E "inet.*192\.|inet.*10\.|inet.*172\." | head -1 | awk '{print $2}' | cut -d: -f2 2>/dev/null)
    fi
    
    # 方法5: 外部IP检测 (fallback)
    if [ -z "$ip" ]; then
        ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null || echo "localhost")
    fi
    
    echo "$ip"
}

# 修复文件权限和行结束符
fix_file_permissions() {
    echo "🔧 修复文件权限和格式..."
    
    # 修复entrypoint.sh权限和格式
    if [ -f "backend/entrypoint.sh" ]; then
        echo "📝 修复 backend/entrypoint.sh"
        
        # 转换行结束符（从CRLF到LF）
        if command -v dos2unix >/dev/null 2>&1; then
            dos2unix backend/entrypoint.sh 2>/dev/null || true
        else
            # 手动转换
            sed -i 's/\r$//' backend/entrypoint.sh 2>/dev/null || true
        fi
        
        # 设置执行权限
        chmod +x backend/entrypoint.sh
        echo "✅ entrypoint.sh权限已修复"
    else
        echo "❌ backend/entrypoint.sh文件不存在"
        exit 1
    fi
    
    # 修复其他可能的脚本文件
    find . -name "*.sh" -type f -exec chmod +x {} \;
    echo "✅ 所有shell脚本权限已修复"
    
    # 确保deploy.sh也有执行权限
    chmod +x deploy_linux.sh 2>/dev/null || true
}

# 清理Docker环境
cleanup_docker() {
    echo "🧹 清理Docker环境..."
    
    # 停止相关容器
    $COMPOSE_COMMAND down 2>/dev/null || true
    $COMPOSE_COMMAND -f docker-compose.dev.yml down 2>/dev/null || true
    $COMPOSE_COMMAND -f docker-compose.prod.yml down 2>/dev/null || true
    
    # 删除相关镜像（可选）
    read -p "🗑️  是否删除旧的Docker镜像以确保干净构建？(y/n): " cleanup_images
    if [[ $cleanup_images =~ ^[Yy]$ ]]; then
        echo "🗑️  删除旧镜像..."
        docker rmi gallery-frontend gallery-backend 2>/dev/null || true
        docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
        echo "✅ 旧镜像已清理"
    fi
    
    # 清理未使用的网络和卷
    docker system prune -f --volumes 2>/dev/null || true
    echo "✅ Docker环境已清理"
}

# 构建和修复Docker镜像
build_with_permission_fix() {
    echo "🔨 构建Docker镜像..."
    
    # 构建后端镜像并修复权限
    echo "🐍 构建后端镜像..."
    docker build -t gallery-backend ./backend
    
    if [ $? -ne 0 ]; then
        echo "❌ 后端镜像构建失败"
        exit 1
    fi
    
    # 创建临时容器来检查和修复权限
    echo "🔧 检查和修复容器内权限..."
    docker run --rm -v $(pwd)/backend:/host-backend gallery-backend sh -c "
        echo '检查 entrypoint.sh 权限:'
        ls -la /app/entrypoint.sh
        
        # 确保权限正确
        chmod +x /app/entrypoint.sh
        
        echo '修复后的权限:'
        ls -la /app/entrypoint.sh
        
        # 测试脚本可执行性
        if [ -x /app/entrypoint.sh ]; then
            echo '✅ entrypoint.sh 可执行'
        else
            echo '❌ entrypoint.sh 仍然不可执行'
            exit 1
        fi
    "
    
    if [ $? -ne 0 ]; then
        echo "❌ 权限修复失败"
        exit 1
    fi
    
    echo "✅ 后端镜像构建完成"
    
    # 构建前端镜像
    echo "🌐 构建前端镜像..."
    docker build -t gallery-frontend ./frontend
    
    if [ $? -ne 0 ]; then
        echo "❌ 前端镜像构建失败"
        exit 1
    fi
    
    echo "✅ 前端镜像构建完成"
}

# 主函数
main() {
    # 系统检查
    check_root_permission
    check_system_requirements
    
    # 获取服务器IP
    SERVER_IP=$(get_server_ip)
    echo "📍 检测到服务器IP: $SERVER_IP"
    
    # 让用户确认或手动输入IP
    echo ""
    read -p "🔍 IP地址是否正确？如不正确请输入实际IP地址（回车确认当前IP）: " user_ip
    if [ -n "$user_ip" ]; then
        SERVER_IP="$user_ip"
        echo "✅ 更新服务器IP为: $SERVER_IP"
    fi
    
    # 选择运行环境
    echo ""
    echo "🏗️  选择运行环境"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. 🔧 开发环境    - 仅3300端口，避免端口冲突，适合本地开发"
    echo "2. 🌐 生产环境    - 仅80端口，标准HTTP访问，适合生产部署"
    echo "3. 🔄 灵活环境    - 双端口支持，同时提供3300和80端口访问"
    echo ""
    read -p "请选择环境 (1-3): " env_choice
    
    # 设置docker-compose文件
    case $env_choice in
        1)
            COMPOSE_FILE="docker-compose.dev.yml"
            ENV_TYPE="开发环境"
            PRIMARY_PORT="3300"
            echo "✅ 选择：$ENV_TYPE (仅$PRIMARY_PORT端口)"
            ;;
        2)
            COMPOSE_FILE="docker-compose.prod.yml"
            ENV_TYPE="生产环境"
            PRIMARY_PORT="80"
            echo "✅ 选择：$ENV_TYPE (仅$PRIMARY_PORT端口)"
            ;;
        3)
            COMPOSE_FILE="docker-compose.yml"
            ENV_TYPE="灵活环境"
            PRIMARY_PORT="80"
            SECONDARY_PORT="3300"
            echo "✅ 选择：$ENV_TYPE (双端口: $PRIMARY_PORT + $SECONDARY_PORT)"
            ;;
        *)
            echo "❌ 无效选择！"
            exit 1
            ;;
    esac
    
    # 选择API配置方式
    echo ""
    echo "🔗 选择API配置方式"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. 🔄 反向代理模式 - 通过nginx代理，前端无需指定后端地址（推荐）"
    echo "2. 🌍 环境变量模式 - 明确指定后端API地址"
    echo ""
    read -p "请选择API配置方式 (1-2): " api_choice
    
    # 配置前端环境变量
    case $api_choice in
        1)
            CONFIG_TYPE="反向代理模式"
            echo "✅ 选择：$CONFIG_TYPE"
            
            # 创建生产环境配置
            cat > frontend/.env.production << EOF
# 反向代理模式配置 - API请求通过nginx代理
VITE_API_URL=
EOF
            ;;
        2)
            CONFIG_TYPE="环境变量模式"
            echo "✅ 选择：$CONFIG_TYPE"
            
            # 创建环境变量配置
            cat > frontend/.env.production << EOF
# 环境变量模式配置 - 明确指定后端API地址
VITE_API_URL=http://$SERVER_IP:8000
EOF
            ;;
        *)
            echo "❌ 无效选择！"
            exit 1
            ;;
    esac
    
    # 显示配置总结
    echo ""
    echo "📋 部署配置总结"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🏗️  运行环境: $ENV_TYPE"
    echo "🔗 API配置: $CONFIG_TYPE"
    echo "📁 配置文件: $COMPOSE_FILE"
    echo "🖥️  服务器IP: $SERVER_IP"
    echo "🐳 Docker Compose: $COMPOSE_COMMAND"
    echo ""
    
    read -p "确认开始部署？(y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "❌ 部署已取消"
        exit 0
    fi
    
    echo ""
    echo "🚀 开始部署..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 修复文件权限
    fix_file_permissions
    
    # 清理Docker环境
    cleanup_docker
    
    # 更新后端环境配置
    echo "🔧 配置后端环境..."
    
    # 确保.env文件存在
    if [ ! -f "backend/.env" ]; then
        if [ -f "backend/env.template" ]; then
            cp backend/env.template backend/.env
            echo "✅ 已从模板创建.env文件"
        else
            echo "❌ 找不到backend/env.template文件"
            exit 1
        fi
    fi
    
    # 配置更新函数
    update_env_value() {
        local key=$1
        local value=$2
        local file="backend/.env"
        
        # 转义特殊字符
        escaped_value=$(echo "$value" | sed 's/[[\.*^$()+?{|]/\\&/g')
        
        # 如果key存在，更新；否则添加
        if grep -q "^$key=" "$file"; then
            sed -i "s|^$key=.*|$key=$escaped_value|" "$file"
            echo "📝 已更新 $key"
        else
            echo "$key=$value" >> "$file"
            echo "📝 已添加 $key"
        fi
    }
    
    # 基础CORS配置
    BASE_CORS_ORIGINS="http://localhost:3300,http://localhost:3301,http://127.0.0.1:3300,http://127.0.0.1:3301"
    CORS_ORIGINS="$BASE_CORS_ORIGINS"
    
    # 添加服务器IP到CORS配置
    if [ "$env_choice" = "1" ] || [ "$env_choice" = "3" ]; then
        CORS_ORIGINS="$CORS_ORIGINS,http://$SERVER_IP:3300"
    fi
    
    if [ "$env_choice" = "2" ] || [ "$env_choice" = "3" ]; then
        CORS_ORIGINS="$CORS_ORIGINS,http://$SERVER_IP"
    fi
    
    # 更新数据库配置
    DATABASE_URL="mysql+pymysql://root:fzbird20250615@$SERVER_IP:3306/gallerydb?charset=utf8mb4"
    
    # 更新配置文件
    update_env_value "BACKEND_CORS_ORIGINS" "$CORS_ORIGINS"
    update_env_value "DATABASE_URL" "$DATABASE_URL"
    update_env_value "# DEPLOYMENT_ENV" "$ENV_TYPE"
    update_env_value "# DEPLOYMENT_MODE" "$CONFIG_TYPE"
    update_env_value "# SERVER_IP" "$SERVER_IP"
    update_env_value "# LAST_UPDATED" "$(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "✅ 后端环境配置已更新"
    
    # 构建镜像（包含权限修复）
    build_with_permission_fix
    
    # 启动服务
    echo "🚀 启动服务..."
    $COMPOSE_COMMAND -f "$COMPOSE_FILE" up -d
    
    if [ $? -ne 0 ]; then
        echo "❌ 服务启动失败"
        echo "📄 查看日志："
        echo "   后端: docker logs gallery_backend"
        echo "   前端: docker logs gallery_frontend"
        echo "   数据库: docker logs mysql_db"
        exit 1
    fi
    
    # 等待服务启动
    echo "⏳ 等待服务启动..."
    sleep 20
    
    # 检查容器状态
    echo "📊 检查容器状态..."
    docker ps --filter "name=gallery" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # 等待后端服务就绪
    echo "🔍 等待后端服务就绪..."
    for i in {1..30}; do
        if curl -s "http://localhost:8000/docs" > /dev/null 2>&1; then
            echo "✅ 后端服务已就绪"
            break
        fi
        echo "⏳ 等待后端服务启动... ($i/30)"
        sleep 3
    done
    
    # 部署完成
    echo ""
    echo "🎉 部署完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 访问信息："
    
    if [ "$env_choice" = "1" ]; then
        echo "🌐 前端访问: http://$SERVER_IP:3300/"
        echo "🔗 API文档: http://$SERVER_IP:8000/docs"
    elif [ "$env_choice" = "2" ]; then
        echo "🌐 前端访问: http://$SERVER_IP/"
        if [ "$api_choice" = "1" ]; then
            echo "🔗 API文档: http://$SERVER_IP/api/docs"
        else
            echo "🔗 API文档: http://$SERVER_IP:8000/docs"
        fi
    else
        echo "🌐 前端访问: http://$SERVER_IP/ 或 http://$SERVER_IP:3300/"
        if [ "$api_choice" = "1" ]; then
            echo "🔗 API文档: http://$SERVER_IP/api/docs"
        else
            echo "🔗 API文档: http://$SERVER_IP:8000/docs"
        fi
    fi
    
    echo ""
    echo "🛠️  管理命令："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 查看日志: docker logs [container_name]"
    echo "🔄 重启服务: $COMPOSE_COMMAND -f $COMPOSE_FILE restart"
    echo "⏹️  停止服务: $COMPOSE_COMMAND -f $COMPOSE_FILE down"
    echo "🧹 清理系统: docker system prune -f"
    echo "📊 容器状态: docker ps"
    echo ""
    
    # 连接测试
    echo "🧪 连接测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 测试后端连接
    if curl -s --connect-timeout 5 "http://localhost:8000/docs" > /dev/null 2>&1; then
        echo "✅ 后端服务连接正常"
    else
        echo "❌ 后端服务连接失败"
    fi
    
    # 测试前端连接
    if [ "$env_choice" = "1" ] || [ "$env_choice" = "3" ]; then
        if curl -s --connect-timeout 5 "http://localhost:3300/" > /dev/null 2>&1; then
            echo "✅ 前端服务(3300端口)连接正常"
        else
            echo "❌ 前端服务(3300端口)连接失败"
        fi
    fi
    
    if [ "$env_choice" = "2" ] || [ "$env_choice" = "3" ]; then
        if curl -s --connect-timeout 5 "http://localhost/" > /dev/null 2>&1; then
            echo "✅ 前端服务(80端口)连接正常"
        else
            echo "❌ 前端服务(80端口)连接失败"
        fi
    fi
    
    echo ""
    echo "🎯 Ubuntu Server部署完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 脚本入口
main "$@" 