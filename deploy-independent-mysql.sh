#!/bin/bash

# ========================================================================
# Gallery 项目使用独立 MySQL 服务的部署脚本
# ========================================================================
# 
# 此脚本用于部署 Gallery 项目，连接到独立的共享 MySQL 数据库服务
# 
# 使用方法:
#   ./deploy-independent-mysql.sh
# 
# ========================================================================

set -e

# 颜色输出函数
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

print_separator() {
    echo "=================================================================="
}

MYSQL_CONTAINER_NAME="shared_mysql_server"
COMPOSE_FILE="docker-compose.independent-mysql.yml"

print_separator
print_info "Gallery 项目 - 独立 MySQL 服务部署"
print_separator

# 检查系统要求
print_info "检查系统要求..."
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装或不在 PATH 中"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

# 检查独立 MySQL 服务是否运行
print_info "检查独立 MySQL 服务状态..."
if ! docker ps | grep -q "$MYSQL_CONTAINER_NAME"; then
    print_error "❌ 独立 MySQL 服务未运行"
    echo ""
    print_info "请先启动独立 MySQL 服务："
    echo "  ./start-independent-mysql.sh"
    echo ""
    print_info "或者手动启动："
    echo "  docker run -d --name shared_mysql_server -p 3306:3306 \\"
    echo "    -e MYSQL_ROOT_PASSWORD=mysql_root_password_2024 \\"
    echo "    -v shared_mysql_data:/var/lib/mysql \\"
    echo "    mysql:8.0"
    exit 1
fi

print_success "✅ 独立 MySQL 服务正在运行"

# 测试数据库连接
print_info "测试数据库连接..."
if command -v mysql &> /dev/null; then
    if mysql -h localhost -P 3306 -u gallery_user -pgallery_pass_2024 -e "SELECT 1;" gallery_db >/dev/null 2>&1; then
        print_success "✅ 数据库连接测试成功"
    else
        print_warning "⚠️ 数据库连接测试失败，但继续部署..."
    fi
else
    print_info "MySQL 客户端未安装，跳过连接测试"
fi

# 停止现有的 Gallery 服务（如果运行）
print_info "停止现有的 Gallery 服务..."
docker-compose down 2>/dev/null || true
docker-compose -f docker-compose.dev.yml down 2>/dev/null || true
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# 创建必要的目录
print_info "创建必要的目录..."
mkdir -p backend/logs
mkdir -p frontend/dist

# 构建和启动服务
print_info "构建和启动 Gallery 服务..."
docker-compose -f "$COMPOSE_FILE" up -d --build

# 等待服务启动
print_info "等待服务启动..."
sleep 30

# 检查服务状态
print_info "检查服务状态..."
print_separator

echo "容器状态："
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep -E "(gallery|mysql)"

echo ""
print_info "网络状态："
docker network ls | grep -E "(gallery|mysql)"

echo ""
print_info "数据卷状态："
docker volume ls | grep -E "(gallery|mysql)"

# 健康检查
print_separator
print_info "执行健康检查..."

# 检查后端服务
if curl -f http://localhost:8000/health >/dev/null 2>&1; then
    print_success "✅ 后端服务健康检查通过"
else
    print_warning "⚠️ 后端服务健康检查失败"
    echo "后端日志："
    docker logs gallery_backend --tail=10
fi

# 检查前端服务
if curl -f http://localhost:3300/ >/dev/null 2>&1; then
    print_success "✅ 前端服务健康检查通过"
else
    print_warning "⚠️ 前端服务健康检查失败"
    echo "前端日志："
    docker logs gallery_frontend --tail=10
fi

# 显示访问信息
print_separator
print_success "🎉 Gallery 项目部署完成！"
print_separator

echo "📊 服务信息："
echo "  前端界面: http://localhost:3300"
echo "  备用访问: http://localhost"
echo "  后端API:  http://localhost:8000"
echo "  API文档:  http://localhost:8000/docs"
echo ""

echo "🗄️ 数据库信息："
echo "  MySQL容器: $MYSQL_CONTAINER_NAME"
echo "  数据库: gallery_db"
echo "  用户: gallery_user"
echo "  主机: localhost:3306"
echo ""

echo "📋 管理命令："
echo "  查看日志: docker-compose -f $COMPOSE_FILE logs -f"
echo "  停止服务: docker-compose -f $COMPOSE_FILE down"
echo "  重启服务: docker-compose -f $COMPOSE_FILE restart"
echo ""
echo "  查看MySQL日志: docker logs $MYSQL_CONTAINER_NAME"
echo "  连接MySQL: docker exec -it $MYSQL_CONTAINER_NAME mysql -u gallery_user -p gallery_db"
echo "  停止MySQL: docker stop $MYSQL_CONTAINER_NAME"
echo ""

echo "🔧 故障排除："
echo "  如果服务无法访问，请检查："
echo "  1. 防火墙设置"
echo "  2. 端口占用情况: netstat -an | grep -E '(3300|8000|3306)'"
echo "  3. 容器日志: docker logs <容器名>"
echo ""

print_info "部署完成！Gallery 项目现在使用独立的共享 MySQL 服务。" 