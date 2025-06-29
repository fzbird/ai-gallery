<template>
  <div class="department-view">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item @click="router.push('/')">首页</n-breadcrumb-item>
          <n-breadcrumb-item @click="router.push('/departments')">部门</n-breadcrumb-item>
          <n-breadcrumb-item>{{ currentDepartment?.name || '部门详情' }}</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <span v-if="currentDepartment">{{ currentDepartment.name }}</span>
            <span v-else>部门详情</span>
          </h1>
          <p class="page-subtitle" v-if="currentDepartment">{{ currentDepartment.description || '部门详细信息与相关图集' }}</p>
        </div>

        <!-- 部门统计信息 -->
        <div class="department-stats" v-if="currentDepartment">
          <div class="stats-item">
            <n-icon><PersonIcon /></n-icon>
            <span>{{ currentDepartment.users ? currentDepartment.users.length : 0 }} 位成员</span>
          </div>
          <div class="stats-item">
            <n-icon><ImagesIcon /></n-icon>
            <span>{{ departmentGalleries.length }} 个图集</span>
          </div>
        </div>

        <!-- 加载状态 -->
        <div v-else-if="loading" class="loading-header">
          <n-spin size="large" />
        </div>

        <!-- 错误状态 -->
        <div v-else class="error-header">
          <n-icon size="48" color="white">
            <BusinessIcon />
          </n-icon>
          <h1>部门未找到</h1>
          <p>请检查部门ID是否正确</p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 部门成员列表 -->
        <section v-if="currentDepartment && currentDepartment.users && currentDepartment.users.length > 0" class="members-section">
          <h2 class="section-title">部门成员</h2>
          <div class="members-grid">
            <div 
              v-for="member in currentDepartment.users" 
              :key="member.id"
              class="member-card"
              @click="viewMemberProfile(member.id)"
            >
              <div class="member-avatar">
                <n-icon size="24" color="#8b5cf6">
                  <PersonIcon />
                </n-icon>
              </div>
              <div class="member-info">
                <h3 class="member-name">{{ member.username }}</h3>
                <p class="member-role">成员</p>
              </div>
            </div>
          </div>
        </section>

        <!-- 图集网格 -->
        <section class="galleries-section">
          <!-- 工具栏 -->
          <div class="toolbar">
            <h2 class="section-title">部门图集</h2>
            <div class="toolbar-actions">
              <n-input
                v-model:value="searchQuery"
                placeholder="搜索图集..."
                clearable
                size="medium"
                style="width: 300px; margin-right: 12px;"
                @keyup.enter="performSearch"
              >
                <template #suffix>
                  <n-button text @click="performSearch">
                    <n-icon>
                      <SearchIcon />
                    </n-icon>
                  </n-button>
                </template>
              </n-input>
              <n-select
                v-model:value="sortBy"
                :options="sortOptions"
                size="medium"
                style="width: 180px;"
                @update:value="onSortChange"
              />
            </div>
          </div>
          
          <!-- 加载状态 -->
          <div v-if="galleriesLoading" class="loading-container">
            <n-spin size="large" />
          </div>

          <!-- 图集展示 -->
          <GalleryGrid 
            v-else-if="filteredGalleries.length > 0"
            :galleries="filteredGalleries"
            :is-loading="galleriesLoading"
            :has-more="hasMoreGalleries"
            @load-more="loadMoreGalleries"
          />

          <!-- 空状态 -->
          <div v-else class="empty-state">
            <n-icon size="60" color="#ccc">
              <ImagesIcon />
            </n-icon>
            <p v-if="searchQuery.trim()">没有找到匹配的图集</p>
            <p v-else>该部门暂无图集</p>
          </div>
        </section>


      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#8b5cf6" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useDepartmentStore } from '@/stores/department'
import { useGalleryStore } from '@/stores/gallery'
import { usePageTitle } from '@/utils/page-title'
import { 
  NInput, 
  NButton, 
  NIcon, 
  NSpin, 
  NBreadcrumb, 
  NBreadcrumbItem, 
  NSelect
} from 'naive-ui'
import { 
  BusinessOutline as BusinessIcon, 
  SearchOutline as SearchIcon,
  ImagesOutline as ImagesIcon,
  PersonOutline as PersonIcon
} from '@vicons/ionicons5'
import GalleryGrid from '@/components/GalleryGrid.vue'
import AppFooter from '@/components/AppFooter.vue'
import apiClient from '@/api/api'

const route = useRoute()
const router = useRouter()
const { setTitle } = usePageTitle()
const departmentStore = useDepartmentStore()
const galleryStore = useGalleryStore()

// 响应式数据
const loading = ref(true)
const galleriesLoading = ref(false)
const departmentGalleries = ref([])
const searchQuery = ref('')
const sortBy = ref('created_at_desc')
const currentPage = ref(1)
const pageSize = ref(24)
const hasMoreGalleries = ref(true)

// 排序选项
const sortOptions = [
  { label: '最新上传', value: 'created_at_desc' },
  { label: '最早上传', value: 'created_at_asc' },
  { label: '最多点赞', value: 'likes_desc' },
  { label: '最多收藏', value: 'bookmarks_desc' },
  { label: '最多浏览', value: 'views_desc' },
  { label: '图片数量多', value: 'image_count_desc' },
  { label: '图片数量少', value: 'image_count_asc' }
]

// 计算属性
const departmentId = computed(() => route.params.id)

const currentDepartment = computed(() => 
  departmentStore.departments.find(dept => dept.id === parseInt(departmentId.value))
)

