<template>
  <div class="help-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>帮助中心</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">帮助中心</h1>
          <p class="page-subtitle">OurGallery 图片分享平台使用指南</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 快速导航 -->
        <div class="quick-nav">
          <n-card class="nav-card">
            <div class="nav-grid">
              <div class="nav-item" @click="scrollToSection('upload')">
                <div class="nav-icon">📤</div>
                <div class="nav-text">上传图片</div>
              </div>
              <div class="nav-item" @click="scrollToSection('gallery')">
                <div class="nav-icon">🖼️</div>
                <div class="nav-text">创建图集</div>
              </div>
              <div class="nav-item" @click="scrollToSection('browse')">
                <div class="nav-icon">👀</div>
                <div class="nav-text">浏览查看</div>
              </div>
              <div class="nav-item" @click="scrollToSection('manage')">
                <div class="nav-icon">⚙️</div>
                <div class="nav-text">内容管理</div>
              </div>
            </div>
          </n-card>
        </div>

        <!-- 帮助内容 -->
        <div class="help-content">
          <!-- 上传图片 -->
          <n-card class="help-card" id="upload">
            <template #header>
              <div class="card-header">
                <span class="card-icon">📤</span>
                <span class="card-title">上传图片</span>
              </div>
            </template>
            <div class="help-section">
              <h3>单张图片上传</h3>
              <ol>
                <li>点击页面顶部的"上传"按钮</li>
                <li>选择要上传的图片文件（支持 JPG、PNG、GIF、WebP 等格式）</li>
                <li>填写图片标题和描述（可选）</li>
                <li>选择分类和添加标签（可选）</li>
                <li>点击"上传"完成上传</li>
              </ol>

              <h3>批量上传</h3>
              <ol>
                <li>在上传页面选择多张图片</li>
                <li>系统会自动处理所有选中的图片</li>
                <li>可以为所有图片设置统一的分类和标签</li>
                <li>也可以为每张图片单独设置信息</li>
              </ol>

              <h3>上传要求</h3>
              <ul>
                <li>支持格式：JPG、JPEG、PNG、GIF、WebP、TIFF、SVG、BMP</li>
                <li>文件大小：单张图片不超过 50MB</li>
                <li>图片分辨率：建议不超过 8000x8000 像素</li>
                <li>内容要求：确保拥有图片的合法使用权</li>
              </ul>
            </div>
          </n-card>

          <!-- 创建图集 -->
          <n-card class="help-card" id="gallery">
            <template #header>
              <div class="card-header">
                <span class="card-icon">🖼️</span>
                <span class="card-title">创建图集</span>
              </div>
            </template>
            <div class="help-section">
              <h3>创建新图集</h3>
              <ol>
                <li>点击页面顶部的"创建图集"按钮</li>
                <li>填写图集标题和描述</li>
                <li>选择图集分类</li>
                <li>上传图集封面图片（可选）</li>
                <li>选择要包含的图片</li>
                <li>点击"创建"完成图集创建</li>
              </ol>

              <h3>图集管理</h3>
              <ul>
                <li><strong>编辑图集：</strong>在图集详情页面点击"编辑"按钮</li>
                <li><strong>添加图片：</strong>在编辑模式下可以添加新图片到图集</li>
                <li><strong>删除图片：</strong>可以移除图集中的特定图片</li>
                <li><strong>设置封面：</strong>可以选择图集中的任意图片作为封面</li>
              </ul>

              <h3>图集设置</h3>
              <ul>
                <li><strong>公开性：</strong>可以设置图集为公开或私有</li>
                <li><strong>标签：</strong>为图集添加相关标签便于搜索</li>
                <li><strong>权限：</strong>可以设置其他用户的访问权限</li>
              </ul>
            </div>
          </n-card>

          <!-- 浏览查看 -->
          <n-card class="help-card" id="browse">
            <template #header>
              <div class="card-header">
                <span class="card-icon">👀</span>
                <span class="card-title">浏览查看</span>
              </div>
            </template>
            <div class="help-section">
              <h3>首页浏览</h3>
              <ul>
                <li><strong>最新内容：</strong>首页显示最新上传的图片和图集</li>
                <li><strong>热门内容：</strong>可以查看最受欢迎的图片和图集</li>
                <li><strong>分类浏览：</strong>通过分类快速找到相关内容</li>
                <li><strong>搜索功能：</strong>使用关键词搜索图片和图集</li>
              </ul>

              <h3>图集查看模式</h3>
              <ul>
                <li><strong>超大图标：</strong>以最大尺寸显示图片卡片</li>
                <li><strong>大图标：</strong>适中的卡片尺寸显示</li>
                <li><strong>小图标：</strong>紧凑的卡片布局</li>
                <li><strong>详细列表：</strong>以列表形式显示图片信息</li>
                <li><strong>幻灯片：</strong>全屏幻灯片播放模式</li>
              </ul>

              <h3>图片详情</h3>
              <ul>
                <li><strong>查看大图：</strong>点击图片可以查看大尺寸版本</li>
                <li><strong>图片信息：</strong>查看图片的详细信息和元数据</li>
                <li><strong>下载图片：</strong>可以下载原始图片文件</li>
                <li><strong>点赞收藏：</strong>对喜欢的图片进行点赞和收藏</li>
              </ul>
            </div>
          </n-card>

          <!-- 内容管理 -->
          <n-card class="help-card" id="manage">
            <template #header>
              <div class="card-header">
                <span class="card-icon">⚙️</span>
                <span class="card-title">内容管理</span>
              </div>
            </template>
            <div class="help-section">
              <h3>个人内容管理</h3>
              <ul>
                <li><strong>我的上传：</strong>在个人页面查看所有上传的图片</li>
                <li><strong>我的图集：</strong>管理个人创建的所有图集</li>
                <li><strong>我的收藏：</strong>查看收藏的图片和图集</li>
                <li><strong>我的点赞：</strong>查看点赞过的内容</li>
              </ul>

              <h3>内容编辑</h3>
              <ul>
                <li><strong>修改信息：</strong>编辑图片或图集的标题、描述</li>
                <li><strong>重新分类：</strong>更改内容的分类归属</li>
                <li><strong>添加标签：</strong>为内容添加或修改标签</li>
                <li><strong>删除内容：</strong>删除不需要的图片或图集</li>
              </ul>

              <h3>权限管理</h3>
              <ul>
                <li><strong>公开设置：</strong>控制内容的可见性</li>
                <li><strong>访问权限：</strong>设置特定用户的访问权限</li>
                <li><strong>下载权限：</strong>控制是否允许下载</li>
              </ul>
            </div>
          </n-card>

          <!-- 常见问题 -->
          <n-card class="help-card">
            <template #header>
              <div class="card-header">
                <span class="card-icon">❓</span>
                <span class="card-title">常见问题</span>
              </div>
            </template>
            <div class="help-section">
              <div class="faq-item">
                <h4>Q: 上传图片失败怎么办？</h4>
                <p>A: 请检查图片格式是否支持、文件大小是否超限，确保网络连接正常。如仍有问题，请联系管理员。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 如何批量管理图片？</h4>
                <p>A: 在个人页面的"我的上传"中，可以选择多张图片进行批量操作，如批量删除、批量修改分类等。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 忘记密码怎么办？</h4>
                <p>A: 请联系企业IT部门或平台管理员重置密码。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 如何设置图片为私有？</h4>
                <p>A: 在上传图片或编辑图片时，在权限设置中选择"私有"，这样只有您自己可以看到。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 支持哪些图片格式？</h4>
                <p>A: 支持 JPG、JPEG、PNG、GIF、WebP、TIFF、SVG、BMP 等常见图片格式。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 如何联系管理员？</h4>
                <p>A: 可以通过邮件联系：admin@ourgallery.com，或联系企业IT支持团队。</p>
              </div>
            </div>
          </n-card>

          <!-- 联系支持 -->
          <n-card class="help-card">
            <template #header>
              <div class="card-header">
                <span class="card-icon">📞</span>
                <span class="card-title">联系支持</span>
              </div>
            </template>
            <div class="help-section">
              <div class="support-info">
                <h3>技术支持</h3>
                <ul>
                  <li><strong>邮箱：</strong>support@ourgallery.com</li>
                  <li><strong>管理员：</strong>平台管理员</li>
                  <li><strong>IT部门：</strong>企业IT支持团队</li>
                </ul>

                <h3>服务时间</h3>
                <p>工作日：9:00 - 18:00</p>
                <p>紧急问题：24小时响应</p>

                <h3>反馈建议</h3>
                <p>如果您有任何建议或发现系统问题，欢迎通过以上方式联系我们。我们会认真处理每一条反馈。</p>
              </div>
            </div>
          </n-card>
        </div>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#667eea" />
  </div>
