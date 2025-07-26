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

// 切换点赞状态
const toggleLike = async () => {
  if (!isAuthenticated.value) {
    message.warning('请先登录');
    return;
  }
  
  try {
    await imageStore.toggleLike(currentImage.value.id);
    message.success(currentImage.value.liked_by_current_user ? '已取消点赞' : '点赞成功');
  } catch (error) {
    console.error('点赞失败:', error);
    message.error('操作失败，请重试');
  }
};

// 切换收藏状态
const toggleBookmark = async () => {
  if (!isAuthenticated.value) {
    message.warning('请先登录');
    return;
  }
  
  try {
    await imageStore.toggleBookmark(currentImage.value.id);
    message.success(currentImage.value.bookmarked_by_current_user ? '已取消收藏' : '收藏成功');
  } catch (error) {
    console.error('收藏失败:', error);
    message.error('操作失败，请重试');
  }
};

// 下载图片
const downloadImage = () => {
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

// 处理图片加载错误
const handleImageError = (event) => {
  console.error('图片加载失败:', event.target.src);
  message.error('图片加载失败');
};

// 打开图片查看器
const openImageViewer = () => {
  showImageViewer.value = true;
};
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
            <n-breadcrumb-item @click="$router.push('/')">首页</n-breadcrumb-item>
            <n-breadcrumb-item v-if="currentImage.gallery" @click="$router.push(`/galleries/${currentImage.gallery.id}`)">
              {{ currentImage.gallery.title }}
            </n-breadcrumb-item>
            <n-breadcrumb-item>{{ currentImage.title }}</n-breadcrumb-item>
          </n-breadcrumb>

          <!-- 页面标题 -->
          <div class="page-title-section">
            <h1 class="page-title">{{ currentImage.title }}</h1>
            <p v-if="currentImage.description" class="page-subtitle">{{ currentImage.description }}</p>
          </div>

          <!-- 图片元信息 -->
          <div class="image-meta-section">
            <div class="meta-row">
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
              <span class="meta-item">
                <n-icon><TimeOutline /></n-icon>
                {{ formatDate(currentImage.created_at) }}
              </span>
            </div>

            <div class="stats-row">
              <span class="stat-badge">
                <n-icon><EyeOutline /></n-icon>
                {{ currentImage.views_count }} 次浏览
              </span>
              <span class="stat-badge">
                <n-icon><HeartOutline /></n-icon>
                {{ currentImage.likes_count }} 次点赞
              </span>
              <span class="stat-badge">
                <n-icon><BookmarkOutline /></n-icon>
                {{ currentImage.bookmarks_count }} 次收藏
              </span>
            </div>

            <!-- 标签 -->
            <div class="tags-section" v-if="currentImage.tags && currentImage.tags.length > 0">
              <n-tag
                v-for="tag in currentImage.tags"
                :key="tag.id"
                class="custom-tag"
                size="medium"
              >
                {{ tag.name }}
              </n-tag>
            </div>
          </div>
        </div>
      </div>

      <!-- 主要内容区域 -->
      <div class="main-content">
        <div class="container">
          <!-- 图片展示区域 -->
          <div class="image-display-section">
            <div class="image-container" @click="showImageViewer = true">
              <div class="image-wrapper">
                <img
                  :src="currentImage.image_url"
                  :alt="currentImage.title"
                  class="main-image"
                  @error="handleImageError"
                />
                <div class="image-overlay">
                  <div class="overlay-content">
                    <n-icon class="expand-icon" size="48"><ExpandOutline /></n-icon>
                    <p class="overlay-text">点击查看大图</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 操作按钮 -->
          <div class="image-actions">
            <n-button
              @click="toggleLike"
              :type="currentImage.liked_by_current_user ? 'primary' : 'default'"
              size="large"
            >
              <template #icon>
                <n-icon>
                  <Heart v-if="currentImage.liked_by_current_user" />
                  <HeartOutline v-else />
                </n-icon>
              </template>
              {{ currentImage.liked_by_current_user ? '已点赞' : '点赞' }}
            </n-button>

            <n-button
              @click="toggleBookmark"
              :type="currentImage.bookmarked_by_current_user ? 'primary' : 'default'"
              size="large"
            >
              <template #icon>
                <n-icon>
                  <Bookmark v-if="currentImage.bookmarked_by_current_user" />
                  <BookmarkOutline v-else />
                </n-icon>
              </template>
              {{ currentImage.bookmarked_by_current_user ? '已收藏' : '收藏' }}
            </n-button>

            <n-button
              @click="downloadImage"
              type="default"
              size="large"
            >
              <template #icon>
                <n-icon><DownloadOutline /></n-icon>
              </template>
              下载
            </n-button>
          </div>

          <!-- 评论区域 -->
          <div class="comments-section">
            <CommentsSection
              :content-id="currentImage.id"
              content-type="image"
              :comments="currentImage.comments"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Error state -->
    <div v-else class="error-container">
      <n-result
        status="404"
        title="图片不存在"
        description="该图片可能已被删除或移动"
      >
        <template #extra>
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

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
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

/* 图片元信息区域 */
.image-meta-section {
  text-align: center;
}

.meta-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 24px;
  margin-bottom: 16px;
  font-size: 14px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  opacity: 0.9;
}

.stats-row {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 16px;
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
  margin-bottom: 0;
}

.custom-tag {
  background: rgba(255, 255, 255, 0.9) !important;
  color: #3b82f6 !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  backdrop-filter: blur(10px);
  font-weight: 500;
  padding: 6px 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin: 0 4px;
}

.custom-tag:hover {
  background: rgba(255, 255, 255, 1) !important;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
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

/* 操作按钮 */
.image-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-bottom: 40px;
}

.image-actions :deep(.n-button) {
  min-width: 120px;
}

/* 评论区域 */
.comments-section {
  margin-bottom: 40px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    padding: 20px 0;
  }
  
  .page-title {
    font-size: 24px;
    margin-bottom: 8px;
  }
  
  .page-subtitle {
    font-size: 14px;
  }
  
  .meta-row {
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: center;
    gap: 16px 12px;
    margin-bottom: 12px;
    font-size: 12px;
  }
  
  .meta-item {
    gap: 4px;
    white-space: nowrap;
  }
  
  .stats-row {
    gap: 12px;
    margin-bottom: 12px;
  }
  
  .stat-badge {
    font-size: 12px;
    padding: 6px 12px;
  }
  
  .image-container {
    min-height: 300px;
    padding: 16px;
  }
  
  .image-actions {
    flex-direction: column;
    align-items: center;
    gap: 12px;
  }
  
  .image-actions :deep(.n-button) {
    width: 200px;
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
  
  .meta-row {
    gap: 12px 8px;
    font-size: 11px;
  }
  
  .stats-row {
    gap: 8px;
  }
  
  .stat-badge {
    font-size: 11px;
    padding: 4px 8px;
  }
  
  .image-container {
    min-height: 250px;
    padding: 12px;
  }
  
  .image-actions :deep(.n-button) {
    width: 180px;
    font-size: 14px;
  }
}
</style> 