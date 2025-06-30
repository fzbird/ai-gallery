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
  <div class="image-card-container" @click="navigateToDetail">
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
          :src="`${API_BASE_URL}${props.image.image_url}`" 
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
  break-inside: avoid;
  margin-bottom: 16px;
  position: relative;
}

.image-card {
  position: relative;
  overflow: hidden;
  break-inside: avoid;
  margin-bottom: 16px;
  border-radius: 8px;
  cursor: pointer;
  width: 100%;
  box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
  transition: all 0.3s cubic-bezier(.25,.8,.25,1);
}

.image-card:hover {
  box-shadow: 0 14px 28px rgba(0,0,0,0.25), 0 10px 10px rgba(0,0,0,0.22);
}

.delete-button-container {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 10;
}

.delete-button {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.delete-button:hover {
  background: rgba(239, 68, 68, 0.1);
}

.image-display {
  width: 100%;
  height: auto;
  display: block;
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0) 50%);
  opacity: 0;
  transition: opacity 0.3s ease;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 16px;
  color: white;
}

.image-card:hover .overlay {
  opacity: 1;
}

.image-info {
  padding: 16px;
}

.image-title {
  margin: 0;
  font-weight: 500;
}

.stats {
  font-size: 0.9em;
}

.image {
  width: 100%;
  height: auto;
  display: block;
}

/* This wrapper is needed for the tooltip to work on a disabled button */
.popconfirm-trigger-wrapper {
  display: inline-block;
}
</style> 