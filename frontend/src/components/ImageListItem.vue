<template>
  <div class="image-list-item" @click="navigateToDetail">
    <div class="item-image">
      <img 
        :src="`${API_BASE_URL()}${image.image_url}`" 
        :alt="image.title"
        loading="lazy"
        @error="handleImageError"
      />
    </div>
    
    <div class="item-content">
      <div class="item-header">
        <h3 class="item-title">{{ image.title }}</h3>
        <div class="item-meta">
          <span class="upload-time">{{ formatDate(image.created_at) }}</span>
        </div>
      </div>
      
      <div class="item-description" v-if="image.description">
        {{ image.description }}
      </div>
      
      <div class="item-stats">
        <div class="stat-item">
          <n-icon><EyeOutline /></n-icon>
          <span>{{ image.views_count || 0 }}</span>
        </div>
        <div class="stat-item">
          <n-icon><HeartOutline /></n-icon>
          <span>{{ image.likes_count || 0 }}</span>
        </div>
        <div class="stat-item">
          <n-icon><BookmarkOutline /></n-icon>
          <span>{{ image.bookmarks_count || 0 }}</span>
        </div>
        <div class="stat-item">
          <n-icon><DownloadOutline /></n-icon>
          <span>{{ image.downloads_count || 0 }}</span>
        </div>
      </div>
      
      <div class="item-tags" v-if="image.tags && image.tags.length > 0">
        <n-tag 
          v-for="tag in image.tags.slice(0, 3)" 
          :key="tag.id" 
          size="small" 
          type="info"
        >
          {{ tag.name }}
        </n-tag>
        <span v-if="image.tags.length > 3" class="more-tags">
          +{{ image.tags.length - 3 }}
        </span>
      </div>
    </div>
    
    <div class="item-actions">
      <n-button size="small" type="primary" ghost>
        <template #icon>
          <n-icon><EyeOutline /></n-icon>
        </template>
        查看
      </n-button>
    </div>
  </div>
</template>

<script setup>
import { NCard, NIcon, NSpace, NTag, NImage, NButton, NPopconfirm, NTooltip } from 'naive-ui';
import { 
  EyeOutline, HeartOutline, BookmarkOutline, DownloadOutline 
} from '@vicons/ionicons5';
import { useRouter } from 'vue-router';
import { computed, defineEmits } from 'vue';
import { API_BASE_URL } from '@/api/api.js';
import { message } from '@/utils/discrete-api';

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
});

const emit = defineEmits(['click']);

const router = useRouter();

function navigateToDetail() {
  router.push({ name: 'image-detail', params: { id: props.image.id } });
}

function handleImageError() {
  // Handle image loading error
}

function formatDate(dateString) {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}
</script>

<style scoped>
.image-list-item {
  display: flex;
  align-items: center;
  padding: 16px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
  gap: 16px;
}

.image-list-item:hover {
  border-color: #10b981;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.item-image {
  flex-shrink: 0;
  width: 120px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
}

.item-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.item-content {
  flex: 1;
  min-width: 0;
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.item-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-meta {
  font-size: 12px;
  color: #6b7280;
  flex-shrink: 0;
  margin-left: 12px;
}

.item-description {
  font-size: 14px;
  color: #4b5563;
  margin-bottom: 12px;
  line-height: 1.5;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.item-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #6b7280;
}

.item-tags {
  display: flex;
  gap: 8px;
  align-items: center;
}

.more-tags {
  font-size: 12px;
  color: #6b7280;
}

.item-actions {
  flex-shrink: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .image-list-item {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .item-image {
    width: 100%;
    height: 120px;
  }
  
  .item-header {
    flex-direction: column;
    gap: 4px;
  }
  
  .item-meta {
    margin-left: 0;
  }
  
  .item-stats {
    justify-content: space-between;
  }
  
  .item-actions {
    align-self: stretch;
  }
  
  .item-actions .n-button {
    width: 100%;
  }
}
</style> 