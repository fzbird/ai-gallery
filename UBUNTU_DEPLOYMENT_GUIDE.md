# Ubuntu Server 24.04.2 部署指南

本指南专门为解决在Ubuntu Server上部署Gallery项目时遇到的权限问题而设计。

## 🚨 问题描述

在Ubuntu Server 24.04.2上执行`deploy.sh`时可能遇到以下错误：

```
ERROR: for gallery_backend  Cannot start service backend: failed to create task for container: 
failed to create shim task: OCI runtime create failed: runc create failed: unable to start 
container process: error during container init: exec: "/app/entrypoint.sh": permission denied: unknown
```

## 🔍 错误分析

这个错误的主要原因是：

1. **权限问题**：`entrypoint.sh`文件在Linux环境下没有执行权限
2. **行结束符问题**：Windows系统创建的文件可能包含CRLF行结束符，Linux需要LF
3. **Docker权限**：用户可能没有正确的Docker权限
4. **文件系统差异**：Linux文件系统对权限的处理更严格

## 🛠️ 解决方案

### 方法一：使用专用Linux部署脚本（推荐）

项目已提供专门的`deploy_linux.sh`脚本，完全解决Ubuntu Server的兼容性问题。

#### 1. 系统要求检查

确保你的Ubuntu Server满足以下要求：

```bash
# 检查Ubuntu版本
lsb_release -a

# 检查Docker
docker --version
docker info

# 检查Docker Compose
docker-compose --version
# 或者
docker compose version
```

#### 2. 安装依赖（如果需要）

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker（如果未安装）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose（如果未安装）
sudo apt install docker-compose-plugin -y

# 将当前用户添加到docker组
sudo usermod -aG docker $USER
newgrp docker

# 启动Docker服务
sudo systemctl start docker
sudo systemctl enable docker
```

#### 3. 克隆项目并部署

```bash
# 克隆项目
git clone <your-repository-url>
cd Gallery

# 确保脚本有执行权限
chmod +x deploy_linux.sh

# 运行Linux专用部署脚本
./deploy_linux.sh
```

#### 4. 脚本功能特性

`deploy_linux.sh` 具有以下Ubuntu优化功能：

- ✅ **自动权限修复**：修复`entrypoint.sh`的执行权限
- ✅ **行结束符转换**：自动将CRLF转换为LF
- ✅ **系统兼容性检查**：验证Ubuntu版本和Docker状态
- ✅ **Docker权限检查**：确保用户有Docker访问权限
- ✅ **智能IP检测**：使用Linux原生命令检测服务器IP
- ✅ **错误恢复**：提供详细的错误信息和解决建议
- ✅ **容器内权限验证**：构建后验证权限设置

### 方法二：手动修复权限问题

如果你希望继续使用原始的`deploy.sh`，可以手动修复权限：

#### 1. 修复文件权限

```bash
# 进入项目目录
cd Gallery

# 修复entrypoint.sh权限
chmod +x backend/entrypoint.sh

# 修复行结束符（如果有dos2unix）
sudo apt install dos2unix -y
dos2unix backend/entrypoint.sh

# 或者手动修复行结束符
sed -i 's/\r$//' backend/entrypoint.sh

# 验证权限
ls -la backend/entrypoint.sh
```

#### 2. 清理Docker环境

```bash
# 停止并删除所有相关容器
docker-compose down --volumes
docker system prune -f

# 删除旧镜像
docker rmi gallery-frontend gallery-backend 2>/dev/null || true
```

#### 3. 重新构建

```bash
# 重新构建后端镜像
docker build -t gallery-backend ./backend

# 验证容器内权限
docker run --rm gallery-backend ls -la /app/entrypoint.sh

# 如果权限正确，运行部署
./deploy.sh
```

### 方法三：修改Dockerfile（永久解决）

项目的Dockerfile已经更新以解决Linux兼容性，如果你使用的是旧版本，可以手动更新：

```dockerfile
# 在backend/Dockerfile中找到以下行：
COPY ./entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 替换为：
COPY ./entrypoint.sh /app/entrypoint.sh

# Fix line endings and permissions for Linux compatibility
RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh && \
    ls -la /app/entrypoint.sh
```

## 🧪 验证部署

部署完成后，验证服务是否正常运行：

```bash
# 检查容器状态
docker ps

# 检查后端日志
docker logs gallery_backend

# 检查前端日志
docker logs gallery_frontend

# 测试后端API
curl http://localhost:8000/docs

# 测试前端访问（根据选择的端口）
curl http://localhost:3300/  # 开发环境
curl http://localhost/       # 生产环境
```

## 🔧 常见问题解决

### 问题1：Docker权限拒绝

```bash
# 错误：permission denied while trying to connect to the Docker daemon socket
sudo usermod -aG docker $USER
newgrp docker
# 或者重新登录
```

### 问题2：端口被占用

```bash
# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :3300
sudo netstat -tlnp | grep :8000

# 停止占用端口的服务
sudo systemctl stop apache2    # 如果安装了Apache
sudo systemctl stop nginx      # 如果安装了Nginx
```

### 问题3：数据库连接失败

```bash
# 检查MySQL容器
docker logs mysql_db

# 检查数据库连接
docker exec -it mysql_db mysql -u root -p
```

### 问题4：内存不足

```bash
# 检查系统资源
free -h
df -h

# 清理Docker资源
docker system prune -a --volumes
```

## 📋 部署配置选项

`deploy_linux.sh`提供以下配置选项：

### 运行环境
1. **开发环境**：仅3300端口，适合开发测试
2. **生产环境**：仅80端口，标准HTTP访问
3. **灵活环境**：双端口（80+3300），提供最大兼容性

### API配置
1. **反向代理模式**：通过nginx代理（推荐）
2. **环境变量模式**：直接指定后端地址

## 🚀 性能优化建议

### Ubuntu Server优化

```bash
# 优化系统性能
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 优化Docker
echo '{"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

### 防火墙配置

```bash
# 配置UFW防火墙
sudo ufw allow 22      # SSH
sudo ufw allow 80      # HTTP
sudo ufw allow 3300    # 开发端口（可选）
sudo ufw allow 8000    # API端口（如果需要外部访问）
sudo ufw enable
```

## 📞 技术支持

如果遇到其他问题，请：

1. 查看容器日志：`docker logs [container_name]`
2. 检查系统资源：`top`, `free -h`, `df -h`
3. 验证网络连接：`curl localhost:8000/docs`
4. 重新运行部署：`./deploy_linux.sh`

---

🎯 **注意**：本指南专门针对Ubuntu Server 24.04.2优化，其他Linux发行版可能需要适当调整命令。 