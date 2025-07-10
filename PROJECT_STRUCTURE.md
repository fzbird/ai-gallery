# 项目目录结构说明

## 概述

本项目经过重新整理，现在包含三个独立的服务模块，每个模块都有明确的职责和独立的部署方式：

```
Cursor/
├── Gallery/                    # 画廊Web应用（核心业务）
├── mysql-service/       # 独立共享MySQL数据库服务
├── mysql_cluster/              # MySQL主从集群服务
└── PROJECT_STRUCTURE.md        # 本文档
```

## 🎨 Gallery 项目

**路径**: `Gallery/`  
**类型**: Web应用项目  
**描述**: 图片分享和管理平台的核心业务代码

### 主要组件
- **backend/**: FastAPI后端应用
- **frontend/**: Vue.js前端应用  
- **docker-compose.yml**: Gallery服务配置
- **deploy.sh**: 一键部署脚本

### 快速启动
```bash
cd Gallery
./deploy.sh
```

### 访问地址
- 前端: http://localhost:80
- 后端API: http://localhost:8000
- API文档: http://localhost:8000/docs

---

## 🗄️ 独立共享MySQL服务

**路径**: `mysql-service/`  
**类型**: 数据库服务  
**描述**: 独立的MySQL数据库服务，可供多个项目使用

### 特性
- ✅ 完全独立的MySQL服务
- ✅ 支持多数据库多用户
- ✅ 自动初始化和配置
- ✅ 数据持久化存储
- ✅ 简单的网络配置

### 快速启动
```bash
cd mysql-service
./deploy-independent-mysql.sh start
```

### 默认配置
- **端口**: 3306
- **Root密码**: `your_root_password`
- **网络**: `shared-mysql-network` (172.23.0.0/16)
- **数据卷**: `shared_mysql_data`

### 连接示例
```python
# Gallery项目连接配置
DATABASE_URL = "mysql+pymysql://gallery_user:gallery_pass@localhost:3306/gallery_db"
```

---

## ⚖️ MySQL主从集群服务

**路径**: `mysql_cluster/`  
**类型**: 高可用数据库集群  
**描述**: MySQL主从复制集群，提供高可用性和读写分离

### 特性
- ✅ 主从复制自动同步
- ✅ 读写分离负载均衡
- ✅ 自动故障转移
- ✅ 性能监控和日志
- ✅ HAProxy负载均衡

### 快速启动
```bash
cd mysql_cluster
./deploy_mysql_cluster.sh start
```

### 服务端口
- **主库**: 3306 (写操作)
- **从库**: 3307 (读操作)  
- **负载均衡**: 3308 (读写分离)
- **只读负载**: 3309 (只读)
- **HAProxy统计**: 8404

### 连接配置
```python
# 读写分离连接
WRITE_DB_URL = "mysql+pymysql://root:cluster_root_pass@localhost:3306/your_db"
READ_DB_URL = "mysql+pymysql://root:cluster_root_pass@localhost:3307/your_db"
CLUSTER_DB_URL = "mysql+pymysql://root:cluster_root_pass@localhost:3308/your_db"
```

---

## 🚀 使用场景和选择指南

### 选择独立共享MySQL服务的情况：
- ✅ 开发环境和测试环境
- ✅ 小到中型项目
- ✅ 需要简单快速部署
- ✅ 多个项目共享同一数据库实例
- ✅ 预算有限的项目

### 选择MySQL集群服务的情况：
- ✅ 生产环境高可用需求
- ✅ 大型项目或高并发应用
- ✅ 需要读写分离优化性能
- ✅ 要求数据冗余和故障恢复
- ✅ 24/7不间断服务需求

---

## 🔗 服务间的关系

### 独立性原则
1. **Gallery项目**: 可以连接到任何MySQL服务
2. **共享MySQL**: 独立运行，不依赖任何项目
3. **MySQL集群**: 完全独立的高可用解决方案

### 网络隔离
- **Gallery**: 使用默认bridge网络或自定义网络
- **共享MySQL**: 专用网络 `shared-mysql-network`
- **MySQL集群**: 专用网络 `mysql-cluster-network`

### 数据持久化
每个服务都有独立的数据卷，确保数据安全和隔离：
- Gallery: `gallery_backend_data`, `gallery_uploads`
- 共享MySQL: `shared_mysql_data`, `shared_mysql_backups`
- MySQL集群: `mysql_master_data`, `mysql_slave_data`, `mysql_cluster_logs`

---

## 📁 目录详细说明

### Gallery/ (核心Web应用)
```
Gallery/
├── backend/                 # FastAPI后端
│   ├── app/                # 应用代码
│   ├── alembic/            # 数据库迁移
│   └── requirements.txt    # Python依赖
├── frontend/               # Vue.js前端
│   ├── src/               # 源代码
│   ├── package.json       # Node.js依赖
│   └── vite.config.js     # 构建配置
├── docker-compose.yml     # 服务编排
├── deploy.sh             # 部署脚本
└── README.md            # 项目说明
```

### mysql-service/ (独立数据库)
```
mysql-service/
├── config/                          # MySQL配置
├── init/                           # 初始化脚本
├── backups/                        # 备份目录
├── docker-compose.independent-mysql.yml    # 服务配置
├── mysql-init.sql                  # 数据库初始化
├── deploy-independent-mysql.sh     # 部署脚本
├── gallery-independent-mysql.env   # 环境变量
└── INDEPENDENT_MYSQL_GUIDE.md     # 详细文档
```

### mysql_cluster/ (高可用集群)
```
mysql_cluster/
├── mysql-cluster-config/           # 集群配置
├── mysql-cluster-data/            # 数据目录
├── mysql-cluster-logs/            # 日志目录
├── docker-compose.mysql-cluster.yml    # 集群配置
├── deploy_mysql_cluster.sh        # 集群管理脚本
├── mysql-cluster.env             # 环境变量
├── test_cluster_config.sh        # 配置验证
└── README.md                     # 集群说明
```

---

## 🛠️ 管理命令总览

### Gallery项目
```bash
cd Gallery
./deploy.sh                    # 部署应用
./deploy.sh stop              # 停止应用
./deploy.sh logs              # 查看日志
```

### 独立MySQL服务
```bash
cd mysql-service
./deploy-independent-mysql.sh start      # 启动服务
./deploy-independent-mysql.sh stop       # 停止服务
./deploy-independent-mysql.sh status     # 查看状态
./deploy-independent-mysql.sh backup     # 备份数据
```

### MySQL集群
```bash
cd mysql_cluster
./deploy_mysql_cluster.sh start          # 启动集群
./deploy_mysql_cluster.sh stop           # 停止集群
./deploy_mysql_cluster.sh status         # 查看状态
./deploy_mysql_cluster.sh failover       # 故障转移
./test_cluster_config.sh                 # 验证配置
```

---

## 🔍 故障排除

### 常见问题
1. **端口冲突**: 检查各服务的端口配置
2. **网络问题**: 确认Docker网络配置
3. **权限问题**: 检查文件和目录权限
4. **数据库连接**: 验证连接字符串和认证信息

### 查看日志
```bash
# Gallery应用日志
cd Gallery && docker-compose logs -f

# 独立MySQL日志
cd mysql-service && docker-compose -f docker-compose.independent-mysql.yml logs -f

# MySQL集群日志
cd mysql_cluster && docker-compose -f docker-compose.mysql-cluster.yml logs -f
```

---

## 📚 文档索引

- **Gallery项目**: `Gallery/README.md`
- **独立MySQL**: `mysql-service/INDEPENDENT_MYSQL_GUIDE.md`
- **MySQL集群**: `mysql_cluster/README.md`
- **快速开始**: `mysql_cluster/MYSQL_CLUSTER_QUICK_START.md`

---

## 🏷️ 版本信息

- **项目重构日期**: 2025年1月
- **MySQL版本**: 8.0
- **Docker Compose版本**: 3.8+
- **Python版本**: 3.11+
- **Node.js版本**: 18+

---

**注意**: 本结构设计遵循微服务原则，确保每个组件都可以独立部署、扩展和维护。 