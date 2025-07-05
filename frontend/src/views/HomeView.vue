<script setup>
import { onMounted, onUnmounted, ref, computed, watch } from 'vue';
import { useGalleryStore } from '@/stores/gallery';
import { useAuthStore } from '@/stores/auth';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { NSpin, NButton, NTag, NSpace, NIcon } from 'naive-ui';
import { useRouter } from 'vue-router';
import { HeartOutline as LikeIcon, BookmarkOutline as BookmarkIcon, ImageOutline as ImageIcon, HomeOutline as HomeIcon, PersonOutline as UserIcon } from '@vicons/ionicons5';
import AppFooter from '@/components/AppFooter.vue';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const galleryStore = useGalleryStore();
const authStore = useAuthStore();
const { clearCustomTitle } = usePageTitle();

const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);
const { isAuthenticated } = storeToRefs(authStore);

const sentinel = ref(null);
const currentPage = ref(1);

const loadMoreGalleries = () => {
  if (hasMore.value && !isLoading.value) {
    galleryStore.fetchGalleries();
  }
};

// 瀑布流布局用的图集数据
const displayedGalleries = computed(() => {
  return galleries.value.map(gallery => {
    // 获取封面图片 - 优先使用cover_image，如果没有则使用第一张图片
    const coverImage = gallery.cover_image || (gallery.images && gallery.images.length > 0 ? gallery.images[0] : null);
    
    // 使用真实标签数据（前5个）
    const tags = gallery.tags ? gallery.tags.slice(0, 5) : [];

    return {
      ...gallery,
      coverImage,
      tags,
      imageCount: gallery.image_count || (gallery.images ? gallery.images.length : 0),
      likesCount: gallery.likes_count || 0,
      bookmarksCount: gallery.bookmarks_count || 0,
      author: gallery.owner?.username || '摄影师'
    };
  });
});

const observer = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting && hasMore.value && !isLoading.value) {
    loadMoreGalleries();
  }
}, {
  rootMargin: '200px',
});

function viewGallery(gallery) {
  router.push({ name: 'gallery', params: { id: gallery.id } });
}

function viewUser(username) {
  router.push({ name: 'profile', params: { username } });
}

onMounted(async () => {
  // 清除自定义标题，使用默认首页标题
  clearCustomTitle();
  
  // 加载图集数据
  galleryStore.fetchGalleries(true);
  
  if (sentinel.value) {
    observer.observe(sentinel.value);
  }
});

onUnmounted(() => {
  if (sentinel.value) {
    observer.unobserve(sentinel.value);
  }
});
</script>

<template>
  <div class="gallery-home">
    <!-- 顶部Banner区域 -->
    <div class="banner-section">
      <div class="banner-content">
        <h1 class="main-title">共同参与，构建完整的图库资源</h1>
        <p class="subtitle">原创 · 高清 · 无水印 · 开放下载</p>
      </div>
      <div class="banner-bg"></div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 图集展示区域 -->
        <div class="galleries-section">
          <div class="galleries-grid">
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
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 加载更多按钮 -->
          <div class="load-more-section" ref="sentinel">
            <n-spin v-if="isLoading" size="large" />
            <n-button 
              v-else-if="hasMore" 
              @click="loadMoreGalleries"
              size="large"
              type="primary"
              ghost
              class="load-more-btn"
            >
              查看更多
            </n-button>
            <p v-else class="no-more-text">已加载全部内容</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#667eea" />
  </div>
</template>



<style scoped>
.gallery-home {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* Banner区域 */
.banner-section {
  position: relative;
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  overflow: hidden;
}

.banner-content {
  text-align: center;
  color: white;
  z-index: 2;
  position: relative;
}

.main-title {
  font-size: 36px;
  font-weight: bold;
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 18px;
  margin: 0;
  opacity: 0.9;
  font-weight: 300;
}

.banner-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.15"/><circle cx="80" cy="40" r="0.5" fill="white" opacity="0.15"/><circle cx="20" cy="60" r="0.5" fill="white" opacity="0.15"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  opacity: 0.3;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
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

/* 删除不需要的底部样式，现在使用AppFooter组件 */

/* 响应式设计 */
@media (max-width: 1200px) {
  .galleries-grid {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .main-title {
    font-size: 28px;
  }

  .subtitle {
    font-size: 16px;
  }

  .galleries-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }

  /* 移动端样式调整 */
}

@media (max-width: 480px) {
  .galleries-grid {
    grid-template-columns: 1fr;
  }

  .banner-section {
    height: 200px;
  }

  .main-title {
    font-size: 24px;
  }

  .subtitle {
    font-size: 14px;
  }
}
</style> 