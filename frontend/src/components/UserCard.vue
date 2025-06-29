<template>
  <div class="user-card" @click="navigateToProfile">
    <div class="user-avatar">
      <n-avatar size="large" class="avatar">
        {{ user.username.charAt(0).toUpperCase() }}
      </n-avatar>
    </div>
    
    <div class="user-info">
      <div class="user-name">
        <h3>{{ user.username }}</h3>
        <span v-if="user.role === 'admin'" class="admin-badge">管理员</span>
      </div>
      
      <div v-if="user.bio" class="user-bio">
        {{ user.bio }}
      </div>
      
      <div class="user-stats">
        <div class="stat-item">
          <span class="stat-number">{{ user.uploads_count || 0 }}</span>
          <span class="stat-label">作品</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ user.followers_count || 0 }}</span>
          <span class="stat-label">粉丝</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ user.following_count || 0 }}</span>
          <span class="stat-label">关注</span>
        </div>
      </div>
      
      <div class="user-meta">
        <span class="join-date">
          加入于 {{ formatDate(user.created_at) }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { NAvatar } from 'naive-ui';

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
});

const router = useRouter();

const navigateToProfile = () => {
  router.push(`/users/${props.user.username}`);
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short'
  });
};
</script>

<style scoped>
.user-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  gap: 16px;
  align-items: flex-start;
}

.user-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.user-avatar {
  flex-shrink: 0;
}

.avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: bold;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.user-name h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1a1a1a;
}

.admin-badge {
  background: linear-gradient(135deg, #ff6b6b, #feca57);
  color: white;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
  font-weight: 500;
}

.user-bio {
  color: #666;
  font-size: 14px;
  line-height: 1.4;
  margin-bottom: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.user-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 8px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 50px;
}

.stat-number {
  font-size: 16px;
  font-weight: 600;
  color: #1a1a1a;
  line-height: 1.2;
}

.stat-label {
  font-size: 12px;
  color: #999;
  line-height: 1.2;
}

.user-meta {
  color: #999;
  font-size: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-card {
    padding: 16px;
    gap: 12px;
  }
  
  .user-name h3 {
    font-size: 16px;
  }
  
  .user-stats {
    gap: 16px;
  }
  
  .stat-number {
    font-size: 14px;
  }
}
</style> 