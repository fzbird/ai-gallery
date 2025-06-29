<template>
  <div class="admin-categories">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">分类管理</h1>
      <p class="page-subtitle">管理系统中的所有图集分类</p>
    </div>



    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索分类名称、描述或路径..."
          clearable
          style="width: 300px"
        >
          <template #prefix>
            <n-icon><SearchOutline /></n-icon>
          </template>
        </n-input>
      </div>
      
      <div class="toolbar-right">
        <n-select
          v-model:value="sortBy"
          :options="sortOptions"
          style="width: 150px"
          @update:value="handleSort"
        />
        
        <n-button @click="openAddModal" type="primary">
          <template #icon>
            <n-icon><AddOutline /></n-icon>
          </template>
          新建分类
        </n-button>
        
        <n-button @click="handleRefresh" :loading="isLoadingCategories">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 分类数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="categoryTreeData"
        :loading="isLoadingCategories"
        :pagination="false"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
        :scroll-x="1150"
      />
      <!-- 分类管理不使用分页，因为分类数量通常较少 -->
      <div class="table-info">
        <span class="table-summary">
          显示 {{ categoryTreeData.length }} / {{ categories.length }} 个分类，包含 {{ categories.filter(c => c.level === 0).length }} 个根分类
          <span v-if="searchQuery.trim()" style="color: #007bff; margin-left: 8px;">
            (已过滤)
          </span>
        </span>
      </div>
    </div>



    <!-- 新建分类弹窗 -->
    <n-modal v-model:show="showModal" preset="dialog" title="分类管理">
      <template #header>
        <div class="modal-header">
          <n-icon size="20">
            <component :is="isEditing ? CreateOutline : AddOutline" />
          </n-icon>
          <span>{{ isEditing ? '编辑分类' : '新建分类' }}</span>
        </div>
      </template>
      
      <n-form
        ref="formRef"
        :model="currentCategory"
        :rules="formRules"
        label-placement="left"
        label-width="100"
        class="category-form"
      >
        <n-form-item label="分类名称" path="name">
          <n-input v-model:value="currentCategory.name" placeholder="请输入分类名称" />
        </n-form-item>
        
        <n-form-item label="父分类" path="parent_id">
          <n-select
            v-model:value="currentCategory.parent_id"
            :options="parentCategoryOptions"
            placeholder="选择父分类（留空为根分类）"
            clearable
            filterable
          />
        </n-form-item>
        
        <n-form-item label="排序权重" path="sort_order">
          <n-input-number
            v-model:value="currentCategory.sort_order"
            placeholder="数字越小排序越靠前"
            :min="0"
            :max="999"
            style="width: 100%"
          />
        </n-form-item>
        
        <n-form-item label="分类描述" path="description">
          <n-input
            v-model:value="currentCategory.description"
            type="textarea"
            placeholder="请输入分类描述"
            :rows="3"
          />
        </n-form-item>
      </n-form>
      
      <template #action>
        <n-space>
          <n-button @click="showModal = false">取消</n-button>
          <n-button type="primary" @click="handleSave" :loading="isSubmitting">
            {{ isEditing ? '保存' : '创建' }}
          </n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { h, onMounted, ref, computed } from 'vue';
import { useAdminStore } from '@/stores/admin';
import { storeToRefs } from 'pinia';
import { categories as categoriesAPI } from '@/api/api';

import {
  NDataTable, NButton, NSpace, NTag, NInput, NSelect, NIcon,
  NModal, NForm, NFormItem, NInputNumber, useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, CreateOutline, TrashOutline,
  AddOutline, FolderOpenOutline, DocumentTextOutline
} from '@vicons/ionicons5';
import AdminPagination from '@/components/common/AdminPagination.vue';

const adminStore = useAdminStore();
const { categories, isLoadingCategories, categoryPagination } = storeToRefs(adminStore);

const dialog = useDialog();
const message = useMessage();

// 搜索和筛选
const searchQuery = ref('');
const sortBy = ref('name');
const isSubmitting = ref(false);

