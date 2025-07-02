<template>
  <div class="categories-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>分类</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">分类</h1>
          <p class="page-subtitle">按分类浏览精彩图集</p>
        </div>

        <!-- 搜索和控制区域 -->
        <div class="search-section">
          <div class="search-bar">
            <n-input
              v-model:value="searchQuery"
              placeholder="搜索分类..."
              clearable
              size="large"
              @keyup.enter="searchCategories"
            >
              <template #suffix>
                <n-button text @click="searchCategories">
                  <n-icon>
                    <SearchIcon />
                  </n-icon>
                </n-button>
              </template>
            </n-input>
          </div>
          
          <!-- 视图模式切换 -->
          <div class="view-controls">
            <n-button-group>
              <n-button 
                :type="viewMode === 'grid' ? 'primary' : 'default'"
                @click="viewMode = 'grid'"
              >
                <template #icon>
                  <n-icon><GridIcon /></n-icon>
                </template>
                卡片视图
              </n-button>
              <n-button 
                :type="viewMode === 'tree' ? 'primary' : 'default'"
                @click="viewMode = 'tree'"
              >
                <template #icon>
                  <n-icon><ListIcon /></n-icon>
                </template>
                树形视图
              </n-button>
            </n-button-group>
          </div>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <!-- 所有分类区域 -->
        <section class="all-categories-section">
          <div class="section-header">
            <h2 class="section-title">所有分类</h2>
            <div class="section-stats">
              <span class="stats-item">
                总分类: {{ totalCategories }}
              </span>
              <span class="stats-item">
                最大层级: {{ maxLevel }}
              </span>
            </div>
          </div>
          
          <!-- 加载状态 -->
          <div v-if="loading" class="loading-container">
            <n-spin size="large" />
          </div>

          <!-- 卡片视图 -->
          <div v-else-if="viewMode === 'grid' && displayCategories.length > 0" class="categories-grid">
            <div 
              v-for="category in displayCategories" 
              :key="category.id"
              class="category-card"
              :class="{ 'has-children': category.has_children }"
              @click="viewCategory(category.id)"
            >
              <!-- 层级指示器 -->
              <div v-if="category.level > 0" class="level-indicator">
                <span class="level-badge">L{{ category.level }}</span>
                <div class="level-path">{{ category.full_path }}</div>
              </div>
              
              <div class="category-icon">
                <n-icon size="32" :color="getCategoryIconColor(category)">
                  <component :is="getCategoryIcon(category)" />
                </n-icon>
              </div>
              <div class="category-info">
                <h3 class="category-name">{{ category.name }}</h3>
                <p class="category-description">{{ category.description || '暂无描述' }}</p>
                <div class="category-stats">
                  <span class="stat primary">{{ getCategoryGalleryCount(category.id) }} 个图集</span>
                  <span v-if="category.all_content_count > category.content_count" class="stat secondary">
                    含子分类: {{ category.all_content_count }} 个
                  </span>
                  <span v-if="category.has_children" class="stat children">
                    {{ getChildrenCount(category.id) }} 个子分类
                  </span>
                </div>
              </div>
              
              <!-- 子分类快速预览 -->
              <div v-if="category.has_children && showChildrenPreview" class="children-preview">
                <div class="children-title">子分类:</div>
                <div class="children-tags">
                  <n-tag 
                    v-for="child in getDirectChildren(category.id).slice(0, 3)" 
                    :key="child.id"
                    size="small"
                    @click.stop="viewCategory(child.id)"
                  >
                    {{ child.name }}
                  </n-tag>
                  <span v-if="getDirectChildren(category.id).length > 3" class="more-indicator">
                    +{{ getDirectChildren(category.id).length - 3 }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- 树形视图 -->
          <div v-else-if="viewMode === 'tree' && categoryTree.length > 0" class="categories-tree">
            <div class="tree-container">
              <CategoryTreeNode 
                v-for="node in filteredCategoryTree" 
                :key="node.id"
                :node="node"
                :search-query="searchQuery"
                @view-category="viewCategory"
              />
            </div>
          </div>

          <!-- 空状态 -->
          <div v-else class="empty-state">
            <n-icon size="60" color="#ccc">
              <FolderIcon />
            </n-icon>
            <p>{{ searchQuery ? '未找到匹配的分类' : '暂无分类' }}</p>
          </div>
        </section>
      </div>
    </div>

    <!-- 统一底部组件 -->
    <AppFooter theme-color="#10b981" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCategoryStore } from '@/stores/category'
