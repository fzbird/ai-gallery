<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useGalleryStore } from '@/stores/gallery';
import { storeToRefs } from 'pinia';
import { NBreadcrumb, NBreadcrumbItem, NCard, NStatistic, NIcon, NTag } from 'naive-ui';
import { BookmarkOutline as BookmarkIcon, StarOutline as StarIcon, HeartOutline as LikeIcon } from '@vicons/ionicons5';
import GalleryGrid from '@/components/GalleryGrid.vue';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const galleryStore = useGalleryStore();
const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);

// 收藏榜统计
const favoritesStats = computed(() => {
  if (galleries.value.length === 0) return { total: 0, maxBookmarks: 0, avgBookmarks: 0, totalLikes: 0 };
  
  const bookmarksArray = galleries.value.map(g => g.bookmarks_count || 0);
  const likesArray = galleries.value.map(g => g.likes_count || 0);
  const total = galleries.value.length;
  const maxBookmarks = Math.max(...bookmarksArray);
  const avgBookmarks = Math.round(bookmarksArray.reduce((a, b) => a + b, 0) / total);
  const totalLikes = likesArray.reduce((a, b) => a + b, 0);
  
  return { total, maxBookmarks, avgBookmarks, totalLikes };
});

// 前三名收藏
const topThreeFavorites = computed(() => {
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
  galleryStore.fetchBookmarkedGalleries(false);
}

function getRankColor(rank) {
  switch(rank) {
    case 1: return '#FF6B9D'; // 粉红色
    case 2: return '#4ECDC4'; // 青色
    case 3: return '#45B7D1'; // 蓝色
    default: return '#667eea';
  }
}

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

// 底部数据




onMounted(() => {
  galleryStore.resetState();
  galleryStore.fetchBookmarkedGalleries(true);
});
</script>

<template>
  <div class="favorites-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>收藏榜</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <n-icon><StarIcon /></n-icon>
            收藏榜
          </h1>
          <p class="page-subtitle">最值得收藏的精品图集排行榜</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 收藏榜统计 -->
        <div class="favorites-stats">
          <n-card title="收藏榜统计" class="stats-card">
            <div class="stats-grid">
              <n-statistic label="上榜图集" :value="favoritesStats.total" />
              <n-statistic label="最高收藏" :value="favoritesStats.maxBookmarks" />
              <n-statistic label="平均收藏" :value="favoritesStats.avgBookmarks" />
              <n-statistic label="总点赞数" :value="favoritesStats.totalLikes" />
            </div>
          </n-card>
        </div>

        <!-- 前三名展示 -->
        <div v-if="topThreeFavorites.length > 0" class="top-three-section">
          <h2 class="section-title">⭐ 收藏榜前三甲</h2>
          <div class="top-three-grid">
            <div 
              v-for="gallery in topThreeFavorites" 
              :key="gallery.id"
              class="top-gallery-card"
              :class="`rank-${gallery.rank}`"
              @click="viewGallery(gallery)"
            >
              <div class="rank-badge">
                <n-icon :color="getRankColor(gallery.rank)" size="24">
                  <StarIcon />
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
                    <StarIcon />
                  </n-icon>
                </div>
                <div class="image-count-badge">{{ gallery.imageCount }}P</div>
              </div>

              <div class="gallery-info">
                <!-- 标题与作者一行布局 -->
                <div class="title-author-row">
                  <h3 class="gallery-title">{{ gallery.title }}</h3>
                  <p class="gallery-author">by {{ gallery.author }}</p>
                </div>
                <!-- 统计信息与排名一行布局 -->
                <div class="stats-rank-row">
                  <div class="gallery-stats">
                    <div class="bookmarks-count">
                      <n-icon><BookmarkIcon /></n-icon>
                      <strong>{{ gallery.bookmarksCount }}</strong>
                      <span>收藏</span>
                    </div>
                    <div class="likes-info">
                      <n-icon><LikeIcon /></n-icon>
                      <span>{{ gallery.likesCount }}</span>
                    </div>
                  </div>
                  <n-tag :color="{ color: getRankColor(gallery.rank), textColor: 'white' }" size="small">
                    收藏第{{ gallery.rank }}名
                  </n-tag>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 完整收藏榜 -->
        <div class="section-title">
          <h2>完整收藏榜</h2>
          <p>按收藏数量倒序排列</p>
        </div>

        <GalleryGrid
          :galleries="galleries"
          :is-loading="isLoading"
          :has-more="hasMore"
          :skip-top-count="3"
          :empty-text="'暂无收藏榜数据'"
          @load-more="loadMore"
        />
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#FF6B9D" />
  </div>
</template>

<style scoped>
.favorites-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #FF6B9D 0%, #4ECDC4 50%, #45B7D1 100%);
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

.favorites-stats {
  margin-bottom: 24px;
}

.stats-card {
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.05) 0%, rgba(78, 205, 196, 0.05) 50%, rgba(69, 183, 209, 0.05) 100%);
  border: 1px solid rgba(255, 107, 157, 0.1);
}

