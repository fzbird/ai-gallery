<script setup>
import { onMounted, watch, ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useImageStore } from '@/stores/image';
import { useAuthStore } from '@/stores/auth';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { NCard, NImage, NSpace, NTag, NButton, NIcon, NSpin, NResult, useMessage } from 'naive-ui';
import { 
  Heart, HeartOutline, Bookmark, BookmarkOutline, DownloadOutline,
  PersonOutline, FolderOutline, TimeOutline, EyeOutline, ExpandOutline
} from '@vicons/ionicons5';
import CommentsSection from '@/components/CommentsSection.vue';
import AppFooter from '@/components/AppFooter.vue';
import ImageViewSkeleton from '@/components/skeletons/ImageViewSkeleton.vue';
import ImageViewer from '@/components/ImageViewer.vue';
import { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  id: {
    type: [String, Number],
    required: true
  }
});

const route = useRoute();
const imageStore = useImageStore();
const authStore = useAuthStore();
const { setTitle } = usePageTitle();
const { currentImage, isLoading } = storeToRefs(imageStore);
const { isAuthenticated } = storeToRefs(authStore);
const message = useMessage();

// 图片查看器状态
const showImageViewer = ref(false);

// 计算图片信息
const imageInfo = computed(() => {
  if (!currentImage.value) return {};
  
  return {
    src: `${API_BASE_URL()}${currentImage.value.image_url}`,
    title: currentImage.value.title,
    size: currentImage.value.file_size ? formatFileSize(currentImage.value.file_size) : '',
    downloadName: currentImage.value.filename || 'image'
  };
});

onMounted(() => {
  imageStore.fetchImageById(props.id);
});

watch(() => route.params.id, (newId) => {
  if (newId) {
    imageStore.fetchImageById(newId);
  }
});

// 监听当前图片变化，更新页面标题
watch(currentImage, (newImage) => {
  if (newImage && newImage.title) {
    setTitle(`${newImage.title} - AI Gallery`);
  }
}, { immediate: true });

const handleCommentPosted = (newComment) => {
  if (currentImage.value) {
    currentImage.value.comments.push(newComment);
  }
}

const handleCommentDeleted = (commentId) => {
  if (currentImage.value) {
    const index = currentImage.value.comments.findIndex(comment => comment.id === commentId);
    if (index !== -1) {
      currentImage.value.comments.splice(index, 1);
    }
  }
}

const handleDownload = () => {
  const imageUrl = `${API_BASE_URL()}${currentImage.value.image_url}`;
  
  // 下载图片
  const a = document.createElement('a');
  a.href = imageUrl;
  a.download = currentImage.value.filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  
  message.success('图片已开始下载');
};

// 打开图片查看器
const openImageViewer = () => {
  showImageViewer.value = true;
};

// 格式化文件大小
const formatFileSize = (bytes) => {
  if (!bytes) return '';
  
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  const size = (bytes / Math.pow(1024, i)).toFixed(1);
  
  return `${size} ${sizes[i]}`;
};

// 格式化日期
function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}
</script>

