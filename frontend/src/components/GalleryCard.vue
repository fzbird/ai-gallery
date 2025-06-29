<script setup>
import { computed, ref, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import { NCard, NTag, NSpace, NIcon } from 'naive-ui';
import { HeartOutline as LikeIcon, BookmarkOutline as BookmarkIcon } from '@vicons/ionicons5';
import api, { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  gallery: {
    type: Object,
    required: true,
  },
});

const router = useRouter();

const displayTags = computed(() => {
  return props.gallery.tags?.slice(0, 5) || [];
});

const imageCountText = computed(() => {
  const count = props.gallery.image_count || props.gallery.images?.length || 0;
  return `${count}P`;
});

// 使用computed计算封面图片URL
const coverImageUrl = computed(() => {
  if (props.gallery.images && Array.isArray(props.gallery.images) && props.gallery.images.length > 0) {
    const firstImage = props.gallery.images[0];
    
    if (firstImage.image_url && typeof firstImage.image_url === 'string' && firstImage.image_url.trim() !== '') {
      return `${API_BASE_URL}${firstImage.image_url}`;
    }
  }
  
  return null;
});

function viewGallery() {
  router.push({ name: 'gallery', params: { id: props.gallery.id } });
}

function viewUser() {
  router.push({ name: 'profile', params: { username: props.gallery.owner.username } });
}

// 监听props变化
watch(() => props.gallery, (newGallery) => {
  // Props change monitoring for debugging if needed
}, { deep: true, immediate: true });
</script>

<template>
  <div class="gallery-card" @click="viewGallery">
    <div class="image-container">
      <img 
        v-if="coverImageUrl" 
        :src="coverImageUrl" 
        :alt="gallery.title"
        class="cover-image"
        @error="console.log('Image load error for:', coverImageUrl)"
      />
      <div v-else class="no-image">
        暂无图片
      </div>
      <div class="image-count">{{ imageCountText }}</div>
    </div>
    
    <div class="card-content">
      <h3 class="gallery-title">{{ gallery.title }}</h3>
      
      <div class="tags-section" v-if="displayTags.length > 0">
        <n-space size="small">
          <n-tag v-for="tag in displayTags" :key="tag.id" size="small" type="info">
            {{ tag.name }}
          </n-tag>
        </n-space>
      </div>
      
      <div class="meta-info">
        <span class="author" @click.stop="viewUser">{{ gallery.owner.username }}</span>
        <div class="stats">
          <span class="stat-item">
            <n-icon><LikeIcon /></n-icon>
            {{ gallery.likes_count || 0 }}
          </span>
          <span class="stat-item">
            <n-icon><BookmarkIcon /></n-icon>
            {{ gallery.bookmarks_count || 0 }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.gallery-card {
  cursor: pointer;
  margin-bottom: 16px;
  break-inside: avoid;
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.gallery-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.image-container {
  position: relative;
  width: 100%;
  aspect-ratio: 4/3;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.no-image {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #999;
  font-size: 14px;
}

.image-count {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.card-content {
  padding: 12px;
}

.gallery-title {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #333;
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
  color: #666;
}

.author {
  cursor: pointer;
  color: #1890ff;
  text-decoration: none;
  transition: color 0.2s ease;
}

.author:hover {
  color: #40a9ff;
}

.stats {
  display: flex;
  gap: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #888;
}

.stat-item .n-icon {
  font-size: 14px;
}
</style> 