</template>

<script setup>
import AppFooter from '@/components/AppFooter.vue';
import { NBreadcrumb, NBreadcrumbItem, NCard } from 'naive-ui';

// 滚动到指定区域
const scrollToSection = (sectionId) => {
  const element = document.getElementById(sectionId);
  if (element) {
    element.scrollIntoView({ 
      behavior: 'smooth',
      block: 'start'
    });
  }
};
</script>

<style scoped>
.help-page {
  padding-top: 64px;
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 16px;
}

.breadcrumb :deep(.n-breadcrumb-item__link) {
  color: rgba(255, 255, 255, 0.8);
}

.breadcrumb :deep(.n-breadcrumb-item__link:hover) {
  color: white;
}

.breadcrumb :deep(.n-breadcrumb-item__separator) {
  color: rgba(255, 255, 255, 0.6);
}

.page-title-section {
  text-align: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 32px;
  font-weight: bold;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.page-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

/* 快速导航 */
.quick-nav {
  margin-bottom: 32px;
}

.nav-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.nav-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  border-radius: 8px;
  background: #f8fafc;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.nav-item:hover {
  background: #e0e7ff;
  border-color: #667eea;
  transform: translateY(-2px);
}

.nav-icon {
  font-size: 32px;
  margin-bottom: 12px;
}

