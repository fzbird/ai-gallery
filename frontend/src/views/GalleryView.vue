<template>
  <div class="gallery-view">
    <!-- Loading state -->
    <div v-if="loading" class="loading-container">
      <n-spin size="large">
        <template #description>加载中...</template>
      </n-spin>
    </div>

    <!-- Gallery content -->
    <div v-else-if="gallery" class="gallery-page">
      <!-- Gallery header banner -->
      <div class="gallery-banner">
        <div class="banner-content">
          <div class="gallery-header-info">
            <h1 class="gallery-main-title">{{ gallery.title }}</h1>
            <p v-if="gallery.description" class="gallery-subtitle">{{ gallery.description }}</p>
            
            <div class="gallery-meta-row">
              <span class="meta-item">
                <n-icon><PersonOutline /></n-icon>
                {{ gallery.owner.username }}
              </span>
              <span class="meta-item" v-if="gallery.category">
                <n-icon><FolderOutline /></n-icon>
                {{ gallery.category.name }}
              </span>
              <span class="meta-item">
                <n-icon><TimeOutline /></n-icon>
                {{ formatDate(gallery.created_at) }}
              </span>
              <span class="meta-item">
                <n-icon><ImagesOutline /></n-icon>
                {{ gallery.image_count }} 张图片
              </span>
            </div>

            <div class="gallery-stats-row">
              <span class="stat-badge">
                <n-icon><EyeOutline /></n-icon>
                {{ gallery.views_count || 0 }} 浏览
              </span>
              <span class="stat-badge">
                <n-icon><HeartOutline /></n-icon>
                {{ gallery.likes_count || 0 }} 点赞
              </span>
              <span class="stat-badge">
                <n-icon><BookmarkOutline /></n-icon>
                {{ gallery.bookmarks_count || 0 }} 收藏
              </span>
            </div>

            <!-- Action buttons -->
            <div class="gallery-actions">
              <!-- 修改按钮（只有所有者可见） -->
              <n-button 
                v-if="canEditGallery"
                type="warning"
                size="large"
                @click="showEditModal = true"
                ghost
              >
                <template #icon>
                  <n-icon><CreateOutline /></n-icon>
                </template>
                修改图集
              </n-button>
              
              <n-button 
                type="primary" 
                size="large"
                :loading="liking"
                @click="toggleLike"
                :disabled="!authStore.isAuthenticated"
                :class="{ 'liked': gallery.liked_by_current_user }"
              >
                <template #icon>
                  <n-icon :component="gallery.liked_by_current_user ? Heart : HeartOutline" />
                </template>
                {{ gallery.liked_by_current_user ? '已点赞' : '点赞' }}
              </n-button>
              
              <n-button 
                type="default"
                size="large"
                :loading="bookmarking"
                @click="toggleBookmark"
                :disabled="!authStore.isAuthenticated"
                :class="{ 'bookmarked': gallery.bookmarked_by_current_user }"
                ghost
              >
                <template #icon>
                  <n-icon :component="gallery.bookmarked_by_current_user ? Bookmark : BookmarkOutline" />
                </template>
                {{ gallery.bookmarked_by_current_user ? '已收藏' : '收藏' }}
              </n-button>
            </div>
          </div>
        </div>
        <div class="banner-bg"></div>
      </div>

      <!-- Main content -->
      <div class="main-content">
        <div class="container">
          <!-- Images grid section -->
          <div class="images-section">
            <div class="section-header">
              <h2 class="section-title">图片列表</h2>
              
              <!-- 显示模式切换 -->
              <div class="view-mode-controls">
                <n-button-group>
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-button 
                        :type="viewMode === 'extra-large' ? 'primary' : 'default'"
                        size="small"
                        @click="setViewMode('extra-large')"
                      >
                        <template #icon>
                          <n-icon><GridOutline /></n-icon>
                        </template>
                      </n-button>
                    </template>
                    超大图标模式
                  </n-tooltip>
                  
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-button 
                        :type="viewMode === 'large' ? 'primary' : 'default'"
                        size="small"
                        @click="setViewMode('large')"
                      >
                        <template #icon>
                          <n-icon><GridOutline /></n-icon>
                        </template>
                      </n-button>
                    </template>
                    大图标模式
                  </n-tooltip>
                  
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-button 
                        :type="viewMode === 'small' ? 'primary' : 'default'"
                        size="small"
                        @click="setViewMode('small')"
                      >
                        <template #icon>
                          <n-icon><GridOutline /></n-icon>
                        </template>
                      </n-button>
                    </template>
                    小图标模式
                  </n-tooltip>
                  
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-button 
                        :type="viewMode === 'list' ? 'primary' : 'default'"
                        size="small"
                        @click="setViewMode('list')"
                      >
                        <template #icon>
                          <n-icon><ListOutline /></n-icon>
                        </template>
                      </n-button>
                    </template>
                    详细列表模式
                  </n-tooltip>
                  
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-button 
                        :type="viewMode === 'slideshow' ? 'primary' : 'default'"
                        size="small"
                        @click="setViewMode('slideshow')"
                      >
                        <template #icon>
                          <n-icon><PlayOutline /></n-icon>
                        </template>
                      </n-button>
                    </template>
                    幻灯片模式
                  </n-tooltip>
                </n-button-group>
              </div>
            </div>
            
            <!-- 图片显示区域 -->
            <div v-if="gallery.images && gallery.images.length > 0" class="images-display">
              <!-- 超大图标模式 -->
              <div v-if="viewMode === 'extra-large'" class="images-grid extra-large-grid">
                <ImageCard 
                  v-for="image in gallery.images" 
                  :key="image.id" 
                  :image="image"
                  :size="'extra-large'"
                  @click="viewImage(image.id)"
                />
              </div>
              
              <!-- 大图标模式 -->
              <div v-else-if="viewMode === 'large'" class="images-grid large-grid">
                <ImageCard 
                  v-for="image in gallery.images" 
                  :key="image.id" 
                  :image="image"
                  :size="'large'"
                  @click="viewImage(image.id)"
                />
              </div>
              
              <!-- 小图标模式 -->
              <div v-else-if="viewMode === 'small'" class="images-grid small-grid">
                <ImageCard 
                  v-for="image in gallery.images" 
                  :key="image.id" 
                  :image="image"
                  :size="'small'"
                  @click="viewImage(image.id)"
                />
              </div>
              
              <!-- 详细列表模式 -->
              <div v-else-if="viewMode === 'list'" class="images-list">
                <ImageListItem 
                  v-for="image in gallery.images" 
                  :key="image.id" 
                  :image="image"
                  @click="viewImage(image.id)"
                />
              </div>
              
              <!-- 幻灯片模式 -->
              <div v-else-if="viewMode === 'slideshow'" class="slideshow-container">
                <ImageSlideshow 
                  :images="gallery.images"
                  @image-click="viewImage"
                />
              </div>
            </div>
            
            <div v-else class="no-images">
              <n-empty description="暂无图片" />
            </div>
          </div>

          <!-- Comments section -->
          <div class="comments-section">
            <div class="comments-card">
              <CommentsSection 
                :gallery-id="gallery.id" 
                :comments="gallery.comments || []" 
                @comment-posted="handleCommentPosted"
                @comment-deleted="handleCommentDeleted"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <AppFooter theme-color="#10b981" />
    </div>

    <!-- Error state -->
    <div v-else class="error-container">
      <n-result status="404" title="图集不存在" description="请检查链接是否正确">
        <template #footer>
          <n-button @click="$router.push('/')">返回首页</n-button>
        </template>
      </n-result>
    </div>

    <!-- 图集编辑模态窗口 -->
    <GalleryEditModal
      v-if="gallery"
      v-model:visible="showEditModal"
      :gallery="gallery"
      @gallery-updated="handleGalleryUpdated"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { 
  NSpin, NIcon, NButton, NEmpty, NResult,
  useMessage, useNotification, NButtonGroup, NTooltip
} from 'naive-ui';
import {
  PersonOutline, FolderOutline, TimeOutline, ImagesOutline,
  EyeOutline, HeartOutline, BookmarkOutline, Heart, Bookmark, CreateOutline,
  GridOutline, ListOutline, PlayOutline
} from '@vicons/ionicons5';

