#!/bin/bash

# Ubuntu Server 环境测试脚本
# 在部署前运行此脚本以验证系统配置

echo "🧪 Ubuntu Server Gallery 环境测试"
echo "=================================="

# 测试结果统计
PASSED=0
FAILED=0
WARNINGS=0

# 测试函数
test_pass() {
    echo "✅ $1"
    ((PASSED++))
}

test_fail() {
    echo "❌ $1"
    echo "   💡 解决方案: $2"
    ((FAILED++))
}

test_warning() {
    echo "⚠️  $1"
    echo "   💡 建议: $2"
    ((WARNINGS++))
}

echo ""
echo "🔍 系统环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查操作系统
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "📋 操作系统: $NAME $VERSION"
    
    if [[ "$NAME" =~ "Ubuntu" ]]; then
        if [[ "$VERSION_ID" > "20.04" || "$VERSION_ID" == "20.04" ]]; then
            test_pass "Ubuntu版本兼容 ($VERSION_ID)"
        else
            test_warning "Ubuntu版本较旧 ($VERSION_ID)" "建议升级到20.04+"
        fi
    else
        test_warning "非Ubuntu系统 ($NAME)" "脚本主要针对Ubuntu优化"
    fi
else
    test_fail "无法检测操作系统" "确保运行在Linux系统上"
fi

# 检查用户权限
if [ "$EUID" -eq 0 ]; then
    test_warning "以root用户运行" "建议使用普通用户并将其添加到docker组"
else
    test_pass "使用普通用户运行"
fi

echo ""
echo "🐳 Docker环境检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    test_pass "Docker已安装 (版本: $DOCKER_VERSION)"
    
    # 检查Docker daemon
    if docker info &> /dev/null; then
        test_pass "Docker daemon运行正常"
        
        # 检查用户权限
        if docker ps &> /dev/null; then
            test_pass "当前用户有Docker权限"
        else
            test_fail "当前用户没有Docker权限" "运行: sudo usermod -aG docker \$USER && newgrp docker"
        fi
    else
        test_fail "Docker daemon未运行" "运行: sudo systemctl start docker"
    fi
else
    test_fail "Docker未安装" "参考: https://docs.docker.com/engine/install/ubuntu/"
fi

# 检查Docker Compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
    test_pass "Docker Compose已安装 (版本: $COMPOSE_VERSION)"
    COMPOSE_COMMAND="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version | cut -d' ' -f3)
    test_pass "Docker Compose Plugin已安装 (版本: $COMPOSE_VERSION)"
    COMPOSE_COMMAND="docker compose"
else
    test_fail "Docker Compose未安装" "运行: sudo apt install docker-compose-plugin"
fi

echo ""
echo "🌐 网络和端口检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查端口占用
check_port() {
    local port=$1
    local service=$2
    
    if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        local process=$(netstat -tlnp 2>/dev/null | grep ":$port " | awk '{print $7}' | head -1)
        test_warning "$service端口($port)被占用" "进程: $process，考虑停止相关服务"
    else
        test_pass "$service端口($port)可用"
    fi
}

check_port 80 "前端(生产)"
check_port 3300 "前端(开发)"
check_port 8000 "后端API"
check_port 3306 "MySQL数据库"

# 检查网络连接
if ping -c 1 google.com &> /dev/null; then
    test_pass "网络连接正常"
else
    test_warning "网络连接可能有问题" "检查网络配置和DNS设置"
fi

echo ""
echo "📁 项目文件检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查关键文件
check_file() {
    local file=$1
    local description=$2
    
    if [[ -f "$file" ]]; then
        test_pass "$description存在: $file"
    else
        test_fail "$description不存在: $file" "确保完整克隆了项目"
    fi
}

check_file "deploy_linux.sh" "Linux部署脚本"
check_file "docker-compose.yml" "Docker Compose配置"
check_file "docker-compose.dev.yml" "开发环境配置"
check_file "docker-compose.prod.yml" "生产环境配置"
check_file "backend/Dockerfile" "后端Docker配置"
check_file "backend/entrypoint.sh" "后端启动脚本"
check_file "backend/env.template" "环境变量模板"
check_file "frontend/Dockerfile" "前端Docker配置"

