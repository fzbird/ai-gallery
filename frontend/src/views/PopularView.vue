<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NCard, NStatistic, NIcon, NTag } from 'naive-ui';
import { HeartOutline as LikeIcon, TrophyOutline as TrophyIcon, FlameOutline as FireIcon, BookmarkOutline as BookmarkIcon, EyeOutline as ViewIcon, PodiumOutline as PodiumIcon, TrendingUpOutline as TrendingUpIcon } from '@vicons/ionicons5';
import GalleryGrid from '@/components/GalleryGrid.vue';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const galleryStore = useGalleryStore();
const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);

// 排行榜统计
const rankingStats = computed(() => {
  if (galleries.value.length === 0) return { total: 0, maxLikes: 0, avgLikes: 0 };
  
  const likesArray = galleries.value.map(g => g.likes_count || 0);
  const total = galleries.value.length;
  const maxLikes = Math.max(...likesArray);
  const avgLikes = Math.round(likesArray.reduce((a, b) => a + b, 0) / total);
  
  return { total, maxLikes, avgLikes };
});

// 前三名
const topThree = computed(() => {
  return galleries.value.slice(0, 3).map((gallery, index) => ({
    ...gallery,
    rank: index + 1,
          coverImage: gallery.cover_image || (gallery.images && gallery.images.length > 0 ? gallery.images[0] : null),
    imageCount: gallery.image_count || (gallery.images ? gallery.images.length : 0),
    likesCount: gallery.likes_count || 0,
    bookmarksCount: gallery.bookmarks_count || 0,
    author: gallery.owner?.username || '摄影师'
  }));
});

function loadMore() {
  galleryStore.fetchPopularGalleries(false);
}

function getRankColor(rank) {
  switch(rank) {
    case 1: return '#FFD700'; // 金色
    case 2: return '#C0C0C0'; // 银色
    case 3: return '#CD7F32'; // 铜色
    default: return '#667eea';
  }
}

function getRankIcon(rank) {
  return TrophyIcon;
}

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

// 底部数据




onMounted(() => {
  galleryStore.resetState();
  galleryStore.fetchPopularGalleries(true);
});
</script>

<template>
  <div class="popular-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>魅力榜</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <n-icon><FireIcon /></n-icon>
            魅力榜
          </h1>
          <p class="page-subtitle">最受欢迎的图集作品排行榜</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 排行榜统计 -->
        <div class="ranking-stats">
          <n-card title="排行榜统计" class="stats-card">
            <div class="stats-grid">
              <n-statistic label="上榜图集" :value="rankingStats.total" />
              <n-statistic label="最高点赞" :value="rankingStats.maxLikes" />
              <n-statistic label="平均点赞" :value="rankingStats.avgLikes" />
              <n-statistic label="竞争指数" :value="85" suffix="%" />
            </div>
          </n-card>
        </div>

        <!-- 前三名展示 -->
        <div v-if="topThree.length > 0" class="top-three-section">
          <h2 class="section-title">🏆 排行榜前三甲</h2>
          <div class="top-three-grid">
            <div 
              v-for="gallery in topThree" 
              :key="gallery.id"
              class="top-gallery-card"
              :class="`rank-${gallery.rank}`"
              @click="viewGallery(gallery)"
            >
              <div class="rank-badge">
                <n-icon :color="getRankColor(gallery.rank)" size="24">
                  <component :is="getRankIcon(gallery.rank)" />
                </n-icon>
                <span class="rank-number">{{ gallery.rank }}</span>
              </div>

              <div class="gallery-cover">
                <img 
                  v-if="gallery.coverImage && gallery.coverImage.image_url" 
                  :src="`${API_BASE_URL()}${gallery.coverImage.image_url}`" 
                  :alt="gallery.title"
                  class="cover-image"
                  loading="lazy"
                >
                <div v-else class="no-image">
                  <n-icon size="40" color="#ccc">
                    <FireIcon />
                  </n-icon>
                </div>
                <div class="image-count-badge">{{ gallery.imageCount }}P</div>
              </div>

              <div class="gallery-info">
                <h3 class="gallery-title">{{ gallery.title }}</h3>
                <p class="gallery-author">by {{ gallery.author }}</p>
                <div class="gallery-stats">
                  <div class="likes-count">
                    <n-icon><LikeIcon /></n-icon>
                    <strong>{{ gallery.likesCount }}</strong>
                  </div>
                  <n-tag :type="gallery.rank <= 3 ? 'warning' : 'info'" size="small">
                    第{{ gallery.rank }}名
                  </n-tag>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 完整排行榜 -->
        <div class="section-title">
          <h2>完整排行榜</h2>
          <p>按点赞数量倒序排列</p>
        </div>

        <GalleryGrid
          :galleries="galleries"
          :is-loading="isLoading"
          :has-more="hasMore"
          :skip-top-count="3"
          :empty-text="'暂无排行榜数据'"
          @load-more="loadMore"
        />
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#ff6b6b" />
  </div>
