<script setup>
import { computed, defineEmits } from 'vue';
import { useRouter } from 'vue-router';
import { NSpin, NButton, NTag, NSpace, NIcon, NEmpty } from 'naive-ui';
import { HeartOutline as LikeIcon, BookmarkOutline as BookmarkIcon, ImageOutline as ImageIcon, DownloadOutline as DownloadIcon } from '@vicons/ionicons5';
import { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  galleries: {
    type: Array,
    default: () => []
  },
  isLoading: {
    type: Boolean,
    default: false
  },
  hasMore: {
    type: Boolean,
    default: true
  },
  showDownloads: {
    type: Boolean,
    default: false
  },
  emptyText: {
    type: String,
    default: '暂无图集'
  },
  skipTopCount: {
    type: Number,
    default: 0
  }
});

const emit = defineEmits(['load-more']);
const router = useRouter();

// 处理图集数据
const displayedGalleries = computed(() => {
  // 跳过前几个图集（避免与前三甲重复）
  const filteredGalleries = props.skipTopCount > 0 
    ? props.galleries.slice(props.skipTopCount) 
    : props.galleries;
    
  return filteredGalleries.map(gallery => {
    // 获取封面图片 - 优先使用cover_image，然后是images[0]
    let coverImage = null;
    
    // 首先尝试使用专门的封面图片
    if (gallery.cover_image && gallery.cover_image.image_url) {
      coverImage = gallery.cover_image;
    }
    // 如果没有专门的封面图片，使用第一张图片
    else if (gallery.images && gallery.images.length > 0 && gallery.images[0].image_url) {
      coverImage = gallery.images[0];
    }
    
    // 使用真实标签数据（前5个）
    const tags = gallery.tags ? gallery.tags.slice(0, 5) : [];

    return {
      ...gallery,
      coverImage,
      tags,
      imageCount: gallery.image_count || (gallery.images ? gallery.images.length : 0),
      likesCount: gallery.likes_count || 0,
      bookmarksCount: gallery.bookmarks_count || 0,
      downloadsCount: gallery.views_count || 0, // 使用views_count作为下载量
      author: gallery.owner?.username || '摄影师'
    };
  });
});

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

function viewUser(username) {
  router.push({ name: 'profile', params: { username } });
}

function loadMore() {
  emit('load-more');
}

function handleImageError(event) {
  console.error('Image load error:', event.target.src);
  // 可以在这里设置默认图片或其他处理
}
</script>

<template>
  <div class="gallery-grid-container">
    <!-- 图集网格 -->
    <div v-if="displayedGalleries.length > 0" class="galleries-grid">
      <div 
        v-for="gallery in displayedGalleries" 
        :key="gallery.id"
        class="gallery-card"
        @click="viewGallery(gallery)"
      >
        <!-- 图集封面 -->
        <div class="gallery-cover">
          <img 
            v-if="gallery.coverImage && gallery.coverImage.image_url" 
            :src="`${API_BASE_URL}${gallery.coverImage.image_url}`" 
            :alt="gallery.title"
            class="cover-image"
            loading="lazy"
            @error="handleImageError"
          >
          <div v-else class="no-image">
            <n-icon size="40" color="#ccc">
              <ImageIcon />
            </n-icon>
            <span>暂无图片</span>
          </div>
          <!-- 图集数量标识 -->
          <div class="image-count-badge">{{ gallery.imageCount }}P</div>
        </div>

        <!-- 图集信息 -->
        <div class="gallery-info">
          <!-- 标题 -->
          <h3 class="gallery-title">{{ gallery.title }}</h3>
          
          <!-- 标签 -->
          <div class="tags-section" v-if="gallery.tags && gallery.tags.length > 0">
            <n-space size="small">
              <n-tag 
                v-for="tag in gallery.tags" 
                :key="tag.id" 
                size="small" 
                type="info"
                round
              >
                {{ tag.name }}
              </n-tag>
            </n-space>
          </div>
          
          <!-- 作者和统计信息 -->
          <div class="meta-info">
            <span class="author" @click.stop="viewUser(gallery.author)">{{ gallery.author }}</span>
            <div class="stats">
              <span class="stat-item">
                <n-icon><LikeIcon /></n-icon>
                {{ gallery.likesCount }}
              </span>
              <span class="stat-item">
                <n-icon><BookmarkIcon /></n-icon>
                {{ gallery.bookmarksCount }}
              </span>
              <span v-if="showDownloads" class="stat-item">
                <n-icon><DownloadIcon /></n-icon>
                {{ gallery.downloadsCount }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 空状态 -->
    <n-empty v-else-if="!isLoading" :description="emptyText" />

    <!-- 加载更多区域 -->
    <div class="load-more-section">
      <n-spin v-if="isLoading" size="large" />
      <n-button 
        v-else-if="hasMore && displayedGalleries.length > 0" 
        @click="loadMore"
        size="large"
        type="primary"
        ghost
        class="load-more-btn"
      >
        查看更多
      </n-button>
      <p v-else-if="displayedGalleries.length > 0" class="no-more-text">已加载全部内容</p>
    </div>
  </div>
</template>

<style scoped>
.gallery-grid-container {
  width: 100%;
}

/* 图集网格 */
.galleries-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.gallery-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.gallery-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.gallery-cover {
  position: relative;
  width: 100%;
  height: 200px;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.gallery-card:hover .cover-image {
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
  font-size: 14px;
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
  padding: 16px;
}

.gallery-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 12px 0;
  color: #1f2937;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.tags-section {
  margin-bottom: 12px;
}

.meta-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.author {
  color: #667eea;
  cursor: pointer;
  font-weight: 500;
  transition: color 0.2s ease;
}

.author:hover {
  color: #4c51bf;
}

.stats {
  display: flex;
  gap: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #6b7280;
  font-size: 13px;
}

/* 加载更多区域 */
.load-more-section {
  text-align: center;
  padding: 20px 0;
}

.load-more-btn {
  padding: 12px 32px;
  font-size: 16px;
}

.no-more-text {
  color: #9ca3af;
  font-size: 14px;
  margin: 0;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .galleries-grid {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .galleries-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }
}

@media (max-width: 480px) {
  .galleries-grid {
    grid-template-columns: 1fr;
  }
}
</style> 