<script setup>
import { ref, computed, onMounted } from 'vue';
import { useAuthStore } from '@/stores/auth';
import { useCommentStore } from '@/stores/comment';
import { useSettingsStore } from '@/stores/settings';
import { NCard, NInput, NButton, NAvatar, NDivider, NPopconfirm, NIcon, NAlert } from 'naive-ui';
import { DeleteOutlined } from '@vicons/antd';
import { WarningOutline } from '@vicons/ionicons5';
import apiClient from '@/api/api.js';

const props = defineProps({
  imageId: {
    type: [Number, String],
    required: false
  },
  galleryId: {
    type: [Number, String],
    required: false
  },
  comments: {
    type: Array,
    required: true
  }
});

const emit = defineEmits(['comment-posted', 'comment-deleted']);

const authStore = useAuthStore();
const commentStore = useCommentStore();
const settingsStore = useSettingsStore();
const newComment = ref('');
const deletingComments = ref(new Set()); // 跟踪正在删除的评论

// 检查是否开放评论
const isCommentsEnabled = computed(() => {
  const settings = settingsStore.settings;
  return !settings || settings.enable_comments === undefined || settings.enable_comments === 'true' || settings.enable_comments === true;
});

const handlePostComment = async () => {
  if (!newComment.value.trim()) return;
  
  if (!isCommentsEnabled.value) {
    // 这里可以显示错误消息，但通常UI已经阻止了这种情况
    return;
  }
  
  try {
    let postedComment;
    if (props.galleryId) {
      postedComment = await commentStore.postGalleryComment({
        galleryId: props.galleryId,
        content: newComment.value,
      });
    } else if (props.imageId) {
      postedComment = await commentStore.postComment({
        imageId: props.imageId,
        content: newComment.value,
      });
    }
    newComment.value = '';
    emit('comment-posted', postedComment);
  } catch (error) {
    // Error is handled globally by the apiClient interceptor,
    // so we just need to catch it to prevent unhandled promise rejection warnings.
    // No extra action needed here.
  }
};

const handleDeleteComment = async (commentId) => {
  deletingComments.value.add(commentId);
  try {
    await commentStore.deleteComment(commentId);
    emit('comment-deleted', commentId);
  } catch (error) {
    // Error is handled globally by the apiClient interceptor
  } finally {
    deletingComments.value.delete(commentId);
  }
};

// 检查当前用户是否可以删除评论
const canDeleteComment = (comment) => {
  if (!authStore.isAuthenticated) return false;
  // 评论作者可以删除自己的评论，管理员可以删除任何评论
  return comment.owner_id === authStore.user?.id || authStore.user?.role === 'admin';
};

const sortedComments = computed(() => {
  return [...props.comments].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
});

// 格式化时间显示
const formatTime = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diff = now - date;
  
  // 小于1分钟
  if (diff < 60000) {
    return '刚刚';
  }
  // 小于1小时
  if (diff < 3600000) {
    const minutes = Math.floor(diff / 60000);
    return `${minutes}分钟前`;
  }
  // 小于1天
  if (diff < 86400000) {
    const hours = Math.floor(diff / 3600000);
    return `${hours}小时前`;
  }
  // 小于7天
  if (diff < 604800000) {
    const days = Math.floor(diff / 86400000);
    return `${days}天前`;
  }
  // 超过7天，显示具体日期
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
};

// 页面加载时获取系统设置
onMounted(async () => {
  if (!settingsStore.settings) {
    await settingsStore.fetchSettings();
  }
});

</script>

