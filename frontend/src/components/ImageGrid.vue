<script setup>
import ImageCard from './ImageCard.vue';

defineProps({
  images: {
    type: Array,
    required: true,
  },
});
</script>

<template>
  <div class="image-grid">
    <ImageCard v-for="image in images" :key="image.id" :image="image" />
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