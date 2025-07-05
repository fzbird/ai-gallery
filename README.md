# AI Gallery - 智能图片库管理系统

一个基于 FastAPI + Vue.js 的现代化图片库管理系统，支持图片上传、分类管理、用户互动、内容推荐等功能。

## 🎉 最新更新

### 🚀 一键部署功能
- **智能化部署脚本** - 自动检测环境、配置CORS、更新数据库连接
- **多环境支持** - 开发环境(3300端口)、生产环境(80端口)、灵活环境(双端口)
- **自动化配置** - IP地址检测、环境变量自动生成和更新
- **端口灵活配置** - 支持不同的端口配置方案和反向代理模式

### 🔧 环境配置改进
- **配置模板系统** - 提供默认配置模板，支持手动修改
- **智能配置更新** - 保留用户手动配置，仅更新必要的部署配置
- **CORS自动配置** - 根据部署环境自动配置跨域访问权限
- **数据库自动配置** - MySQL服务器地址自动更新

### 🛠️ 部署体验优化
- **图片显示修复** - 修复了图集封面和图片显示问题
- **统一图片URL处理** - 前后端统一的图片路径处理机制
- **容器化改进** - 多种Docker Compose配置支持不同部署场景
- **故障排除指南** - 详细的问题诊断和解决方案

## ✨ 功能特性

### 🔐 用户管理
- **用户注册/登录** - 支持用户名密码登录，系统可配置开放注册
- **用户资料** - 头像、个人信息管理
- **用户关注** - 关注其他用户，查看关注者动态
- **权限管理** - 管理员、普通用户角色区分

### 📸 内容管理
- **图片上传** - 支持批量上传，自动生成缩略图
- **图集创建** - 将多张图片组织成图集
- **智能去重** - 基于文件哈希的重复文件检测
- **标签系统** - 为内容添加标签，便于分类和搜索
- **分类管理** - 多级分类支持，层次化内容组织

### 🎯 专题与推荐
- **专题系统** - 创建主题专题，策划精选内容
- **个性化推荐** - 基于用户行为的内容推荐
- **热门内容** - 展示系统热门图片和图集
- **时间线** - 按时间维度浏览内容

### 💫 互动功能
- **点赞收藏** - 对图片和图集进行点赞、收藏
- **评论系统** - 支持对图片和图集发表评论（可系统配置开关）
- **搜索功能** - 全文搜索图片、图集、用户
- **Feed流** - 关注用户的最新内容推送

### 🏢 组织架构
- **部门管理** - 支持组织内部的部门结构
- **权限控制** - 基于部门的内容访问控制

### ⚙️ 系统管理
- **管理后台** - 用户、内容、分类、专题的统一管理
- **系统设置** - 站点名称、Logo、注册开关、评论开关等配置
- **数据统计** - 用户、内容、互动等多维度数据分析
- **内容审核** - 图片、评论的审核管理

### 🚀 部署与运维
- **一键部署** - 智能化部署脚本，自动配置环境
- **多环境支持** - 开发、生产、灵活环境配置
- **自动化配置** - IP地址检测、CORS配置、数据库连接自动化
- **端口灵活配置** - 支持80端口、3300端口或双端口模式
- **环境变量管理** - 智能的环境配置文件管理
- **容器化部署** - Docker容器化，支持多种部署模式

## 🛠️ 技术栈

### 后端技术
- **FastAPI** - 现代化的 Python Web 框架
- **SQLAlchemy 2.0** - ORM 框架，支持异步操作
- **Alembic** - 数据库迁移工具
- **MySQL 8.0** - 主数据库
- **Pydantic v2** - 数据验证和序列化
- **JWT** - 用户认证和授权
- **Pillow** - 图片处理和缩略图生成

### 前端技术
- **Vue.js 3** - 渐进式 JavaScript 框架
- **Naive UI** - Vue 3 组件库
- **Pinia** - Vue 状态管理
- **Vue Router 4** - 前端路由
- **Axios** - HTTP 客户端
- **Chart.js** - 数据可视化
- **Vite** - 前端构建工具

