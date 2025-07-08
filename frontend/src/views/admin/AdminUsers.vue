<template>
  <div class="admin-users">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">用户管理</h1>
      <p class="page-subtitle">管理系统中的所有注册用户</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid" v-if="userStats">
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><PeopleOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ userStats.total_users || 0 }}</div>
          <div class="stat-label">用户总数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><CheckmarkCircleOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ userStats.active_users || 0 }}</div>
          <div class="stat-label">活跃用户</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><ShieldCheckmarkOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ userStats.superusers || 0 }}</div>
          <div class="stat-label">管理员</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><PauseCircleOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ userStats.inactive_users || 0 }}</div>
          <div class="stat-label">未激活</div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索用户名或邮箱..."
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
          v-model:value="statusFilter"
          placeholder="用户状态"
          clearable
          style="width: 120px"
          :options="statusOptions"
          @update:value="handleFilter"
        />
        
        <n-select
          v-model:value="roleFilter"
          placeholder="用户角色"
          clearable
          style="width: 120px"
          :options="roleOptions"
          @update:value="handleFilter"
        />
        
        <n-select
          v-model:value="sortBy"
          :options="sortOptions"
          style="width: 150px"
          @update:value="handleSort"
        />
        
        <n-button @click="handleRefresh" :loading="isLoadingUsers">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 用户数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="users"
        :loading="isLoadingUsers"
        :pagination="false"
        :remote="true"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
      />
      <admin-pagination
        :page="userPagination.page"
        :page-size="userPagination.pageSize"
        :item-count="userPagination.total"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>



    <!-- 编辑用户弹窗 -->
    <n-modal v-model:show="showEditModal" preset="dialog" title="编辑用户">
      <template #header>
        <div class="modal-header">
          <n-icon size="20"><CreateOutline /></n-icon>
          <span>编辑用户</span>
        </div>
      </template>
      
      <n-form
        v-if="editingUser"
        ref="editFormRef"
        :model="editingUser"
        :rules="formRules"
        label-placement="left"
        label-width="100"
        class="user-form"
        @submit.prevent="handleUpdateUser"
      >
        <n-form-item label="用户名" path="username">
          <n-input v-model:value="editingUser.username" disabled />
        </n-form-item>
        
        <n-form-item label="邮箱" path="email">
          <n-input v-model:value="editingUser.email" />
        </n-form-item>
        
        <n-form-item label="个人简介" path="bio">
          <n-input type="textarea" v-model:value="editingUser.bio" placeholder="输入个人简介..." />
        </n-form-item>
        
        <n-form-item label="部门" path="department_id">
          <n-select
            v-model:value="editingUser.department_id"
            :options="departmentOptions"
            placeholder="选择部门"
            clearable
          />
        </n-form-item>
        
        <n-form-item label="激活状态" path="is_active">
          <n-switch v-model:value="editingUser.is_active">
            <template #checked>激活</template>
            <template #unchecked>禁用</template>
          </n-switch>
        </n-form-item>
        
        <n-form-item label="管理员权限" path="is_superuser">
          <n-switch v-model:value="editingUser.is_superuser">
            <template #checked>管理员</template>
            <template #unchecked>普通用户</template>
          </n-switch>
        </n-form-item>
      </n-form>
      
      <template #action>
        <n-space>
          <n-button @click="showEditModal = false">取消</n-button>
          <n-button type="primary" @click="handleUpdateUser" :loading="isUpdating">
            保存
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
import { useAdminStore } from '@/stores/admin';
import { useDepartmentStore } from '@/stores/department';
import { storeToRefs } from 'pinia';
import { format } from 'date-fns';
import {
  NDataTable, NButton, NSpace, NTag, NInput, NSelect, NIcon,
  NSwitch, NModal, NForm, NFormItem, useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, CreateOutline, TrashOutline, KeyOutline,
  PeopleOutline, CheckmarkCircleOutline, ShieldCheckmarkOutline, PauseCircleOutline
} from '@vicons/ionicons5';
import { useAuthStore } from '@/stores/auth';
import AdminPagination from '@/components/common/AdminPagination.vue';

const adminStore = useAdminStore();
const authStore = useAuthStore();
const departmentStore = useDepartmentStore();

const { users, isLoadingUsers, userPagination, userStats } = storeToRefs(adminStore);
const { user: currentUser } = storeToRefs(authStore);
const { departments } = storeToRefs(departmentStore);

const dialog = useDialog();
const message = useMessage();

// 搜索和筛选
const searchQuery = ref('');
const statusFilter = ref(null);
const roleFilter = ref(null);
const sortBy = ref('created_at');
const isUpdating = ref(false);

// 弹窗状态
const showEditModal = ref(false);
const editingUser = ref(null);

// 计算部门选项
const departmentOptions = computed(() => 
  departments.value.map(d => ({ label: d.name, value: d.id }))
);

// 状态选项
const statusOptions = [
  { label: '已激活', value: 'active' },
  { label: '已禁用', value: 'inactive' }
];

// 角色选项
const roleOptions = [
  { label: '管理员', value: 'admin' },
  { label: '普通用户', value: 'user' }
];

// 排序选项
const sortOptions = [
  { label: '最新注册', value: 'created_at' },
  { label: '按用户名', value: 'username' },
  { label: '按部门', value: 'department' }
];

