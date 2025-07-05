#!/bin/bash

# Gallery 自动部署脚本 - 多环境支持版本
# 支持开发、生产、灵活三种部署模式

echo "🚀 Gallery 自动部署脚本 v2.0"
echo "=============================="

# 获取服务器IP - 多种方法兼容，优先获取内网IP
get_server_ip() {
    local ip=""
    
    # 方法1: Windows系统 - ipconfig (优先检测内网IP)
    if [ -z "$ip" ] && command -v ipconfig >/dev/null 2>&1; then
        # 优先获取192.168网段的IP
        ip=$(ipconfig 2>/dev/null | awk '/192\.168\./ {print $NF}' | head -1 2>/dev/null)
        
        # 如果没有192.168网段，则获取10.x网段的IP
        if [ -z "$ip" ]; then
            ip=$(ipconfig 2>/dev/null | awk '/10\./ {print $NF}' | head -1 2>/dev/null)
        fi
        
        # 如果还是没有，则获取172.16-31网段的IP（排除Docker虚拟网卡）
        if [ -z "$ip" ]; then
            ip=$(ipconfig 2>/dev/null | awk '/172\.1[6-9]\./ || /172\.2[0-9]\./ || /172\.3[0-1]\./ {print $NF}' | head -1 2>/dev/null)
        fi
    fi
    
    # 方法2: 使用 hostname -I (Linux)
    if [ -z "$ip" ] && command -v hostname >/dev/null 2>&1; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}' 2>/dev/null)
    fi
    
    # 方法3: 使用 ip route (Linux)
    if [ -z "$ip" ] && command -v ip >/dev/null 2>&1; then
        ip=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' | head -1 2>/dev/null)
    fi
    
    # 方法4: 使用 ifconfig (通用)
    if [ -z "$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig 2>/dev/null | grep -E "inet.*192\.|inet.*10\.|inet.*172\." | head -1 | awk '{print $2}' | cut -d: -f2 2>/dev/null)
    fi
    
    # 方法5: 读取网络接口文件
    if [ -z "$ip" ] && [ -f /proc/net/route ]; then
        local interface=$(awk '/^[a-zA-Z]/ && $2 == "00000000" {print $1}' /proc/net/route | head -1)
        if [ -n "$interface" ]; then
            ip=$(ip addr show "$interface" 2>/dev/null | grep -E "inet.*192\.|inet.*10\.|inet.*172\." | head -1 | awk '{print $2}' | cut -d/ -f1 2>/dev/null)
        fi
    fi
    
    # 方法6: 外部IP检测 (fallback)
    if [ -z "$ip" ]; then
        ip=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "localhost")
    fi
    
    echo "$ip"
}

SERVER_IP=$(get_server_ip)
echo "📍 检测到服务器IP: $SERVER_IP"

# 让用户确认或手动输入IP
echo ""
read -p "🔍 IP地址是否正确？如不正确请输入实际IP地址（回车确认当前IP）: " user_ip
if [ -n "$user_ip" ]; then
    SERVER_IP="$user_ip"
    echo "✅ 更新服务器IP为: $SERVER_IP"
fi

# 步骤1: 选择运行环境
echo ""
echo "🏗️  步骤1: 选择运行环境"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 🔧 开发环境    - 仅3300端口，避免端口冲突，适合本地开发"
echo "2. 🌐 生产环境    - 仅80端口，标准HTTP访问，适合生产部署"  
echo "3. 🔄 灵活环境    - 双端口支持，同时提供3300和80端口访问"
echo ""
read -p "请选择环境 (1-3): " env_choice

# 设置docker-compose文件和环境描述
case $env_choice in
    1)
        COMPOSE_FILE="docker-compose.dev.yml"
        ENV_TYPE="开发环境"
        PRIMARY_PORT="3300"
        SECONDARY_PORT=""
        echo "✅ 选择：$ENV_TYPE (仅$PRIMARY_PORT端口)"
        ;;
    2)
        COMPOSE_FILE="docker-compose.prod.yml"
        ENV_TYPE="生产环境"
        PRIMARY_PORT="80"
        SECONDARY_PORT=""
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

