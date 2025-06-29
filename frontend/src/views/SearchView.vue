<script setup>
import { onMounted, onUnmounted, watch, computed, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useGalleryStore } from '@/stores/gallery';
import { useUserStore } from '@/stores/user';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { NSpin, NBreadcrumb, NBreadcrumbItem, NEmpty, NInput, NButton, NIcon, NTabs, NTabPane } from 'naive-ui';
import { SearchOutline as SearchIcon } from '@vicons/ionicons5';
import GalleryGrid from '@/components/GalleryGrid.vue';
import UserGrid from '@/components/UserGrid.vue';
import AppFooter from '@/components/AppFooter.vue';

const route = useRoute();
const router = useRouter();
const galleryStore = useGalleryStore();
const userStore = useUserStore();
const { setTitle, clearCustomTitle } = usePageTitle();
const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);
const { users, isLoadingUsers, hasMoreUsers } = storeToRefs(userStore);

// 当前选中的标签页
const activeTab = ref(route.query.type || 'galleries');

// 获取搜索关键词（支持q和tag参数）
const query = computed(() => route.query.q || route.query.tag || '');

// 搜索统计信息
const searchStats = computed(() => {
  if (activeTab.value === 'users') {
    return {
      totalResults: users.value.length,
      totalImages: users.value.reduce((sum, user) => sum + (user.uploads_count || 0), 0),
      query: query.value
    };
  } else {
    return {
      totalResults: galleries.value.length,
      totalImages: galleries.value.reduce((sum, gallery) => sum + (gallery.image_count || 0), 0),
      query: query.value
    };
  }
});

// 空状态文本
const emptyText = computed(() => {
  if (activeTab.value === 'users') {
    return `没有找到与 "${query.value}" 相关的用户`;
  } else {
    return `没有找到与 "${query.value}" 相关的图集`;
  }
});

function loadMore() {
  if (query.value) {
    if (activeTab.value === 'users') {
      userStore.searchUsers(query.value, false, users.value.length);
    } else {
      galleryStore.searchGalleries(query.value, false);
    }
  }
}

function performNewSearch() {
  if (query.value) {
    if (activeTab.value === 'users') {
      userStore.resetUsersState();
      userStore.searchUsers(query.value, true);
    } else {
      galleryStore.resetState();
      galleryStore.searchGalleries(query.value, true);
    }
  }
}

// 切换标签页
function handleTabChange(value) {
  activeTab.value = value;
  router.push({ 
    path: '/search', 
    query: { 
      ...route.query, 
      type: value 
    } 
  });
  
  // 如果有搜索词，立即执行搜索
  if (query.value) {
    performNewSearch();
  }
}

onMounted(() => {
  // 从URL获取tab类型
  activeTab.value = route.query.type || 'galleries';
  
  if (query.value) {
    setTitle(`"${query.value}" - 搜索结果`);
    performNewSearch();
  }
});

watch(query, (newQuery) => {
  if (newQuery) {
    setTitle(`"${newQuery}" - 搜索结果`);
    performNewSearch();
  } else {
    clearCustomTitle();
    galleryStore.resetState();
    userStore.resetUsersState();
  }
});

// 监听路由变化，更新activeTab
watch(() => route.query.type, (newType) => {
  if (newType && newType !== activeTab.value) {
    activeTab.value = newType;
    if (query.value) {
      performNewSearch();
    }
  }
});

onUnmounted(() => {
  clearCustomTitle();
});
</script>