# 检查entrypoint.sh权限
if [[ -f "backend/entrypoint.sh" ]]; then
    if [[ -x "backend/entrypoint.sh" ]]; then
        test_pass "entrypoint.sh有执行权限"
    else
        test_warning "entrypoint.sh缺少执行权限" "deploy_linux.sh将自动修复"
    fi
    
    # 检查行结束符
    if file backend/entrypoint.sh | grep -q "CRLF"; then
        test_warning "entrypoint.sh使用Windows行结束符" "deploy_linux.sh将自动转换"
    else
        test_pass "entrypoint.sh使用正确的行结束符"
    fi
fi

echo ""
echo "💾 系统资源检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查内存
MEMORY_MB=$(free -m | awk 'NR==2{print $2}')
if [[ $MEMORY_MB -ge 2048 ]]; then
    test_pass "内存充足 (${MEMORY_MB}MB)"
elif [[ $MEMORY_MB -ge 1024 ]]; then
    test_warning "内存一般 (${MEMORY_MB}MB)" "建议至少2GB内存以获得更好性能"
else
    test_fail "内存不足 (${MEMORY_MB}MB)" "建议至少1GB内存，推荐2GB+"
fi

# 检查磁盘空间
DISK_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [[ $DISK_SPACE -ge 10 ]]; then
    test_pass "磁盘空间充足 (${DISK_SPACE}GB可用)"
elif [[ $DISK_SPACE -ge 5 ]]; then
    test_warning "磁盘空间一般 (${DISK_SPACE}GB可用)" "建议保持至少10GB可用空间"
else
    test_fail "磁盘空间不足 (${DISK_SPACE}GB可用)" "至少需要5GB可用空间"
fi

# 检查CPU核心数
CPU_CORES=$(nproc)
if [[ $CPU_CORES -ge 2 ]]; then
    test_pass "CPU核心充足 (${CPU_CORES}核心)"
else
    test_warning "CPU核心较少 (${CPU_CORES}核心)" "建议至少2个CPU核心"
fi

echo ""
echo "🔧 工具和依赖检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查常用工具
check_command() {
    local cmd=$1
    local description=$2
    local install_hint=$3
    
    if command -v $cmd &> /dev/null; then
        test_pass "$description可用"
    else
        test_warning "$description不可用" "$install_hint"
    fi
}

check_command "curl" "curl命令" "sudo apt install curl"
check_command "git" "Git版本控制" "sudo apt install git"
check_command "netstat" "网络状态工具" "sudo apt install net-tools"
check_command "dos2unix" "行结束符转换工具" "sudo apt install dos2unix"

echo ""
echo "📊 测试结果汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 通过: $PASSED 项"
echo "❌ 失败: $FAILED 项"
echo "⚠️  警告: $WARNINGS 项"

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo "🎉 环境检查通过！可以运行部署脚本："
    echo "   ./deploy_linux.sh"
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo ""
        echo "💡 建议处理上述警告项以获得更好的部署体验"
    fi
else
    echo "❌ 环境检查失败，请先解决以下问题：" 
    echo "   - 修复上述 $FAILED 个失败项"
    echo "   - 参考 UBUNTU_DEPLOYMENT_GUIDE.md 获取详细帮助"
    echo ""
    echo "🔧 快速修复命令："
    
    if ! command -v docker &> /dev/null; then
        echo "   # 安装Docker:"
        echo "   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    fi
    
    if ! docker info &> /dev/null; then
        echo "   # 启动Docker并添加用户权限:"
        echo "   sudo systemctl start docker"
        echo "   sudo usermod -aG docker \$USER && newgrp docker"
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "   # 安装Docker Compose:"
        echo "   sudo apt install docker-compose-plugin"
    fi
fi

echo ""
echo "📖 更多信息："
echo "   - 详细部署指南: UBUNTU_DEPLOYMENT_GUIDE.md"
echo "   - 如遇问题可查看容器日志: docker logs [container_name]"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 