<script setup>
import { onMounted, watch, computed } from 'vue';
import { useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useAuthStore } from '@/stores/auth';
import { storeToRefs } from 'pinia';
import { NSpin, NCard, NTabs, NTabPane, NAvatar, NStatistic, NSpace, NButton, NBreadcrumb, NBreadcrumbItem, NIcon, NEmpty } from 'naive-ui';
import { PersonOutline, HeartOutline, CloudUploadOutline, PeopleOutline } from '@vicons/ionicons5';
import ImageGrid from '@/components/ImageGrid.vue';
import GalleryGrid from '@/components/GalleryGrid.vue';
import AppFooter from '@/components/AppFooter.vue';

const props = defineProps({
  username: {
    type: String,
    required: true
  }
});

const route = useRoute();
const userStore = useUserStore();
const authStore = useAuthStore();

const { profile, uploadedGalleries, uploadedImages, likedImages, isLoadingProfile, isLoadingUploaded, isLoadingLiked } = storeToRefs(userStore);
const { user: currentUser, isAuthenticated } = storeToRefs(authStore);

const isOwnProfile = computed(() => {
  return isAuthenticated.value && currentUser.value?.username === profile.value?.username;
});

function fetchAllData(username) {
  userStore.fetchUserProfile(username);
  userStore.fetchUploadedGalleries(username);
  userStore.fetchUploadedImages(username);
  userStore.fetchLikedImages(username);
}

onMounted(() => {
  fetchAllData(props.username);
});

watch(() => route.params.username, (newUsername) => {
  if (newUsername) {
    fetchAllData(newUsername);
  }
});

function handleFollow() {
  if (!isAuthenticated.value) {
    // Optionally, redirect to login
    return;
  }
  userStore.toggleFollow(props.username);
}
</script>

<template>
  <div class="profile-view">
    <!-- Loading state -->
    <div v-if="isLoadingProfile" class="loading-container">
      <n-spin size="large">
        <template #description>加载中...</template>
      </n-spin>
    </div>

    <!-- Profile content -->
    <div v-else-if="profile" class="profile-page">
      <!-- Profile header banner -->
      <div class="profile-banner">
        <div class="banner-content">
          <div class="container">
            <!-- 面包屑导航 -->
            <n-breadcrumb class="breadcrumb">
              <n-breadcrumb-item @click="$router.push('/')">首页</n-breadcrumb-item>
              <n-breadcrumb-item @click="$router.push('/users')">用户</n-breadcrumb-item>
              <n-breadcrumb-item>{{ profile.username }}</n-breadcrumb-item>
            </n-breadcrumb>

            <!-- 用户信息 -->
            <div class="profile-header">
              <div class="profile-avatar">
                <n-avatar :size="120" round class="user-avatar">
                  <n-icon size="60"><PersonOutline /></n-icon>
                </n-avatar>
              </div>
              
              <div class="profile-info">
                <h1 class="profile-title">{{ profile.username }}</h1>
                <p class="profile-bio">{{ profile.bio || '这个用户很懒，什么都没留下...' }}</p>
                
                <!-- 统计信息 -->
                <div class="profile-stats">
                  <div class="stat-item">
                    <n-icon><PeopleOutline /></n-icon>
                    <span class="stat-number">{{ profile.followers_count || 0 }}</span>
                    <span class="stat-label">粉丝</span>
                  </div>
                  <div class="stat-item">
                    <n-icon><PeopleOutline /></n-icon>
                    <span class="stat-number">{{ profile.following_count || 0 }}</span>
                    <span class="stat-label">关注</span>
                  </div>
                  <div class="stat-item">
                    <n-icon><CloudUploadOutline /></n-icon>
                    <span class="stat-number">{{ uploadedGalleries.length }}</span>
                    <span class="stat-label">图集</span>
                  </div>
                  <div class="stat-item">
                    <n-icon><HeartOutline /></n-icon>
                    <span class="stat-number">{{ likedImages.length }}</span>
                    <span class="stat-label">喜欢</span>
                  </div>
                </div>
              </div>

              <!-- 操作按钮 -->
              <div class="profile-actions" v-if="isAuthenticated && !isOwnProfile">
                <n-button
                  :type="profile.is_following ? 'default' : 'primary'"
                  size="large"
                  @click="handleFollow"
                  ghost
                >
                  {{ profile.is_following ? '取消关注' : '关注' }}
                </n-button>
              </div>
            </div>
          </div>
        </div>
        <div class="banner-bg"></div>
      </div>

      <!-- 主要内容区域 -->
      <div class="main-content">
        <div class="container">
          <div class="content-tabs">
            <n-tabs type="line" animated size="large" class="profile-tabs">
              <n-tab-pane name="galleries" tab="上传的图集">
                <div class="tab-content">
                  <n-spin :show="isLoadingUploaded">
                    <GalleryGrid :galleries="uploadedGalleries" v-if="uploadedGalleries.length > 0" />
                    <div v-else class="empty-state">
                      <n-empty description="该用户还没有上传任何图集">
                        <template #icon>
                          <n-icon size="48"><CloudUploadOutline /></n-icon>
                        </template>
                      </n-empty>
                    </div>
                  </n-spin>
                </div>
              </n-tab-pane>
              
              <n-tab-pane name="images" tab="上传的图片">
                <div class="tab-content">
                  <n-spin :show="isLoadingUploaded">
                    <ImageGrid :images="uploadedImages" v-if="uploadedImages.length > 0" />
                    <div v-else class="empty-state">
                      <n-empty description="该用户还没有上传任何图片">
                        <template #icon>
                          <n-icon size="48"><CloudUploadOutline /></n-icon>
                        </template>
                      </n-empty>
                    </div>
                  </n-spin>
                </div>
              </n-tab-pane>
              
              <n-tab-pane name="likes" tab="喜欢的图片">
                <div class="tab-content">
                  <n-spin :show="isLoadingLiked">
                    <ImageGrid :images="likedImages" v-if="likedImages.length > 0" />
                    <div v-else class="empty-state">
                      <n-empty description="该用户还没有喜欢任何图片">
                        <template #icon>
                          <n-icon size="48"><HeartOutline /></n-icon>
                        </template>
                      </n-empty>
                    </div>
                  </n-spin>
                </div>
              </n-tab-pane>
            </n-tabs>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <AppFooter theme-color="#667eea" />
    </div>

    <!-- Error state -->
    <div v-else class="error-container">
      <div class="container">
        <n-empty description="用户不存在" size="large">
          <template #icon>
            <n-icon size="48"><PersonOutline /></n-icon>
          </template>
          <template #extra>
            <n-button @click="$router.push('/')">返回首页</n-button>
          </template>
        </n-empty>
      </div>
    </div>
  </div>