import { useGalleryStore } from '@/stores/gallery'
import { usePageTitle } from '@/utils/page-title'
import { useRouter } from 'vue-router'
import { 
  NInput, NButton, NIcon, NSpin, NBreadcrumb, NBreadcrumbItem, 
  NButtonGroup, NTag 
} from 'naive-ui'
import { 
  Folder as FolderIcon, 
  Search as SearchIcon,
  Grid as GridIcon,
  List as ListIcon,
  FolderOpen as FolderOpenOutline,
  Document as DocumentOutline
} from '@vicons/ionicons5'
import AppFooter from '@/components/AppFooter.vue'
import CategoryTreeNode from '@/components/CategoryTreeNode.vue'
import { categories } from '@/api/api'

const router = useRouter()
const { setTitle } = usePageTitle()
const categoryStore = useCategoryStore()
const galleryStore = useGalleryStore()

// 响应式数据
const loading = ref(false)
const searchQuery = ref('')
const categoryCounts = ref({})
const viewMode = ref('tree') // 默认使用树形视图
const showChildrenPreview = ref(true)

// 计算属性
const displayCategories = computed(() => {
  let categories = categoryStore.categories
  
  // 搜索过滤
  if (searchQuery.value.trim()) {
    categories = categories.filter(category =>
      category.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      (category.description && category.description.toLowerCase().includes(searchQuery.value.toLowerCase())) ||
      (category.full_path && category.full_path.toLowerCase().includes(searchQuery.value.toLowerCase()))
    )
  }
  
  // 按层级和排序权重排序
  return categories.sort((a, b) => {
    if (a.level !== b.level) {
      return a.level - b.level
    }
    if (a.sort_order !== b.sort_order) {
      return a.sort_order - b.sort_order
    }
    return a.name.localeCompare(b.name)
  })
})

const categoryTree = computed(() => categoryStore.categoryTree)

const filteredCategoryTree = computed(() => {
  if (!searchQuery.value.trim()) {
    return categoryTree.value
  }
  
  // 递归过滤树节点
  const filterTree = (nodes) => {
    return nodes.reduce((filtered, node) => {
      const matches = node.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                     (node.description && node.description.toLowerCase().includes(searchQuery.value.toLowerCase()))
      
      const filteredChildren = node.children ? filterTree(node.children) : []
      
      if (matches || filteredChildren.length > 0) {
        filtered.push({
          ...node,
          children: filteredChildren
        })
      }
      
      return filtered
    }, [])
  }
  
  return filterTree(categoryTree.value)
})

const totalCategories = computed(() => categoryStore.categories.length)

const maxLevel = computed(() => {
  return Math.max(0, ...categoryStore.categories.map(cat => cat.level || 0))
})

// 方法
function getCategoryIcon(category) {
  if (category.has_children) {
    return FolderOpenOutline
  }
  return category.level > 0 ? DocumentOutline : FolderIcon
}

function getCategoryIconColor(category) {
  const colors = ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ef4444']
  return colors[category.level % colors.length] || '#10b981'
}

function getDirectChildren(categoryId) {
  return categoryStore.categories.filter(cat => cat.parent_id === categoryId)
}

function getChildrenCount(categoryId) {
  return getDirectChildren(categoryId).length
}

// 设置页面标题
onMounted(async () => {
  setTitle('分类')
  await loadCategories()
  await loadCategoryCounts()
})

