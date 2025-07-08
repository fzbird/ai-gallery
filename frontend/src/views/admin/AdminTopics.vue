<template>
  <div class="admin-topics">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">专题管理</h1>
      <p class="page-subtitle">管理系统中的所有专题分类</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid" v-if="topicStats">
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><LayersOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ topicStats.total_topics || 0 }}</div>
          <div class="stat-label">专题总数</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><EyeOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ topicStats.active_topics || 0 }}</div>
          <div class="stat-label">活跃专题</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><CreateOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ topicStats.inactive_topics || 0 }}</div>
          <div class="stat-label">禁用专题</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon">
          <n-icon size="24"><SearchOutline /></n-icon>
        </div>
        <div class="stat-content">
          <div class="stat-number">{{ topicStats.total_galleries_in_topics || 0 }}</div>
          <div class="stat-label">专题图集</div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <n-input
          v-model:value="searchQuery"
          placeholder="搜索专题名称..."
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
        <n-button @click="showCreateModal = true" type="primary">
          <template #icon>
            <n-icon><AddOutline /></n-icon>
          </template>
          新建专题
        </n-button>
        
        <n-button @click="handleRefresh" :loading="isLoadingTopics">
          <template #icon>
            <n-icon><RefreshOutline /></n-icon>
          </template>
          刷新
        </n-button>
      </div>
    </div>

    <!-- 专题数据表格 -->
    <div class="table-container">
      <n-data-table
        :columns="columns"
        :data="topics"
        :loading="isLoadingTopics"
        :pagination="false"
        :row-key="(row) => row.id"
        :bordered="false"
        size="small"
        class="admin-table"
      />
      <admin-pagination
        :page="topicPagination.page"
        :page-size="topicPagination.pageSize"
        :item-count="topicPagination.total"
        @update:page="handlePageChange"
        @update:page-size="handlePageSizeChange"
      />
    </div>



    <!-- 创建专题弹窗 -->
    <n-modal v-model:show="showCreateModal" preset="dialog" title="新建专题">
      <template #header>
        <div class="modal-header">
          <n-icon size="20"><AddOutline /></n-icon>
          <span>新建专题</span>
        </div>
      </template>
      
      <n-form
        ref="createFormRef"
        :model="createForm"
        :rules="formRules"
        label-placement="left"
        label-width="100"
        class="create-form"
      >
        <n-form-item label="专题名称" path="name">
          <n-input v-model:value="createForm.name" placeholder="请输入专题名称" />
        </n-form-item>
        
        <n-form-item label="URL标识" path="slug">
          <n-input v-model:value="createForm.slug" placeholder="请输入URL友好的标识符" />
        </n-form-item>
        
        <n-form-item label="专题描述" path="description">
          <n-input
            v-model:value="createForm.description"
            type="textarea"
            placeholder="请输入专题描述"
            :rows="3"
          />
        </n-form-item>

        <n-form-item label="封面图片" path="cover_image_url">
          <div class="cover-image-section">
            <!-- 当前封面预览 -->
            <div v-if="createForm.cover_image_url" class="current-cover-preview">
              <n-image
                :src="createForm.cover_image_url"
                width="200"
                height="120"
                object-fit="cover"
                style="border-radius: 6px"
              />
              <div class="cover-info">
                <span>当前封面</span>
                <n-button size="small" @click="createForm.cover_image_url = ''" type="error" ghost>
                  <template #icon>
                    <n-icon><TrashOutline /></n-icon>
                  </template>
                  移除
                </n-button>
              </div>
            </div>
            
            <!-- URL输入 -->
            <div class="upload-section">
              <n-input
                v-model:value="createForm.cover_image_url"
                placeholder="输入封面图片URL"
                clearable
              >
                <template #prefix>
                  <n-icon><LinkOutline /></n-icon>
                </template>
              </n-input>
              <p style="margin: 0; font-size: 12px; color: #6b7280;">
                提示：创建专题后可以在编辑页面上传本地图片
              </p>
            </div>
          </div>
        </n-form-item>
        
        <n-form-item label="状态" path="is_active">
          <n-switch v-model:value="createForm.is_active">
            <template #checked>启用</template>
            <template #unchecked>禁用</template>
          </n-switch>
        </n-form-item>
      </n-form>
      
      <template #action>
        <n-space>
          <n-button @click="showCreateModal = false">取消</n-button>
          <n-button type="primary" @click="handleCreate" :loading="isCreating">
            创建
          </n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- 编辑专题弹窗 -->
    <n-modal v-model:show="showEditModal" preset="dialog" title="编辑专题">
      <template #header>
        <div class="modal-header">
          <n-icon size="20"><CreateOutline /></n-icon>
          <span>编辑专题</span>
        </div>
      </template>
      
      <n-form
        ref="editFormRef"
        :model="editForm"
        :rules="formRules"
        label-placement="left"
        label-width="100"
        class="edit-form"
      >
        <n-form-item label="专题名称" path="name">
          <n-input v-model:value="editForm.name" placeholder="请输入专题名称" />
        </n-form-item>
        
        <n-form-item label="URL标识" path="slug">
          <n-input v-model:value="editForm.slug" placeholder="请输入URL友好的标识符" />
        </n-form-item>
        
        <n-form-item label="专题描述" path="description">
          <n-input
            v-model:value="editForm.description"
            type="textarea"
            placeholder="请输入专题描述"
            :rows="3"
          />
        </n-form-item>

        <n-form-item label="封面图片" path="cover_image_url">
          <div class="cover-image-section">
            <!-- 当前封面预览 -->
            <div v-if="editForm.cover_image_url" class="current-cover-preview">
              <n-image
                :src="editForm.cover_image_url"
                width="200"
                height="120"
                object-fit="cover"
                style="border-radius: 6px"
              />
              <div class="cover-info">
                <span>当前封面</span>
                <n-button size="small" @click="removeCover" type="error" ghost>
                  <template #icon>
                    <n-icon><TrashOutline /></n-icon>
                  </template>
                  移除
                </n-button>
              </div>
            </div>
            
            <!-- 上传新封面 -->
            <div class="upload-section">
              <n-button 
                :loading="isUploading" 
                style="width: 100%"
                @click="triggerCoverUpload"
              >
                <template #icon>
                  <n-icon><CloudUploadOutline /></n-icon>
                </template>
                {{ editForm.cover_image_url ? '更换封面' : '上传封面图片' }}
              </n-button>
              
              <!-- 隐藏的文件输入 -->
              <input 
                ref="coverFileInput"
                type="file" 
                accept="image/*" 
                style="display: none" 
                @change="handleCoverFileChange"
              />
              
              <!-- URL输入备选方案 -->
              <n-divider style="margin: 12px 0">或</n-divider>
              <n-input
                v-model:value="editForm.cover_image_url"
                placeholder="输入封面图片URL"
                clearable
              >
                <template #prefix>
                  <n-icon><LinkOutline /></n-icon>
                </template>
              </n-input>
            </div>
          </div>
        </n-form-item>
        
        <n-form-item label="状态" path="is_active">
          <n-switch v-model:value="editForm.is_active">
            <template #checked>启用</template>
            <template #unchecked>禁用</template>
          </n-switch>
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
import { ref, onMounted, h, computed } from 'vue';
import { useTopicStore } from '@/stores/topic';
import { useAdminStore } from '@/stores/admin';
import { useAuthStore } from '@/stores/auth';
import { storeToRefs } from 'pinia';
import { format } from 'date-fns';
import {
  NDataTable, NButton, NImage, NTag, NInput, NSwitch,
  NIcon, NSpace, NModal, NForm, NFormItem, NDivider,
  useDialog, useMessage
} from 'naive-ui';
import {
  SearchOutline, RefreshOutline, CreateOutline, TrashOutline,
  AddOutline, EyeOutline, LayersOutline, CloudUploadOutline, LinkOutline
} from '@vicons/ionicons5';
import AdminPagination from '@/components/common/AdminPagination.vue';