</template>

<style scoped>
.popular-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8e53 100%);
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

.ranking-stats {
  margin-bottom: 40px;
}

.stats-card {
  background: linear-gradient(135deg, rgba(255, 107, 107, 0.05) 0%, rgba(255, 142, 83, 0.05) 100%);
  border: 1px solid rgba(255, 107, 107, 0.1);
}

.stats-card :deep(.n-card-header) {
  padding: 12px 20px 8px 20px; /* 减少头部padding */
}

.stats-card :deep(.n-card__content) {
  padding: 8px 20px 16px 20px; /* 减少内容padding */
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr; /* 固定2列布局 */
  grid-template-rows: 1fr 1fr; /* 固定2行布局 */
  gap: 12px 20px; /* 垂直间距12px，水平间距20px */
  margin-top: 8px; /* 减少顶部间距 */
}

.stats-grid :deep(.n-statistic) {
  text-align: center;
}

.stats-grid :deep(.n-statistic .n-statistic-label) {
  font-size: 13px; /* 减小标签字体 */
  color: #6b7280;
  margin-bottom: 4px; /* 减少标签与数值间距 */
}

.stats-grid :deep(.n-statistic .n-statistic-value) {
  font-size: 20px; /* 减小数值字体 */
  font-weight: 600;
  line-height: 1.2; /* 紧凑行高 */
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

.top-gallery-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.rank-1 {
  border: 2px solid #FFD700;
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.05) 0%, rgba(255, 215, 0, 0.02) 100%);
}

.rank-2 {
  border: 2px solid #C0C0C0;
  background: linear-gradient(135deg, rgba(192, 192, 192, 0.05) 0%, rgba(192, 192, 192, 0.02) 100%);
}

.rank-3 {
  border: 2px solid #CD7F32;
  background: linear-gradient(135deg, rgba(205, 127, 50, 0.05) 0%, rgba(205, 127, 50, 0.02) 100%);
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
  z-index: 1;
}

.rank-number {
  font-weight: bold;
  font-size: 14px;
  color: #1f2937;
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
  margin: 0 0 12px 0;
}

.gallery-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.likes-count {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #ff6b6b;
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 24px; /* 减小标题尺寸 */
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
  
  .ranking-stats {
    margin-bottom: 20px; /* 进一步减少统计区下方间距 */
  }

  .stats-grid {
    grid-template-columns: 1fr 1fr; /* 保持2列布局 */
    grid-template-rows: 1fr 1fr; /* 保持2行布局 */
    gap: 8px 12px; /* 进一步减少间距：垂直8px，水平12px */
    margin-top: 6px;
  }
  
  .stats-grid :deep(.n-statistic) {
    text-align: center;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-label) {
    font-size: 11px; /* 进一步减小标签字体 */
    margin-bottom: 2px;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-value) {
    font-size: 16px; /* 进一步减小数值字体 */
    line-height: 1.1;
  }

  .top-three-grid {
    grid-template-columns: 1fr;
    gap: 16px; /* 减少前三名卡片间距 */
  }
  
  .top-three-section {
    margin-bottom: 24px;
  }

  .section-title h2 {
    font-size: 20px;
  }
  
  .section-title {
    margin-bottom: 20px;
  }
  
  .stats-card :deep(.n-card-header) {
    padding: 8px 12px 4px 12px; /* 进一步减少卡片头部padding */
  }
  
  .stats-card :deep(.n-card__content) {
    padding: 4px 12px 12px 12px; /* 进一步减少卡片内容padding */
  }
  
  .gallery-cover {
    height: 160px; /* 减少前三名图片高度 */
  }
  
  .gallery-title {
    font-size: 16px;
  }
  
  .gallery-author {
    font-size: 13px;
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
  
  .ranking-stats {
    margin-bottom: 12px; /* 更紧凑的统计区间距 */
  }

  .stats-grid {
    grid-template-columns: 1fr 1fr; /* 超小屏幕也保持2列布局 */
    grid-template-rows: 1fr 1fr; /* 超小屏幕也保持2行布局 */
    gap: 6px 8px; /* 更紧凑的间距：垂直6px，水平8px */
    margin-top: 4px;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-label) {
    font-size: 10px; /* 更小的标签字体 */
    margin-bottom: 1px;
  }
  
  .stats-grid :deep(.n-statistic .n-statistic-value) {
    font-size: 14px; /* 更小的数值字体 */
    line-height: 1.0;
  }

  .top-gallery-card {
    padding: 12px; /* 减少卡片内边距 */
  }
  
  .gallery-cover {
    height: 140px; /* 进一步减小图片高度 */
    margin-bottom: 12px;
  }

  .gallery-title {
    font-size: 15px;
  }
  
  .gallery-author {
    font-size: 12px;
    margin-bottom: 8px;
  }
  
  .section-title h2 {
    font-size: 18px;
  }
  
  .section-title {
    margin-bottom: 16px;
  }
  
  .top-three-section {
    margin-bottom: 16px;
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