<template>
  <div class="image-view">
    <!-- Loading state -->
    <div v-if="isLoading" class="loading-container">
      <n-spin size="large">
        <template #description>加载中...</template>
      </n-spin>
    </div>

    <!-- Image content -->
    <div v-else-if="currentImage" class="image-page">
      <!-- Image header banner -->
      <div class="image-banner">
        <div class="banner-content">
          <div class="image-header-info">
            <h1 class="image-main-title">{{ currentImage.title }}</h1>
            <p v-if="currentImage.description" class="image-subtitle">{{ currentImage.description }}</p>
            
            <div class="image-meta-row">
              <span class="meta-item">
                <n-icon><PersonOutline /></n-icon>
                {{ currentImage.owner?.username || '未知用户' }}
              </span>
              <span class="meta-item" v-if="currentImage.category">
                <n-icon><FolderOutline /></n-icon>
                {{ currentImage.category.name }}
              </span>
              <span class="meta-item">
                <n-icon><TimeOutline /></n-icon>
                {{ formatDate(currentImage.created_at) }}
              </span>
            </div>

            <div class="image-stats-row">
              <span class="stat-badge">
                <n-icon><EyeOutline /></n-icon>
                {{ currentImage.views_count || 0 }} 浏览
              </span>
              <span class="stat-badge">
                <n-icon><HeartOutline /></n-icon>
                {{ currentImage.likes_count || 0 }} 点赞
              </span>
              <span class="stat-badge">
                <n-icon><BookmarkOutline /></n-icon>
                {{ currentImage.bookmarks_count || 0 }} 收藏
              </span>
            </div>

            <!-- Tags -->
            <div v-if="currentImage.tags && currentImage.tags.length > 0" class="tags-section">
              <n-space>
                <n-tag 
                  v-for="tag in currentImage.tags" 
                  :key="tag.id" 
                  type="primary"
                  round
                  class="custom-tag"
                >
                  {{ tag.name }}
                </n-tag>
              </n-space>
            </div>

            <!-- Action buttons -->
            <div class="image-actions">
              <n-button 
                type="primary" 
                size="large"
                @click="imageStore.toggleLike(currentImage.id)" 
                :disabled="!isAuthenticated"
              >
                <template #icon>
                  <n-icon :component="currentImage.liked_by_current_user ? Heart : HeartOutline" />
                </template>
                {{ currentImage.liked_by_current_user ? '已喜欢' : '喜欢' }}
              </n-button>
              
              <n-button 
                type="default"
                size="large"
                @click="imageStore.toggleBookmark(currentImage.id)" 
                :disabled="!isAuthenticated"
                ghost
              >
                <template #icon>
                  <n-icon :component="currentImage.bookmarked_by_current_user ? Bookmark : BookmarkOutline" />
                </template>
                {{ currentImage.bookmarked_by_current_user ? '已收藏' : '收藏' }}
              </n-button>
              
              <n-button 
                type="default"
                size="large"
                @click="openImageViewer"
                ghost
              >
                <template #icon>
                  <n-icon><ExpandOutline /></n-icon>
                </template>
                查看大图
              </n-button>
              
              <n-button 
                type="default"
                size="large"
                @click="handleDownload"
                ghost
              >
                <template #icon>
                  <n-icon><DownloadOutline /></n-icon>
                </template>
                下载
              </n-button>
            </div>
          </div>
        </div>
        <div class="banner-bg"></div>
      </div>

      <!-- Main content -->
      <div class="main-content">
        <div class="container">
          <!-- Image display section -->
          <div class="image-display-section">
            <div class="image-container" @click="openImageViewer">
              <div class="image-wrapper">
                <img 
                  :src="`${API_BASE_URL()}${currentImage.image_url}`" 
                  :alt="currentImage.title" 
                  class="main-image" 
                />
                <div class="image-overlay">
                  <div class="overlay-content">
                    <n-icon size="40" class="expand-icon">
                      <ExpandOutline />
                    </n-icon>
                    <p class="overlay-text">点击查看大图</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Comments section -->
          <div class="comments-section">
            <div class="comments-card">
              <CommentsSection
                v-if="currentImage.comments"
                :image-id="currentImage.id"
                :comments="currentImage.comments"
                @comment-posted="handleCommentPosted"
                @comment-deleted="handleCommentDeleted"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <AppFooter theme-color="#3b82f6" />
    </div>

    <!-- Error state -->
    <div v-else class="error-container">
      <n-result status="404" title="图片不存在" description="请检查链接是否正确">
        <template #footer>
          <n-button @click="$router.push('/')">返回首页</n-button>
        </template>
      </n-result>
    </div>

    <!-- Image Viewer -->
    <ImageViewer
      v-if="currentImage"
      v-model:show="showImageViewer"
      :image-src="imageInfo.src"
      :image-title="imageInfo.title"
      :image-size="imageInfo.size"
      :download-name="imageInfo.downloadName"
    />
  </div>
</template>

