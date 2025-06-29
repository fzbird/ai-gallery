# AI Gallery - 智能图片库管理系统

一个基于 FastAPI + Vue.js 的现代化图片库管理系统，支持图片上传、分类管理、用户互动、内容推荐等功能。

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

## 🛠️ 技术栈

### 后端技术
- **FastAPI** - 现代化的 Python Web 框架
- **SQLAlchemy 2.0** - ORM 框架，支持异步操作
- **Alembic** - 数据库迁移工具
- **PostgreSQL** - 主数据库
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
- PostgreSQL 12+
- Docker & Docker Compose (可选)

### 使用 Docker 部署（推荐）

1. **克隆项目**
```bash
git clone <repository-url>
cd Gallery
```

2. **配置环境变量**
```bash
# 复制并编辑环境配置
cp .env.example .env
# 编辑 .env 文件，配置数据库连接等信息
```

3. **启动服务**
```bash
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
- 前端界面：http://localhost:3000
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
# 创建PostgreSQL数据库
createdb gallery_db

# 设置环境变量
export DATABASE_URL="postgresql://username:password@localhost/gallery_db"
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

### 环境变量

#### 后端环境变量
```bash
# 数据库配置
DATABASE_URL=postgresql://username:password@localhost/gallery_db

# 安全配置
SECRET_KEY=your-jwt-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 文件上传配置
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760  # 10MB

# CORS配置
ALLOWED_ORIGINS=["http://localhost:3000"]
```

#### 前端环境变量
```bash
# API地址配置
VITE_API_URL=http://localhost:8000
```

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
├── docker-compose.yml      # Docker编排
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

1. **数据库连接失败**
   - 检查PostgreSQL服务是否启动
   - 验证数据库连接字符串配置

2. **文件上传失败**
   - 检查上传目录权限
   - 验证文件大小限制设置

3. **前端构建失败**
   - 清除node_modules并重新安装依赖
   - 检查Node.js版本兼容性

4. **API请求跨域错误**
   - 检查后端CORS配置
   - 验证前端API地址配置

### 日志查看

```bash
# 查看后端日志
docker-compose logs backend

# 查看前端日志
docker-compose logs frontend

# 查看数据库日志
docker-compose logs postgres
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

- 项目Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 邮箱: 36178831@qq.com

## 🙏 致谢

感谢以下开源项目的支持：

- [FastAPI](https://fastapi.tiangolo.com/) - 现代化的Python Web框架
- [Vue.js](https://vuejs.org/) - 渐进式JavaScript框架
- [Naive UI](https://www.naiveui.com/) - Vue 3组件库
- [SQLAlchemy](https://www.sqlalchemy.org/) - Python SQL工具包
- [PostgreSQL](https://www.postgresql.org/) - 开源关系型数据库

---

⭐ 如果这个项目对你有帮助，请给它一个 Star！ 