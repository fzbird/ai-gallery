<template>
  <div class="admin-departments">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">部门管理</h1>
      <p class="page-subtitle">管理组织结构中的所有部门</p>
    </div>



    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索部门名称..."
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
          新建部门
        </n-button>
        
        <n-button @click="handleRefresh" :loading="isLoading">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 部门数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="departments"
        :loading="isLoading"
        :pagination="false"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
      />
      <admin-pagination
        :page="departmentPagination.page"
        :page-size="departmentPagination.pageSize"
        :item-count="departmentPagination.total"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>



    <!-- 新建/编辑部门弹窗 -->
    <n-modal v-model:show="showModal" preset="dialog" title="部门管理">
      <template #header>
        <div class="modal-header">
          <n-icon size="20">
            <component :is="isEditing ? CreateOutline : AddOutline" />
          </n-icon>
          <span>{{ isEditing ? '编辑部门' : '新建部门' }}</span>
        </div>
      </template>
      
      <n-form
        ref="formRef"
        :model="editingDepartment"
        :rules="formRules"
        label-placement="left"
        label-width="100"
        class="department-form"
      >
        <n-form-item label="部门名称" path="name">
          <n-input 
            v-model:value="editingDepartment.name" 
            placeholder="请输入部门名称" 
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
import { h, onMounted, ref, computed, watch } from 'vue';

// 简单的防抖函数实现
function debounce(func, delay) {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
}
import { useDepartmentStore } from '@/stores/department';
import { useAdminStore } from '@/stores/admin';
import { storeToRefs } from 'pinia';

import {
  NDataTable, NButton, NSpace, NTag, NInput, NSelect, NIcon,
  NModal, NForm, NFormItem, useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, CreateOutline, TrashOutline,
  AddOutline
} from '@vicons/ionicons5';
import AdminPagination from '@/components/common/AdminPagination.vue';

const departmentStore = useDepartmentStore();
const { departments, isLoading, departmentPagination } = storeToRefs(departmentStore);

const dialog = useDialog();
const message = useMessage();

// 搜索和筛选
const searchQuery = ref('');
const sortBy = ref('name');
const isSubmitting = ref(false);

// 弹窗状态
const showModal = ref(false);
const isEditing = ref(false);
const editingDepartment = ref({ id: null, name: '' });

// 排序选项
const sortOptions = [
  { label: '按名称', value: 'name' },
  { label: '按用户数量', value: 'user_count' }
];

// 表单验证规则
const formRules = {
  name: [
    { required: true, message: '请输入部门名称', trigger: ['input', 'blur'] },
    { min: 2, max: 50, message: '部门名称长度应在2-50字符之间', trigger: ['input', 'blur'] }
  ]
};

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 60,
    sorter: 'default'
  },
  {
    title: '部门名称',
    key: 'name',
    width: 200,
    sorter: 'default',
    render(row) {
      return h(
        'div',
        { class: 'department-name-cell-compact' },
        row.name
      );
    }
  },
  {
    title: '用户数量',
    key: 'user_count',
    width: 100,
    render(row) {
      const count = getDepartmentUserCount(row);
      return h(
        NTag,
        { type: count > 0 ? 'success' : 'default' },
        { default: () => `${count} 位` }
      );
    }
  },
  {
    title: '图集数量',
    key: 'gallery_count',
    width: 100,
    render(row) {
      const count = getDepartmentGalleryCount(row.id);
      return h(
        NTag,
        { type: count > 0 ? 'info' : 'default' },
        { default: () => `${count} 个` }
      );
    }
  },

  {
    title: '操作',
    key: 'actions',
    width: 150,
    render(row) {
      return h(NSpace, { 
        size: 'small',
        style: { 
          display: 'flex', 
          flexWrap: 'nowrap' 
        } 
      }, {
        default: () => [
          h(NButton, { 
            size: 'small', 
            type: 'primary',
            ghost: true,
            onClick: () => openEditModal(row),
            style: {
              padding: '0 12px',
              height: '28px',
              fontSize: '12px',
              minWidth: '65px'
            }
          }, { 
            default: () => '编辑',
            icon: () => h(NIcon, { size: 14 }, { default: () => h(CreateOutline) })
          }),
          h(NButton, { 
            size: 'small', 
            type: 'error',
            onClick: () => handleDelete(row),
            style: {
              padding: '0 12px',
              height: '28px',
              fontSize: '12px',
              minWidth: '65px'
            }
          }, { 
            default: () => '删除',
            icon: () => h(NIcon, { size: 14 }, { default: () => h(TrashOutline) })
          }),
        ],
      });
    },
  },
];