// 分类统计数据
const categoryCounts = ref({});

// 弹窗状态
const showModal = ref(false);
const isEditing = ref(false);
const currentCategory = ref({
  name: '',
  description: '',
  parent_id: null,
  sort_order: 0,
});

// 表单验证规则
const formRules = {
  name: [
    { required: true, message: '请输入分类名称', trigger: ['input', 'blur'] },
    { min: 2, max: 50, message: '分类名称长度应在2-50字符之间', trigger: ['input', 'blur'] }
  ]
};

// 排序选项
const sortOptions = [
  { label: '按名称', value: 'name' },
  { label: '按层级', value: 'level' },
  { label: '按图集数量', value: 'gallery_count' }
];

// 树形表格展示
const showTreeView = ref(false);

// 表格列定义
const columns = computed(() => {
  const baseColumns = [
    {
      title: 'ID',
      key: 'id',
      width: 60,
      sorter: 'default',
      fixed: 'left'
    },
    {
      title: '分类名称',
      key: 'name',
      width: 100,
      sorter: 'default',
      render(row) {
        const getIconColor = (level) => {
          const colors = ['#3b82f6', '#10b981', '#f97316', '#ef4444', '#8b5cf6'];
          return colors[level % colors.length];
        };

        return h(
          'div',
          { class: 'category-name-cell' },
          [
            h(NIcon, {
              size: 18,
              color: getIconColor(row.level || 0),
              style: { marginRight: '4px' }
            }, {
              default: () => row.children && row.children.length > 0
                ? h(FolderOpenOutline)
                : h(DocumentTextOutline)
            }),
            h('span', { class: 'category-name' }, row.name),
            row.level > 0 && h('span', { class: 'category-level' }, `L${row.level}`)
          ]
        );
      }
    },
    {
      title: '分类描述',
      key: 'description',
      width: 200,
      ellipsis: {
        tooltip: { class: 'light-tooltip' }
      },
      render(row) {
        const description = row.description || '暂无描述';
        return h('span', { class: 'category-description' }, description);
      }
    },
    {
      title: '内容数量',
      key: 'content_count',
      width: 80,
      render(row) {
        const directCount = row.content_count || 0;
        const totalCount = row.all_content_count || 0;
        
        return h(
          'div',
          { class: 'content-count-cell' },
          [
            h(NTag, { type: 'success', size: 'small' }, { default: () => `${directCount}` }),
            totalCount > directCount && h(
              NTag, 
              { type: 'info', size: 'small', style: { marginLeft: '4px' } }, 
              { default: () => `总计: ${totalCount}` }
            )
          ]
        );
      }
    },
    {
      title: '操作',
      key: 'actions',
      width: 100,
      fixed: 'right',
      render(row) {
        return h(
          NSpace,
          { size: 'small' },
          {
            default: () => [
              h(NButton, { size: 'small', type: 'primary', ghost: true, onClick: () => openEditModal(row) }, { default: () => '编辑' }),
              h(NButton, { size: 'small', type: 'info', ghost: true, onClick: () => openAddChildModal(row) }, { default: () => '添加子分类' }),
              h(NButton, { size: 'small', type: 'error', ghost: true, onClick: () => handleDelete(row) }, { default: () => '删除' })
            ]
          }
        );
      }
    }
  ];
  
  return baseColumns;
});

// 获取分类图集数量
const getCategoryGalleryCount = (categoryId) => {
  return categoryCounts.value[categoryId] || 0;
};

