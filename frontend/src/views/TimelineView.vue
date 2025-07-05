<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NTimeline, NTimelineItem, NCard, NTag, NSpace, NIcon, NButton } from 'naive-ui';
import { HeartOutline as LikeIcon, BookmarkOutline as BookmarkIcon, ImageOutline as ImageIcon, TimeOutline as TimeIcon } from '@vicons/ionicons5';
import { useRouter } from 'vue-router';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const galleryStore = useGalleryStore();
const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);

// 按日期分组的图集
const groupedGalleries = computed(() => {
  const groups = {};
  
  galleries.value.forEach(gallery => {
    // 模拟创建日期（实际应该从API获取）
    const date = gallery.created_at ? new Date(gallery.created_at) : new Date();
    const dateKey = date.toLocaleDateString('zh-CN');
    
    if (!groups[dateKey]) {
      groups[dateKey] = [];
    }
    
    groups[dateKey].push({
      ...gallery,
      coverImage: gallery.cover_image || (gallery.images && gallery.images.length > 0 ? gallery.images[0] : null),
      imageCount: gallery.image_count || (gallery.images ? gallery.images.length : 0),
      likesCount: gallery.likes_count || 0,
      bookmarksCount: gallery.bookmarks_count || 0,
      author: gallery.owner?.username || '摄影师',
      timeString: date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
    });
  });
  
  // 转换为数组并按日期排序
  return Object.entries(groups)
    .map(([date, items]) => ({ date, items }))
    .sort((a, b) => new Date(b.date) - new Date(a.date));
});

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

function viewUser(username) {
  router.push({ name: 'profile', params: { username } });
}

function loadMore() {
  galleryStore.fetchTimelineGalleries(false);
}

// 底部数据




onMounted(() => {
  galleryStore.resetState();
  galleryStore.fetchTimelineGalleries(true);
});
</script>

<template>
  <div class="timeline-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>时间线</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">时间线</h1>
          <p class="page-subtitle">按时间顺序浏览图集更新历程</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <div class="timeline-container">
          <n-timeline v-if="groupedGalleries.length > 0">
            <n-timeline-item 
              v-for="(group, index) in groupedGalleries" 
              :key="group.date"
              :color="index === 0 ? '#667eea' : '#d1d5db'"
            >
              <template #header>
                <div class="timeline-date">
                  <n-icon><TimeIcon /></n-icon>
                  <span>{{ group.date }}</span>
                  <n-tag size="small" type="info">{{ group.items.length }} 个图集</n-tag>
                </div>
              </template>
              
              <div class="timeline-content">
                <div class="galleries-timeline-grid">
                  <div 
                    v-for="gallery in group.items" 
                    :key="gallery.id"
                    class="timeline-gallery-card"
                    @click="viewGallery(gallery)"
                  >
                    <!-- 图集缩略图 -->
                    <div class="timeline-gallery-thumb">
                      <img 
                        v-if="gallery.coverImage && gallery.coverImage.image_url" 
                        :src="`${API_BASE_URL}${gallery.coverImage.image_url}`" 
                        :alt="gallery.title"
                        class="cover-image"
                        loading="lazy"
                      >
                      <div v-else class="no-thumb">
                        <n-icon size="20" color="#ccc">
                          <ImageIcon />
                        </n-icon>
                      </div>
                      <div class="image-count-badge">{{ gallery.imageCount }}P</div>
                    </div>

                    <!-- 图集信息 -->
                    <div class="timeline-gallery-info">
                      <div class="gallery-header">
                        <h4 class="gallery-title">{{ gallery.title }}</h4>
                        <span class="upload-time">{{ gallery.timeString }}</span>
                      </div>
                      
                      <div class="gallery-meta">
                        <span class="author" @click.stop="viewUser(gallery.author)">
                          {{ gallery.author }}
                        </span>
                        <div class="stats">
                          <span class="stat-item">
                            <n-icon><LikeIcon /></n-icon>
                            {{ gallery.likesCount }}
                          </span>
                          <span class="stat-item">
                            <n-icon><BookmarkIcon /></n-icon>
                            {{ gallery.bookmarksCount }}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </n-timeline-item>
          </n-timeline>

          <!-- 空状态 -->
          <div v-else-if="!isLoading" class="empty-state">
            <n-icon size="60" color="#d1d5db">
              <TimeIcon />
            </n-icon>
            <h3>暂无时间线数据</h3>
            <p>还没有图集上传记录</p>
          </div>

          <!-- 加载更多 -->
          <div class="load-more-section">
            <n-button 
              v-if="hasMore && groupedGalleries.length > 0" 
              @click="loadMore"
              :loading="isLoading"
              size="large"
              type="primary"
              ghost
              class="load-more-btn"
            >
              加载更多历史记录
            </n-button>
          </div>
        </div>
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#6366f1" />
  </div>
</template>

<style scoped>
.timeline-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 50%, #4338ca 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0;
}

.container {
  max-width: 1400px;
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

.timeline-container {
  max-width: 800px;
  margin: 0 auto;
}

.timeline-date {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #374151;
}

.timeline-content {
  margin-top: 16px;
}

.galleries-timeline-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.timeline-gallery-card {
  display: flex;
  background: white;
  border-radius: 8px;
  padding: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.2s ease;
  cursor: pointer;
}

.timeline-gallery-card:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.timeline-gallery-thumb {
  position: relative;
  width: 80px;
  height: 60px;
  flex-shrink: 0;
  margin-right: 12px;
  border-radius: 6px;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-thumb {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}

.image-count-badge {
  position: absolute;
  top: 4px;
  right: 4px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 6px;
  border-radius: 8px;
  font-size: 10px;
  font-weight: 500;
}

.timeline-gallery-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.gallery-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.gallery-title {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  line-height: 1.4;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.upload-time {
  font-size: 12px;
  color: #9ca3af;
  flex-shrink: 0;
  margin-left: 8px;
}

.gallery-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
}

.author {
  color: #667eea;
  cursor: pointer;
  font-weight: 500;
}

.author:hover {
  color: #4c51bf;
}

.stats {
  display: flex;
  gap: 8px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 2px;
  color: #6b7280;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #9ca3af;
}

.empty-state h3 {
  margin: 16px 0 8px 0;
  font-size: 18px;
  color: #6b7280;
}

.empty-state p {
  margin: 0;
  font-size: 14px;
}

/* 加载更多 */
.load-more-section {
  text-align: center;
  padding: 32px 0;
}

.load-more-btn {
  padding: 12px 32px;
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 28px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .timeline-container {
    max-width: 100%;
  }

  .timeline-gallery-card {
    padding: 10px;
  }

  .timeline-gallery-thumb {
    width: 60px;
    height: 45px;
    margin-right: 10px;
  }

  .gallery-title {
    font-size: 13px;
  }

  .gallery-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .upload-time {
    margin-left: 0;
  }
}

/* 页脚 */
.footer {
  background: #1f2937;
  color: white;
  padding: 40px 0;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-content p {
  margin: 0;
  color: #9ca3af;
}

.footer-links {
  display: flex;
  gap: 24px;
}

.footer-links a {
  color: #9ca3af;
  text-decoration: none;
  transition: color 0.2s ease;
}

.footer-links a:hover {
  color: white;
}

/* 响应式设计扩展 */
@media (max-width: 768px) {
  .links-content {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  
  .footer-content {
    flex-direction: column;
    text-align: center;
  }
  
  .footer-links {
    justify-content: center;
  }
}
</style> 