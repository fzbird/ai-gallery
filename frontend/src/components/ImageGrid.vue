<script setup>
import ImageCard from './ImageCard.vue';
import { defineEmits } from 'vue';

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
  return props.showDeleteButton && props.currentUserId && image.owner?.id === props.currentUserId;
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
  column-count: 4;
  column-gap: 16px;
}

@media (max-width: 1200px) {
  .image-grid {
    column-count: 3;
  }
}

@media (max-width: 768px) {
  .image-grid {
    column-count: 2;
  }
}

@media (max-width: 480px) {
  .image-grid {
    column-count: 1;
  }
}
</style> 