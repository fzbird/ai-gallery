<script setup>
import ImageCard from './ImageCard.vue';
import { defineEmits } from 'vue';
import { useAuthStore } from '@/stores/auth';

const props = defineProps({
  images: {
    type: Array,
    required: true,
  },
  showDeleteButton: {
    type: Boolean,
    default: false
  },
  currentUserId: {
    type: Number,
    default: null
  }
});

const emit = defineEmits(['delete-image']);

function handleDeleteImage(imageId) {
  emit('delete-image', imageId);
}

function canDeleteImage(image) {
  if (!props.showDeleteButton || !props.currentUserId) {
    return false;
  }
  
  // 从存储中获取当前用户信息以检查管理员权限
  const authStore = useAuthStore();
  const currentUser = authStore.user;
  
  // 图片拥有者或管理员可以删除
  return image.owner?.id === props.currentUserId || currentUser?.is_superuser === true;
}
</script>

<template>
  <div class="image-grid">
    <ImageCard 
      v-for="image in images" 
      :key="image.id" 
      :image="image" 
      :show-delete-button="canDeleteImage(image)"
      @delete-image="handleDeleteImage"
    />
  </div>
</template>

<style scoped>
.image-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

@media (max-width: 1200px) {
  .image-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .image-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
  }
}

@media (max-width: 480px) {
  .image-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
}
</style> 