import ImageCard from '@/components/ImageCard.vue';
import CommentsSection from '@/components/CommentsSection.vue';
import AppFooter from '@/components/AppFooter.vue';
import GalleryEditModal from '@/components/GalleryEditModal.vue';
import { useAuthStore } from '@/stores/auth';
import { usePageTitle } from '@/utils/page-title';
import api from '@/api/api.js';
import ImageListItem from '@/components/ImageListItem.vue';
import ImageSlideshow from '@/components/ImageSlideshow.vue';

const route = useRoute();
const router = useRouter();
const message = useMessage();
const notification = useNotification();
const authStore = useAuthStore();
const { setTitle } = usePageTitle();

const gallery = ref(null);
const loading = ref(true);
const liking = ref(false);
const bookmarking = ref(false);
const showEditModal = ref(false);
const viewMode = ref('extra-large'); // 默认显示模式

// 计算属性：判断是否可以编辑图集
const canEditGallery = computed(() => {
  return authStore.isAuthenticated && 
         gallery.value && 
         gallery.value.owner && 
         gallery.value.owner.id === authStore.user?.id;
});

// 获取图集详情
async function fetchGallery() {
  try {
    loading.value = true;
    const response = await api.get(`/galleries/${route.params.id}`);
    gallery.value = response.data;
  } catch (error) {
    console.error('获取图集详情失败:', error);
    message.error('获取图集详情失败');
  } finally {
    loading.value = false;
  }
}

