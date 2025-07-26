<script setup>
import { onMounted, watch, ref, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useImageStore } from '@/stores/image';
import { useAuthStore } from '@/stores/auth';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { NCard, NImage, NSpace, NTag, NButton, NIcon, NSpin, NResult, useMessage, NBreadcrumb, NBreadcrumbItem } from 'naive-ui';
import { 
  Heart, HeartOutline, Bookmark, BookmarkOutline, DownloadOutline,
  PersonOutline, FolderOutline, TimeOutline, EyeOutline, ExpandOutline, ImagesOutline
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
      <!-- 页面头部 -->
      <div class="page-header">
        <div class="container">
          <!-- 面包屑导航 -->
          <n-breadcrumb class="breadcrumb">
            <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
            <n-breadcrumb-item v-if="currentImage.gallery" :href="`/galleries/${currentImage.gallery.id}`">
              {{ currentImage.gallery.title }}
            </n-breadcrumb-item>
            <n-breadcrumb-item>{{ currentImage.title }}</n-breadcrumb-item>
          </n-breadcrumb>

          <!-- 页面标题 -->
          <div class="page-title-section">
            <h1 class="page-title">{{ currentImage.title }}</h1>
            <p v-if="currentImage.description" class="page-subtitle">{{ currentImage.description }}</p>
          </div>

          <!-- 图片统计信息 -->
          <div class="image-stats" v-if="currentImage">
            <div class="stats-item">
              <n-icon><EyeOutline /></n-icon>
              <span>{{ currentImage.views_count || 0 }} 浏览</span>
            </div>
            <div class="stats-item">
              <n-icon><HeartOutline /></n-icon>
              <span>{{ currentImage.likes_count || 0 }} 点赞</span>
            </div>
            <div class="stats-item">
              <n-icon><BookmarkOutline /></n-icon>
              <span>{{ currentImage.bookmarks_count || 0 }} 收藏</span>
            </div>
            <div class="stats-item">
              <span>上传于 {{ formatDate(currentImage.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 主要内容区域 -->
      <div class="main-content">
        <div class="container">
          <!-- 图片信息卡片 -->
          <div class="image-info-card">
            <div class="image-meta-row">
              <span class="meta-item">
                <n-icon><PersonOutline /></n-icon>
                {{ currentImage.owner?.username || '未知用户' }}
              </span>
              <span class="meta-item" v-if="currentImage.category">
                <n-icon><FolderOutline /></n-icon>
                {{ currentImage.category.name }}
              </span>
              <span class="meta-item" v-if="currentImage.gallery">
                <n-icon><ImagesOutline /></n-icon>
                {{ currentImage.gallery.title }}
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

            <!-- 操作按钮 -->
            <div class="image-actions">
              <n-button 
                type="primary" 
                @click="openImageViewer"
                class="view-button"
              >
                <template #icon>
                  <n-icon><ExpandOutline /></n-icon>
                </template>
                查看大图
              </n-button>
              
              <n-button 
                @click="handleDownload"
                class="download-button"
              >
                <template #icon>
                  <n-icon><DownloadOutline /></n-icon>
                </template>
                下载图片
              </n-button>
            </div>
          </div>

          <!-- 图片展示区域 -->
          <div class="image-container">
            <n-card class="image-card">
              <div class="image-wrapper" @click="openImageViewer">
                <n-image
                  :src="imageInfo.src"
                  :alt="currentImage.title"
                  class="main-image"
                  object-fit="contain"
                  preview-disabled
                />
              </div>
            </n-card>
          </div>

          <!-- 评论区域 -->
          <div class="comments-section">
            <n-card class="comments-card">
              <CommentsSection
                :content-id="currentImage.id"
                :content-type="'image'"
                :comments="currentImage.comments"
                @comment-posted="handleCommentPosted"
                @comment-deleted="handleCommentDeleted"
              />
            </n-card>
          </div>
        </div>
      </div>

      <!-- 图片查看器 -->
      <ImageViewer
        v-if="showImageViewer"
        :image-info="imageInfo"
        @close="showImageViewer = false"
      />
    </div>

    <!-- Error state -->
    <div v-else class="error-container">
      <n-result
        status="404"
        title="图片不存在"
        description="您访问的图片可能已被删除或不存在"
      >
        <template #extra>
          <n-button @click="$router.push('/')" type="primary">
            返回首页
          </n-button>
        </template>
      </n-result>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#3b82f6" />
  </div>
</template>

<style scoped>
.image-view {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
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
  margin-bottom: 20px;
}

.page-title {
  font-size: 32px;
  font-weight: 700;
  margin: 0 0 8px 0;
  color: white;
}

.page-subtitle {
  font-size: 16px;
  margin: 0;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.5;
}

.image-stats {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
}

.stats-item .n-icon {
  font-size: 16px;
}

/* 主要内容区域 */
.main-content {
  padding: 32px 0;
}

/* 图片信息卡片 */
.image-info-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.image-meta-row {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #6b7280;
}

.meta-item .n-icon {
  font-size: 16px;
  color: #9ca3af;
}

.tags-section {
  margin-bottom: 20px;
}

.custom-tag {
  font-size: 12px;
  padding: 4px 12px;
}

.image-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.view-button {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border: none;
  color: white;
  font-weight: 500;
}

.view-button:hover {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
}

.download-button {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  color: #374151;
  font-weight: 500;
}

.download-button:hover {
  background: #e5e7eb;
  border-color: #9ca3af;
}

/* 图片展示区域 */
.image-container {
  margin-bottom: 32px;
}

.image-card {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.image-wrapper {
  cursor: pointer;
  transition: transform 0.2s ease;
  background: #f9fafb;
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.image-wrapper:hover {
  transform: scale(1.02);
}

.main-image {
  max-width: 100%;
  max-height: 600px;
  object-fit: contain;
}

/* 评论区域 */
.comments-section {
  margin-bottom: 32px;
}

.comments-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* Loading state */
.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
  padding: 64px 24px 24px;
}

/* Error state */
.error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
  padding: 64px 24px 24px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    padding: 20px 0;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .page-subtitle {
    font-size: 14px;
  }
  
  .image-stats {
    gap: 16px;
  }
  
  .stats-item {
    font-size: 13px;
  }
  
  .main-content {
    padding: 24px 0;
  }
  
  .image-info-card {
    padding: 20px;
    margin-bottom: 20px;
  }
  
  .image-meta-row {
    gap: 16px;
    margin-bottom: 16px;
  }
  
  .meta-item {
    font-size: 13px;
  }
  
  .image-actions {
    gap: 8px;
  }
  
  .image-wrapper {
    min-height: 300px;
  }
  
  .main-image {
    max-height: 400px;
  }
}

@media (max-width: 480px) {
  .page-header {
    padding: 16px 0;
  }
  
  .page-title {
    font-size: 20px;
  }
  
  .page-subtitle {
    font-size: 13px;
  }
  
  .image-stats {
    gap: 12px;
  }
  
  .stats-item {
    font-size: 12px;
  }
  
  .main-content {
    padding: 16px 0;
  }
  
  .container {
    padding: 0 16px;
  }
  
  .image-info-card {
    padding: 16px;
    margin-bottom: 16px;
  }
  
  .image-meta-row {
    gap: 12px;
    margin-bottom: 12px;
  }
  
  .meta-item {
    font-size: 12px;
  }
  
  .image-wrapper {
    min-height: 250px;
  }
  
  .main-image {
    max-height: 300px;
  }
}
</style> 