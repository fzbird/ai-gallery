<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NCard, NStatistic, NTime } from 'naive-ui';
import GalleryGrid from '@/components/GalleryGrid.vue';
import apiClient from '@/api/api.js';

const galleryStore = useGalleryStore();
const { galleries: allGalleries, isLoading, hasMore } = storeToRefs(galleryStore);

// 每日统计数据
const dailyStats = ref({
  today_galleries: 0,
  today_images: 0,
  today_likes: 0,
  today_bookmarks: 0
});

const isLoadingStats = ref(false);

// 今日日期
const today = computed(() => {
  return new Date().toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  });
});

// 筛选今日图集
const todayGalleries = computed(() => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayTime = today.getTime();
  
  return allGalleries.value.filter(gallery => {
    if (!gallery.created_at) return false;
    const galleryDate = new Date(gallery.created_at);
    galleryDate.setHours(0, 0, 0, 0);
    return galleryDate.getTime() === todayTime;
  });
});

// 获取每日统计数据
async function fetchDailyStats() {
  isLoadingStats.value = true;
  try {
    const response = await apiClient.get('/admin/daily-stats');
    dailyStats.value = response.data;
  } catch (error) {
    console.error('Error fetching daily stats:', error);
    // 如果API调用失败，使用本地计算的统计数据作为后备
    dailyStats.value = {
      today_galleries: todayGalleries.value.length,
      today_images: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.imageCount || 0), 0),
      today_likes: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.likesCount || 0), 0),
      today_bookmarks: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.bookmarksCount || 0), 0)
    };
  } finally {
    isLoadingStats.value = false;
  }
}

function loadMore() {
  galleryStore.fetchGalleries(false);
}

onMounted(async () => {
  galleryStore.resetState();
  await Promise.all([
    galleryStore.fetchGalleries(true),
    fetchDailyStats()
  ]);
});
</script>

<template>
  <div class="daily-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>每日更新</n-breadcrumb-item>
          <n-breadcrumb-item href="/timeline"> | 时间线 | </n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">每日更新</h1>
          <p class="page-subtitle">{{ today }} · 发现今日最新上传的精彩图集</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 今日统计 -->
        <div class="today-stats">
          <n-card title="今日统计" class="stats-card">
            <div class="stats-grid">
              <n-statistic label="新增图集" :value="dailyStats.today_galleries" />
              <n-statistic label="新增图片" :value="dailyStats.today_images" />
              <n-statistic label="获得点赞" :value="dailyStats.today_likes" />
              <n-statistic label="获得收藏" :value="dailyStats.today_bookmarks" />
            </div>
          </n-card>
        </div>

        <!-- 图集展示 -->
        <div class="content-section-title">
          <h2>今日新增图集</h2>
          <p>按上传时间倒序排列</p>
        </div>

        <GalleryGrid
          :galleries="todayGalleries"
          :is-loading="isLoading"
          :has-more="hasMore"
          :empty-text="'今日暂无新增图集'"
          @load-more="loadMore"
        />
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#f59e0b" />
  </div>
</template>

<style scoped>
.daily-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 50%, #b45309 100%);
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

.today-stats {
  margin-bottom: 40px;
}

.stats-card {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.stats-card :deep(.n-card-header) {
  padding: 8px 20px 4px 20px; /* 进一步减少头部padding */
}

.stats-card :deep(.n-card__content) {
  padding: 4px 20px 12px 20px; /* 进一步减少内容padding */
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* 超小屏也保持4列 */
  gap: 4px; /* 最小间距 */
  margin-top: 2px;
}

.stats-grid :deep(.n-statistic) {
  text-align: center;
}

.stats-grid :deep(.n-statistic .n-statistic-label) {
  font-size: 9px; /* 最小标签字体 */
  margin-bottom: 0px;
}

.stats-grid :deep(.n-statistic .n-statistic-value) {
  font-size: 12px; /* 最小数值字体 */
  line-height: 1.0;
}

.content-section-title {
  text-align: center;
  margin-bottom: 32px;
}

.content-section-title h2 {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.content-section-title p {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 24px; /* 进一步减小标题 */
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-header {
    padding: 16px 0;
  }
  
  .breadcrumb {
    margin-bottom: 12px;
  }
  
  .page-title-section {
    margin-bottom: 16px;
  }
  
  .main-content {
    padding: 20px 0; /* 进一步减少主内容区padding */
  }
  
  .today-stats {
    margin-bottom: 20px; /* 进一步减少统计区下方间距 */
  }

  .stats-grid {
    grid-template-columns: repeat(4, 1fr); /* 移动端也保持4列 */
    gap: 8px; /* 减少间距 */
    margin-top: 2px;
  }
  
  .stats-grid :deep(.n-statistic) {
    text-align: center;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-label) {
    font-size: 10px; /* 移动端更小字体 */
    margin-bottom: 1px;
  }

  .stats-grid :deep(.n-statistic .n-statistic-value) {
    font-size: 14px; /* 移动端更小数值 */
    line-height: 1.0;
  }

  .content-section-title {
    margin-bottom: 20px;
  }

  .content-section-title h2 {
    font-size: 20px;
  }
  
  .stats-card :deep(.n-card-header) {
    padding: 8px 12px 4px 12px; /* 进一步减少卡片头部padding */
  }
  
  .stats-card :deep(.n-card__content) {
    padding: 4px 12px 12px 12px; /* 进一步减少卡片内容padding */
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 20px; /* 超小屏幕进一步减小 */
  }
  
  .page-subtitle {
    font-size: 13px;
  }
  
  .container {
    padding: 0 12px;
  }
  
  .main-content {
    padding: 12px 0; /* 更紧凑的主内容区 */
  }
  
  .today-stats {
    margin-bottom: 12px; /* 更紧凑的统计区间距 */
  }

  .stats-grid {
    grid-template-columns: repeat(4, 1fr); /* 超小屏也保持4列 */
    gap: 4px; /* 最小间距 */
    margin-top: 2px;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-label) {
    font-size: 9px; /* 最小标签字体 */
    margin-bottom: 0px;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-value) {
    font-size: 12px; /* 最小数值字体 */
    line-height: 1.0;
  }
  
  .content-section-title {
    margin-bottom: 16px;
  }
  
  .content-section-title h2 {
    font-size: 18px;
  }
  
  .stats-card :deep(.n-card-header) {
    padding: 6px 8px 2px 8px; /* 更紧凑的卡片头部 */
  }
  
  .stats-card :deep(.n-card__content) {
    padding: 2px 8px 8px 8px; /* 更紧凑的卡片内容 */
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