// 格式化日期
function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

// 查看图片详情
function viewImage(imageId) {
  router.push({ name: 'image-detail', params: { id: imageId } });
}

// 切换点赞
async function toggleLike() {
  if (!authStore.isAuthenticated) {
    message.warning('请先登录');
    return;
  }

  try {
    liking.value = true;
    const response = await api.post(`/galleries/${gallery.value.id}/like`);
    
    // 更新状态
    gallery.value.liked_by_current_user = response.data.liked;
    gallery.value.likes_count = response.data.likes_count;
    
    message.success(response.data.liked ? '点赞成功' : '取消点赞');
  } catch (error) {
    console.error('点赞操作失败:', error);
    message.error('操作失败');
    // 如果出错，重新获取最新状态
    fetchGallery();
  } finally {
    liking.value = false;
  }
}

// 切换收藏
async function toggleBookmark() {
  if (!authStore.isAuthenticated) {
    message.warning('请先登录');
    return;
  }

  try {
    bookmarking.value = true;
    const response = await api.post(`/galleries/${gallery.value.id}/bookmark`);
    
    // 更新状态
    gallery.value.bookmarked_by_current_user = response.data.bookmarked;
    gallery.value.bookmarks_count = response.data.bookmarks_count;
    
    message.success(response.data.bookmarked ? '收藏成功' : '取消收藏');
  } catch (error) {
    console.error('收藏操作失败:', error);
    message.error('操作失败');
    // 如果出错，重新获取最新状态
    fetchGallery();
  } finally {
    bookmarking.value = false;
  }
}

// 处理新评论
function handleCommentPosted(newComment) {
  if (gallery.value) {
    // 将新评论添加到评论列表的开头
    gallery.value.comments = gallery.value.comments || [];
    gallery.value.comments.unshift(newComment);
  }
}

// 处理删除评论
function handleCommentDeleted(commentId) {
  if (gallery.value) {
    const index = gallery.value.comments.findIndex(comment => comment.id === commentId);
    if (index !== -1) {
      gallery.value.comments.splice(index, 1);
    }
  }
}

// 处理图集更新
function handleGalleryUpdated() {
  // 重新获取图集详情
  fetchGallery();
  message.success('图集修改成功！');
}

// 切换显示模式
function setViewMode(mode) {
  viewMode.value = mode;
}

// 监听图集数据变化，更新页面标题
watch(gallery, (newGallery) => {
  if (newGallery && newGallery.title) {
    setTitle(`${newGallery.title} - AI Gallery`);
  }
}, { immediate: true });

onMounted(() => {
  fetchGallery();
});
</script>

<style scoped>
.gallery-view {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.loading-container, .error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}

