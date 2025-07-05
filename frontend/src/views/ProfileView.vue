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

const canManageProfile = computed(() => {
  // 用户可以管理自己的资料，或者管理员可以管理任何用户的资料
  return isAuthenticated.value && (
    currentUser.value?.username === profile.value?.username ||
    currentUser.value?.is_superuser === true
  );
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

async function handleDeleteGallery(galleryId) {
  try {
    await userStore.deleteUserGallery(galleryId);
    await userStore.fetchUploadedImages(props.username);
  } catch (error) {
    console.error('Error deleting gallery:', error);
  }
}

async function handleDeleteImage(imageId) {
  try {
    await userStore.deleteUserImage(imageId);
    await userStore.fetchUploadedGalleries(props.username);
  } catch (error) {
    console.error('Error deleting image:', error);
  }
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
                    <GalleryGrid 
                      :galleries="uploadedGalleries" 
                      :show-delete-button="canManageProfile"
                      :current-user-id="currentUser?.id"
                      @delete-gallery="handleDeleteGallery"
                      v-if="uploadedGalleries.length > 0" 
                    />
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
                    <ImageGrid 
                      :images="uploadedImages" 
                      :show-delete-button="canManageProfile"
                      :current-user-id="currentUser?.id"
                      @delete-image="handleDeleteImage"
                      v-if="uploadedImages.length > 0" 
                    />
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
  .profile-banner {
    padding: 20px 0; /* 大幅减少banner padding */
  }
  
  .container {
    padding: 0 16px;
  }
  
  .breadcrumb {
    margin-bottom: 16px; /* 减少面包屑下方间距 */
  }
  
  .profile-header {
    flex-direction: column;
    text-align: center;
    gap: 16px; /* 减少元素间距 */
  }
  
  .user-avatar {
    width: 80px !important; /* 减小头像尺寸 */
    height: 80px !important;
    border-width: 2px;
  }
  
  .user-avatar :deep(.n-icon) {
    font-size: 36px !important; /* 调整头像图标大小 */
  }
  
  .profile-title {
    font-size: 24px; /* 减小标题字体 */
    margin-bottom: 8px;
  }
  
  .profile-bio {
    font-size: 14px; /* 减小bio字体 */
    margin-bottom: 16px;
  }
  
  .profile-stats {
    justify-content: center;
    flex-wrap: wrap;
    gap: 8px; /* 减少统计项间距 */
  }
  
  .stat-item {
    padding: 6px 12px; /* 减少统计项内边距 */
    gap: 4px;
    border-radius: 16px;
  }
  
  .stat-number {
    font-size: 14px; /* 减小数字字体 */
  }
  
  .stat-label {
    font-size: 12px; /* 减小标签字体 */
  }
  
  .main-content {
    padding: 24px 0; /* 减少主内容区padding */
  }
  
  .tab-content {
    padding: 16px; /* 减少标签页内容padding */
  }
  
  .profile-tabs :deep(.n-tabs-nav) {
    padding: 0 16px; /* 减少标签页导航padding */
  }
  
  .profile-tabs :deep(.n-tabs-tab) {
    font-size: 14px; /* 减小标签页字体 */
  }
}

/* 超小屏幕进一步优化 */
@media (max-width: 480px) {
  .profile-banner {
    padding: 16px 0; /* 超小屏幕进一步减少padding */
  }
  
  .container {
    padding: 0 12px;
  }
  
  .breadcrumb {
    margin-bottom: 12px;
  }
  
  .profile-header {
    gap: 12px;
  }
  
  .user-avatar {
    width: 70px !important; /* 超小屏幕进一步减小头像 */
    height: 70px !important;
  }
  
  .user-avatar :deep(.n-icon) {
    font-size: 32px !important;
  }
  
  .profile-title {
    font-size: 20px; /* 进一步减小标题 */
    margin-bottom: 6px;
  }
  
  .profile-bio {
    font-size: 13px;
    margin-bottom: 12px;
  }
  
  .profile-stats {
    gap: 6px;
  }
  
  .stat-item {
    padding: 4px 8px;
    border-radius: 12px;
    min-width: 60px; /* 确保统计项有最小宽度 */
  }
  
  .stat-number {
    font-size: 13px;
  }
  
  .stat-label {
    font-size: 11px;
  }
  
  .main-content {
    padding: 16px 0;
  }
  
  .tab-content {
    padding: 12px;
  }
  
  .profile-tabs :deep(.n-tabs-nav) {
    padding: 0 12px;
  }
  
  .profile-tabs :deep(.n-tabs-tab) {
    font-size: 13px;
    padding: 8px 12px; /* 减少标签页内边距 */
  }
  
  .empty-state {
    min-height: 200px; /* 减少空状态最小高度 */
  }
  
  .breadcrumb :deep(.n-breadcrumb-item) {
    font-size: 13px; /* 减小面包屑字体 */
  }
}

/* 针对统计项的特殊优化 - 确保在小屏幕上2行显示 */
@media (max-width: 360px) {
  .profile-stats {
    justify-content: space-between;
    width: 100%;
  }
  
  .stat-item {
    flex: 1;
    max-width: calc(50% - 3px);
    margin-bottom: 6px;
  }
}
</style> 