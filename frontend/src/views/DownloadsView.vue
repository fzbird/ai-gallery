<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NCard, NStatistic, NIcon, NTag } from 'naive-ui';
import {
  DownloadOutline as DownloadIcon,
  ArrowDownOutline as ArrowDownIcon,
  PodiumOutline as PodiumIcon,
  TrendingUpOutline as TrendingUpIcon,
  AlertCircleOutline as AlertIcon
} from '@vicons/ionicons5';
import GalleryGrid from '@/components/GalleryGrid.vue';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const galleryStore = useGalleryStore();
const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);

// 下载榜统计
const downloadsStats = computed(() => {
  if (galleries.value.length === 0) return { total: 0, maxDownloads: 0, avgDownloads: 0, totalBookmarks: 0 };
  
  const downloadsArray = galleries.value.map(g => g.views_count || 0); // 使用views_count作为下载量
  const bookmarksArray = galleries.value.map(g => g.bookmarks_count || 0);
  const total = galleries.value.length;
  const maxDownloads = Math.max(...downloadsArray);
  const avgDownloads = Math.round(downloadsArray.reduce((a, b) => a + b, 0) / total);
  const totalBookmarks = bookmarksArray.reduce((a, b) => a + b, 0);
  
  return { total, maxDownloads, avgDownloads, totalBookmarks };
});

// 前三名下载
const topThreeDownloads = computed(() => {
  return galleries.value.slice(0, 3).map((gallery, index) => ({
    ...gallery,
    rank: index + 1,
          coverImage: gallery.cover_image || (gallery.images && gallery.images.length > 0 ? gallery.images[0] : null),
    imageCount: gallery.image_count || (gallery.images ? gallery.images.length : 0),
    likesCount: gallery.likes_count || 0,
    bookmarksCount: gallery.bookmarks_count || 0,
    downloadsCount: gallery.views_count || 0, // 使用views_count作为下载量image.png
    author: gallery.owner?.username || '摄影师',
    // 计算下载转化率
    conversionRate: Math.round(((gallery.views_count || 0) / Math.max(gallery.likes_count || 1, 1)) * 100)
  }));
});

function loadMore() {
  galleryStore.fetchDownloadGalleries(false);
}

function getRankColor(rank) {
  switch(rank) {
    case 1: return '#10B981'; // 绿色
    case 2: return '#3B82F6'; // 蓝色
    case 3: return '#8B5CF6'; // 紫色
    default: return '#667eea';
  }
}

function getDownloadLevel(downloads) {
  if (downloads >= 800) return { level: 'HOT', color: '#ef4444' };
  if (downloads >= 500) return { level: 'FIRE', color: '#f97316' };
  if (downloads >= 200) return { level: 'POPULAR', color: '#eab308' };
  return { level: 'RISING', color: '#10b981' };
}

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

// 底部数据




onMounted(() => {
  galleryStore.resetState();
  galleryStore.fetchDownloadGalleries(true);
});
</script>