const filteredGalleries = computed(() => {
  if (!searchQuery.value.trim()) {
    return departmentGalleries.value
  }
  return departmentGalleries.value.filter(gallery =>
    gallery.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
    (gallery.description && gallery.description.toLowerCase().includes(searchQuery.value.toLowerCase()))
  )
})



// 监听路由参数变化
watch(() => route.params.id, async (newId) => {
  if (newId) {
    await loadDepartmentData()
  }
}, { immediate: true })

// 页面初始化
onMounted(async () => {
  await loadDepartmentData()
})

// 加载部门数据
async function loadDepartmentData() {
  loading.value = true
  try {
    // 确保部门数据已加载
    if (departmentStore.departments.length === 0) {
      await departmentStore.fetchDepartments()
    }
    
    // 获取当前部门信息
    const dept = currentDepartment.value
    if (dept) {
      setTitle(`${dept.name} - 部门`)
      await loadDepartmentGalleries(true)
    } else {
      setTitle('部门未找到')
      console.error('部门未找到:', departmentId.value)
    }
  } catch (error) {
    console.error('加载部门数据失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载部门图集
async function loadDepartmentGalleries(reset = false) {
  galleriesLoading.value = true
  try {
    if (reset) {
      currentPage.value = 1
      departmentGalleries.value = []
      hasMoreGalleries.value = true
    }

    const skip = (currentPage.value - 1) * pageSize.value
    const params = {
      skip,
      limit: pageSize.value,
      department_id: departmentId.value
    }
    
    // 处理排序参数
    if (sortBy.value !== 'created_at_desc') {
      const sortField = sortBy.value.replace('_desc', '').replace('_asc', '')
      const sortOrder = sortBy.value.includes('_desc') ? 'desc' : 'asc'
      params.sort = sortField
      params.order = sortOrder
    }
    
    const response = await apiClient.get('/galleries/', { params })
    
    const newGalleries = response.data || []
    
    if (reset) {
      departmentGalleries.value = newGalleries
    } else {
      departmentGalleries.value.push(...newGalleries)
    }
    
    // 判断是否还有更多数据
    hasMoreGalleries.value = newGalleries.length === pageSize.value
    
    if (!reset) {
      currentPage.value++
    }
  } catch (error) {
    console.error('加载部门图集失败:', error)
    if (reset) {
      departmentGalleries.value = []
    }
  } finally {
    galleriesLoading.value = false
  }
}

// 执行搜索
function performSearch() {
  // 搜索逻辑在计算属性中实现，无需重新请求API
  // 前端过滤会自动生效
}

// 排序变化处理
function onSortChange() {
  loadDepartmentGalleries(true)
}



// 加载更多图集
function loadMoreGalleries() {
  if (!galleriesLoading.value && hasMoreGalleries.value) {
    loadDepartmentGalleries(false)
  }
}

// 查看成员资料
function viewMemberProfile(memberId) {
  // 需要先获取用户的username，因为路由使用的是username而不是id
  const member = currentDepartment.value?.users?.find(user => user.id === memberId)
  if (member && member.username) {
    router.push({ name: 'profile', params: { username: member.username } })
  }
}
</script>

<style scoped>
.department-view {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.page-header {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
  color: white;
  padding: 24px 0 40px;
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

.page-title-section {
  text-align: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.page-subtitle {
  font-size: 1.125rem;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

.department-stats {
  display: flex;
  justify-content: center;
  gap: 32px;
}

.stats-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: rgba(255, 255, 255, 0.9);
  font-size: 1rem;
}

.loading-header,
.error-header {
  text-align: center;
  padding: 40px 0;
}

.loading-header h1,
.error-header h1 {
  font-size: 2rem;
  margin: 16px 0 8px 0;
}

.main-content {
  padding: 40px 0;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  gap: 16px;
}

.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 24px 0;
}

/* 成员列表样式 */
.members-section {
  margin-bottom: 48px;
}

.members-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.member-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  border: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.member-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #8b5cf6;
}

.member-avatar {
  width: 48px;
  height: 48px;
  background: #f3f0ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}

.member-info {
  text-align: center;
}

.member-name {
  font-size: 14px;
  font-weight: 600;
  margin: 0 0 4px 0;
  color: #1f2937;
}

.member-role {
  font-size: 12px;
  color: #6b7280;
  margin: 0;
  background: #f3f0ff;
  padding: 2px 8px;
  border-radius: 12px;
  display: inline-block;
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 80px 0;
}

.empty-state {
  text-align: center;
  padding: 80px 20px;
  color: #6b7280;
}

.empty-state p {
  margin: 16px 0 0 0;
  font-size: 1.125rem;
}

.pagination-section {
  margin-top: 40px;
  display: flex;
  justify-content: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-title {
    font-size: 2rem;
  }

  .page-subtitle {
    font-size: 1rem;
  }

  .department-stats {
    flex-direction: column;
    gap: 16px;
  }

  .toolbar {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }

  .toolbar-actions {
    flex-direction: column;
    gap: 12px;
  }

  .toolbar-actions n-input {
    width: 100% !important;
    margin-right: 0 !important;
  }

  .toolbar-actions n-select {
    width: 100% !important;
  }

  .members-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 12px;
  }

  .member-card {
    padding: 16px;
  }
}

@media (max-width: 480px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 1.75rem;
  }

  .page-subtitle {
    font-size: 0.875rem;
  }

  .department-stats {
    gap: 12px;
  }

  .stats-item {
    font-size: 0.875rem;
  }
}
</style>