.gallery-page {
  min-height: calc(100vh - 64px);
}

/* Gallery Banner */
.gallery-banner {
  position: relative;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  overflow: hidden;
  color: white;
}

.banner-content {
  text-align: center;
  z-index: 2;
  position: relative;
  max-width: 1200px;
  padding: 0 24px;
}

.gallery-header-info {
  max-width: 800px;
  margin: 0 auto;
}

.gallery-main-title {
  font-size: 42px;
  font-weight: bold;
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  line-height: 1.2;
}

.gallery-subtitle {
  font-size: 18px;
  margin: 0 0 24px 0;
  opacity: 0.9;
  font-weight: 300;
  line-height: 1.5;
}

.gallery-meta-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 24px;
  margin-bottom: 20px;
  font-size: 14px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  opacity: 0.9;
}

.gallery-stats-row {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 32px;
}

.stat-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  backdrop-filter: blur(10px);
}

.gallery-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

/* 图集页面专用按钮样式 */
.gallery-view :deep(.n-button--primary) {
  background: linear-gradient(135deg, #ffffff 0%, #f3f4f6 100%) !important;
  color: #059669 !important;
  border: 2px solid rgba(255, 255, 255, 0.8) !important;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.gallery-view :deep(.n-button--primary:hover) {
  background: linear-gradient(135deg, #f9fafb 0%, #e5e7eb 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}

/* 已点赞状态的特殊样式 */
.gallery-view :deep(.n-button--primary.liked) {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
  color: white !important;
  border-color: #10b981 !important;
}

.gallery-view :deep(.n-button--default) {
  background: rgba(255, 255, 255, 0.15) !important;
  color: white !important;
  border: 2px solid rgba(255, 255, 255, 0.3) !important;
  font-weight: 500;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.gallery-view :deep(.n-button--default:hover) {
  background: rgba(255, 255, 255, 0.25) !important;
  border-color: rgba(255, 255, 255, 0.5) !important;
  transform: translateY(-2px);
}

/* 已收藏状态的特殊样式 */
.gallery-view :deep(.n-button--default.bookmarked) {
  background: rgba(255, 255, 255, 0.9) !important;
  color: #059669 !important;
  border-color: rgba(255, 255, 255, 0.8) !important;
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

/* Main Content */
.main-content {
  padding: 40px 0;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.images-section {
  margin-bottom: 40px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  text-align: left;
}

.view-mode-controls {
  display: flex;
  gap: 8px;
}

.images-display {
  /* 移除默认的grid设置，让子类控制 */
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  padding: 24px;
}

/* Specific styles for each view mode */
.images-grid.extra-large-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
}

.images-grid.large-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.images-grid.small-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.images-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.slideshow-container {
  width: 100%;
  height: 80vh; /* 增大到80vh以获得更大的显示区域 */
  background: #000;
  border-radius: 12px;
  overflow: hidden;
  position: relative;
}

.no-images {
  text-align: center;
  padding: 60px 0;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.comments-section {
  margin-bottom: 40px;
}

.comments-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .images-grid.extra-large-grid {
    grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
    gap: 20px;
  }
  
  .images-grid.large-grid {
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 16px;
  }
  
  .images-grid.small-grid {
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
  }
  
  .slideshow-container {
    height: 75vh;
  }
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .section-title {
    text-align: center;
  }
  
  .view-mode-controls {
    justify-content: center;
    flex-wrap: wrap;
  }
  
  .images-grid.extra-large-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .images-grid.large-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 12px;
  }
  
  .images-grid.small-grid {
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 8px;
  }
  
  .slideshow-container {
    height: 60vh;
  }
}

@media (max-width: 480px) {
  .section-header {
    gap: 12px;
  }
  
  .view-mode-controls {
    gap: 4px;
  }
  
  .view-mode-controls .n-button {
    padding: 0 8px !important;
    height: 32px !important;
    font-size: 12px !important;
  }
  
  .images-grid.extra-large-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .images-grid.large-grid {
    grid-template-columns: 1fr;
    gap: 8px;
  }
  
  .images-grid.small-grid {
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 6px;
  }
  
  .slideshow-container {
    height: 50vh;
  }
}
</style> 