// 搜索和排序后的分类列表
const filteredAndSortedCategories = computed(() => {
  let result = [...categories.value];
  
  // 应用搜索过滤
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim();
    result = result.filter(cat => 
      cat.name.toLowerCase().includes(query) ||
      (cat.description && cat.description.toLowerCase().includes(query)) ||
      (cat.full_path && cat.full_path.toLowerCase().includes(query))
    );
  }
  
  // 应用排序
  switch (sortBy.value) {
    case 'name':
      result.sort((a, b) => a.name.localeCompare(b.name, 'zh-CN'));
      break;
    case 'level':
      result.sort((a, b) => {
        // 先按层级排序，同层级再按名称排序
        if (a.level !== b.level) {
          return a.level - b.level;
        }
        return a.name.localeCompare(b.name, 'zh-CN');
      });
      break;
    case 'gallery_count':
      result.sort((a, b) => {
        const countA = a.content_count || 0;
        const countB = b.content_count || 0;
        // 按图集数量倒序排列
        if (countA !== countB) {
          return countB - countA;
        }
        // 数量相同时按名称排序
        return a.name.localeCompare(b.name, 'zh-CN');
      });
      break;
    default:
      // 默认按ID排序
      result.sort((a, b) => a.id - b.id);
  }
  
  return result;
});

// 将扁平列表转换为树形结构
const categoryTreeData = computed(() => {
  const list = filteredAndSortedCategories.value;
  const map = {};
  const roots = [];

  // 首先，将所有项放入map中，并初始化children数组
  for (const item of list) {
    map[item.id] = { ...item, children: [] };
  }

  // 然后，遍历map，将每个项放入其父项的children数组中
  for (const id in map) {
    const item = map[id];
    if (item.parent_id && map[item.parent_id]) {
      map[item.parent_id].children.push(item);
    } else {
      roots.push(item);
    }
  }
  
  // 如果有搜索过滤，可能导致父节点被过滤掉，这里做一个兼容处理
  // 如果一个节点的父节点不在map里，也把它当作根节点
  if (searchQuery.value.trim()) {
    const allNodes = Object.values(map);
    const visibleIds = new Set(allNodes.map(n => n.id));
    return allNodes.filter(node => !node.parent_id || !visibleIds.has(node.parent_id));
  }

  return roots;
});

// 父分类选项（排除当前编辑的分类及其子分类）
const parentCategoryOptions = computed(() => {
  const currentId = currentCategory.value.id;
  
  return categories.value
    .filter(cat => {
      // 如果是编辑模式，排除自己和自己的后代
      if (isEditing.value && currentId) {
        if (cat.id === currentId) return false;
        // 这里可能需要更复杂的逻辑来排除后代分类
      }
      return true;
    })
    .map(cat => ({
      label: cat.full_path || cat.name,
      value: cat.id,
      disabled: cat.id === currentId
    }));
});

// 加载分类下的图集数量
async function loadCategoryCounts() {
  try {
    // 调用API获取每个分类下的图集数量
    const response = await categoriesAPI.getCategoryStats();
    const stats = response.data || {};
    
    // 转换数据格式：从数组转为以ID为键的对象
    if (stats.category_gallery_stats && Array.isArray(stats.category_gallery_stats)) {
      const countsMap = {};
      stats.category_gallery_stats.forEach(item => {
        countsMap[item.id] = item.gallery_count;
      });
      categoryCounts.value = countsMap;
    } else {
      categoryCounts.value = {};
    }
  } catch (error) {
    console.error('加载分类统计失败:', error);
    // 如果API调用失败，使用默认值
    categoryCounts.value = {};
  }
}

// 事件处理
function openAddModal() {
  isEditing.value = false;
  currentCategory.value = { name: '', description: '', parent_id: null, sort_order: 0 };
  showModal.value = true;
}

function openEditModal(category) {
  isEditing.value = true;
  currentCategory.value = { ...category };
  showModal.value = true;
}

function openAddChildModal(parentCategory) {
  isEditing.value = false;
  currentCategory.value = { 
    name: '', 
    description: '', 
    parent_id: parentCategory.id, 
    sort_order: 0 
  };
  showModal.value = true;
}

async function handleSave() {
  isSubmitting.value = true;
  try {
    if (isEditing.value) {
      await adminStore.updateCategory(currentCategory.value.id, currentCategory.value);
      message.success('分类更新成功');
    } else {
      await adminStore.createCategory(currentCategory.value);
      message.success('分类创建成功');
    }
    showModal.value = false;
    await loadCategoryCounts(); // 重新加载统计数据
  } catch (error) {
    message.error('操作失败：' + (error.message || '未知错误'));
  } finally {
    isSubmitting.value = false;
  }
}

