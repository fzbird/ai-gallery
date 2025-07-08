<template>
  <div class="admin-galleries">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">图集管理</h1>
      <p class="page-subtitle">管理系统中的所有图集内容</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid" v-if="galleryStats">
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><FolderOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ galleryStats.total_galleries || 0 }}</div>
          <div class="stat-label">图集总数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><EyeOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ galleryStats.published_galleries || 0 }}</div>
          <div class="stat-label">已发布</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><ArchiveOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ galleryStats.draft_galleries || 0 }}</div>
          <div class="stat-label">草稿箱</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><ImageOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ galleryStats.total_images || 0 }}</div>
          <div class="stat-label">图片总数</div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索图集标题、描述..."
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
          v-model:value="categoryFilter"
          placeholder="按分类筛选"
          clearable
          style="width: 180px"
          :options="categories.map(cat => ({ label: cat.name, value: cat.id }))"
          @update:value="handleFilter"
        />
        
        <n-select
          v-model:value="sortBy"
          :options="sortOptions"
          style="width: 150px"
          @update:value="handleSort"
        />
        
        <n-button @click="handleRefresh" :loading="isLoadingGalleries">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 图集数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="galleries"
        :loading="isLoadingGalleries"
        :pagination="false"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
      />
      <admin-pagination
        :page="galleryPagination.page"
        :page-size="galleryPagination.pageSize"
        :item-count="galleryPagination.total"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>



    <!-- 图集编辑弹窗 -->
    <n-modal v-model:show="showEditModal" preset="dialog" title="编辑图集">
      <template #header>
        <div class="modal-header">
          <n-icon size="20"><CreateOutline /></n-icon>
          <span>编辑图集</span>
        </div>
      </template>
      
      <n-form
        ref="editFormRef"
        :model="editForm"
        :rules="editRules"
        label-placement="left"
        label-width="80"
        class="edit-form"
      >
        <n-form-item label="标题" path="title">
          <n-input v-model:value="editForm.title" placeholder="请输入图集标题" />
        </n-form-item>
        
        <n-form-item label="描述" path="description">
          <n-input
            v-model:value="editForm.description"
            type="textarea"
            placeholder="请输入图集描述"
            :rows="3"
          />
        </n-form-item>
        
        <n-form-item label="分类" path="category_id">
          <n-select
            v-model:value="editForm.category_id"
            placeholder="选择分类"
            clearable
            :options="categories.map(cat => ({ label: cat.name, value: cat.id }))"
          />
        </n-form-item>
      </n-form>
      
      <template #action>
        <n-space>
          <n-button @click="showEditModal = false">取消</n-button>
          <n-button type="primary" @click="handleSaveEdit" :loading="isSaving">
            保存
          </n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, h, watch } from 'vue';

// 简单的防抖函数实现
function debounce(func, delay) {
  let timeoutId;
  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
}
import { useAdminStore } from '@/stores/admin';
import { useCategoryStore } from '@/stores/category';
import { storeToRefs } from 'pinia';
import { format } from 'date-fns';
import {
  NDataTable, NButton, NImage, NTag, NInput, NSelect, 
  NIcon, NSpace, NModal, NForm, NFormItem, useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, CreateOutline, TrashOutline,
  EyeOutline, ArchiveOutline, ImageOutline, FolderOutline
} from '@vicons/ionicons5';
import AdminPagination from '@/components/common/AdminPagination.vue';

const adminStore = useAdminStore();
const categoryStore = useCategoryStore();
const { galleries, isLoadingGalleries, galleryPagination, galleryStats } = storeToRefs(adminStore);
const { categories } = storeToRefs(categoryStore);

const dialog = useDialog();
const message = useMessage();

// 计算总页数
const pageCount = computed(() => {
  return Math.ceil(galleryPagination.value.total / galleryPagination.value.pageSize);
});

// 搜索和筛选
const searchQuery = ref('');
const categoryFilter = ref(null);
const sortBy = ref('created_at');

// 编辑相关
const showEditModal = ref(false);
const editForm = ref({
  id: null,
  title: '',
  description: '',
  category_id: null
});
const editFormRef = ref(null);
const isSaving = ref(false);

// 排序选项
const sortOptions = [
  { label: '创建时间', value: 'created_at' },
  { label: '浏览量', value: 'views_count' },
  { label: '点赞数', value: 'likes_count' },
  { label: '收藏数', value: 'bookmarks_count' }
];

// 表单验证规则
const editRules = {
  title: [
    { required: true, message: '请输入图集标题', trigger: 'blur' }
  ]
};