### 部署工具
- **Docker** - 容器化部署
- **Docker Compose** - 多容器编排
- **Nginx** - 反向代理和静态文件服务

## 📦 快速开始

### 环境要求
- Python 3.8+
- Node.js 16+
- MySQL 8.0+
- Docker & Docker Compose (推荐)

### 🚀 一键部署（推荐）

1. **克隆项目**
```bash
git clone <repository-url>
cd Gallery
```

2. **运行一键部署脚本**
```bash
chmod +x deploy.sh
./deploy.sh
```

3. **选择部署环境**
```
选择部署环境：
1. 开发环境 (localhost:3300)
2. 生产环境 (localhost:80)
3. 灵活环境 (localhost:3300 和 localhost:80)
```

4. **选择API配置模式**
```
选择API配置模式：
1. 反向代理模式 (推荐) - 通过nginx代理
2. 环境变量模式 - 直接访问后端API
```

5. **自动化配置**
脚本会自动：
- 检测服务器IP地址
- 生成/更新环境配置文件
- 配置CORS跨域设置
- 更新数据库连接地址
- 构建并启动所有服务

6. **访问应用**
- 前端界面：http://服务器IP:端口
- 后端API：http://服务器IP:8000
- API文档：http://服务器IP:8000/docs

### 🔧 手动Docker部署

1. **克隆项目**
```bash
git clone <repository-url>
cd Gallery
```

2. **配置环境变量**
```bash
# 复制并编辑环境配置模板
cp backend/env.template backend/.env
# 编辑 backend/.env 文件，配置数据库连接等信息
```

3. **选择部署环境**
```bash
# 开发环境（仅3300端口）
docker-compose -f docker-compose.dev.yml up -d

# 生产环境（仅80端口）
docker-compose -f docker-compose.prod.yml up -d

# 灵活环境（双端口支持）
docker-compose up -d
```

4. **初始化数据库**
```bash
# 运行数据库迁移
docker-compose exec backend alembic upgrade head

# 创建管理员用户（可选）
docker-compose exec backend python initial_data.py
```

5. **访问应用**
- 前端界面：http://localhost:3300 或 http://localhost:80
- 后端API：http://localhost:8000
- API文档：http://localhost:8000/docs

### 手动部署

#### 后端设置

1. **创建虚拟环境**
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
```

2. **安装依赖**
```bash
pip install -r requirements.txt
```

3. **配置数据库**
```bash
# 创建MySQL数据库
mysql -u root -p
CREATE DATABASE gallery_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 设置环境变量
export DATABASE_URL="mysql://root:password@localhost:3306/gallery_db"
export SECRET_KEY="your-secret-key-here"
```

4. **运行数据库迁移**
```bash
alembic upgrade head
```

5. **启动后端服务**
```bash
uvicorn app.main:app --reload --port 8000
```

#### 前端设置

1. **安装依赖**
```bash
cd frontend
npm install
```

2. **配置环境变量**
```bash
# 创建 .env.local 文件
echo "VITE_API_URL=http://localhost:8000" > .env.local
```

3. **启动开发服务器**
```bash
npm run dev
```

4. **构建生产版本**
```bash
npm run build
```

## 🔧 配置说明

### 环境配置

#### 后端环境配置 (backend/.env)
```bash
# Gallery 后端环境配置
# 可以手动修改此文件，或使用deploy.sh自动配置

# CORS跨域配置
# 支持逗号分隔的多个地址
BACKEND_CORS_ORIGINS=http://localhost:3300,http://127.0.0.1:3300

# 数据库配置
# MySQL服务器地址 (自动部署时会更新为实际服务器地址)
DATABASE_URL=mysql+pymysql://用户名:密码@服务器IP:端口/数据库名?charset=utf8mb4

