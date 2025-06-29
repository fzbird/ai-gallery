<script setup>
import AppFooter from '@/components/AppFooter.vue';

import { ref, onMounted, onUnmounted, watch, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useGalleryStore } from '@/stores/gallery';
import { useCategoryStore } from '@/stores/category';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { NSelect, NBreadcrumb, NBreadcrumbItem } from 'naive-ui';
import GalleryGrid from '@/components/GalleryGrid.vue';

const route = useRoute();
const router = useRouter();
const galleryStore = useGalleryStore();
const categoryStore = useCategoryStore();
const { setTitle, clearCustomTitle } = usePageTitle();

const { galleries, isLoading, hasMore } = storeToRefs(galleryStore);
const { categories } = storeToRefs(categoryStore);

const currentCategoryId = ref(null);

// 当前选中的分类信息
const currentCategory = computed(() => {
  if (!currentCategoryId.value) return null;
  return categories.value.find(c => c.id === currentCategoryId.value);
});

// 分类选择选项
const categoryOptions = computed(() => {
  return categories.value.map(category => ({
    label: category.name,
    value: category.id
  }));
});

// 监听路由变化
watch(() => route.params.id, (newCategoryId) => {
  if (newCategoryId) {
    currentCategoryId.value = parseInt(newCategoryId);
    loadGalleries();
  }
}, { immediate: true });

// 监听分类变化
watch(currentCategoryId, (newCategoryId) => {
  if (newCategoryId) {
    loadGalleries();
    // 更新页面标题
    const category = categories.value.find(c => c.id === newCategoryId);
    if (category) {
      setTitle(`${category.name} - 分类浏览`);
    }
  }
});

// 监听分类数据变化，更新标题
watch(currentCategory, (newCategory) => {
  if (newCategory) {
    setTitle(`${newCategory.name} - 分类浏览`);
  } else {
    clearCustomTitle();
  }
});

function loadGalleries() {
  if (currentCategoryId.value) {
    galleryStore.resetState();
    galleryStore.fetchGalleriesByCategory(currentCategoryId.value, true);
  }
}

function loadMore() {
  if (currentCategoryId.value) {
    galleryStore.fetchGalleriesByCategory(currentCategoryId.value, false);
  }
}

function handleCategoryChange(categoryId) {
  currentCategoryId.value = categoryId;
  // 使用路由导航而不是手动修改URL
  router.push({ name: 'category', params: { id: categoryId } });
}

// 底部数据




onMounted(async () => {
  // 加载分类列表
  await categoryStore.fetchCategories();
  
  // 如果URL中有分类ID，则加载对应分类的图集
  const categoryId = route.params.id;
  if (categoryId) {
    currentCategoryId.value = parseInt(categoryId);
  } else if (categories.value.length > 0) {
    // 默认选择第一个分类
    currentCategoryId.value = categories.value[0].id;
    handleCategoryChange(currentCategoryId.value);
  }
});

onUnmounted(() => {
  // 清理自定义标题
  clearCustomTitle();
});
</script>

<template>
  <div class="category-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item href="/categories">分类</n-breadcrumb-item>
          <n-breadcrumb-item v-if="currentCategory">{{ currentCategory.name }}</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <span v-if="currentCategory">{{ currentCategory.name }}</span>
            <span v-else>分类浏览</span>
          </h1>
          <p class="page-subtitle">浏览不同分类的精彩图集</p>
        </div>

        <!-- 分类选择器 -->
        <div class="category-selector">
          <n-select
            v-model:value="currentCategoryId"
            :options="categoryOptions"
            placeholder="选择分类"
            @update:value="handleCategoryChange"
            class="category-select"
            size="large"
          />
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <div v-if="currentCategory" class="category-description">
          <p v-if="currentCategory.description">{{ currentCategory.description }}</p>
        </div>

        <!-- 图集展示 -->
        <GalleryGrid
          :galleries="galleries"
          :is-loading="isLoading"
          :has-more="hasMore"
          :empty-text="currentCategory ? `${currentCategory.name} 分类下暂无图集` : '请选择一个分类'"
          @load-more="loadMore"
        />
      </div>
    </div>

    
  
    <!-- 统一底部组件 -->
    <AppFooter theme-color="#10b981" />
  </div>
</template>

<style scoped>
.category-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #10b981 0%, #059669 50%, #047857 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0;
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
  margin-bottom: 24px;
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

.category-selector {
  display: flex;
  justify-content: center;
}

.category-select {
  width: 300px;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

.category-description {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.category-description p {
  margin: 0;
  color: #4b5563;
  line-height: 1.6;
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

  .category-select {
    width: 100%;
    max-width: 300px;
  }

  .page-header {
    padding: 16px 0;
  }
}

/* 页脚 */
.footer {
  background: #1f2937;
  color: white;
  padding: 40px 0;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-content p {
  margin: 0;
  color: #9ca3af;
}

.footer-links {
  display: flex;
  gap: 24px;
}

.footer-links a {
  color: #9ca3af;
  text-decoration: none;
  transition: color 0.2s ease;
}

.footer-links a:hover {
  color: white;
}

/* 响应式设计扩展 */
@media (max-width: 768px) {
  .links-content {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  
  .footer-content {
    flex-direction: column;
    text-align: center;
  }
  
  .footer-links {
    justify-content: center;
  }
}
</style> 