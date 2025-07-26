<script setup>
import { NCard, NIcon, NSpace, NTag, NImage, NButton, NPopconfirm, NTooltip } from 'naive-ui';
import { EyeOutline, HeartOutline, BookmarkOutline, TrashOutline as DeleteIcon } from '@vicons/ionicons5';
import { useRouter } from 'vue-router';
import { computed, defineEmits } from 'vue';
import { API_BASE_URL } from '@/api/api.js';
import { message } from '@/utils/discrete-api';

const props = defineProps({
  image: {
    type: Object,
    required: true
  },
  showDeleteButton: {
    type: Boolean,
    default: false
  },
  isCoverImage: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'large',
    validator: (value) => ['extra-large', 'large', 'small'].includes(value)
  }
});

const emit = defineEmits(['delete-image']);

const router = useRouter();

function navigateToDetail() {
  router.push({ name: 'image-detail', params: { id: props.image.id } });
}

function handleImageError() {
  // Handle image loading error
}

async function handleDeleteImage() {
  try {
    emit('delete-image', props.image.id);
    message.success('图片删除成功');
  } catch (error) {
    message.error('删除失败，请稍后重试');
  }
}
</script>

<template>
  <div class="image-card-container" :class="`size-${size}`" @click="navigateToDetail">
    <n-card class="image-card" hoverable>
      <div v-if="showDeleteButton" class="delete-button-container" @click.stop>
        <n-tooltip trigger="hover" :disabled="!image.is_cover_image">
          <template #trigger>
            <div class="popconfirm-trigger-wrapper">
              <n-popconfirm
                @positive-click="handleDeleteImage"
                negative-text="取消"
                positive-text="删除"
                :disabled="image.is_cover_image"
              >
                <template #trigger>
                  <n-button 
                    type="error" 
                    ghost 
                    size="small" 
                    circle
                    class="delete-button"
                    :disabled="image.is_cover_image"
                  >
                    <template #icon>
                      <n-icon><DeleteIcon /></n-icon>
                    </template>
                  </n-button>
                </template>
                确定要删除这张图片吗？此操作不可撤销。
              </n-popconfirm>
            </div>
          </template>
          此图片为图集封面，无法直接删除。请先更换图集封面。
        </n-tooltip>
      </div>

      <template #cover>
        <img 
          :src="`${API_BASE_URL()}${props.image.image_url}`" 
          :alt="props.image.title"
          class="image"
          loading="lazy"
          @error="handleImageError"
        />
      </template>
      <div class="image-info">
        <h3 class="image-title">{{ props.image.title }}</h3>
        <div class="stats">
          <n-space align="center">
            <n-icon :component="HeartOutline" />
            <span>{{ props.image.likes_count }}</span>
            <n-icon :component="BookmarkOutline" />
            <span>{{ props.image.bookmarks_count || 0 }}</span>
          </n-space>
        </div>
      </div>
    </n-card>
  </div>
</template>

<style scoped>
.image-card-container {
  cursor: pointer;
  transition: transform 0.2s ease;
}

.image-card-container:hover {
  transform: translateY(-4px);
}

.image-card {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.image-card:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.image {
  width: 100%;
  height: auto;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.image-card:hover .image {
  transform: scale(1.05);
}

.image-info {
  padding: 12px;
}

.image-title {
  margin: 0 0 8px 0;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.stats {
  font-size: 12px;
  color: #6b7280;
}

.delete-button-container {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 10;
}

.delete-button {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
}

/* 不同尺寸的样式 */
.size-extra-large .image-card {
  min-height: 450px;
  max-width: 100%;
}

.size-extra-large .image {
  height: 350px;
  width: 100%;
  object-fit: cover;
}

.size-extra-large .image-title {
  font-size: 16px;
  margin-bottom: 12px;
}

.size-extra-large .stats {
  font-size: 14px;
}

.size-large .image-card {
  min-height: 350px;
  max-width: 100%;
}

.size-large .image {
  height: 260px;
  width: 100%;
  object-fit: cover;
}

.size-large .image-title {
  font-size: 14px;
  margin-bottom: 8px;
}

.size-large .stats {
  font-size: 12px;
}

.size-small .image-card {
  min-height: 220px;
  max-width: 100%;
}

.size-small .image {
  height: 160px;
  width: 100%;
  object-fit: cover;
}

.size-small .image-title {
  font-size: 12px;
  margin-bottom: 6px;
}

.size-small .stats {
  font-size: 11px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .size-extra-large .image-card {
    min-height: 400px;
  }
  
  .size-extra-large .image {
    height: 300px;
  }
  
  .size-large .image-card {
    min-height: 320px;
  }
  
  .size-large .image {
    height: 240px;
  }
  
  .size-small .image-card {
    min-height: 200px;
  }
  
  .size-small .image {
    height: 140px;
  }
}

@media (max-width: 768px) {
  .size-extra-large .image-card {
    min-height: 350px;
  }
  
  .size-extra-large .image {
    height: 250px;
  }
  
  .size-large .image-card {
    min-height: 280px;
  }
  
  .size-large .image {
    height: 200px;
  }
  
  .size-small .image-card {
    min-height: 180px;
  }
  
  .size-small .image {
    height: 120px;
  }
}

@media (max-width: 480px) {
  .size-extra-large .image-card {
    min-height: 300px;
  }
  
  .size-extra-large .image {
    height: 200px;
  }
  
  .size-large .image-card {
    min-height: 240px;
  }
  
  .size-large .image {
    height: 160px;
  }
  
  .size-small .image-card {
    min-height: 160px;
  }
  
  .size-small .image {
    height: 100px;
  }
}
</style> 