# 步骤2: 选择API配置方式
echo ""
echo "🔗 步骤2: 选择API配置方式"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. 🔄 反向代理模式 - 通过nginx代理，前端无需指定后端地址（推荐）"
echo "2. 🌍 环境变量模式 - 明确指定后端API地址"
echo "3. 🏷️  自定义域名模式 - 使用自定义域名访问"
echo ""
read -p "请选择API配置方式 (1-3): " api_choice

# 配置前端环境变量
case $api_choice in
    1)
        CONFIG_TYPE="反向代理模式"
        echo "✅ 选择：$CONFIG_TYPE"
        echo "🔧 配置反向代理..."
        
        # 创建生产环境配置（使用相对路径，让nginx处理）
        cat > frontend/.env.production << EOF
# 反向代理模式配置 - API请求通过nginx代理
VITE_API_URL=
EOF
        
        if [ "$env_choice" = "2" ]; then
            ACCESS_URL="http://$SERVER_IP/"
            API_URL="http://$SERVER_IP/api/"
        elif [ "$env_choice" = "1" ]; then
            echo "⚠️  注意：开发环境建议使用环境变量模式以避免nginx配置复杂性"
            ACCESS_URL="http://$SERVER_IP:3300/"
            API_URL="http://$SERVER_IP:3300/api/"
        else
            ACCESS_URL="http://$SERVER_IP/ 或 http://$SERVER_IP:3300/"
            API_URL="http://$SERVER_IP/api/ 或 http://$SERVER_IP:3300/api/"
        fi
        ;;
        
    2)
        CONFIG_TYPE="环境变量模式"
        echo "✅ 选择：$CONFIG_TYPE"
        echo "🔧 配置环境变量..."
        
        # 创建环境变量配置
        cat > frontend/.env.production << EOF
# 环境变量模式配置 - 明确指定后端API地址
VITE_API_URL=http://$SERVER_IP:8000
EOF
        
        if [ "$env_choice" = "2" ]; then
            ACCESS_URL="http://$SERVER_IP/"
            API_URL="http://$SERVER_IP:8000/"
        elif [ "$env_choice" = "1" ]; then
            ACCESS_URL="http://$SERVER_IP:3300/"
            API_URL="http://$SERVER_IP:8000/"
        else
            ACCESS_URL="http://$SERVER_IP/ 或 http://$SERVER_IP:3300/"
            API_URL="http://$SERVER_IP:8000/"
        fi
        ;;
        
    3)
        CONFIG_TYPE="自定义域名模式"
        echo "✅ 选择：$CONFIG_TYPE"
        read -p "🌐 请输入您的域名（如: example.com）: " domain
        
        if [ -z "$domain" ]; then
            echo "❌ 域名不能为空！"
            exit 1
        fi
        
        echo "🔧 配置自定义域名..."
        
        # 询问是否使用HTTPS
        read -p "🔒 是否使用HTTPS？(y/n): " use_https
        
        if [[ $use_https =~ ^[Yy]$ ]]; then
            PROTOCOL="https"
            cat > frontend/.env.production << EOF
# 自定义域名配置 (HTTPS)
VITE_API_URL=https://$domain:8000
EOF
        else
            PROTOCOL="http"
            cat > frontend/.env.production << EOF
# 自定义域名配置 (HTTP)
VITE_API_URL=http://$domain:8000
EOF
        fi
        
        if [ "$env_choice" = "2" ]; then
            ACCESS_URL="$PROTOCOL://$domain/"
            API_URL="$PROTOCOL://$domain:8000/"
        elif [ "$env_choice" = "1" ]; then
            ACCESS_URL="$PROTOCOL://$domain:3300/"
            API_URL="$PROTOCOL://$domain:8000/"
        else
            ACCESS_URL="$PROTOCOL://$domain/ 或 $PROTOCOL://$domain:3300/"
            API_URL="$PROTOCOL://$domain:8000/"
        fi
        
        echo "⚠️  请确保域名 '$domain' 已正确解析到服务器IP: $SERVER_IP"
        ;;
        
    *)
        echo "❌ 无效选择！"
        exit 1
        ;;
