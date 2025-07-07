# Ubuntu Server 快速部署指南

## 🚀 快速开始

### 1. 环境测试（推荐）
```bash
./test_ubuntu_environment.sh
```

### 2. Linux专用部署
```bash
./deploy_linux.sh
```

## ❌ 如果遇到权限错误

错误信息：
```
exec: "/app/entrypoint.sh": permission denied
```

### 快速修复：
```bash
# 修复文件权限
chmod +x backend/entrypoint.sh
sed -i 's/\r$//' backend/entrypoint.sh

# 清理Docker环境
docker-compose down --volumes
docker system prune -f

# 重新部署
./deploy_linux.sh
```

## 📋 系统要求

- Ubuntu 20.04+ (推荐 24.04.2)
- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ RAM
- 5GB+ 可用磁盘空间

## 🔧 快速安装Docker

```bash
# 安装Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装Docker Compose
sudo apt install docker-compose-plugin -y

# 用户权限
sudo usermod -aG docker $USER
newgrp docker

# 启动服务
sudo systemctl start docker
sudo systemctl enable docker
```

## 📖 详细文档

- 完整指南：[UBUNTU_DEPLOYMENT_GUIDE.md](UBUNTU_DEPLOYMENT_GUIDE.md)
- 数据库初始化：[DATABASE_INITIALIZATION_GUIDE.md](DATABASE_INITIALIZATION_GUIDE.md)
- 环境测试：`./test_ubuntu_environment.sh`
- 问题排查：`docker logs [container_name]`

## 🎯 访问地址

部署成功后根据选择的环境：

- **开发环境**：http://YOUR_IP:3300/
- **生产环境**：http://YOUR_IP/
- **API文档**：http://YOUR_IP:8000/docs

## 🗃️ 数据库自动初始化

### 自动创建的数据
- 👥 **20个用户** (包含管理员和示例用户)
- 🖼️ **160张图片** (从网络下载的真实图片)
- 📚 **40个图集** (智能分组的作品集)
- 📁 **多级分类** (摄影、设计、艺术等)
- 🏷️ **30+标签** (风景、人像、创意等)
- 🎯 **6个主题** (春日物语、城市印象等)

### 登录信息
- **管理员**：admin@gallery.com / admin123456
- **示例用户**：zhang@gallery.com, li@gallery.com 等 / password123
- **测试用户**：user001@gallery.com ~ user020@gallery.com / password123

### 手动重新初始化
```bash
./manual_init_database.sh
``` 