# 环境信息 (由部署脚本自动更新)
# DEPLOYMENT_ENV=开发环境
# DEPLOYMENT_MODE=手动配置
# SERVER_IP=localhost
# LAST_UPDATED=手动配置
```

#### 前端环境配置

**反向代理模式（推荐）**：
- 前端通过nginx代理访问后端
- 无需额外配置，自动处理API路由

**环境变量模式**：
```bash
# 前端环境变量 (frontend/.env)
VITE_API_URL=http://服务器IP:8000
```

### 多环境支持

#### 开发环境
- 端口：3300
- 适用于：开发测试
- 配置文件：`docker-compose.dev.yml`

#### 生产环境
- 端口：80
- 适用于：生产部署
- 配置文件：`docker-compose.prod.yml`

#### 灵活环境
- 端口：3300 + 80
- 适用于：多场景兼容
- 配置文件：`docker-compose.yml`

### 系统配置

管理员可以通过后台管理界面配置以下系统设置：

- **站点名称** - 自定义站点标题
- **站点Logo** - 上传自定义Logo
- **开放注册** - 控制是否允许新用户注册
- **开放评论** - 控制是否允许用户发表评论
- **文件上传限制** - 设置文件大小和类型限制

## 📚 API 文档

后端提供完整的 RESTful API，主要端点包括：

### 认证相关
- `POST /auth/login` - 用户登录
- `POST /auth/register` - 用户注册
- `POST /auth/refresh` - 刷新令牌

### 用户管理
- `GET /users/` - 获取用户列表
- `GET /users/{user_id}` - 获取用户详情
- `PUT /users/{user_id}` - 更新用户信息
- `POST /users/{user_id}/follow` - 关注/取消关注用户

### 内容管理
- `GET /images/` - 获取图片列表
- `POST /images/` - 上传图片
- `GET /images/{image_id}` - 获取图片详情
- `POST /images/{image_id}/like` - 点赞/取消点赞
- `POST /images/{image_id}/bookmark` - 收藏/取消收藏

### 图集管理
- `GET /galleries/` - 获取图集列表
- `POST /galleries/` - 创建图集
- `GET /galleries/{gallery_id}` - 获取图集详情
- `PUT /galleries/{gallery_id}` - 更新图集信息

### 分类和标签
- `GET /categories/` - 获取分类树
- `POST /categories/` - 创建分类
- `GET /tags/` - 获取标签列表

### 专题管理
- `GET /topics/` - 获取专题列表
- `POST /topics/` - 创建专题
- `GET /topics/{topic_id}/galleries` - 获取专题下的图集

### 评论系统
- `GET /comments/` - 获取评论列表
- `POST /comments/` - 发表评论
- `DELETE /comments/{comment_id}` - 删除评论

详细的API文档可以在启动后端服务后访问 `http://localhost:8000/docs` 查看。

## 🏗️ 项目结构

```
Gallery/
├── backend/                 # 后端代码
│   ├── app/
│   │   ├── api/            # API路由
│   │   ├── core/           # 核心配置
│   │   ├── crud/           # 数据库操作
│   │   ├── db/             # 数据库连接
│   │   ├── models/         # 数据模型
│   │   ├── schemas/        # Pydantic模式
│   │   └── services/       # 业务逻辑
│   ├── alembic/            # 数据库迁移
│   ├── uploads/            # 文件上传目录
│   ├── env.template        # 环境配置模板
│   └── requirements.txt    # Python依赖
├── frontend/               # 前端代码
│   ├── src/
│   │   ├── api/           # API调用
│   │   ├── components/    # Vue组件
│   │   ├── stores/        # Pinia状态管理
│   │   ├── views/         # 页面组件
│   │   └── utils/         # 工具函数
│   ├── public/            # 静态资源
│   └── package.json       # Node.js依赖
├── docker-compose.yml      # Docker编排（灵活环境）
├── docker-compose.dev.yml  # 开发环境配置
├── docker-compose.prod.yml # 生产环境配置
├── deploy.sh              # 一键部署脚本
├── DOCKER_PORT_GUIDE.md   # 端口配置指南
├── ENV_CONFIG_IMPROVEMENT.md # 环境配置改进说明
└── README.md              # 项目说明
```

