<template>
  <div class="admin-comments">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">评论管理</h1>
      <p class="page-subtitle">管理系统中的所有用户评论</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid" v-if="commentStats">
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><ChatbubblesOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ commentStats.total_comments || 0 }}</div>
          <div class="stat-label">总评论数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><TodayOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ commentStats.today_comments || 0 }}</div>
          <div class="stat-label">今日评论</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><LayersOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ commentPagination.total || 0 }}</div>
          <div class="stat-label">总评论数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><FolderOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ getActiveUsersCount() }}</div>
          <div class="stat-label">活跃评论者</div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索评论内容或用户名..."
          clearable
          style="width: 300px"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <n-icon><SearchOutline /></n-icon>
          </template>
        </n-input>
        <n-button @click="handleSearch" type="primary" ghost>
          <template #icon>
            <n-icon><SearchOutline /></n-icon>
          </template>
          搜索
        </n-button>
      </div>
      
      <div class="toolbar-right">
        <n-select
          v-model:value="sortBy"
          :options="sortOptions"
          style="width: 150px"
          @update:value="handleSort"
        />
        
        <n-button @click="handleRefresh" :loading="isLoadingComments">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 评论数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="comments"
        :loading="isLoadingComments"
        :pagination="false"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
      />
      <admin-pagination
        :page="commentPagination.page"
        :page-size="commentPagination.pageSize"
        :item-count="commentPagination.total"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>


  </div>
</template>

<script setup>
import { ref, onMounted, h, computed } from 'vue';
import { useAdminStore } from '@/stores/admin';
import { storeToRefs } from 'pinia';
import { format } from 'date-fns';
import {
  NDataTable, NButton, NTag, NInput, NSelect, NIcon, 
  NSpace, useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, TrashOutline, ChatbubblesOutline,
  TodayOutline, LayersOutline, FolderOutline
} from '@vicons/ionicons5';
import AdminPagination from '@/components/common/AdminPagination.vue';

const adminStore = useAdminStore();
const { comments, isLoadingComments, commentPagination, commentStats } = storeToRefs(adminStore);

const dialog = useDialog();
const message = useMessage();

// 计算总页数
const pageCount = computed(() => {
  return Math.ceil(commentPagination.value.total / commentPagination.value.pageSize);
});

// 搜索和筛选
const searchQuery = ref('');
const sortBy = ref('created_at');

// 排序选项
const sortOptions = [
  { label: '最新评论', value: 'created_at' },
  { label: '按用户', value: 'owner_id' }
];

// 统计计算
const getActiveUsersCount = () => {
  if (!commentStats.value?.top_commenters) return 0;
  return commentStats.value.top_commenters.length;
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
    title: '评论用户',
    key: 'owner',
    width: 100,
    render(row) {
      return h('div', { 
        class: 'user-info',
        style: 'font-weight: 600; line-height: 1.2;' 
      }, row.owner?.username || '未知用户');
    }
  },
  {
    title: '评论内容',
    key: 'content',
    width: 400,
    render(row) {
      const maxLength = 120;
      const content = row.content || '';
      const truncated = content.length > maxLength ? content.substring(0, maxLength) + '...' : content;
      
      return h('div', { 
        class: 'comment-content',
        style: 'word-break: break-word; line-height: 1.4;',
        title: content // 完整内容作为tooltip
      }, truncated);
    }
  },
  {
    title: '评论时间',
    key: 'created_at',
    width: 140,
    sorter: (a, b) => new Date(a.created_at) - new Date(b.created_at),
    render(row) {
      return format(new Date(row.created_at), 'yyyy-MM-dd HH:mm');
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 80,
    render(row) {
      return h(NButton, {
        size: 'small',
        type: 'error',
        ghost: true,
        onClick: () => handleDelete(row),
        style: {
          height: '28px',
          padding: '0 12px',
          fontSize: '12px'
        }
      }, { 
        default: () => '删除',
        icon: () => h(NIcon, { size: 14 }, { default: () => h(TrashOutline) })
      });
    }
  }
];

// 事件处理函数
function handleSearch() {
  const filters = {};
  if (searchQuery.value.trim()) {
    filters.search = searchQuery.value.trim();
  }
  adminStore.fetchComments(1, commentPagination.value.pageSize, filters);
}

function handleSort() {
  const filters = {};
  if (searchQuery.value.trim()) {
    filters.search = searchQuery.value.trim();
  }
  if (sortBy.value) {
    filters.sort = sortBy.value;
    filters.order = 'desc';
  }
  adminStore.fetchComments(1, commentPagination.value.pageSize, filters);
}

function handleRefresh() {
  Promise.all([
    adminStore.fetchComments(commentPagination.value.page, commentPagination.value.pageSize),
    adminStore.fetchCommentStats()
  ]);
}

function handlePageChange(page) {
  const filters = {};
  if (searchQuery.value.trim()) {
    filters.search = searchQuery.value.trim();
  }
  adminStore.fetchComments(page, commentPagination.value.pageSize, filters);
}

function handlePageSizeChange(pageSize) {
  const filters = {};
  if (searchQuery.value.trim()) {
    filters.search = searchQuery.value.trim();
  }
  adminStore.fetchComments(1, pageSize, filters);
}

function handleDelete(comment) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除用户 "${comment.owner?.username}" 的这条评论吗？此操作不可撤销。`,
    positiveText: '确定删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await adminStore.deleteComment(comment.id);
        message.success('评论删除成功');
        // 刷新统计数据
        await adminStore.fetchCommentStats();
      } catch (error) {
        message.error('评论删除失败：' + (error.message || '未知错误'));
      }
    }
  });
}

// 生命周期
onMounted(async () => {
  await Promise.all([
    adminStore.fetchComments(),
    adminStore.fetchCommentStats()
  ]);
});
</script>

<style scoped>
.admin-comments {
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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



/* 响应式设计 */
@media (max-width: 768px) {
  .admin-comments {
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