esac

echo ""
echo "📋 部署配置总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  运行环境: $ENV_TYPE"
echo "🔗 API配置: $CONFIG_TYPE"
echo "📁 配置文件: $COMPOSE_FILE"
echo "🌐 访问地址: $ACCESS_URL"
echo "🔗 API地址: $API_URL"
echo ""

read -p "确认开始部署？(y/n): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ 部署已取消"
    exit 0
fi

echo ""
echo "🏗️  开始构建和部署..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 停止现有容器
echo "⏹️  停止现有容器..."
docker-compose down 2>/dev/null || true
docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# 更新后端环境配置
echo "🔧 更新后端环境配置..."

# 确保.env文件存在
if [ ! -f "backend/.env" ]; then
    echo "📋 创建默认.env文件..."
    cp backend/env.template backend/.env
    echo "✅ 已从模板创建.env文件"
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
        # 使用临时文件避免sed在某些系统上的问题
        sed "s|^$key=.*|$key=$escaped_value|" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        echo "📝 已更新 $key"
    else
        echo "$key=$value" >> "$file"
        echo "📝 已添加 $key"
    fi
}

# 基础CORS配置（开发环境默认配置）
BASE_CORS_ORIGINS="http://localhost:3300,http://localhost:3301,http://127.0.0.1:3300,http://127.0.0.1:3301"

# 根据环境和API配置生成CORS配置
CORS_ORIGINS="$BASE_CORS_ORIGINS"

# 添加服务器IP到CORS配置
if [ "$env_choice" = "1" ] || [ "$env_choice" = "3" ]; then
    # 开发环境和灵活环境需要3300端口
    CORS_ORIGINS="$CORS_ORIGINS,http://$SERVER_IP:3300"
    echo "📍 已添加 http://$SERVER_IP:3300 到CORS配置"
fi

if [ "$env_choice" = "2" ] || [ "$env_choice" = "3" ]; then
    # 生产环境和灵活环境需要80端口
    CORS_ORIGINS="$CORS_ORIGINS,http://$SERVER_IP"
    echo "📍 已添加 http://$SERVER_IP 到CORS配置"
fi

# 更新数据库配置（MySQL服务器运行在相同地址）
DATABASE_URL="mysql+pymysql://root:fzbird20250615@$SERVER_IP:3306/gallerydb?charset=utf8mb4"

# 更新配置文件
echo "🔧 更新配置项..."
update_env_value "BACKEND_CORS_ORIGINS" "$CORS_ORIGINS"
update_env_value "DATABASE_URL" "$DATABASE_URL"
update_env_value "# DEPLOYMENT_ENV" "$ENV_TYPE"
update_env_value "# DEPLOYMENT_MODE" "$CONFIG_TYPE"
update_env_value "# SERVER_IP" "$SERVER_IP"
update_env_value "# LAST_UPDATED" "$(date '+%Y-%m-%d %H:%M:%S')"

echo "✅ 后端环境配置已更新：backend/.env"

# 重新构建和启动
echo "🔄 使用 $COMPOSE_FILE 重新构建容器..."
docker-compose -f "$COMPOSE_FILE" up -d --build

# 等待容器启动
echo "⏳ 等待容器启动..."
sleep 15

# 检查容器状态
echo "📊 检查容器状态..."
docker ps --filter "name=gallery" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 等待服务就绪
echo "🔍 等待服务就绪..."
for i in {1..30}; do
    if curl -s "http:///$SERVER_IP:8000/docs" > /dev/null 2>&1; then
        echo "✅ 后端服务已就绪"
        break
    fi
    echo "⏳ 等待后端服务启动... ($i/30)"
    sleep 2