## 🎨 界面展示

系统提供现代化的响应式界面：

- **首页** - 展示最新、热门内容
- **分类浏览** - 按分类层次浏览内容
- **搜索页面** - 全文搜索功能
- **用户中心** - 个人资料、上传记录、互动历史
- **管理后台** - 数据统计、内容管理、系统配置

## 📈 数据统计

系统提供丰富的数据统计功能：

- **用户统计** - 注册用户数、活跃用户、用户增长趋势
- **内容统计** - 图片数量、图集数量、上传趋势
- **互动统计** - 点赞数、评论数、收藏数
- **分类统计** - 各分类下的内容分布
- **热门排行** - 最受欢迎的内容和用户

## 🚀 性能优化

- **图片处理** - 自动生成多种规格缩略图
- **缓存策略** - 静态资源缓存、API响应缓存
- **数据库优化** - 索引优化、查询优化
- **CDN支持** - 静态资源CDN分发
- **懒加载** - 图片懒加载、分页加载

## 🔒 安全特性

- **身份认证** - JWT令牌认证
- **权限控制** - 基于角色的访问控制
- **数据验证** - 严格的输入验证
- **SQL注入防护** - ORM防SQL注入
- **XSS防护** - 前端内容过滤
- **文件上传安全** - 文件类型和大小限制

## 🐛 故障排除

### 常见问题

1. **部署脚本运行失败**
   - 确保脚本有执行权限：`chmod +x deploy.sh`
   - 检查Docker和Docker Compose是否正确安装
   - 确认当前用户有Docker权限

2. **IP地址检测错误**
   - 脚本自动检测IP，如果检测错误可手动编辑 `backend/.env` 文件
   - Windows用户确保使用Git Bash或WSL运行脚本

3. **端口冲突**
   - 检查80端口或3300端口是否被其他服务占用
   - 可以选择不同的部署环境避免冲突

4. **CORS跨域错误**
   - 一键部署脚本会自动配置CORS
   - 如果手动配置，确保 `backend/.env` 中的 `BACKEND_CORS_ORIGINS` 包含正确的前端地址

5. **数据库连接失败**
   - 检查MySQL服务是否启动
   - 验证数据库连接字符串配置
   - 一键部署脚本会自动更新数据库地址

6. **前端页面无法访问**
   - 检查选择的部署环境对应的端口
   - 确认nginx容器是否正常启动
   - 检查防火墙设置

7. **图片显示异常**
   - 检查uploads目录权限
   - 确认图片文件路径配置正确

### 配置检查

```bash
# 检查当前配置
cat backend/.env

# 检查容器状态
docker-compose ps

# 检查端口使用
netstat -tlnp | grep :80
netstat -tlnp | grep :3300
```

### 日志查看

```bash
# 查看后端日志
docker-compose logs backend

# 查看前端日志
docker-compose logs frontend

# 查看数据库日志
docker-compose logs db

# 查看nginx日志
docker-compose logs nginx
```

### 重新部署

```bash
# 停止所有服务
docker-compose down

# 清理容器和镜像（可选）
docker system prune -a

# 重新运行部署脚本
./deploy.sh
```

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

此项目使用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📧 联系方式

如有问题或建议，请通过以下方式联系：

- 项目Issues: [GitHub Issues](https://github.com/fzbird/ai-gallery/issues)
- 邮箱: 36178831@qq.com

## 🙏 致谢

感谢以下开源项目的支持：

- [FastAPI](https://fastapi.tiangolo.com/) - 现代化的Python Web框架
- [Vue.js](https://vuejs.org/) - 渐进式JavaScript框架
- [Naive UI](https://www.naiveui.com/) - Vue 3组件库
- [SQLAlchemy](https://www.sqlalchemy.org/) - Python SQL工具包
- [MySQL](https://www.mysql.com/) - 开源关系型数据库

---

⭐ 如果这个项目对你有帮助，请给它一个 Star！ 