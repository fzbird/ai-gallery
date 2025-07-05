# Gallery 跨服务器部署指南

本指南帮助您解决前端在其他服务器无法访问后端的问题。

## 🚨 问题描述

当前端硬编码 `http://localhost:8000` 时，在其他服务器访问会失败，因为 `localhost` 只指向访问者的本地机器。

## 🔧 解决方案

### 方案 1：环境变量配置（推荐用于开发/测试）

**步骤 1：配置环境变量**

编辑 `frontend/.env.production` 文件：
```bash
# 将 YOUR_SERVER_IP 替换为您服务器的真实 IP 或域名
VITE_API_URL=http://YOUR_SERVER_IP:8000
```

**示例：**
```bash
# 使用 IP 地址
VITE_API_URL=http://192.168.1.100:8000

# 使用域名
VITE_API_URL=http://your-domain.com:8000
```

**步骤 2：重新构建**
```bash
docker-compose up -d --build
```

### 方案 2：反向代理（推荐用于生产环境）

使用 Nginx 反向代理，前后端使用同一个域名和端口。

**优势：**
- ✅ 无需暴露后端端口
- ✅ 更好的安全性
- ✅ 自动 CORS 处理
- ✅ 统一的访问入口

**配置已完成，访问方式：**
```bash
# 前端 + 后端（通过反向代理）
http://your-server-ip/

# API 请求会自动转发到后端
http://your-server-ip/api/v1/...
```

### 方案 3：动态检测（自动化）

系统会自动检测当前环境并配置 API 地址：

1. **开发环境**：使用 `localhost:8000`
2. **端口访问**：`domain:3300` → 自动使用 `domain:8000`
3. **标准端口**：`domain` → 使用反向代理
4. **环境变量**：优先使用 `VITE_API_URL`

## 🚀 部署步骤

### 快速部署（推荐）

1. **获取服务器 IP 或域名**
```bash
# 查看服务器 IP
ip addr show | grep inet
```

2. **选择部署方式**

**A. 使用反向代理（推荐）**
```bash
# 直接部署，无需额外配置
docker-compose up -d --build

# 访问：http://your-server-ip/
```

**B. 使用环境变量**
```bash
# 设置环境变量
echo "VITE_API_URL=http://$(hostname -I | awk '{print $1}'):8000" > frontend/.env.production

# 重新构建
docker-compose up -d --build

# 访问：http://your-server-ip:3300/
```

### 高级配置

**自定义域名配置**
```bash
# 1. 设置域名解析
# 2. 配置环境变量
echo "VITE_API_URL=http://your-domain.com:8000" > frontend/.env.production

# 3. 或者使用反向代理（推荐）
# 访问：http://your-domain.com/
```

**HTTPS 配置**
```bash
# 更新环境变量使用 HTTPS
echo "VITE_API_URL=https://your-domain.com:8000" > frontend/.env.production

# 或者配置 Nginx SSL 证书（需要额外配置）
```

## 🧪 测试验证

### 检查配置是否生效

1. **检查前端配置**
```bash
# 访问前端，打开浏览器开发者工具
# 查看 Network 标签页，API 请求的地址是否正确
```

2. **测试 API 连接**
```bash
# 直接测试后端
curl http://your-server-ip:8000/api/v1/docs

# 通过反向代理测试
curl http://your-server-ip/api/v1/docs
```

3. **检查容器状态**
```bash
docker ps
docker logs gallery_backend
docker logs gallery_frontend
```

## 🛠️ 故障排除

### 常见问题

**1. 仍然显示 localhost:8000**
- 清除浏览器缓存
- 确认环境变量文件正确
- 重新构建容器

**2. CORS 错误**
- 检查 Nginx 配置
- 确认后端 CORS 设置
- 使用反向代理方案

**3. 连接超时**
- 检查防火墙设置
- 确认端口是否开放
- 验证服务器 IP/域名

### 调试命令

```bash
# 查看容器日志
docker logs gallery_frontend
docker logs gallery_backend

# 查看网络连接
docker network ls
docker network inspect gallery_gallery-network

# 重新构建
docker-compose down
docker-compose up -d --build
```

## 📱 不同访问方式对比

| 访问方式 | 前端地址 | 后端地址 | 适用场景 |
|---------|----------|----------|----------|
| 反向代理 | `http://server/` | `http://server/api/` | 生产环境 |
| 端口访问 | `http://server:3300/` | `http://server:8000/` | 开发/测试 |
| 本地开发 | `http://localhost:3300/` | `http://localhost:8000/` | 本地开发 |

## ✅ 推荐方案

1. **生产环境**：使用反向代理（方案 2）
2. **测试环境**：使用环境变量（方案 1）
3. **开发环境**：使用默认配置

通过这些配置，您的 Gallery 应用将可以在任何服务器上正常访问！ 