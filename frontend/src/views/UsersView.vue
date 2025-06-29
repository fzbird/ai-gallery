<template>
  <div class="users-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item @click="router.push('/')">首页</n-breadcrumb-item>
          <n-breadcrumb-item>用户</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">用户</h1>
          <p class="page-subtitle">发现优秀的摄影师和创作者</p>
        </div>

        <!-- 搜索区域 -->
        <div class="search-section">
          <div class="search-bar">
            <n-input
              v-model:value="searchQuery"
              placeholder="搜索用户..."
              clearable
              size="large"
              @keyup.enter="searchUsers"
            >
              <template #suffix>
                <n-button text @click="searchUsers">
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
        <!-- 排序和筛选 -->
        <div class="controls-section">
          <h2 class="section-title">所有用户</h2>
          <div class="controls">
            <n-select
              v-model:value="sortBy"
              :options="sortOptions"
              size="medium"
              style="width: 200px;"
              @update:value="onSortChange"
            />
          </div>
        </div>
        
        <!-- 加载状态 -->
        <div v-if="loading" class="loading-container">
          <n-spin size="large" />
        </div>

        <!-- 用户网格 -->
        <div v-else-if="displayUsers.length > 0" class="users-grid">
          <div 
            v-for="user in displayUsers" 
            :key="user.id"
            class="user-card"
            @click="viewUser(user.username)"
          >
            <div class="user-avatar">
              <n-avatar :size="64" round>
                <n-icon size="32" color="#667eea">
                  <PersonIcon />
                </n-icon>
              </n-avatar>
            </div>
            <div class="user-info">
              <h3 class="user-name">{{ user.username }}</h3>
              <p class="user-bio">{{ user.bio || '这个用户很懒，什么都没留下...' }}</p>
              <div class="user-meta">
                <span class="meta-item" v-if="user.department">
                  <n-icon><BusinessIcon /></n-icon>
                  {{ user.department.name }}
                </span>
                <span class="meta-item">
                  <n-icon><CalendarIcon /></n-icon>
                  {{ formatJoinDate(user.created_at) }}
                </span>
              </div>
              <div class="user-stats">
                <span class="stat">{{ user.followers_count || 0 }} 粉丝</span>
                <span class="stat">{{ user.uploads_count || 0 }} 作品</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-else class="empty-state">
          <n-icon size="60" color="#ccc">
            <PersonIcon />
          </n-icon>
          <p v-if="searchQuery.trim()">没有找到匹配的用户</p>
          <p v-else>暂无用户</p>
        </div>

        <!-- 加载更多 -->
        <div v-if="hasMore && displayUsers.length > 0" class="load-more-section">
          <n-button 
            @click="loadMoreUsers"
            size="large"
            type="primary"
            ghost
            :loading="loadingMore"
            class="load-more-btn"
          >
            查看更多
          </n-button>
        </div>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#667eea" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { usePageTitle } from '@/utils/page-title'
import { 
  NInput, 
  NButton, 
  NIcon, 
  NSpin, 
  NBreadcrumb, 
  NBreadcrumbItem, 
  NSelect,
  NAvatar
} from 'naive-ui'
import { 
  PersonOutline as PersonIcon, 
  SearchOutline as SearchIcon,
  BusinessOutline as BusinessIcon,
  CalendarOutline as CalendarIcon
} from '@vicons/ionicons5'
import AppFooter from '@/components/AppFooter.vue'
import apiClient from '@/api/api'

const router = useRouter()
const { setTitle } = usePageTitle()

// 响应式数据
const loading = ref(false)
const loadingMore = ref(false)
const users = ref([])
const searchQuery = ref('')
const sortBy = ref('created_at_desc')
const currentPage = ref(1)
const pageSize = ref(24)
const hasMore = ref(true)

// 排序选项
const sortOptions = [
  { label: '最新注册', value: 'created_at_desc' },
  { label: '最早注册', value: 'created_at_asc' },
  { label: '用户名 A-Z', value: 'username_asc' },
  { label: '用户名 Z-A', value: 'username_desc' }
  // 注：粉丝数和作品数排序暂时不支持，因为需要复杂的聚合查询
]

// 计算属性 - 搜索现在在后端处理，所以直接返回用户列表
const displayUsers = computed(() => {
  return users.value
})

// 页面初始化
onMounted(async () => {
  setTitle('用户')
  await loadUsers(true)
})

// 监听搜索查询变化，实现实时搜索
let searchTimeout = null
watch(searchQuery, (newValue) => {
  // 清除之前的定时器
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }
  
  // 设置新的定时器，500ms后执行搜索
  searchTimeout = setTimeout(() => {
    loadUsers(true)
  }, 500)
})

// 加载用户列表
async function loadUsers(reset = false) {
  if (reset) {
    loading.value = true
    currentPage.value = 1
    users.value = []
    hasMore.value = true
  } else {
    loadingMore.value = true
  }

  try {
    const skip = (currentPage.value - 1) * pageSize.value
    const params = {
      skip,
      limit: pageSize.value,
      search: searchQuery.value.trim() // 添加搜索参数
    }
    
    // 处理排序参数
    const sortField = sortBy.value.replace('_desc', '').replace('_asc', '')
    const sortOrder = sortBy.value.includes('_desc') ? 'desc' : 'asc'
    params.sort = sortField
    params.order = sortOrder
    

    
    const response = await apiClient.get('/users/', { params })
    const newUsers = response.data || []
    
    if (reset) {
      users.value = newUsers
    } else {
      users.value.push(...newUsers)
    }
    
    // 判断是否还有更多数据
    hasMore.value = newUsers.length === pageSize.value
    
    if (!reset) {
      currentPage.value++
    }
  } catch (error) {
    console.error('加载用户列表失败:', error)
    if (reset) {
      users.value = []
    }
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

// 加载更多用户
function loadMoreUsers() {
  if (!loadingMore.value && hasMore.value) {
    loadUsers(false)
  }
}

// 搜索用户
function searchUsers() {
  // 重新加载用户列表，包含搜索条件
  loadUsers(true)
}

// 排序变化处理
function onSortChange() {
  loadUsers(true)
}

// 查看用户详情
function viewUser(username) {
  router.push({ name: 'profile', params: { username } })
}

// 格式化注册日期
function formatJoinDate(dateString) {
  if (!dateString) return '未知'
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', { 
    year: 'numeric', 
    month: 'long'
  })
}
</script>

<style scoped>
.users-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #667eea 100%);
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
  cursor: pointer;
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

.controls-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
  color: #1f2937;
}

.controls {
  display: flex;
  gap: 16px;
  align-items: center;
}

/* 用户网格 */
.users-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.user-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.user-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.user-avatar {
  margin-bottom: 16px;
}

.user-info {
  width: 100%;
}

.user-name {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #1f2937;
}

.user-bio {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 16px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  min-height: 2.8em;
}

.user-meta {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 16px;
}

.meta-item {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-size: 12px;
  color: #6b7280;
}

.user-stats {
  display: flex;
  justify-content: center;
  gap: 16px;
  font-size: 12px;
}

.stat {
  background: #f0f7ff;
  padding: 4px 12px;
  border-radius: 16px;
  color: #1e40af;
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

.load-more-section {
  text-align: center;
  margin-top: 40px;
}

.load-more-btn {
  min-width: 160px;
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
  
  .users-grid {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }
  
  .user-card {
    padding: 20px;
  }
  
  .main-content {
    padding: 20px 0;
  }

  .controls-section {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }

  .controls {
    justify-content: center;
  }
}
</style> 