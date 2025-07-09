# Docker 权限问题修复指南

本指南解决在不同操作系统间 git clone 项目后，Docker 容器启动时出现的权限错误问题。

## 🚨 问题描述

当您在其他机器上 git clone 项目并运行 `deploy.sh` 时，可能会遇到以下错误：

```
ERROR: for gallery_backend  Cannot start service backend: failed to create task for container: 
failed to create shim task: OCI runtime create failed: runc create failed: 
unable to start container process: error during container init: 
exec: "/app/entrypoint.sh": permission denied: unknown
```

## 🔍 问题原因

1. **文件权限丢失**：在不同操作系统间 git clone 时，文件的执行权限可能丢失
2. **换行符不兼容**：Windows 和 Linux 系统的换行符格式不同（\r\n vs \n）
3. **Docker volume 覆盖**：docker-compose.yml 中的 volume 挂载会覆盖容器内的文件权限

## 💡 解决方案

### 方案1：使用权限修复脚本（推荐）

```bash
# 1. 给修复脚本添加执行权限
chmod +x fix_permissions.sh

# 2. 运行权限修复脚本
./fix_permissions.sh

# 3. 运行部署脚本
./deploy.sh
```

### 方案2：手动修复权限

```bash
# 1. 修复 entrypoint.sh 权限
chmod +x backend/entrypoint.sh

# 2. 修复 deploy.sh 权限
chmod +x deploy.sh

# 3. 修复换行符问题
dos2unix backend/entrypoint.sh  # 如果安装了 dos2unix
# 或者使用 sed
sed -i 's/\r$//' backend/entrypoint.sh

# 4. 运行部署脚本
./deploy.sh
```

### 方案3：验证修复效果

```bash
# 使用测试脚本验证修复效果
chmod +x test_fix.sh
./test_fix.sh
```

## 🔧 技术详解

### 修复内容

1. **Dockerfile 改进**：
   - 添加了 `startup.sh` 脚本，确保 entrypoint.sh 始终有执行权限
   - 创建备份文件，防止 volume 挂载覆盖
   - 自动修复换行符格式

2. **Docker Compose 修复**：
   - 移除了重复的 `entrypoint` 配置
   - 让 Dockerfile 中的 ENTRYPOINT 生效

3. **部署脚本改进**：
   - 自动检查和修复文件权限
   - 修复换行符格式问题
   - 提供详细的错误信息

### 关键文件

- `backend/Dockerfile` - 容器构建配置
- `backend/entrypoint.sh` - 容器启动脚本
- `fix_permissions.sh` - 权限修复脚本
- `deploy.sh` - 部署脚本
- `docker-compose.yml` - 容器编排配置

## 🏗️ 构建流程

新的构建流程确保权限问题得到彻底解决：

1. **构建时**：Dockerfile 中设置正确的权限和备份
2. **运行时**：startup.sh 检查并修复权限问题
3. **部署时**：deploy.sh 预先检查和修复权限

## 📋 检查清单

在部署前，请确认：

- [ ] `backend/entrypoint.sh` 有执行权限
- [ ] `deploy.sh` 有执行权限
- [ ] `fix_permissions.sh` 有执行权限
- [ ] 文件换行符格式为 Unix 格式（LF）
- [ ] Docker 服务正常运行
- [ ] 当前用户有 Docker 权限

## 🛠️ 故障排除

### 如果权限修复脚本失败

```bash
# 检查当前权限
ls -la backend/entrypoint.sh
ls -la deploy.sh
ls -la fix_permissions.sh

# 强制修复权限
chmod +x backend/entrypoint.sh
chmod +x deploy.sh
chmod +x fix_permissions.sh

# 使用 Git 修复权限
git update-index --chmod=+x backend/entrypoint.sh
git update-index --chmod=+x deploy.sh
git update-index --chmod=+x fix_permissions.sh
```

### 如果容器仍然无法启动

```bash
# 查看详细错误信息
docker-compose logs backend

# 手动测试容器构建
cd backend
docker build -t test-backend .
docker run --rm -it test-backend /bin/bash

# 在容器内检查权限
ls -la /app/entrypoint.sh
ls -la /app/startup.sh
```

### 如果换行符问题持续存在

```bash
# 检查文件换行符格式
file backend/entrypoint.sh

# 使用 tr 命令修复
tr -d '\r' < backend/entrypoint.sh > backend/entrypoint.sh.tmp
mv backend/entrypoint.sh.tmp backend/entrypoint.sh
chmod +x backend/entrypoint.sh
```

## 🎯 预防措施

为了避免将来出现权限问题：

1. **提交时保持权限**：
   ```bash
   git add --chmod=+x backend/entrypoint.sh
   git add --chmod=+x deploy.sh
   git add --chmod=+x fix_permissions.sh
   ```

2. **配置 Git 设置**：
   ```bash
   git config core.filemode true
   git config core.autocrlf false
   ```

3. **使用 .gitattributes**：
   ```
   *.sh text eol=lf
   ```

## 📞 支持

如果按照本指南操作后仍然遇到问题，请：

1. 检查 Docker 和 Docker Compose 版本
2. 确认操作系统和 Shell 环境
3. 查看完整的错误日志
4. 提供系统环境信息

---

💡 **提示**：建议在每次 git clone 后都运行 `./fix_permissions.sh` 来确保权限正常。 