<style scoped>
.image-view {
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

.image-page {
  min-height: calc(100vh - 64px);
}

/* Image Banner */
.image-banner {
  position: relative;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
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

.image-header-info {
  max-width: 800px;
  margin: 0 auto;
}

.image-main-title {
  font-size: 42px;
  font-weight: bold;
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  line-height: 1.2;
}

.image-subtitle {
  font-size: 18px;
  margin: 0 0 24px 0;
  opacity: 0.9;
  font-weight: 300;
  line-height: 1.5;
}

.image-meta-row {
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

.image-stats-row {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 24px;
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

.tags-section {
  margin-bottom: 32px;
}

.custom-tag {
  background: rgba(255, 255, 255, 0.9) !important;
  color: #3b82f6 !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  backdrop-filter: blur(10px);
  font-weight: 500;
  padding: 6px 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.custom-tag:hover {
  background: rgba(255, 255, 255, 1) !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.image-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

/* 图片页面专用按钮样式 */
.image-view :deep(.n-button--primary) {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%) !important;
  color: #3b82f6 !important;
  border: 2px solid rgba(255, 255, 255, 0.8) !important;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(10px);
}

.image-view :deep(.n-button--primary:hover) {
  background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}

.image-view :deep(.n-button--default) {
  background: rgba(255, 255, 255, 0.15) !important;
  color: white !important;
  border: 2px solid rgba(255, 255, 255, 0.3) !important;
  font-weight: 500;
  backdrop-filter: blur(10px);
}

.image-view :deep(.n-button--default:hover) {
  background: rgba(255, 255, 255, 0.25) !important;
  border-color: rgba(255, 255, 255, 0.5) !important;
  transform: translateY(-2px);
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

.image-display-section {
  margin-bottom: 40px;
}

.image-container {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.image-container:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.image-wrapper {
  position: relative;
  display: inline-block;
}

.main-image {
  max-width: 100%;
  max-height: 70vh;
  border-radius: 8px;
  transition: filter 0.3s ease;
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.image-wrapper:hover .image-overlay {
  opacity: 1;
}

.overlay-content {
  text-align: center;
  color: white;
}

.expand-icon {
  margin-bottom: 8px;
  color: white;
}

.overlay-text {
  margin: 0;
  font-size: 14px;
  font-weight: 500;
  color: white;
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
@media (max-width: 768px) {
  .image-banner {
    min-height: 220px; /* 大幅减少banner高度 */
    padding: 20px 0;
  }
  
  .banner-content {
    padding: 0 16px;
  }
  
  .image-main-title {
    font-size: 24px; /* 进一步减小标题 */
    margin-bottom: 8px;
  }
  
  .image-subtitle {
    font-size: 14px;
    margin-bottom: 16px;
  }
  
  .image-meta-row {
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
    gap: 16px 12px; /* 垂直16px，水平12px */
    margin-bottom: 16px;
    font-size: 12px;
  }
  
  .meta-item {
    gap: 4px;
    white-space: nowrap;
  }
  
  .image-stats-row {
    flex-direction: row;
    justify-content: center;
    gap: 8px;
    margin-bottom: 16px;
  }
  
  .stat-badge {
    padding: 6px 12px;
    font-size: 12px;
    border-radius: 16px;
    gap: 4px;
  }
  
  .tags-section {
    margin-bottom: 20px;
  }
  
  .image-actions {
    flex-direction: row;
    justify-content: center;
    gap: 8px;
    flex-wrap: wrap;
  }
  
  .image-actions .n-button {
    padding: 0 12px !important;
    height: 36px !important;
    font-size: 13px !important;
    min-width: auto !important;
  }
  
  .main-content {
    padding: 24px 0;
  }
  
  .image-container {
    padding: 16px;
    min-height: 300px;
  }
  
  .comments-card {
    padding: 16px;
  }
}

/* 超小屏幕进一步优化 */
@media (max-width: 480px) {
  .image-banner {
    min-height: 180px; /* 超小屏幕进一步减少高度 */
    padding: 16px 0;
  }
  
  .image-main-title {
    font-size: 20px;
    margin-bottom: 6px;
  }
  
  .image-subtitle {
    font-size: 13px;
    margin-bottom: 12px;
  }
  
  .image-meta-row {
    gap: 12px 8px;
    margin-bottom: 12px;
    font-size: 11px;
  }
  
  .image-stats-row {
    gap: 6px;
    margin-bottom: 12px;
  }
  
  .stat-badge {
    padding: 4px 8px;
    font-size: 11px;
    border-radius: 12px;
  }
  
  .tags-section {
    margin-bottom: 16px;
  }
  
  .image-actions {
    gap: 6px;
  }
  
  .image-actions .n-button {
    padding: 0 8px !important;
    height: 32px !important;
    font-size: 12px !important;
  }
  
  .main-content {
    padding: 16px 0;
  }
  
  .container {
    padding: 0 12px;
  }
  
  .image-container {
    padding: 12px;
    min-height: 250px;
  }
  
  .comments-card {
    padding: 12px;
  }
}
</style> 