function handleDelete(category) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除分类 "${category.name}" 吗？此操作将影响相关图集。`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await adminStore.deleteCategory(category.id);
        message.success('分类删除成功');
        await loadCategoryCounts(); // 重新加载统计数据
      } catch (error) {
        message.error('删除失败：' + (error.message || '未知错误'));
      }
    }
  });
}

function handleSearch() {
  // 搜索功能现在通过计算属性 filteredAndSortedCategories 自动处理
}

function handleSort() {
  // 排序功能现在通过计算属性 filteredAndSortedCategories 自动处理
}

function handleRefresh() {
  adminStore.fetchCategories();
  loadCategoryCounts(); // 同时刷新分类统计
}

function handlePageChange(page) {
  // 由于分类不再使用分页，此函数暂时保留但不执行任何操作
}

function handlePageSizeChange(pageSize) {
  // 由于分类不再使用分页，此函数暂时保留但不执行任何操作
}

// 生命周期
onMounted(async () => {
  await adminStore.fetchCategories();
  await loadCategoryCounts(); // 加载分类统计数据
});
</script>

<style scoped>
.admin-categories {
  padding: 24px;
  background-color: #f8fafc;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.page-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.toolbar-left {
  display: flex;
  gap: 12px;
  align-items: center;
}

.toolbar-right {
  display: flex;
  gap: 12px;
  align-items: center;
}

.table-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  margin-bottom: 24px;
}

.admin-table :deep(.n-data-table-th) {
  background: #f8fafc;
  font-weight: 600;
}

.admin-table :deep(.n-data-table-td) {
  padding: 8px 12px !important;
}

.admin-table :deep(.n-data-table-tr) {
  height: 48px;
}

.category-name-cell {
  display: flex;
  align-items: center;
  gap: 6px;
}

.category-level {
  font-size: 11px;
  font-weight: 600;
  padding: 1px 5px;
  border-radius: 4px;
  background-color: #eef2ff;
  color: #4f46e5;
  margin-left: 8px;
}

.admin-table :deep(td) {
  vertical-align: middle;
  padding-top: 12px !important;
  padding-bottom: 12px !important;
}

.admin-table :deep(tbody tr) {
  border-bottom: 1px solid #f1f5f9;
  transition: background-color 0.2s;
}

.admin-table :deep(tbody tr:hover) {
  background-color: #f8fafc;
}

.category-name {
  flex: 1;
  font-weight: 600;
  color: #1f2937;
}

.category-description {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
}

/* 操作按钮样式优化 */
.admin-table :deep(.n-space) {
  flex-wrap: nowrap !important;
  gap: 4px !important;
}

.admin-table :deep(.n-button--small) {
  padding: 0 8px !important;
  font-size: 12px !important;
  height: 24px !important;
}

.stats-section {
  background: white;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stats-section h3 {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.table-info {
  padding: 12px 16px;
  background: #f8fafc;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 16px;
  color: #64748b;
  font-size: 14px;
}

.table-summary {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.category-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.category-stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 6px;
}

.rank {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
}

.modal-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.category-form {
  margin: 16px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-categories {
    padding: 16px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .toolbar {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .toolbar-left,
  .toolbar-right {
    justify-content: center;
  }
}
</style>

<style>
/* 
  使用自定义类为 Tooltip 应用浅色主题。
  这个类通过列定义中的 ellipsis.tooltip.class 传递。
*/
.light-tooltip.n-tooltip {
  background-color: #f1f5f9 !important;
  color: #334155 !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1) !important;
}

.light-tooltip.n-tooltip .n-tooltip-arrow {
  background-color: #f1f5f9 !important;
  border-top: 1px solid #e2e8f0 !important;
  border-left: 1px solid #e2e8f0 !important;
}
</style> 