const topicStore = useTopicStore();
const adminStore = useAdminStore();
const authStore = useAuthStore();
const { topics, isLoadingTopics, topicPagination } = storeToRefs(topicStore);
const { topicStats } = storeToRefs(adminStore);

const dialog = useDialog();
const message = useMessage();

// 计算总页数
const pageCount = computed(() => {
  return Math.ceil(topicPagination.value.total / topicPagination.value.pageSize);
});

// 搜索
const searchQuery = ref('');

// 创建相关
const showCreateModal = ref(false);
const createForm = ref({
  name: '',
  slug: '',
  description: '',
  cover_image_url: '',
  is_active: true
});
const createFormRef = ref(null);
const isCreating = ref(false);

// 编辑相关
const showEditModal = ref(false);
const editForm = ref({
  id: null,
  name: '',
  description: '',
  cover_image_url: '',
  is_active: true
});
const editFormRef = ref(null);
const isSaving = ref(false);

// 图片上传相关
const coverFileInput = ref(null);
const isUploading = ref(false);

// 表单验证规则
const formRules = {
  name: [
    { required: true, message: '请输入专题名称', trigger: 'blur' },
    { min: 2, max: 50, message: '专题名称长度应为2-50个字符', trigger: 'blur' }
  ],
  slug: [
    { required: true, message: '请输入URL标识', trigger: 'blur' },
    { min: 2, max: 50, message: 'URL标识长度应为2-50个字符', trigger: 'blur' },
    { pattern: /^[a-z0-9-_]+$/, message: 'URL标识只能包含小写字母、数字、短横线和下划线', trigger: 'blur' }
  ],
  description: [
    { max: 500, message: '描述不能超过500个字符', trigger: 'blur' }
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
      if (row.cover_image_url) {
        return h(NImage, {
          width: 80,
          height: 60,
          src: row.cover_image_url,
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
    title: '专题信息',
    key: 'info',
    render(row) {
      return h('div', { class: 'topic-info' }, [
        h('div', { class: 'topic-title', style: 'font-weight: 600; margin-bottom: 4px;' }, row.name),
        h('div', { class: 'topic-desc', style: 'color: #666; font-size: 12px; margin-bottom: 6px;' }, 
          row.description ? (row.description.length > 50 ? row.description.substring(0, 50) + '...' : row.description) : '暂无描述'
        ),
        h('div', { class: 'topic-meta', style: 'display: flex; gap: 8px;' }, [
          h(NTag, { 
            size: 'small', 
            type: row.is_active ? 'success' : 'error' 
          }, { 
            default: () => row.is_active ? '启用' : '禁用',
            icon: () => h(NIcon, null, { default: () => h(LayersOutline) })
          })
        ])
      ]);
    }
  },
  {
    title: '图集数量',
    key: 'galleries_count',
    width: 120,
    render(row) {
      return h('span', { style: 'color: #666;' }, row.galleries_count || 0);
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

// 事件处理函数
function handleSearch() {
  adminStore.fetchTopics(
    pagination.value.page,
    pagination.value.pageSize,
    searchValue.value
  );
}

function handleRefresh() {
  topicStore.fetchAdminTopics();
}

function handlePageChange(page) {
  topicStore.fetchAdminTopics(page, topicPagination.value.pageSize);
}

function handlePageSizeChange(pageSize) {
  topicStore.fetchAdminTopics(1, pageSize);
}

async function handleCreate() {
  try {
    await createFormRef.value?.validate();
    isCreating.value = true;
    
    await topicStore.createTopic(createForm.value, true);
    
    message.success('专题创建成功');
    showCreateModal.value = false;
    
    // 重置表单
    createForm.value = {
      name: '',
      slug: '',
      description: '',
      cover_image_url: '',
      is_active: true
    };
  } catch (error) {
    message.error('专题创建失败：' + (error.message || '未知错误'));
  } finally {
    isCreating.value = false;
  }
}

function handleEdit(topic) {
  editForm.value = {
    id: topic.id,
    name: topic.name,
    slug: topic.slug || '',
    description: topic.description || '',
    cover_image_url: topic.cover_image_url || '',
    is_active: topic.is_active
  };
  showEditModal.value = true;
}

async function handleSaveEdit() {
  try {
    await editFormRef.value?.validate();
    isSaving.value = true;
    
    // 从editForm中排除id，保留cover_image_url让后端处理
    const { id, ...updateData } = editForm.value;
    console.log('Saving topic data:', updateData);
    
    await topicStore.updateTopic(id, updateData, true);
    
    message.success('专题更新成功');
    showEditModal.value = false;
  } catch (error) {
    console.error('专题更新失败:', error);
    message.error('专题更新失败：' + (error.message || '未知错误'));
  } finally {
    isSaving.value = false;
  }
}

function handleDelete(topic) {
  dialog.warning({
    title: '确认删除',
    content: `你确定要删除专题 "${topic.name}" 吗？此操作不可撤销。`,
    positiveText: '确定删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await topicStore.deleteTopic(topic.id, true);
        message.success('专题删除成功');
      } catch (error) {
        message.error('专题删除失败：' + (error.message || '未知错误'));
      }
    }
  });
}

// 触发封面图片上传
function triggerCoverUpload() {
  coverFileInput.value?.click();
}

// 处理封面图片上传
async function handleCoverFileChange(event) {
  const file = event.target.files?.[0];
  if (!file) return;

  // 验证文件类型
  if (!file.type.startsWith('image/')) {
    message.error('请选择图片文件');
    return;
  }

  // 验证文件大小（限制为5MB）
  const maxSize = 5 * 1024 * 1024; // 5MB
  if (file.size > maxSize) {
    message.error('图片文件大小不能超过5MB');
    return;
  }

  try {
    isUploading.value = true;
    
    console.log('Uploading file:', {
      name: file.name,
      size: file.size,
      type: file.type
    });
    
    // 创建FormData
    const formData = new FormData();
    formData.append('file', file);

    // 调用上传API
    const response = await fetch(`/api/v1/topics/${editForm.value.id}/upload-cover`, {
      method: 'POST',
      body: formData,
      headers: {
        'Authorization': `Bearer ${authStore.token}`
        // 不设置Content-Type，让浏览器自动设置
      },
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.detail || `上传失败: ${response.status}`);
    }

    const result = await response.json();
    
    // 更新编辑表单中的封面URL
    editForm.value.cover_image_url = result.cover_image_url;
    
    message.success('封面上传成功！');
    
    // 刷新专题列表
    await topicStore.fetchAdminTopics();
    
  } catch (error) {
    console.error('封面上传失败:', error);
    message.error(error.message || '封面上传失败，请重试');
  } finally {
    isUploading.value = false;
    // 清空文件输入，允许重新选择同一文件
    if (coverFileInput.value) {
      coverFileInput.value.value = '';
    }
  }
}

// 移除封面
function removeCover() {
  editForm.value.cover_image_url = '';
  message.info('已移除封面图片');
}

// 生命周期
onMounted(async () => {
  await Promise.all([
    topicStore.fetchAdminTopics(),
    adminStore.fetchTopicStats()
  ]);
});
</script>

<style scoped>
.admin-topics {
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

.create-form,
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

.topic-info {
  min-width: 200px;
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
  background: linear-gradient(135deg, #f59e0b 0%, #b45309 100%);
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

/* 统计分析部分 */
.stats-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stats-section h3 {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.topic-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.topic-stat-item {
  display: flex;
  align-items: center;
  padding: 12px;
  background: #f8fafc;
  border-radius: 6px;
  gap: 12px;
}

.rank {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #f59e0b 0%, #b45309 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 14px;
}

.topic-name {
  flex: 1;
  font-weight: 500;
  color: #374151;
}

.gallery-count {
  color: #6b7280;
  font-size: 14px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-topics {
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

/* 封面图片上传样式 */
.cover-image-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.current-cover-preview {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  padding: 12px;
  background: #f8fafc;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
}

.cover-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.cover-info > span {
  font-size: 14px;
  color: #6b7280;
}

.upload-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
</style> 