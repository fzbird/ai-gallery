# Gallery 数据库初始化指南

## 🎯 概述

Gallery 系统现在支持完全自动化的数据库初始化，包括：
- 📊 完整的数据库结构创建
- 🖼️  从网络下载真实示例图片
- 👥 创建示例用户和数据
- 📚 生成图集和分类数据
- 🏷️  添加标签和主题

## 🚀 自动初始化

### 使用 deploy_linux.sh（推荐）

部署脚本会自动检测数据库状态并初始化：

```bash
./deploy_linux.sh
```

**自动初始化流程：**
1. 启动 MySQL 容器
2. 运行数据库迁移 (alembic)
3. 检查是否已有用户数据
4. 如果数据库为空，自动运行初始化脚本
5. 下载示例图片并创建完整数据

### 初始化包含的数据

#### 👥 用户数据 (20个用户)
- **管理员**: `admin@gallery.com` / `admin123456`
- **预设用户**: 
  - `zhang@gallery.com` - 张伟 (风光摄影师)
  - `li@gallery.com` - 李娜 (平面设计师)
  - `wang@gallery.com` - 王芳 (数字艺术家)
  - `liu@gallery.com` - 刘强 (街头摄影师)
  - `chen@gallery.com` - 陈静 (人像摄影师)
- **随机用户**: `user001@gallery.com` ~ `user020@gallery.com`
- **统一密码**: `password123`

#### 🏢 组织数据
- **部门**: 摄影部、设计部、艺术部、媒体部、策划部
- **分类**: 多级分类结构
  - 摄影作品 → 风光摄影、人像摄影、街头摄影等
  - 设计作品 → 海报设计、UI设计、品牌设计等
  - 艺术创作 → 油画、水彩画、素描等
- **主题**: 春日物语、城市印象、人像艺术、自然之美等
- **标签**: 30+ 个常用标签

#### 🖼️  图片数据 (160张图片)
- **来源**: Unsplash、Lorem Picsum 等免费图片服务
- **分类**: 根据主题自动分类和标签
- **优化**: 自动压缩和尺寸调整
- **元数据**: 包含标题、描述、AI分析结果

#### 📚 图集数据 (40个图集)
- **自动创建**: 每个用户1-2个图集
- **智能分组**: 3-6张相关图片组成图集
- **封面设置**: 自动选择第一张图片作为封面

#### 💝 互动数据
- **点赞**: 随机用户点赞
- **收藏**: 随机收藏内容
- **统计**: 自动更新浏览量、点赞数等

## 🔧 手动初始化

### 使用手动初始化脚本

如果需要重新初始化或部分初始化：

```bash
./manual_init_database.sh
```

**可选模式：**
1. **完全重新初始化**: 清空所有数据并重建
2. **仅添加示例数据**: 保留现有用户，添加示例内容
3. **仅重新下载图片**: 重新下载所有图片文件

### 单独运行初始化脚本

在容器内直接运行：

```bash
# 进入后端容器
docker exec -it gallery_backend bash

# 运行初始化脚本
python init_database_with_demo.py
```

## 📁 文件结构

初始化后的文件结构：

```
backend/uploads/
├── images/          # 用户上传的图片
│   ├── img_123456_1_0.jpg
│   ├── img_123456_1_1.jpg
│   └── ...
├── galleries/       # 图集相关文件
├── topics/          # 主题相关文件
└── temp/           # 临时文件
```

## ⚙️ 配置参数

可以修改 `init_database_with_demo.py` 中的配置：

```python
CONFIG = {
    'USERS_COUNT': 20,          # 用户数量
    'IMAGES_PER_USER': 8,       # 每用户图片数
    'GALLERIES_PER_USER': 2,    # 每用户图集数
    'DOWNLOAD_TIMEOUT': 30,     # 下载超时时间
    'IMAGE_QUALITY': 85,        # 图片质量
    'MAX_IMAGE_SIZE': (1200, 1200),  # 最大图片尺寸
}
```

## 🔍 图片下载源

系统从以下源下载示例图片：

1. **Unsplash**: 高质量摄影作品
   - 风光: `https://source.unsplash.com/1200x800/?landscape`
   - 人像: `https://source.unsplash.com/1200x800/?portrait`
   - 街头: `https://source.unsplash.com/1200x800/?street`

2. **Lorem Picsum**: 随机图片
   - `https://picsum.photos/1200/800`

## 🐛 故障排除

### 问题1: 图片下载失败

**现象**: 某些图片显示为空或下载失败

**解决方案**:
```bash
# 检查网络连接
curl -I https://source.unsplash.com/800x600

# 重新下载图片
./manual_init_database.sh
# 选择模式3：仅重新下载图片
```

### 问题2: 数据库连接失败

**现象**: 初始化过程中报数据库连接错误

**解决方案**:
```bash
# 检查MySQL容器状态
docker logs mysql_db

# 重启数据库容器
docker restart mysql_db

# 等待数据库启动后重试
sleep 20
./manual_init_database.sh
```

### 问题3: 权限问题

**现象**: 无法创建上传目录或写入文件

**解决方案**:
```bash
# 检查容器内权限
docker exec gallery_backend ls -la /app/uploads

# 重建容器
docker-compose down
docker-compose up -d --build
```

### 问题4: 内存不足

**现象**: 图片下载或处理过程中内存不足

**解决方案**:
- 减少 `USERS_COUNT` 和 `IMAGES_PER_USER` 参数
- 调小 `MAX_IMAGE_SIZE` 配置
- 增加服务器内存

## 📊 验证初始化结果

### 检查数据统计

```bash
# 通过API检查
curl http://localhost:8000/api/v1/users/?skip=0&limit=1

# 或在容器内检查
docker exec gallery_backend python -c "
from app.db.session import SessionLocal
from app.models.user import User
from app.models.image import Image
from app.models.gallery import Gallery

db = SessionLocal()
print(f'用户: {db.query(User).count()}')
print(f'图片: {db.query(Image).count()}')
print(f'图集: {db.query(Gallery).count()}')
db.close()
"
```

### 访问前端验证

1. 打开浏览器访问系统
2. 使用管理员账号登录: `admin@gallery.com` / `admin123456`
3. 检查各个页面的数据显示
4. 验证图片是否正常加载

## 🎯 最佳实践

1. **首次部署**: 直接使用 `deploy_linux.sh`，让系统自动初始化
2. **开发测试**: 使用 `manual_init_database.sh` 的模式1重置数据
3. **生产环境**: 建议手动创建管理员用户，而不使用示例数据
4. **备份数据**: 在重新初始化前备份重要数据
5. **监控日志**: 初始化过程中观察容器日志

## 📝 自定义初始化

如需自定义初始化数据：

1. 复制 `init_database_with_demo.py` 为新文件
2. 修改 `DEMO_DATA` 字典中的数据
3. 调整配置参数
4. 在 `entrypoint.sh` 中替换脚本名称

---

🎉 **完成**: 按照本指南，您应该能够成功初始化 Gallery 数据库并获得丰富的示例数据！ 