<template>
  <n-card title="评论区">
    <!-- 评论功能关闭提示 -->
    <n-alert v-if="!isCommentsEnabled" type="info" class="comments-disabled-alert">
      <template #icon>
        <n-icon :component="WarningOutline" />
      </template>
      <template #header>
        评论功能已关闭
      </template>
      管理员已暂时关闭评论功能。
    </n-alert>
    
    <div v-if="authStore.isAuthenticated && isCommentsEnabled">
      <n-input
        v-model:value="newComment"
        type="textarea"
        placeholder="发表你的看法..."
        :autosize="{ minRows: 3 }"
        :disabled="commentStore.isSubmitting"
      />
      <n-button
        type="primary"
        @click="handlePostComment"
        :loading="commentStore.isSubmitting"
        style="margin-top: 12px;"
      >
        发表评论
      </n-button>
      <n-divider />
    </div>
    
    <!-- 未登录用户提示 -->
    <div v-else-if="!authStore.isAuthenticated && isCommentsEnabled" class="login-prompt">
      <n-divider>
        <router-link to="/login" style="color: #1890ff; text-decoration: none;">
          登录后参与评论
        </router-link>
      </n-divider>
    </div>

    <div class="comments-list" :class="{ 'many-comments': sortedComments.length > 5 }">
      <div v-for="comment in sortedComments" :key="comment.id" class="comment-item">
        <div class="comment-header">
          <div class="user-info">
            <n-avatar size="medium" class="comment-avatar">
              {{ comment.owner.username.charAt(0).toUpperCase() }}
            </n-avatar>
            <div class="user-details">
              <strong class="username">{{ comment.owner.username }}</strong>
              <span class="comment-time">
                {{ formatTime(comment.created_at) }}
              </span>
            </div>
          </div>
          <div v-if="canDeleteComment(comment)" class="comment-actions">
            <n-popconfirm
              @positive-click="handleDeleteComment(comment.id)"
              positive-text="删除"
              negative-text="取消"
              trigger="click"
            >
              <template #trigger>
                <n-button
                  size="small"
                  tertiary
                  type="error"
                  :loading="deletingComments.has(comment.id)"
                  :disabled="deletingComments.has(comment.id)"
                  class="delete-btn"
                >
                  <template #icon>
                    <n-icon><DeleteOutlined /></n-icon>
                  </template>
                </n-button>
              </template>
              确定要删除这条评论吗？
            </n-popconfirm>
          </div>
        </div>
        <div class="comment-content">
          {{ comment.content }}
        </div>
      </div>
      <div v-if="comments.length === 0" class="no-comments">
        还没有评论，快来抢沙发吧！
      </div>
    </div>
  </n-card>
</template>

<style scoped>
.comments-list {
  /* 移除固定高度，让内容自然流动 */
  overflow-x: hidden;
}

/* 只有评论数量较多时才限制高度并显示滚动条 */
.comments-list.many-comments {
  max-height: 500px;
  overflow-y: auto;
  /* Firefox 滚动条样式 */
  scrollbar-width: thin;
  scrollbar-color: #c1c1c1 transparent;
}

.comment-item {
  padding: 16px 0;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.2s ease;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-item:hover {
  background-color: #fafafa;
  border-radius: 8px;
  padding: 16px 12px;
  margin: 0 -12px;
}

.comment-header {
  margin-bottom: 8px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.comment-actions {
  opacity: 0;
  transition: opacity 0.2s ease;
  margin-left: 12px;
}

.comment-item:hover .comment-actions {
  opacity: 1;
}

.delete-btn {
  padding: 4px 6px !important;
  min-width: auto !important;
}

.delete-btn:hover {
  color: #ff4d4f !important;
  border-color: #ff4d4f !important;
}

.comment-avatar {
  flex-shrink: 0;
}

.user-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.username {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  line-height: 1.4;
}

.comment-time {
  font-size: 12px;
  color: #999;
  line-height: 1.2;
}

.comment-content {
  font-size: 14px;
  line-height: 1.6;
  color: #555;
  margin-left: 52px; /* 对齐头像右侧 */
  word-wrap: break-word;
  white-space: pre-wrap;
}

.no-comments {
  text-align: center;
  color: #999;
  padding: 40px 20px;
  font-size: 14px;
  margin: 0; /* 确保没有额外的边距 */
}

/* Webkit 滚动条样式 - 只对有很多评论的列表生效 */
.comments-list.many-comments::-webkit-scrollbar {
  width: 6px;
}

.comments-list.many-comments::-webkit-scrollbar-track {
  background: transparent;
}

.comments-list.many-comments::-webkit-scrollbar-thumb {
  background: rgba(193, 193, 193, 0.5);
  border-radius: 3px;
}

.comments-list.many-comments::-webkit-scrollbar-thumb:hover {
  background: #c1c1c1;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .comment-content {
    margin-left: 0;
    margin-top: 8px;
  }
  
  .user-info {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .user-details {
    flex-direction: row;
    align-items: center;
    gap: 8px;
  }
}

.comments-disabled-alert {
  margin-bottom: 16px;
}

.login-prompt {
  margin-bottom: 16px;
}
</style> 