<template>
  <div class="downloads-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>下载榜</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <n-icon><TrendingIcon /></n-icon>
            下载榜
          </h1>
          <p class="page-subtitle">最受欢迎的图集下载排行榜</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 下载榜统计 -->
        <div class="downloads-stats">
          <n-card title="下载榜统计" class="stats-card">
            <div class="stats-grid">
              <n-statistic label="上榜图集" :value="downloadsStats.total" />
              <n-statistic label="最高下载" :value="downloadsStats.maxDownloads" />
              <n-statistic label="平均下载" :value="downloadsStats.avgDownloads" />
              <n-statistic label="总收藏数" :value="downloadsStats.totalBookmarks" />
            </div>
          </n-card>
        </div>

        <!-- 前三名展示 -->
        <div v-if="topThreeDownloads.length > 0" class="top-three-section">
          <h2 class="section-title">📈 下载榜前三甲</h2>
          <div class="top-three-grid">
            <div 
              v-for="gallery in topThreeDownloads" 
              :key="gallery.id"
              class="top-gallery-card"
              :class="`rank-${gallery.rank}`"
              @click="viewGallery(gallery)"
            >
              <div class="rank-badge">
                <n-icon :color="getRankColor(gallery.rank)" size="24">
                  <TrendingIcon />
                </n-icon>
                <span class="rank-number">{{ gallery.rank }}</span>
              </div>

              <!-- 热度标签 -->
              <div class="heat-level">
                <n-tag 
                  :color="{ color: getDownloadLevel(gallery.downloadsCount).color, textColor: 'white' }" 
                  size="small"
                  strong
                >
                  {{ getDownloadLevel(gallery.downloadsCount).level }}
                </n-tag>
              </div>

              <div class="gallery-cover">
                <img 
                  v-if="gallery.coverImage && gallery.coverImage.image_url" 
                  :src="`${API_BASE_URL}${gallery.coverImage.image_url}`" 
                  :alt="gallery.title"
                  class="cover-image"
                  loading="lazy"
                >
                <div v-else class="no-image">
                  <n-icon size="40" color="#ccc">
                    <DownloadIcon />
                  </n-icon>
                </div>
                <div class="image-count-badge">{{ gallery.imageCount }}P</div>
              </div>

              <div class="gallery-info">
                <h3 class="gallery-title">{{ gallery.title }}</h3>
                <p class="gallery-author">by {{ gallery.author }}</p>
                
                <!-- 下载统计 -->
                <div class="download-stats">
                  <div class="downloads-count">
                    <n-icon><ArrowDownIcon /></n-icon>
                    <strong>{{ gallery.downloadsCount }}</strong>
                    <span>下载</span>
                  </div>
                  <div class="conversion-rate">
                    转化率 {{ gallery.conversionRate }}%
                  </div>
                </div>

                <!-- 其他统计 -->
                <div class="other-stats">
                  <div class="stat-item">
                    <n-icon><LikeIcon /></n-icon>
                    <span>{{ gallery.likesCount }}</span>
                  </div>
                  <div class="stat-item">
                    <n-icon><BookmarkIcon /></n-icon>
                    <span>{{ gallery.bookmarksCount }}</span>
                  </div>
                </div>

                <n-tag :color="{ color: getRankColor(gallery.rank), textColor: 'white' }" size="small">
                  下载第{{ gallery.rank }}名
                </n-tag>
              </div>
            </div>
          </div>
        </div>

        <!-- 完整下载榜 -->
        <div class="section-title">
          <h2>完整下载榜</h2>
          <p>按下载数量倒序排列</p>
        </div>

        <GalleryGrid
          :galleries="galleries"
          :is-loading="isLoading"
          :has-more="hasMore"
          :skip-top-count="3"
          :show-downloads="true"
          :empty-text="'暂无下载榜数据'"
          @load-more="loadMore"
        />
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#10B981" />
  </div>
</template>

<style scoped>
.downloads-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #10B981 0%, #3B82F6 50%, #8B5CF6 100%);
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
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
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

.downloads-stats {
  margin-bottom: 40px;
}

.stats-card {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.05) 0%, rgba(59, 130, 246, 0.05) 50%, rgba(139, 92, 246, 0.05) 100%);
  border: 1px solid rgba(16, 185, 129, 0.1);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 24px;
  margin-top: 16px;
}

/* 前三名展示 */
.top-three-section {
  margin-bottom: 40px;
  padding-top: 15px;
}

.section-title {
  text-align: center;
  margin-bottom: 32px;
}

.section-title h2 {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.section-title p {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.top-three-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.top-gallery-card {
  position: relative;
  background: white;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  margin-top: 15px;
}

.top-gallery-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #10B981, #3B82F6, #8B5CF6);
}

.top-gallery-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.rank-1 {
  border: 2px solid #10B981;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
}

.rank-2 {
  border: 2px solid #3B82F6;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
}

.rank-3 {
  border: 2px solid #8B5CF6;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
}

.rank-badge {
  position: absolute;
  top: -10px;
  left: 20px;
  display: flex;
  align-items: center;
  gap: 4px;
  background: white;
  padding: 6px 12px;
  border-radius: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 2;
}

.rank-number {
  font-weight: bold;
  font-size: 14px;
  color: #1f2937;
}

.heat-level {
  position: absolute;
  top: -8px;
  right: 20px;
  z-index: 3;
}

.gallery-cover {
  position: relative;
  width: 100%;
  height: 200px;
  margin-bottom: 16px;
  border-radius: 12px;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.top-gallery-card:hover .cover-image {
  transform: scale(1.05);
}

.no-image {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
}

.image-count-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.gallery-info {
  text-align: center;
}

.gallery-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.gallery-author {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 16px 0;
}

.download-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding: 8px 12px;
  background: #f8fafc;
  border-radius: 8px;
}

.downloads-count {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #10B981;
  font-size: 16px;
  font-weight: 600;
}

.conversion-rate {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.other-stats {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #6b7280;
  font-size: 14px;
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

  .page-header {
    padding: 16px 0;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }

  .top-three-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .section-title h2 {
    font-size: 20px;
  }

  .download-stats {
    flex-direction: column;
    gap: 4px;
  }

  .other-stats {
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .top-gallery-card {
    padding: 16px;
  }

  .gallery-title {
    font-size: 16px;
  }

  .rank-badge {
    left: 16px;
  }

  .heat-level {
    right: 16px;
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