// 表格列定义
const columns = [
  {
    title: 'ID',
    key: 'id',
    width: 80,
    sorter: 'default'
  },
  {
    title: '封面',
    key: 'cover',
    width: 120,
    render(row) {
      const coverImage = row.cover_image || (row.images && row.images[0]);
      if (coverImage && coverImage.image_url) {
        return h(NImage, {
          width: 80,
          height: 60,
          src: coverImage.image_url,
          objectFit: 'cover',
          style: 'border-radius: 6px'
        });
      }
      return h('div', {
        class: 'no-cover',
        style: 'width: 80px; height: 60px; background: #f5f5f5; border-radius: 6px; display: flex; align-items: center; justify-content: center; color: #ccc;'
      }, '无封面');
    }
  },
  {
    title: '图集信息',
    key: 'info',
    render(row) {
      return h('div', { class: 'gallery-info' }, [
        h('div', { class: 'gallery-title', style: 'font-weight: 600; margin-bottom: 4px;' }, row.title),
        h('div', { class: 'gallery-desc', style: 'color: #666; font-size: 12px; margin-bottom: 6px;' }, 
          row.description ? (row.description.length > 50 ? row.description.substring(0, 50) + '...' : row.description) : '暂无描述'
        ),
        h('div', { class: 'gallery-meta', style: 'display: flex; gap: 8px;' }, [
          h(NTag, { size: 'small', type: 'info' }, { default: () => `${row.image_count || 0} 张图片` }),
          row.category ? h(NTag, { size: 'small', type: 'success' }, { 
            default: () => row.category.name,
            icon: () => h(NIcon, null, { default: () => h(FolderOutline) })
          }) : null
        ])
      ]);
    }
  },
  {
    title: '作者',
    key: 'owner',
    width: 120,
    render(row) {
      return row.owner ? row.owner.username : '未知用户';
    }
  },
  {
    title: '统计',
    key: 'stats',
    width: 200,
    render(row) {
      return h('div', { class: 'stats-container', style: 'display: flex; gap: 12px;' }, [
        h('div', { class: 'stat-item', style: 'display: flex; align-items: center; gap: 4px;' }, [
          h(NIcon, { size: 14, color: '#666' }, { default: () => h(EyeOutline) }),
          h('span', { style: 'font-size: 12px; color: #666;' }, row.views_count || 0)
        ]),
        h('div', { class: 'stat-item', style: 'display: flex; align-items: center; gap: 4px;' }, [
          h(NIcon, { size: 14, color: '#f56565' }, { default: () => h(EyeOutline) }),
          h('span', { style: 'font-size: 12px; color: #666;' }, row.likes_count || 0)
        ]),
        h('div', { class: 'stat-item', style: 'display: flex; align-items: center; gap: 4px;' }, [
          h(NIcon, { size: 14, color: '#f6ad55' }, { default: () => h(EyeOutline) }),
          h('span', { style: 'font-size: 12px; color: #666;' }, row.bookmarks_count || 0)
        ])
      ]);
    }
  },
  {
    title: '创建时间',
    key: 'created_at',
    width: 150,
    sorter: (a, b) => new Date(a.created_at) - new Date(b.created_at),
    render(row) {
      return format(new Date(row.created_at), 'yyyy-MM-dd HH:mm');
    }
  },
  {
    title: '操作',
    key: 'actions',
    width: 140,
    render(row) {
      return h(NSpace, { size: 'small' }, [
        h(NButton, {
          size: 'small',
          type: 'primary',
          ghost: true,
          onClick: () => handleEdit(row)
        }, { 
          default: () => '编辑',
          icon: () => h(NIcon, null, { default: () => h(CreateOutline) })
        }),
        h(NButton, {
          size: 'small',
          type: 'error',
          ghost: true,
          onClick: () => handleDelete(row)
        }, { 
          default: () => '删除',
          icon: () => h(NIcon, null, { default: () => h(TrashOutline) })
        })
      ]);
    }
  }
];

// 创建防抖搜索函数
const debouncedSearch = debounce(() => {
  fetchGalleriesWithFilters(1);
}, 300);

// 获取图集列表（带筛选参数）
function fetchGalleriesWithFilters(page = galleryPagination.value.page) {
  const filters = {};
  
  if (searchQuery.value.trim()) {
    filters.search = searchQuery.value.trim();
  }
  
  if (categoryFilter.value) {
    filters.category_id = categoryFilter.value;
  }
  
  if (sortBy.value) {
    filters.sort = sortBy.value;
    filters.order = 'desc';
  }
  
  adminStore.fetchGalleries(page, galleryPagination.value.pageSize, filters);
}

function handleFilter() {
  fetchGalleriesWithFilters(1);
}

function handleSort() {
  fetchGalleriesWithFilters(galleryPagination.value.page);
}

function handleRefresh() {
  fetchGalleriesWithFilters(galleryPagination.value.page);
}

function handlePageChange(page) {
  fetchGalleriesWithFilters(page);
}

function handlePageSizeChange(pageSize) {
  fetchGalleriesWithFilters(1);
}

// 监听搜索输入变化
watch(searchQuery, () => {
  debouncedSearch();
});

// 监听筛选条件变化
watch([categoryFilter], () => {
  fetchGalleriesWithFilters(1);
});

function handleEdit(gallery) {
  editForm.value = {
    id: gallery.id,
    title: gallery.title,
    description: gallery.description || '',
    category_id: gallery.category ? gallery.category.id : null
  };
  showEditModal.value = true;
}

async function handleSaveEdit() {
  try {
    await editFormRef.value?.validate();
    isSaving.value = true;
    
    const { id, ...updateData } = editForm.value;
    await adminStore.updateGallery(id, updateData);
    
    message.success('图集更新成功');
    showEditModal.value = false;
  } catch (error) {
    message.error('图集更新失败：' + (error.message || '未知错误'));
  } finally {
    isSaving.value = false;
  }
}

function handleDelete(gallery) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除图集 "${gallery.title}" 吗？此操作不可撤销。`,
    positiveText: '确定删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await adminStore.deleteGallery(gallery.id);
        message.success('图集删除成功');
      } catch (error) {
        message.error('图集删除失败：' + (error.message || '未知错误'));
      }
    }
  });
}

// 生命周期
onMounted(() => {
  adminStore.fetchGalleries(galleryPagination.value.page, galleryPagination.value.pageSize);
  categoryStore.fetchCategories();
  adminStore.fetchGalleryStats();
});
</script>

<style scoped>
.admin-galleries {
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
}

.admin-table :deep(.n-data-table-th) {
  background: #f8fafc;
  font-weight: 600;
}

.modal-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.edit-form {
  margin-top: 16px;
}

.no-cover {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #ccc;
}

.gallery-info {
  min-width: 200px;
}

.stats-container {
  min-width: 120px;
}

/* 统计卡片样式 */
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



/* 响应式设计 */
@media (max-width: 768px) {
  .admin-galleries {
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