<template>
  <div class="users-grid">
    <!-- 用户列表 -->
    <div v-if="users.length > 0" class="grid-container">
      <UserCard 
        v-for="user in users" 
        :key="user.id" 
        :user="user" 
      />
    </div>

    <!-- 空状态 -->
    <div v-else-if="!isLoading" class="empty-state">
      <n-empty 
        :description="emptyText"
        size="large"
      >
        <template #icon>
          <n-icon size="64" color="#d1d5db">
            <PeopleOutline />
          </n-icon>
        </template>
      </n-empty>
    </div>

    <!-- 加载更多按钮 -->
    <div v-if="hasMore && users.length > 0" class="load-more-section">
      <n-button 
        @click="$emit('load-more')"
        :loading="isLoading"
        size="large"
        style="width: 200px;"
      >
        加载更多用户
      </n-button>
    </div>

    <!-- 底部加载状态 -->
    <div v-if="isLoading && users.length > 0" class="loading-more">
      <n-spin size="medium">
        <template #description>正在加载更多用户...</template>
      </n-spin>
    </div>
  </div>
</template>

<script setup>
import { NEmpty, NButton, NSpin, NIcon } from 'naive-ui';
import { PeopleOutline } from '@vicons/ionicons5';
import UserCard from './UserCard.vue';

defineProps({
  users: {
    type: Array,
    default: () => []
  },
  isLoading: {
    type: Boolean,
    default: false
  },
  hasMore: {
    type: Boolean,
    default: true
  },
  emptyText: {
    type: String,
    default: '没有找到相关用户'
  }
});

defineEmits(['load-more']);
</script>

<style scoped>
.users-grid {
  width: 100%;
}

.grid-container {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
  margin-bottom: 40px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
  padding: 40px 20px;
}

.load-more-section {
  display: flex;
  justify-content: center;
  margin: 40px 0;
}

.loading-more {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px 20px;
}

/* 响应式设计 */
@media (min-width: 768px) {
  .grid-container {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1200px) {
  .grid-container {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 1600px) {
  .grid-container {
    grid-template-columns: repeat(4, 1fr);
  }
}
</style> 