done

echo ""
echo "🎉 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 访问信息："

if [ "$env_choice" = "1" ]; then
    # 开发环境
    echo "🌐 前端访问: http://$SERVER_IP:3300/"
    echo "🔗 API文档: http://$SERVER_IP:8000/docs"
    echo "📊 健康检查: http://$SERVER_IP:8000/api/v1/health"
elif [ "$env_choice" = "2" ]; then
    # 生产环境
    if [ "$api_choice" = "1" ]; then
        echo "🌐 前端访问: http://$SERVER_IP/"
        echo "🔗 API文档: http://$SERVER_IP/api/v1/docs"
        echo "📊 健康检查: http://$SERVER_IP/api/v1/health"
    else
        echo "🌐 前端访问: http://$SERVER_IP/"
        echo "🔗 API文档: http://$SERVER_IP:8000/docs"
        echo "📊 健康检查: http://$SERVER_IP:8000/api/v1/health"
    fi
elif [ "$env_choice" = "3" ]; then
    # 灵活环境
    echo "🌐 前端访问: http://$SERVER_IP/ 或 http://$SERVER_IP:3300/"
    if [ "$api_choice" = "1" ]; then
        echo "🔗 API文档: http://$SERVER_IP/api/v1/docs 或 http://$SERVER_IP:3300/api/v1/docs"
        echo "📊 健康检查: http://$SERVER_IP/api/v1/health"
    else
        echo "🔗 API文档: http://$SERVER_IP:8000/docs"
        echo "📊 健康检查: http://$SERVER_IP:8000/api/v1/health"
    fi
fi

if [ "$api_choice" = "3" ]; then
    echo ""
    echo "🏷️  自定义域名访问："
    echo "🌐 前端: $ACCESS_URL"
    echo "🔗 API: $API_URL"
fi

echo ""
echo "🛠️  故障排除命令："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📄 查看前端日志: docker logs gallery_frontend"
echo "📄 查看后端日志: docker logs gallery_backend" 
echo "📄 查看数据库日志: docker logs mysql_db"
echo "🔄 重新部署: ./deploy.sh"
echo "⏹️  停止服务: docker-compose -f $COMPOSE_FILE down"
echo "🧹 清理容器: docker system prune -f"
echo ""
echo "📖 详细说明请查看: DEPLOYMENT_GUIDE.md"
echo "📖 端口配置说明请查看: DOCKER_PORT_GUIDE.md"

# 连接测试
echo ""
echo "🧪 连接测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试后端连接
if curl -s "http://localhost:8000/docs" > /dev/null 2>&1; then
    echo "✅ 后端服务连接正常"
else
    echo "❌ 后端服务连接失败"
fi

# 测试前端连接
if [ "$env_choice" = "1" ] || [ "$env_choice" = "3" ]; then
    if curl -s "http://localhost:3300/" > /dev/null 2>&1; then
        echo "✅ 前端服务(3300端口)连接正常"
    else
        echo "❌ 前端服务(3300端口)连接失败"
    fi
fi

if [ "$env_choice" = "2" ] || [ "$env_choice" = "3" ]; then
    if curl -s "http://localhost/" > /dev/null 2>&1; then
        echo "✅ 前端服务(80端口)连接正常"
    else
        echo "❌ 前端服务(80端口)连接失败"
    fi
fi

# 测试API代理（如果是反向代理模式）
if [ "$api_choice" = "1" ] && ([ "$env_choice" = "2" ] || [ "$env_choice" = "3" ]); then
    if curl -s "http://localhost/api/v1/docs" > /dev/null 2>&1; then
        echo "✅ API反向代理连接正常"
    else
        echo "❌ API反向代理连接失败"
    fi
fi

# 显示配置文件内容
echo "📋 当前后端配置："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat backend/.env
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🎯 部署脚本执行完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 