<template>
  <div class="search-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>搜索</n-breadcrumb-item>
          <n-breadcrumb-item v-if="query">"{{ query }}"</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <span v-if="query">搜索结果</span>
            <span v-else>图集搜索</span>
          </h1>
          <p class="page-subtitle" v-if="query">
            为您找到关于 "{{ query }}" 的相关图集
          </p>
          <p class="page-subtitle" v-else>
            搜索您感兴趣的图集作品
          </p>
        </div>

        <!-- 搜索框 -->
        <div class="search-section">
          <div class="search-container">
            <n-input
              :value="query"
              @input="$router.push({ path: '/search', query: { q: $event } })"
              placeholder="输入关键词搜索图集..."
              size="large"
              clearable
              @keyup.enter="performNewSearch"
              class="search-input"
            >
              <template #prefix>
                <n-icon><SearchIcon /></n-icon>
              </template>
              <template #suffix>
                <n-button 
                  type="primary" 
                  @click="performNewSearch"
                  :disabled="!query"
                  size="medium"
                  class="search-btn"
                >
                  搜索
                </n-button>
              </template>
            </n-input>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 搜索标签页 -->
        <div v-if="query" class="search-tabs-section">
          <n-tabs 
            :value="activeTab" 
            @update:value="handleTabChange"
            type="segment"
            animated
            class="search-tabs"
          >
            <n-tab-pane name="galleries" tab="图集">
              <!-- 图集搜索统计信息 -->
              <div v-if="!isLoading" class="search-stats">
                <div class="stats-card">
                  <div class="stats-info">
                    <span class="stats-number">{{ galleries.length }}</span>
                    <span class="stats-label">个图集</span>
                  </div>
                  <div class="stats-info">
                    <span class="stats-number">{{ galleries.reduce((sum, gallery) => sum + (gallery.image_count || 0), 0) }}</span>
                    <span class="stats-label">张图片</span>
                  </div>
                  <div class="stats-text">
                    包含关键词 "{{ query }}" 的图集搜索结果
                  </div>
                </div>
              </div>
            </n-tab-pane>
            
            <n-tab-pane name="users" tab="用户">
              <!-- 用户搜索统计信息 -->
              <div v-if="!isLoadingUsers" class="search-stats">
                <div class="stats-card">
                  <div class="stats-info">
                    <span class="stats-number">{{ users.length }}</span>
                    <span class="stats-label">个用户</span>
                  </div>
                  <div class="stats-info">
                    <span class="stats-number">{{ users.reduce((sum, user) => sum + (user.uploads_count || 0), 0) }}</span>
                    <span class="stats-label">个作品</span>
                  </div>
                  <div class="stats-text">
                    包含关键词 "{{ query }}" 的用户搜索结果
                  </div>
                </div>
              </div>
            </n-tab-pane>
          </n-tabs>
        </div>

        <!-- 搜索结果 -->
        <div class="search-results">
          <!-- 未输入搜索词的状态 -->
          <div v-if="!query" class="search-placeholder">
            <n-empty 
              description="请输入关键词开始搜索"
              size="large"
            >
              <template #icon>
                <n-icon size="64" color="#d1d5db">
                  <SearchIcon />
                </n-icon>
              </template>
              <template #extra>
                <div class="search-tips">
                  <h4>搜索提示：</h4>
                  <ul>
                    <li>可以搜索图集标题、描述或标签</li>
                    <li>可以搜索用户名和用户简介</li>
                    <li>支持中文和英文关键词</li>
                    <li>多个关键词用空格分隔</li>
                  </ul>
                </div>
              </template>
            </n-empty>
          </div>

          <!-- 有搜索词的情况 -->
          <div v-else>
            <!-- 图集搜索结果 -->
            <div v-if="activeTab === 'galleries'">
              <n-spin :show="isLoading && galleries.length === 0" size="large">
                <GalleryGrid
                  :galleries="galleries"
                  :is-loading="isLoading"
                  :has-more="hasMore"
                  :empty-text="emptyText"
                  @load-more="loadMore"
                />
              </n-spin>
            </div>

            <!-- 用户搜索结果 -->
            <div v-else-if="activeTab === 'users'">
              <n-spin :show="isLoadingUsers && users.length === 0" size="large">
                <UserGrid
                  :users="users"
                  :is-loading="isLoadingUsers"
                  :has-more="hasMoreUsers"
                  :empty-text="emptyText"
                  @load-more="loadMore"
                />
              </n-spin>
                         </div>
           </div>
         </div>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#6366f1" />
  </div>
</template>

<style scoped>
.search-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0 32px 0;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 16px;
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

.page-title-section {
  text-align: center;
  margin-bottom: 32px;
}

.page-title {
  font-size: 32px;
  font-weight: bold;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.page-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

/* 搜索区域 */
.search-section {
  display: flex;
  justify-content: center;
}

.search-container {
  width: 100%;
  max-width: 600px;
}

.search-input {
  border-radius: 25px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
}

.search-input :deep(.n-input__input-el) {
  font-size: 16px;
  padding: 12px 20px;
}

.search-btn {
  margin-right: 8px;
  border-radius: 15px;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

/* 搜索标签页 */
.search-tabs-section {
  margin-bottom: 30px;
}

.search-tabs {
  margin-bottom: 20px;
}

.search-tabs :deep(.n-tabs-nav) {
  background: white;
  border-radius: 12px;
  padding: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.search-tabs :deep(.n-tabs-tab) {
  border-radius: 8px;
  font-weight: 500;
  padding: 12px 24px;
}

.search-tabs :deep(.n-tabs-tab--active) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

/* 搜索统计 */
.search-stats {
  margin-bottom: 32px;
}

.stats-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  display: flex;
  align-items: center;
  gap: 32px;
  flex-wrap: wrap;
}

.stats-info {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.stats-number {
  font-size: 24px;
  font-weight: bold;
  color: #6366f1;
}

.stats-label {
  font-size: 14px;
  color: #6b7280;
}

.stats-text {
  color: #4b5563;
  font-size: 14px;
  margin-left: auto;
}

/* 搜索结果 */
.search-results {
  min-height: 400px;
}

.search-placeholder,
.no-results {
  padding: 60px 20px;
}

.search-tips,
.no-results-tips {
  text-align: left;
  margin-top: 16px;
}

.search-tips h4 {
  margin: 0 0 8px 0;
  color: #374151;
}

.search-tips ul,
.no-results-tips ul {
  margin: 8px 0 0 0;
  padding-left: 20px;
  color: #6b7280;
}

.search-tips li,
.no-results-tips li {
  margin-bottom: 4px;
}

.no-results-tips p {
  margin: 0 0 8px 0;
  color: #374151;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 28px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-header {
    padding: 16px 0 24px 0;
  }

  .stats-card {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .stats-text {
    margin-left: 0;
  }

  .search-placeholder,
  .no-results {
    padding: 40px 16px;
  }
}
</style> 