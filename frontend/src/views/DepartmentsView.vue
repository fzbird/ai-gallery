<template>
  <div class="departments-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>部门</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">部门</h1>
          <p class="page-subtitle">按部门浏览精彩图集</p>
        </div>

        <!-- 搜索区域 -->
        <div class="search-section">
          <div class="search-bar">
            <n-input
              v-model:value="searchQuery"
              placeholder="搜索部门..."
              clearable
              size="large"
              @keyup.enter="searchDepartments"
            >
              <template #suffix>
                <n-button text @click="searchDepartments">
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
        <!-- 所有部门区域 -->
        <section class="all-departments-section">
          <h2 class="section-title">所有部门</h2>
          
          <!-- 加载状态 -->
          <div v-if="loading" class="loading-container">
            <n-spin size="large" />
          </div>

          <!-- 部门网格 -->
          <div v-else-if="displayDepartments.length > 0" class="departments-grid">
            <div 
              v-for="department in displayDepartments" 
              :key="department.id"
              class="department-card"
              @click="viewDepartment(department.id)"
            >
              <div class="department-icon">
                <n-icon size="32" color="#8b5cf6">
                  <BusinessIcon />
                </n-icon>
              </div>
              <div class="department-info">
                <h3 class="department-name">{{ department.name }}</h3>
                <p class="department-description">{{ department.description || '暂无描述' }}</p>
                <div class="department-stats">
                  <span class="stat">{{ department.users ? department.users.length : 0 }} 位成员</span>
                  <span class="stat">{{ getDepartmentGalleryCount(department.id) }} 个图集</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 空状态 -->
          <div v-else class="empty-state">
            <n-icon size="60" color="#ccc">
              <BusinessIcon />
            </n-icon>
            <p>暂无部门</p>
          </div>
        </section>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#8b5cf6" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useDepartmentStore } from '@/stores/department'
import { useGalleryStore } from '@/stores/gallery'
import { usePageTitle } from '@/utils/page-title'
import { useRouter } from 'vue-router'
import { NInput, NButton, NIcon, NSpin, NBreadcrumb, NBreadcrumbItem } from 'naive-ui'
import { BusinessOutline as BusinessIcon, SearchOutline as SearchIcon } from '@vicons/ionicons5'
import AppFooter from '@/components/AppFooter.vue'
import { departments } from '@/api/api'

const router = useRouter()
const { setTitle } = usePageTitle()
const departmentStore = useDepartmentStore()
const galleryStore = useGalleryStore()

// 响应式数据
const loading = ref(false)
const searchQuery = ref('')
const departmentCounts = ref({})

// 计算属性
const displayDepartments = computed(() => {
  if (!searchQuery.value.trim()) {
    return departmentStore.departments
  }
  return departmentStore.departments.filter(department =>
    department.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
    (department.description && department.description.toLowerCase().includes(searchQuery.value.toLowerCase()))
  )
})

// 设置页面标题
onMounted(async () => {
  setTitle('部门')
  await loadDepartments()
  await loadDepartmentCounts()
})

// 加载部门列表
async function loadDepartments() {
  loading.value = true
  try {
    await departmentStore.fetchDepartments()
  } catch (error) {
    console.error('加载部门失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载部门下的图集数量
async function loadDepartmentCounts() {
  try {
    // 调用API获取每个部门下的图集数量
    const response = await departments.getDepartmentStats()
    departmentCounts.value = response.data || {}
  } catch (error) {
    console.error('加载部门统计失败:', error)
    // 如果API调用失败，使用默认值
    departmentCounts.value = {}
  }
}

// 获取部门下的图集数量
function getDepartmentGalleryCount(departmentId) {
  return departmentCounts.value[departmentId] || 0
}

// 搜索部门
function searchDepartments() {
  // 搜索逻辑已在计算属性中实现
}

// 查看部门详情
function viewDepartment(departmentId) {
  router.push({ name: 'department', params: { id: departmentId } })
}
</script>

<style scoped>
.departments-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.page-header {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 50%, #6d28d9 100%);
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

/* 部门网格 */
.departments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.department-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  border: 1px solid #e5e7eb;
}

.department-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #8b5cf6;
}

.department-icon {
  margin-bottom: 16px;
  display: flex;
  justify-content: center;
}

.department-info {
  text-align: center;
}

.department-name {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #1f2937;
}

.department-description {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 12px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.department-stats {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  font-size: 12px;
}

.stat {
  background: #f3f0ff;
  padding: 4px 12px;
  border-radius: 16px;
  color: #6d28d9;
  font-weight: 500;
  flex: 1;
  text-align: center;
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
  
  .departments-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 16px;
  }
  
  .department-card {
    padding: 20px;
  }
  
  .main-content {
    padding: 20px 0;
  }
}
</style> 