.stats-card :deep(.n-card-header) {
  padding: 8px 20px 4px 20px; /* 进一步减少头部padding */
}

.stats-card :deep(.n-card__content) {
  padding: 4px 20px 12px 20px; /* 进一步减少内容padding */
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* 单行4列布局 */
  gap: 16px; /* 统一间距 */
  margin-top: 4px; /* 减少顶部间距 */
}

.stats-grid :deep(.n-statistic) {
  text-align: center;
}

.stats-grid :deep(.n-statistic .n-statistic-label) {
  font-size: 12px; /* 适中的标签字体 */
  color: #6b7280;
  margin-bottom: 2px; /* 减少标签与数值间距 */
}

.stats-grid :deep(.n-statistic .n-statistic-value) {
  font-size: 18px; /* 适中的数值字体 */
  font-weight: 600;
  line-height: 1.1; /* 紧凑行高 */
}

/* 前三名展示 */
.top-three-section {
  margin-bottom: 40px;
  padding-top: 15px;
}

.section-title {
  text-align: center;
  margin-bottom: 24px;
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
  background: linear-gradient(90deg, #FF6B9D, #4ECDC4, #45B7D1);
}

.top-gallery-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.rank-1 {
  border: 2px solid #FF6B9D;
  background: linear-gradient(135deg, rgba(255, 107, 157, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
}

.rank-2 {
  border: 2px solid #4ECDC4;
  background: linear-gradient(135deg, rgba(78, 205, 196, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
}

.rank-3 {
  border: 2px solid #45B7D1;
  background: linear-gradient(135deg, rgba(69, 183, 209, 0.03) 0%, rgba(255, 255, 255, 1) 100%);
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
  z-index: 3;
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

/* 标题与作者一行布局 */
.title-author-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
  gap: 8px;
}

.gallery-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  line-height: 1.3;
  flex: 1;
  text-align: left;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.gallery-author {
  font-size: 12px;
  color: #6b7280;
  margin: 0;
  white-space: nowrap;
  flex-shrink: 0;
  text-align: right;
}

/* 统计信息与排名一行布局 */
.stats-rank-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.gallery-stats {
  display: flex;
  gap: 12px;
  align-items: center;
}

.bookmarks-count {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #FF6B9D;
  font-size: 16px;
  font-weight: 600;
}

.likes-info {
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
  
  .favorites-stats {
    margin-bottom: 16px; /* 进一步减少统计区下方间距 */
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
    margin-bottom: 16px;
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
    font-size: 14px;
  }
  
  .gallery-author {
    font-size: 11px;
  }
  
  .title-author-row {
    margin-bottom: 10px;
    gap: 6px;
  }
  
  .stats-rank-row {
    gap: 6px;
  }
  
  .gallery-stats {
    gap: 8px;
  }

  .gallery-stats {
    flex-direction: row; /* 保持水平排列 */
    justify-content: space-around; /* 均匀分布 */
    gap: 8px;
    margin-bottom: 8px;
  }
  
  .bookmarks-count {
    font-size: 14px;
  }
  
  .likes-info {
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
  
  .favorites-stats {
    margin-bottom: 10px; /* 更紧凑的统计区间距 */
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

  .top-gallery-card {
    padding: 12px; /* 减少卡片内边距 */
  }
  
  .gallery-cover {
    height: 140px; /* 进一步减小图片高度 */
    margin-bottom: 12px;
  }

  .gallery-title {
    font-size: 13px;
  }
  
  .gallery-author {
    font-size: 10px;
  }
  
  .title-author-row {
    margin-bottom: 8px;
    gap: 4px;
  }
  
  .stats-rank-row {
    gap: 4px;
  }
  
  .gallery-stats {
    gap: 6px;
  }
  
  .gallery-stats {
    flex-direction: column; /* 超小屏幕垂直排列 */
    gap: 6px;
    align-items: center;
  }
  
  .bookmarks-count {
    font-size: 13px;
  }
  
  .likes-info {
    font-size: 12px;
  }
  
  .section-title h2 {
    font-size: 18px;
  }
  
  .section-title {
    margin-bottom: 12px;
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