</template>

<style scoped>
.profile-view {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.loading-container, .error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 60vh;
}

.profile-page {
  min-height: calc(100vh - 64px);
}

/* Profile Banner */
.profile-banner {
  position: relative;
  padding: 48px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  overflow: hidden;
  color: white;
}

.banner-content {
  width: 100%;
  z-index: 2;
  position: relative;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 24px;
}

.breadcrumb :deep(.n-breadcrumb-item__link) {
  color: rgba(255, 255, 255, 0.8);
}

.breadcrumb :deep(.n-breadcrumb-item__link:hover) {
  color: white;
}

.breadcrumb :deep(.n-breadcrumb-item__separator) {
  color: rgba(255, 255, 255, 0.6);
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 32px;
  max-width: 1000px;
  margin: 0 auto;
}

.profile-avatar {
  flex-shrink: 0;
}

.user-avatar {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 3px solid rgba(255, 255, 255, 0.3);
}

.user-avatar :deep(.n-avatar__text) {
  color: white;
}

.profile-info {
  flex: 1;
  min-width: 0;
}

.profile-title {
  font-size: 36px;
  font-weight: bold;
  margin: 0 0 12px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  line-height: 1.2;
}

.profile-bio {
  font-size: 16px;
  margin: 0 0 24px 0;
  opacity: 0.9;
  font-weight: 300;
  line-height: 1.5;
}

.profile-stats {
  display: flex;
  gap: 32px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 12px 16px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
}

.stat-number {
  font-size: 18px;
  font-weight: bold;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
}

.profile-actions {
  flex-shrink: 0;
}

.banner-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.15"/><circle cx="80" cy="40" r="0.5" fill="white" opacity="0.15"/><circle cx="20" cy="60" r="0.5" fill="white" opacity="0.15"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
  opacity: 0.3;
}

/* Main Content */
.main-content {
  padding: 40px 0;
}

.content-tabs {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.profile-tabs :deep(.n-tabs-nav) {
  padding: 0 24px;
  background: #fafafa;
}

.profile-tabs :deep(.n-tabs-tab) {
  font-weight: 500;
  font-size: 16px;
}

.tab-content {
  padding: 24px;
  min-height: 400px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }
  
  .profile-header {
    flex-direction: column;
    text-align: center;
    gap: 24px;
  }
  
  .profile-title {
    font-size: 28px;
  }
  
  .profile-stats {
    justify-content: center;
    flex-wrap: wrap;
    gap: 16px;
  }
  
  .stat-item {
    padding: 8px 12px;
    gap: 6px;
  }
  
  .stat-number {
    font-size: 16px;
  }
  
  .stat-label {
    font-size: 13px;
  }
  
  .tab-content {
    padding: 16px;
  }
}
</style> 