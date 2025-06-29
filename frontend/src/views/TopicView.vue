<template>
  <div class="topic-detail-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item href="/topics">专题</n-breadcrumb-item>
          <n-breadcrumb-item v-if="topic">{{ topic.name }}</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <span v-if="topic">{{ topic.name }}</span>
            <span v-else>专题详情</span>
          </h1>
          <p class="page-subtitle" v-if="topic">{{ topic.description || '汇集最美的自然风光图集，包含山川、湖泊、森林等各种自然景观' }}</p>
        </div>

        <!-- 专题统计信息 -->
        <div class="topic-stats" v-if="topic">
          <div class="stats-item">
            <n-icon><ImageIcon /></n-icon>
            <span>{{ topic.galleries_count }} 个图集</span>
          </div>
          <div class="stats-item">
            <span>创建于 {{ formatDate(topic.created_at) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 加载状态 -->
        <div v-if="loading" class="loading-container">
          <n-spin size="large" />
        </div>

        <!-- 专题不存在 -->
        <div v-else-if="!topic" class="error-state">
          <n-empty description="专题不存在或已被删除">
            <template #extra>
              <n-button @click="goBack" type="primary">返回专题列表</n-button>
            </template>
          </n-empty>
        </div>

        <!-- 专题内容 -->
        <div v-else>
          <!-- 工具栏 -->
          <div class="toolbar">
            <h2 class="section-title">专题图集</h2>
            <div class="toolbar-actions">
              <n-select
                v-model:value="sortBy"
                :options="sortOptions"
                @update:value="handleSortChange"
                size="large"
                style="width: 180px"
              />
            </div>
          </div>

          <!-- 图集展示 -->
          <GalleryGrid
            :galleries="galleries"
            :is-loading="galleriesLoading"
            :has-more="hasMore"
            :empty-text="`${topic.name} 专题下暂无图集`"
            @load-more="loadMore"
          />
        </div>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#3b82f6" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { usePageTitle } from '@/utils/page-title'
import { topics } from '@/api/api'
import { NButton, NIcon, NSpin, NSelect, NBreadcrumb, NBreadcrumbItem, NEmpty } from 'naive-ui'
import { ImageOutline as ImageIcon } from '@vicons/ionicons5'
import GalleryGrid from '@/components/GalleryGrid.vue'
import AppFooter from '@/components/AppFooter.vue'

const route = useRoute()
const router = useRouter()
const { setTitle } = usePageTitle()

// 响应式数据
const topic = ref(null)
const galleries = ref([])
const loading = ref(false)
const galleriesLoading = ref(false)
const hasMore = ref(true)
const currentPage = ref(1)
const pageSize = 12
const sortBy = ref('created_at')

// 排序选项
const sortOptions = [
  { label: '最新发布', value: 'created_at' },
  { label: '最多浏览', value: 'views_count' },
  { label: '最多点赞', value: 'likes_count' },
  { label: '最多收藏', value: 'bookmarks_count' }
]

// 计算属性
const topicId = computed(() => parseInt(route.params.id))

// 加载专题详情
async function loadTopic() {
  loading.value = true
  try {
    const response = await topics.getTopicDetail(topicId.value)
    topic.value = response.data
    setTitle(`${topic.value.name} - 专题`)
  } catch (error) {
    console.error('加载专题详情失败:', error)
    topic.value = null
  } finally {
    loading.value = false
  }
}

// 加载专题下的图集
async function loadGalleries(reset = false) {
  galleriesLoading.value = true
  try {
    const skip = reset ? 0 : (currentPage.value - 1) * pageSize
    
    const response = await topics.getTopicGalleries(topicId.value, {
      skip,
      limit: pageSize,
      sort: sortBy.value,
      order: 'desc'
    })
    
    if (reset) {
      galleries.value = response.data
      currentPage.value = 1
    } else {
      galleries.value.push(...response.data)
    }
    
    hasMore.value = response.data.length === pageSize
    if (!reset) currentPage.value++
  } catch (error) {
    console.error('加载专题图集失败:', error)
    if (error.response) {
      console.error('Response status:', error.response.status)
      console.error('Response data:', error.response.data)
    }
  } finally {
    galleriesLoading.value = false
  }
}

// 排序变化处理
function handleSortChange() {
  currentPage.value = 1
  loadGalleries(true)
}

// 加载更多
function loadMore() {
  loadGalleries()
}

// 返回专题列表
function goBack() {
  router.push('/topics')
}

// 格式化日期
function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

// 页面初始化
onMounted(async () => {
  await loadTopic()
  if (topic.value) {
    loadGalleries(true)
  }
})
</script>

<style scoped>
.topic-detail-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
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
  line-height: 1.5;
}

.topic-stats {
  display: flex;
  justify-content: center;
  gap: 32px;
  margin-top: 16px;
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
}

.stats-item n-icon {
  font-size: 16px;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400px;
}

.error-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 400px;
}

/* 工具栏 */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  padding: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }
  
  .page-header {
    padding: 16px 0;
  }
  
  .page-title {
    font-size: 28px;
  }
  
  .page-subtitle {
    font-size: 14px;
  }
  
  .topic-stats {
    flex-direction: column;
    gap: 12px;
  }
  
  .toolbar {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .toolbar-actions {
    justify-content: center;
  }
  
  .main-content {
    padding: 20px 0;
  }
}
</style> 