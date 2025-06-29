<template>
  <div class="image-layout">
    <div class="image-display-container">
      <n-skeleton height="60vh" width="100%" />
    </div>
    <div class="sidebar">
      <div class="image-details-container">
        <n-card>
          <n-skeleton text :repeat="1" style="width: 60%" />
          <n-skeleton text :repeat="3" />
          <template #action>
            <n-space justify="space-between">
              <n-skeleton text style="width: 30%" />
              <n-space>
                <n-skeleton :sharp="false" size="medium" style="width: 80px;" />
                <n-skeleton :sharp="false" size="medium" style="width: 80px;" />
              </n-space>
            </n-space>
          </template>
        </n-card>
      </div>
      <div>
        <n-card title="评论区">
           <n-skeleton text :repeat="4" />
        </n-card>
      </div>
    </div>
  </div>
</template>

<script setup>
import { NSkeleton, NCard, NSpace } from 'naive-ui';
</script>

<style scoped>
.image-layout {
  display: grid;
  grid-template-columns: minmax(0, 3fr) minmax(0, 1fr);
  gap: 24px;
  align-items: start;
}
.image-display-container {
  display: flex;
  align-items: center;
  justify-content: center;
}
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.image-details-container {
  display: flex;
  flex-direction: column;
}
@media (max-width: 992px) {
  .image-layout {
    grid-template-columns: 1fr;
  }
}
</style> 