// 加载分类列表和树结构
async function loadCategories() {
  loading.value = true
  try {
    await Promise.all([
      categoryStore.fetchCategories(),
      categoryStore.fetchCategoryTree()
    ])
  } catch (error) {
    console.error('加载分类失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载分类下的图集数量
async function loadCategoryCounts() {
  try {
    const response = await categories.getCategoryStats()
    const stats = response.data || {}
    
    if (stats.category_gallery_stats && Array.isArray(stats.category_gallery_stats)) {
      const countsMap = {}
      stats.category_gallery_stats.forEach(item => {
        countsMap[item.id] = item.gallery_count
      })
      categoryCounts.value = countsMap
    } else {
      categoryCounts.value = {}
    }
  } catch (error) {
    console.error('加载分类统计失败:', error)
    categoryCounts.value = {}
  }
}

// 获取分类下的图集数量
function getCategoryGalleryCount(categoryId) {
  return categoryCounts.value[categoryId] || 0
}

// 搜索分类
function searchCategories() {
  // 搜索逻辑已在计算属性中实现
}

// 查看分类详情
function viewCategory(categoryId) {
  router.push({ name: 'category', params: { id: categoryId } })
}
</script>

<style scoped>
.categories-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

.page-header {
  background: linear-gradient(135deg, #10b981 0%, #059669 50%, #047857 100%);
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

/* 搜索和控制区域 */
.search-section {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.search-bar {
  width: 400px;
  max-width: 100%;
}

.view-controls {
  flex-shrink: 0;
}

.view-controls .n-button-group {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 4px;
}

.view-controls .n-button {
  color: rgba(255, 255, 255, 0.8);
  border: none;
}

.view-controls .n-button:hover {
  color: white;
  background: rgba(255, 255, 255, 0.2);
}

.view-controls .n-button--primary {
  color: white;
  background: rgba(255, 255, 255, 0.2);
}

/* 分类区域标题 */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 40px 0 20px 0;
  flex-wrap: wrap;
  gap: 16px;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  margin: 0;
  color: #1f2937;
}

.section-stats {
  display: flex;
  gap: 16px;
  align-items: center;
}

.stats-item {
  font-size: 14px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 6px 12px;
  border-radius: 16px;
  font-weight: 500;
}

/* 分类网格 */
.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.category-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: center;
  border: 1px solid #e5e7eb;
}

.category-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #10b981;
}

.category-card.has-children {
  border-left: 4px solid #10b981;
  position: relative;
}

.category-card.has-children::before {
  content: '';
  position: absolute;
  top: 8px;
  right: 8px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #10b981;
}

.category-icon {
  margin-bottom: 16px;
  display: flex;
  justify-content: center;
}

.category-info {
  text-align: center;
}

.category-name {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: #1f2937;
}

.category-description {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 12px 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* 层级指示器 */
.level-indicator {
  position: absolute;
  top: 8px;
  left: 8px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  z-index: 1;
}

.level-badge {
  background: linear-gradient(135deg, #3b82f6, #1d4ed8);
  color: white;
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
}

.level-path {
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 6px;
  border-radius: 6px;
  font-size: 10px;
  max-width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.category-stats {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 6px;
  font-size: 12px;
}

.stat {
  padding: 4px 8px;
  border-radius: 12px;
  font-weight: 500;
  font-size: 11px;
}

.stat.primary {
  background: #ecfdf5;
  color: #047857;
}

.stat.secondary {
  background: #eff6ff;
  color: #1d4ed8;
}

.stat.children {
  background: #fef3c7;
  color: #92400e;
}

/* 子分类预览 */
.children-preview {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #e5e7eb;
  text-align: left;
}

.children-title {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 6px;
  font-weight: 500;
}

.children-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
}

.children-tags .n-tag {
  cursor: pointer;
  transition: all 0.2s ease;
}

.children-tags .n-tag:hover {
  transform: scale(1.05);
}

.more-indicator {
  font-size: 11px;
  color: #6b7280;
  font-weight: 500;
}

/* 加载和空状态 */
.loading-container {
  text-align: center;
  padding: 60px 0;
}

/* 树形视图 */
.categories-tree {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
  margin-bottom: 40px;
}

.tree-container {
  padding: 16px;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  color: #9ca3af;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }
  
  .page-title {
    font-size: 28px;
  }
  
  .search-section {
    flex-direction: column;
    gap: 12px;
  }
  
  .search-bar {
    width: 100%;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .section-stats {
    flex-wrap: wrap;
  }
  
  .categories-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 16px;
  }
  
  .category-card {
    padding: 16px;
  }
  
  .level-path {
    max-width: 150px;
  }
}

@media (max-width: 480px) {
  .categories-grid {
    grid-template-columns: 1fr;
  }
  
  .level-indicator {
    position: static;
    margin-bottom: 8px;
  }
  
  .level-path {
    max-width: none;
  }
}
</style> 