// 表单验证规则
const formRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: ['input', 'blur'] },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: ['input', 'blur'] }
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
    title: '用户名',
    key: 'username',
    width: 120,
    render(row) {
      return h(
        'div',
        { 
          class: 'username-cell',
          style: 'font-weight: 600; line-height: 1.2;'
        },
        row.username
      );
    }
  },
  { 
    title: '部门', 
    key: 'department.name',
    width: 100,
    render(row) {
      return row.department ? h(NTag, { type: 'info' }, { default: () => row.department.name }) : '未分配';
    }
  },
  { 
    title: '角色', 
    key: 'is_superuser',
    width: 80,
    render(row) {
      return h(
        NTag,
        { type: row.is_superuser ? 'success' : 'info' },
        { default: () => (row.is_superuser ? '管理员' : '用户') }
      );
    }
  },
  { 
    title: '状态', 
    key: 'is_active',
    width: 80,
    render(row) {
      return h(
        NTag,
        { type: row.is_active ? 'success' : 'error' },
        { default: () => (row.is_active ? '激活' : '禁用') }
      );
    }
  },
  {
    title: '注册时间',
    key: 'created_at',
    width: 140,
    render(row) {
      return row.created_at ? format(new Date(row.created_at), 'yyyy-MM-dd HH:mm') : '未知';
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 220,
    render(row) {
      const isSelf = currentUser.value?.id === row.id;
      return h(NSpace, { 
        size: 'small',
        style: { 
          display: 'flex', 
          flexWrap: 'nowrap',
          justifyContent: 'flex-start'
        } 
      }, {
        default: () => [
          h(NButton, { 
            size: 'small', 
            type: 'primary',
            ghost: true,
            onClick: () => openEditModal(row),
            style: {
              height: '28px',
              padding: '0 8px',
              fontSize: '12px',
              minWidth: '50px'
            }
          }, { 
            default: () => '编辑',
            icon: () => h(NIcon, { size: 12 }, { default: () => h(CreateOutline) })
          }),
          h(NButton, { 
            size: 'small', 
            type: 'warning', 
            disabled: isSelf, 
            onClick: () => handleResetPassword(row),
            style: {
              height: '28px',
              padding: '0 6px',
              fontSize: '12px',
              minWidth: '70px'
            }
          }, { 
            default: () => '重置密码',
            icon: () => h(NIcon, { size: 12 }, { default: () => h(KeyOutline) })
          }),
          h(NButton, { 
            size: 'small', 
            type: 'error', 
            disabled: isSelf, 
            onClick: () => handleDelete(row),
            style: {
              height: '28px',
              padding: '0 8px',
              fontSize: '12px',
              minWidth: '50px'
            }
          }, { 
            default: () => '删除',
            icon: () => h(NIcon, { size: 12 }, { default: () => h(TrashOutline) })
          }),
        ],
      });
    },
  },
];

// 事件处理
function openEditModal(user) {
  editingUser.value = { 
    ...user, 
    bio: user.bio || '',
    department_id: user.department?.id || null
  };
  showEditModal.value = true;
}

async function handleUpdateUser() {
  if (!editingUser.value) return;
  
  isUpdating.value = true;
  try {
    const { id, ...updateData } = editingUser.value;
    
    const payload = {
      username: updateData.username,
      email: updateData.email,
      is_active: updateData.is_active,
      is_superuser: updateData.is_superuser,
      bio: updateData.bio,
      department_id: updateData.department_id,
    };
    
    await adminStore.updateUser(id, payload);
    message.success('用户更新成功');
    showEditModal.value = false;
    await adminStore.fetchUserStats();
  } catch (error) {
    message.error('更新失败：' + (error.message || '未知错误'));
  } finally {
    isUpdating.value = false;
  }
}

function handleDelete(user) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除用户 "${user.username}" 吗？此操作不可逆。`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await adminStore.deleteUser(user.id);
        message.success('用户删除成功');
        await adminStore.fetchUserStats();
      } catch (error) {
        message.error('删除失败：' + (error.message || '未知错误'));
      }
    },
  });
}

function handleResetPassword(user) {
  dialog.warning({
    title: '确认重置密码',
    content: `你确定要为用户 "${user.username}" 重置密码吗？新密码将随机生成。`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        const newPassword = await adminStore.resetUserPassword(user.id);
        dialog.success({
          title: '密码已重置',
          content: `用户 "${user.username}" 的新密码是： ${newPassword}`,
          positiveText: '好的'
        });
      } catch (error) {
        message.error('重置失败：' + (error.message || '未知错误'));
      }
    },
  });
}

// 创建防抖搜索函数
const debouncedSearch = debounce(() => {
  fetchUsersWithFilters(1);
}, 300);

// 获取用户列表（带筛选参数）
function fetchUsersWithFilters(page = userPagination.value.page) {
  const filters = {
    search: searchQuery.value.trim(),
    status: statusFilter.value,
    role: roleFilter.value,
    sort: sortBy.value,
    order: 'desc'
  };
  
  adminStore.fetchUsers(page, userPagination.value.pageSize, filters);
}

function handleFilter() {
  fetchUsersWithFilters(1);
}

function handleSort() {
  fetchUsersWithFilters(userPagination.value.page);
}

function handleRefresh() {
  Promise.all([
    fetchUsersWithFilters(userPagination.value.page),
    adminStore.fetchUserStats()
  ]);
}

// 监听搜索输入变化
watch(searchQuery, () => {
  debouncedSearch();
});

// 监听筛选条件变化
watch([statusFilter, roleFilter], () => {
  fetchUsersWithFilters(1);
});

// 分页事件处理
function handlePageChange(page) {
  fetchUsersWithFilters(page);
}

function handlePageSizeChange(pageSize) {
  fetchUsersWithFilters(1);
}

// 生命周期
onMounted(async () => {
  await Promise.all([
    adminStore.fetchUsers(),
    departmentStore.fetchDepartments()
  ]);
});
</script>

<style scoped>
.admin-users {
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
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
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

.username-cell {
  font-weight: 600;
  color: #1f2937;
}



.modal-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.user-form {
  margin: 16px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-users {
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