.nav-text {
  font-size: 16px;
  font-weight: 600;
  color: #374151;
  text-align: center;
}

/* 帮助内容 */
.help-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.help-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.card-icon {
  font-size: 24px;
}

.card-title {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
}

.help-section {
  line-height: 1.8;
  color: #374151;
}

.help-section h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 24px 0 12px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid #e5e7eb;
}

.help-section h4 {
  font-size: 16px;
  font-weight: 600;
  color: #374151;
  margin: 20px 0 8px 0;
}

.help-section p {
  margin: 12px 0;
  font-size: 16px;
}

.help-section ul,
.help-section ol {
  margin: 12px 0;
  padding-left: 24px;
}

.help-section li {
  margin: 8px 0;
  font-size: 16px;
}

.help-section strong {
  color: #1f2937;
  font-weight: 600;
}

/* FAQ样式 */
.faq-item {
  margin: 24px 0;
  padding: 16px;
  background: #f9fafb;
  border-radius: 8px;
  border-left: 4px solid #667eea;
}

.faq-item h4 {
  color: #1f2937;
  margin: 0 0 8px 0;
}

.faq-item p {
  margin: 0;
  color: #6b7280;
}

/* 支持信息 */
.support-info {
  background: #f0f9ff;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid #bae6fd;
}

.support-info h3 {
  color: #0369a1;
  margin: 16px 0 8px 0;
}

.support-info ul {
  margin: 8px 0;
}

.support-info li {
  margin: 4px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 24px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-header {
    padding: 16px 0;
  }

  .main-content {
    padding: 20px 0;
  }

  .nav-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }

  .nav-item {
    padding: 16px;
  }

  .nav-icon {
    font-size: 24px;
  }

  .nav-text {
    font-size: 14px;
  }

  .card-title {
    font-size: 18px;
  }

  .help-section h3 {
    font-size: 16px;
  }

  .help-section p,
  .help-section li {
    font-size: 15px;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 20px;
  }

  .page-subtitle {
    font-size: 13px;
  }

  .container {
    padding: 0 12px;
  }

  .main-content {
    padding: 12px 0;
  }

  .nav-grid {
    grid-template-columns: 1fr;
  }

  .nav-item {
    padding: 12px;
  }

  .nav-icon {
    font-size: 20px;
  }

  .nav-text {
    font-size: 13px;
  }

  .card-title {
    font-size: 16px;
  }

  .help-section h3 {
    font-size: 15px;
  }

  .help-section p,
  .help-section li {
    font-size: 14px;
  }

  .faq-item {
    padding: 12px;
  }
}
</style> 