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
- 环境测试：`./test_ubuntu_environment.sh`
- 问题排查：`docker logs [container_name]`

## 🎯 访问地址

部署成功后根据选择的环境：

- **开发环境**：http://YOUR_IP:3300/
- **生产环境**：http://YOUR_IP/
- **API文档**：http://YOUR_IP:8000/docs 