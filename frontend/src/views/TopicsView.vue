<template>
  <div class="topics-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>专题</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">专题</h1>
          <p class="page-subtitle">探索不同主题的精彩图集</p>
        </div>

        <!-- 搜索区域 -->
        <div class="search-section">
          <div class="search-bar">
            <n-input
              v-model:value="searchQuery"
              placeholder="搜索专题..."
              clearable
              size="large"
              @keyup.enter="searchTopics"
            >
              <template #suffix>
                <n-button text @click="searchTopics">
                  <n-icon>
                    <SearchIcon />
                  </n-icon>
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
      <!-- 推荐专题区域 -->
      <section v-if="featuredTopics.length > 0" class="featured-section">
        <h2 class="section-title">推荐专题</h2>
        <div class="featured-topics">
          <div 
            v-for="topic in featuredTopics" 
            :key="topic.id"
            class="featured-topic-card"
            @click="viewTopic(topic.id)"
          >
            <div class="topic-cover">
              <img 
                v-if="topic.cover_image_url" 
                :src="topic.cover_image_url" 
                :alt="topic.name"
                class="cover-image"
                @error="handleImageError"
              >
              <div v-else class="no-cover">
                <n-icon size="40" color="#ccc">
                  <ImageIcon />
                </n-icon>
              </div>
            </div>
            <div class="topic-info">
              <h3 class="topic-name">{{ topic.name }}</h3>
              <p class="topic-description">{{ topic.description }}</p>
              <div class="topic-stats">
                <span class="stat">{{ topic.galleries_count }} 个图集</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 所有专题区域 -->
      <section class="all-topics-section">
        <h2 class="section-title">所有专题</h2>
        
        <!-- 加载状态 -->
        <div v-if="loading" class="loading-container">
          <n-spin size="large" />
        </div>

        <!-- 专题网格 -->
        <div v-else-if="displayTopics.length > 0" class="topics-grid">
          <div 
            v-for="topic in displayTopics" 
            :key="topic.id"
            class="topic-card"
            @click="viewTopic(topic.id)"
          >
            <div class="topic-cover">
              <img 
                v-if="topic.cover_image_url" 
                :src="topic.cover_image_url" 
                :alt="topic.name"
                class="cover-image"
                @error="handleImageError"
              >
              <div v-else class="no-cover">
                <n-icon size="24" color="#ccc">
                  <ImageIcon />
                </n-icon>
              </div>
              <div v-if="topic.is_featured" class="featured-badge">推荐</div>
            </div>
            <div class="topic-info">
              <h3 class="topic-name">{{ topic.name }}</h3>
              <p class="topic-description">{{ topic.description }}</p>
              <div class="topic-stats">
                <span class="stat">{{ topic.galleries_count }} 个图集</span>
                <span class="date">{{ formatDate(topic.created_at) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-else class="empty-state">
          <n-icon size="60" color="#ccc">
            <ImageIcon />
          </n-icon>
          <p>暂无专题</p>
        </div>

        <!-- 加载更多 -->
        <div v-if="hasMore && !loading" class="load-more">
          <n-button @click="loadMore" size="large" type="primary" ghost>
            加载更多
          </n-button>
        </div>
      </section>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#3b82f6" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { topics } from '@/api/api'
import { usePageTitle } from '@/utils/page-title'
import { useRouter } from 'vue-router'
import { NInput, NButton, NIcon, NSpin, NBreadcrumb, NBreadcrumbItem } from 'naive-ui'
import { ImageOutline as ImageIcon, SearchOutline as SearchIcon } from '@vicons/ionicons5'
import AppFooter from '@/components/AppFooter.vue'

const router = useRouter()
const { setTitle } = usePageTitle()

// 响应式数据
const loading = ref(false)
const searchQuery = ref('')
const allTopics = ref([])
const featuredTopics = ref([])
const displayTopics = ref([])
const hasMore = ref(true)
const currentPage = ref(1)
const pageSize = 12

// 设置页面标题
onMounted(() => {
  setTitle('专题')
  loadFeaturedTopics()
  loadTopics()
})

// 加载推荐专题
async function loadFeaturedTopics() {
  try {
    const response = await topics.getTopics({ featured_only: true })
    featuredTopics.value = response.data
  } catch (error) {
    console.error('加载推荐专题失败:', error)
  }
}

// 加载专题列表
async function loadTopics(reset = false) {
  if (loading.value) return
  
  loading.value = true
  try {
    const skip = reset ? 0 : (currentPage.value - 1) * pageSize
    const response = await topics.getTopics({ 
      skip, 
      limit: pageSize 
    })
    
    if (reset) {
      allTopics.value = response.data
      displayTopics.value = response.data
      currentPage.value = 1
    } else {
      allTopics.value.push(...response.data)
      displayTopics.value.push(...response.data)
    }
    
    hasMore.value = response.data.length === pageSize
    if (!reset) currentPage.value++
  } catch (error) {
    console.error('加载专题失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索专题
async function searchTopics() {
  if (!searchQuery.value.trim()) {
    displayTopics.value = allTopics.value
    return
  }
  
  loading.value = true
  try {
    const response = await topics.searchTopics(searchQuery.value.trim())
    displayTopics.value = response.data
    hasMore.value = false
  } catch (error) {
    console.error('搜索专题失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载更多
function loadMore() {
  if (searchQuery.value.trim()) return
  loadTopics()
}

// 查看专题详情
function viewTopic(topicId) {
  router.push({ name: 'topic', params: { id: topicId } })
}

// 格式化日期
function formatDate(dateString) {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

// 处理图片加载错误
function handleImageError(event) {
  event.target.style.display = 'none'
  const noCover = event.target.parentElement.querySelector('.no-cover')
  if (noCover) {
    noCover.style.display = 'flex'
  }
}
</script>

<style scoped>
.topics-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.page-header {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
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

/* 搜索区域 */
.search-section {
  display: flex;
  justify-content: center;
}

.search-bar {
  width: 400px;
  max-width: 100%;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  margin: 40px 0 20px 0;
  color: #1f2937;
}

/* 推荐专题区域 */
.featured-section {
  margin-bottom: 40px;
}

.featured-topics {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
}

.featured-topic-card {
  display: flex;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
  height: 140px;
}

.featured-topic-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
  border-color: #3b82f6;
}

.featured-topic-card .topic-cover {
  width: 180px;
  height: 140px;
  flex-shrink: 0;
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
}

.featured-topic-card .cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
  border-radius: 0;
}

.featured-topic-card:hover .cover-image {
  transform: scale(1.05);
}

.featured-topic-card .no-cover {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 50%, #1d4ed8 100%);
  color: white;
}

.featured-topic-card .topic-info {
  padding: 20px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 0;
}

.featured-topic-card .topic-name {
  font-size: 18px;
  font-weight: 700;
  margin: 0 0 6px 0;
  color: #1f2937;
  line-height: 1.3;
}

.featured-topic-card .topic-description {
  font-size: 13px;
  color: #6b7280;
  margin: 0 0 12px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}

.featured-topic-card .topic-stats {
  display: flex;
  align-items: center;
  font-size: 12px;
  color: #3b82f6;
  font-weight: 600;
  margin-top: auto;
}

.featured-topic-card .stat {
  background: #eff6ff;
  padding: 3px 10px;
  border-radius: 16px;
  color: #1d4ed8;
  font-size: 11px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  margin: 40px 0 20px 0;
  color: #1f2937;
}

/* 推荐专题区域 */
.featured-section {
  margin-bottom: 40px;
}

/* 专题网格 */
.topics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.topic-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
}

.topic-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.topic-cover {
  position: relative;
  width: 100%;
  height: 160px;
  overflow: hidden;
}

.cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.topic-card:hover .cover-image {
  transform: scale(1.05);
}

.no-cover {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
}

.featured-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #f59e0b;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.topic-info {
  padding: 16px;
}

.topic-name {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #1f2937;
}

.topic-description {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 12px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.topic-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #9ca3af;
}

.stat {
  font-weight: 500;
}

/* 加载和空状态 */
.loading-container {
  text-align: center;
  padding: 60px 0;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  color: #9ca3af;
}

.empty-state p {
  margin: 16px 0 0 0;
  font-size: 16px;
}

.load-more {
  text-align: center;
  padding: 20px 0;
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
  
  .search-bar {
    width: 100%;
  }
  
  .featured-topics {
    grid-template-columns: 1fr;
  }
  
  .featured-topic-card {
    flex-direction: column;
    height: auto; /* 移动端允许自动高度 */
    min-height: 280px; /* 设置最小高度确保一致性 */
  }
  
  .featured-topic-card .topic-cover {
    width: 100%;
    height: 180px; /* 减小移动端图片高度 */
  }
  
  .featured-topic-card .topic-info {
    padding: 20px;
    text-align: center;
    justify-content: flex-start; /* 移动端从顶部开始布局 */
  }
  
  .featured-topic-card .topic-name {
    font-size: 18px;
    margin-bottom: 8px;
  }
  
  .featured-topic-card .topic-description {
    font-size: 14px;
    margin-bottom: 16px;
    text-align: center;
  }
  
  .featured-topic-card .topic-stats {
    justify-content: center;
    margin-top: auto; /* 推到底部 */
  }
  
  .topics-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }
  
  .main-content {
    padding: 20px 0;
  }
}
</style> 