// 简化的统计方法（仅保留表格显示需要的）
const getDepartmentUserCount = (department) => {
  return department.users ? department.users.length : 0;
};

const getDepartmentGalleryCount = (departmentId) => {
  // 这里可以根据需要从其他地方获取数据，或者返回默认值
  return 0;
};

// 事件处理
function openAddModal() {
  isEditing.value = false;
  editingDepartment.value = { id: null, name: '' };
  showModal.value = true;
}

function openEditModal(department) {
  isEditing.value = true;
  editingDepartment.value = { ...department };
  showModal.value = true;
}

async function handleSave() {
  if (!editingDepartment.value.name.trim()) {
    message.error('部门名称不能为空');
    return;
  }

  isSubmitting.value = true;
  try {
    if (isEditing.value) {
      await departmentStore.updateDepartment(editingDepartment.value.id, editingDepartment.value.name);
      message.success('部门更新成功！');
    } else {
      await departmentStore.createDepartment(editingDepartment.value.name);
      message.success('部门创建成功！');
    }
    showModal.value = false;
  } catch (error) {
    message.error('操作失败：' + (error.message || '请稍后重试'));
  } finally {
    isSubmitting.value = false;
  }
}

function handleDelete(department) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除部门 "${department.name}" 吗？此操作将影响相关用户。`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await departmentStore.deleteDepartment(department.id);
        message.success('部门删除成功！');
      } catch (error) {
        message.error(error.response?.data?.detail || '删除失败，可能有关联用户。');
      }
    },
  });
}

// 创建防抖搜索函数
const debouncedSearch = debounce(() => {
  fetchDepartmentsWithFilters(1);
}, 300);

// 获取部门列表（带筛选参数）
function fetchDepartmentsWithFilters(page = departmentPagination.value.page) {
  const filters = {
    search: searchQuery.value.trim(),
    sort: sortBy.value,
    order: 'asc'
  };
  
  departmentStore.fetchDepartments(page, departmentPagination.value.pageSize, filters);
}

function handleSort() {
  fetchDepartmentsWithFilters(departmentPagination.value.page);
}

function handleRefresh() {
  fetchDepartmentsWithFilters(departmentPagination.value.page);
}

// 监听搜索输入变化
watch(searchQuery, () => {
  debouncedSearch();
});

// 分页事件处理
function handlePageChange(page) {
  fetchDepartmentsWithFilters(page);
}

function handlePageSizeChange(pageSize) {
  fetchDepartmentsWithFilters(1);
}

// 生命周期
onMounted(async () => {
  await departmentStore.fetchDepartments();
});
</script>

<style scoped>
.admin-departments {
  padding: 24px;
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
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
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

.department-name-cell-compact {
  font-weight: 600;
  color: #1f2937;
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

.department-user-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.department-stat-item {
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
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
}

.department-name {
  flex: 1;
  font-weight: 600;
  color: #1f2937;
}

.user-count,
.gallery-count {
  color: #6b7280;
  font-size: 14px;
  min-width: 80px;
}

.modal-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.department-form {
  margin: 16px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-departments {
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
  
  .department-stat-item {
    flex-wrap: wrap;
  }
  
  .user-count,
  .gallery-count {
    min-width: 60px;
  }
}
</style> 