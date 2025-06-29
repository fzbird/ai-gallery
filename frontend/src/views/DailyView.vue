<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NCard, NStatistic, NTime } from 'naive-ui';
import GalleryGrid from '@/components/GalleryGrid.vue';

const galleryStore = useGalleryStore();
const { galleries: allGalleries, isLoading, hasMore } = storeToRefs(galleryStore);

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

// 统计信息
const todayStats = computed(() => {
  return {
    totalGalleries: todayGalleries.value.length,
    totalImages: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.imageCount || 0), 0),
    totalLikes: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.likesCount || 0), 0),
    totalBookmarks: todayGalleries.value.reduce((sum, gallery) => sum + (gallery.bookmarksCount || 0), 0)
  };
});

function loadMore() {
  galleryStore.fetchGalleries(false);
}

onMounted(() => {
  galleryStore.resetState();
  galleryStore.fetchGalleries(true);
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
              <n-statistic label="新增图集" :value="todayStats.totalGalleries" />
              <n-statistic label="新增图片" :value="todayStats.totalImages" />
              <n-statistic label="获得点赞" :value="todayStats.totalLikes" />
              <n-statistic label="获得收藏" :value="todayStats.totalBookmarks" />
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

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 24px;
  margin-top: 16px;
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

  .section-title h2 {
    font-size: 20px;
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
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