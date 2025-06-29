<script setup>
import { NCard, NIcon, NSpace, NTag, NImage } from 'naive-ui';
import { EyeOutline, HeartOutline, BookmarkOutline } from '@vicons/ionicons5';
import { useRouter } from 'vue-router';
import { computed } from 'vue';
import { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
});

const router = useRouter();

function navigateToDetail() {
  router.push({ name: 'image-detail', params: { id: props.image.id } });
}

function handleImageError() {
  // Handle image loading error
}
</script>

<template>
  <div class="image-card-container" @click="navigateToDetail">
    <n-card class="image-card" hoverable>
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
</style> 