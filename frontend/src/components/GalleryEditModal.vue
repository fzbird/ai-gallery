<template>
  <n-modal 
    v-model:show="modalVisible" 
    preset="dialog" 
    :style="{ width: '1200px', maxWidth: '95vw' }"
    :show-icon="false"
    :closable="false"
    :mask-closable="false"
    transform-origin="center"
  >
    <template #header>
      <div class="modal-header">
        <n-icon class="header-icon"><CreateOutline /></n-icon>
        <span class="header-title">修改图集</span>
      </div>
    </template>

    <div class="edit-modal-content">
      <n-spin :show="isLoading">
        <n-form ref="formRef" :model="formModel" :rules="rules" class="edit-form">
          
          <!-- 图片管理区域 -->
          <div class="images-section">
            <div class="section-header">
              <n-icon class="section-icon"><ImagesOutline /></n-icon>
              <h3>图片管理</h3>
              <p>拖拽调整顺序，第一个图片为封面图</p>
            </div>
            
            <!-- 现有图片列表 -->
            <div v-if="existingImages.length > 0" class="existing-images">
              <div class="images-grid" ref="imagesContainer">
                <div 
                  v-for="(image, index) in existingImages" 
                  :key="image.id"
                  class="image-item"
                  :class="{ 'is-cover': index === 0, 'dragging': image.isDragging }"
                  draggable="true"
                  @dragstart="handleDragStart(index, $event)"
                  @dragover="handleDragOver($event)"
                  @drop="handleDrop(index, $event)"
                  @dragend="handleDragEnd"
                  @dragenter="handleDragEnter(index, $event)"
                  @dragleave="handleDragLeave($event)"
                >
                  <!-- 封面标识 -->
                  <div v-if="index === 0" class="cover-badge">
                    <n-tooltip trigger="hover" placement="top">
                      <template #trigger>
                        <div class="cover-icon">
                          <n-icon><StarOutline /></n-icon>
                        </div>
                      </template>
                      <span>图集封面图片</span>
                    </n-tooltip>
                  </div>
                  
                  <!-- 拖拽手柄 -->
                  <div class="drag-handle">
                    <n-icon><ReorderThreeOutline /></n-icon>
                  </div>
                  
                  <!-- 图片预览 -->
                  <div class="image-preview">
                    <img 
                      :src="image.image_url" 
                      :alt="image.title"
                      class="preview-img"
                    />
                  </div>
                  
                  <!-- 图片信息 -->
                  <div class="image-info">
                    <div class="image-title">{{ image.title }}</div>
                    <div class="image-meta">{{ formatFileSize(image.file_size) }}</div>
                  </div>
                  
                  <!-- 图片操作按钮 -->
                  <div class="image-actions">
                    <!-- 设置封面按钮 -->
                    <n-tooltip v-if="index !== 0" trigger="hover" placement="top">
                      <template #trigger>
                        <n-button 
                          type="warning" 
                          ghost 
                          size="small" 
                          circle
                          class="cover-btn"
                          @click="setCoverImage(index)"
                        >
                          <template #icon>
                            <n-icon><StarOutline /></n-icon>
                          </template>
                        </n-button>
                      </template>
                      <span>设为封面</span>
                    </n-tooltip>
                    
                    <!-- 删除按钮 -->
                    <n-popconfirm
                      @positive-click="removeExistingImage(image.id, index)"
                      negative-text="取消"
                      positive-text="删除"
                    >
                      <template #trigger>
                        <n-button 
                          type="error" 
                          ghost 
                          size="small" 
                          circle
                          class="delete-btn"
                        >
                          <template #icon>
                            <n-icon><TrashOutline /></n-icon>
                          </template>
                        </n-button>
                      </template>
                      确定要删除这张图片吗？此操作不可撤销。
                    </n-popconfirm>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 新图片上传区域 -->
            <div class="upload-area">
              <n-upload
                multiple
                directory-dnd
                :default-upload="false"
                @change="handleNewFileChange"
                :show-file-list="false"
                :accept="acceptAttribute"
                class="custom-upload"
              >
                <n-upload-dragger class="upload-dragger">
                  <div class="upload-content">
                    <div class="upload-icon-wrapper">
                      <n-icon size="48" class="upload-icon">
                        <CloudUploadOutline />
                      </n-icon>
                    </div>
                    <div class="upload-text">
                      <h4>添加新图片</h4>
                      <p class="upload-hint">
                        支持拖拽上传，或点击选择文件
                      </p>
                    </div>
                  </div>
                </n-upload-dragger>
              </n-upload>
            </div>
            
            <!-- 新上传文件列表 -->
            <div v-if="newFileList.length > 0" class="new-files-section">
              <h4>待上传图片</h4>
              <div class="new-files-list">
                <div 
                  v-for="(file, index) in newFileList" 
                  :key="file.id"
                  class="new-file-item"
                >
                  <div class="file-preview">
                    <img v-if="file.preview" :src="file.preview" alt="预览" />
                    <n-icon v-else size="24"><ImageOutline /></n-icon>
                  </div>
                  <div class="file-info">
                    <div class="file-name">{{ file.name }}</div>
                    <div class="file-size">{{ formatFileSize(file.file.size) }}</div>
                  </div>
                  <div class="file-actions">
                    <n-button 
                      size="small" 
                      type="error" 
                      quaternary 
                      @click="removeNewFile(index)"
                    >
                      <template #icon>
                        <n-icon><TrashOutline /></n-icon>
                      </template>
                    </n-button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 图集信息区域 -->
          <div class="gallery-info-section">
            <div class="section-header">
              <n-icon class="section-icon"><DocumentTextOutline /></n-icon>
              <h3>图集信息</h3>
              <p>修改图集的基本信息</p>
            </div>
            
            <div class="form-grid">
              <n-form-item label="图集标题" path="title" required>
                <n-input 
                  v-model:value="formModel.title" 
                  placeholder="请输入图集标题" 
                  clearable
                />
              </n-form-item>
              
              <n-form-item label="作品分类" path="category_id">
                <n-select
                  v-model:value="formModel.category_id"
                  :options="categoryOptions"
                  placeholder="选择图集分类（可选）"
                  clearable
                />
              </n-form-item>
              
              <n-form-item label="专题分类" path="topic_id">
                <n-select
                  v-model:value="formModel.topic_id"
                  :options="topicOptions"
                  placeholder="选择相关专题（可选）"
                  clearable
                />
              </n-form-item>
              
              <n-form-item label="图集描述" path="description">
                <n-input 
                  v-model:value="formModel.description" 
                  type="textarea" 
                  placeholder="描述图集的主题、创作背景或其他相关信息..."
                  :autosize="{ minRows: 3, maxRows: 6 }"
                />
              </n-form-item>
              
              <n-form-item label="标签" path="tags">
                <n-input 
                  v-model:value="formModel.tags" 
                  placeholder="用逗号分隔，例如: 风景摄影,自然,户外" 
                />
              </n-form-item>
            </div>
          </div>
        </n-form>
      </n-spin>
    </div>

    <template #action>
      <div class="modal-actions">
        <n-button @click="handleCancel" :disabled="isLoading">
          取消
        </n-button>
        <n-button 
          type="primary" 
          @click="handleSave" 
          :loading="isLoading"
        >
          保存修改
        </n-button>
      </div>
    </template>
  </n-modal>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue';
import { 
  NModal, NForm, NFormItem, NInput, NButton, NSelect, NUpload, 
  NSpin, NIcon, NTooltip, NPopconfirm, useMessage 
} from 'naive-ui';
import {
  CreateOutline, ImagesOutline, DocumentTextOutline, CloudUploadOutline,
  StarOutline, ReorderThreeOutline, TrashOutline, ImageOutline
} from '@vicons/ionicons5';
import { useCategoryStore } from '@/stores/category';
import { useTopicStore } from '@/stores/topic';
import { useSettingsStore } from '@/stores/settings';
import { calculateFileHash } from '@/utils/file-hasher';
import apiClient, { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  gallery: {
    type: Object,
    required: true
  },
  visible: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:visible', 'gallery-updated']);

// 计算属性来处理模态窗口显示状态
const modalVisible = computed({
  get: () => props.visible,
  set: (value) => emit('update:visible', value)
});

const message = useMessage();
const categoryStore = useCategoryStore();
const topicStore = useTopicStore();
const settingsStore = useSettingsStore();

const formRef = ref(null);
const isLoading = ref(false);
const existingImages = ref([]);
const newFileList = ref([]);
const draggedIndex = ref(-1);

// 表单数据
const formModel = reactive({
  title: '',
  description: '',
  category_id: null,
  topic_id: null,
  tags: ''
});

// 表单验证规则
const rules = {
  title: {
    required: true,
    message: '请输入图集标题',
    trigger: ['blur', 'input'],
    validator: (rule, value) => {
      if (!value || value.trim() === '') {
        return new Error('图集标题不能为空');
      }
      if (value.trim().length < 2) {
        return new Error('图集标题至少需要2个字符');
      }
      if (value.trim().length > 100) {
        return new Error('图集标题不能超过100个字符');
      }
      return true;
    }
  }
};

// 计算属性
const categoryOptions = computed(() => categoryStore.selectOptions);
const topicOptions = computed(() => topicStore.activeSelectOptions);

// 系统设置
const systemSettings = computed(() => settingsStore.settings || {});
const allowedFileTypes = computed(() => {
  const types = systemSettings.value.allowed_file_types || 'jpg,jpeg,png,gif,webp,tiff,svg,bmp';
  return types.split(',').map(type => type.trim().toLowerCase());
});
const allowedExtensions = computed(() => allowedFileTypes.value.map(type => `.${type}`));
const acceptAttribute = computed(() => allowedExtensions.value.join(',') + ',image/*');
const maxFileSize = computed(() => parseInt(systemSettings.value.max_upload_size) || (50 * 1024 * 1024));

// 监听显示状态
watch(() => props.visible, (newVal) => {
  if (newVal) {
    initModal();
  } else {
    resetModal();
  }
});

// 初始化模态窗口
async function initModal() {
  if (!props.gallery) return;
  
  // 加载必要数据
  await loadStores();
  
  // 初始化表单数据
  formModel.title = props.gallery.title || '';
  formModel.description = props.gallery.description || '';
  formModel.category_id = props.gallery.category?.id || null;
  formModel.topic_id = props.gallery.topic_id || null;
  
  // 处理标签
  if (props.gallery.tags && Array.isArray(props.gallery.tags)) {
    formModel.tags = props.gallery.tags.map(tag => tag.name).join(', ');
  } else {
    formModel.tags = '';
  }
  
  // 初始化现有图片列表
  existingImages.value = [...(props.gallery.images || [])].map(img => ({
    ...img,
    image_url: img.image_url || `${API_BASE_URL}${img.image_url}`,
    isDragging: false
  }));
}

// 重置模态窗口
function resetModal() {
  Object.assign(formModel, {
    title: '',
    description: '',
    category_id: null,
    topic_id: null,
    tags: ''
  });
  existingImages.value = [];
  newFileList.value = [];
  draggedIndex.value = -1;
}

// 加载必要的Store数据
async function loadStores() {
  const loadTasks = [];
  
  if (!categoryStore.categories.length) {
    loadTasks.push(categoryStore.fetchCategories());
  }
  
  if (!topicStore.topics.length) {
    loadTasks.push(topicStore.fetchTopics());
  }
  
  if (!settingsStore.settings) {
    loadTasks.push(settingsStore.fetchSettings());
  }
  
  await Promise.all(loadTasks);
}

// 格式化文件大小
function formatFileSize(bytes) {
  if (!bytes) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 拖拽处理 - 现有图片
function handleDragStart(index, event) {
  draggedIndex.value = index;
  existingImages.value[index].isDragging = true;
  event.dataTransfer.effectAllowed = 'move';
}

function handleDragOver(event) {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
}

function handleDragEnter(index, event) {
  event.preventDefault();
}

function handleDragLeave(event) {
  // 可以添加视觉反馈
}

function handleDrop(dropIndex, event) {
  event.preventDefault();
  const dragIndex = draggedIndex.value;
  
  if (dragIndex !== -1 && dragIndex !== dropIndex) {
    // 执行拖拽排序
    const draggedItem = existingImages.value[dragIndex];
    existingImages.value.splice(dragIndex, 1);
    existingImages.value.splice(dropIndex, 0, draggedItem);
    
    message.success(`图片已移动${dropIndex === 0 ? '，现在是封面图片' : ''}`);
  }
  
  handleDragEnd();
}

function handleDragEnd() {
  existingImages.value.forEach(img => {
    img.isDragging = false;
  });
  draggedIndex.value = -1;
}

// 删除现有图片
async function removeExistingImage(imageId, index) {
  try {
    isLoading.value = true;
    await apiClient.delete(`/images/${imageId}`);
    existingImages.value.splice(index, 1);
    message.success('图片删除成功');
  } catch (error) {
    console.error('删除图片失败:', error);
    message.error('删除图片失败');
  } finally {
    isLoading.value = false;
  }
}

// 处理新文件上传
async function handleNewFileChange(data) {
  // 过滤掉已存在的文件（基于文件名和大小）
  const validFiles = data.fileList.filter(file => {
    // 检查是否已经存在相同的文件
    const isDuplicate = newFileList.value.some(existingFile => 
      existingFile.name === file.name && 
      existingFile.file.size === file.file.size
    );
    
    if (isDuplicate) {
      message.warning(`文件 "${file.name}" 已经在上传列表中，已跳过`);
      return false;
    }
    
    const isValidType = validateFileType(file.file);
    const isValidSize = validateFileSize(file.file);
    
    if (!isValidType) {
      message.warning(`文件 "${file.name}" 不是支持的图片格式，已跳过`);
      return false;
    }
    
    if (!isValidSize) {
      message.warning(`文件 "${file.name}" 超过大小限制，已跳过`);
      return false;
    }
    
    return true;
  });

  // 创建文件项并生成预览
  const newFiles = [];
  for (const file of validFiles) {
    const preview = await createFilePreview(file.file);
    newFiles.push({
      id: file.id || Date.now() + Math.random(),
      name: file.name,
      file: file.file,
      preview,
      status: 'pending',
      hash: null
    });
  }

  newFileList.value.push(...newFiles);
  if (validFiles.length > 0) {
    message.success(`已选择 ${validFiles.length} 个新图片文件`);
  }
}

// 验证文件类型
function validateFileType(file) {
  const fileName = file.name.toLowerCase();
  const fileType = file.type;
  
  const hasValidExtension = allowedExtensions.value.some(ext => fileName.endsWith(ext));
  const hasValidMimeType = file.type.startsWith('image/');
  
  return hasValidExtension || hasValidMimeType;
}

// 验证文件大小
function validateFileSize(file) {
  return file.size <= maxFileSize.value;
}

// 创建文件预览
function createFilePreview(file) {
  return new Promise((resolve) => {
    if (file.type.startsWith('image/')) {
      const reader = new FileReader();
      reader.onload = (e) => resolve(e.target.result);
      reader.onerror = () => resolve(null);
      reader.readAsDataURL(file);
    } else {
      resolve(null);
    }
  });
}

// 删除新文件
function removeNewFile(index) {
  newFileList.value.splice(index, 1);
}

// 取消操作
function handleCancel() {
  emit('update:visible', false);
}

// 保存修改
async function handleSave() {
  try {
    // 验证表单
    await formRef.value?.validate();
    
    isLoading.value = true;
    
    // 1. 更新图集基本信息
    const galleryUpdateData = {
      title: formModel.title.trim(),
      description: formModel.description || '',
      category_id: formModel.category_id,
      topic_id: formModel.topic_id
    };
    
    // 处理标签
    if (formModel.tags && formModel.tags.trim()) {
      galleryUpdateData.tags = formModel.tags;
    }
    
    // 设置封面图片（第一张图片）
    if (existingImages.value.length > 0) {
      galleryUpdateData.cover_image_id = existingImages.value[0].id;
    }
    
    await apiClient.put(`/galleries/${props.gallery.id}`, galleryUpdateData);
    
    // 2. 上传新图片
    if (newFileList.value.length > 0) {
      await uploadNewImages();
    }
    
    // 3. 更新图片顺序（如果需要）
    await updateImageOrder();
    
    message.success('图集修改成功！');
    emit('gallery-updated');
    emit('update:visible', false);
    
  } catch (error) {
    console.error('保存图集修改失败:', error);
    message.error('保存失败：' + (error.response?.data?.detail || error.message));
  } finally {
    isLoading.value = false;
  }
}

// 上传新图片
async function uploadNewImages() {
  let uploadedCount = 0;
  let failedCount = 0;
  
  for (const fileItem of newFileList.value) {
    try {
      // 计算文件哈希
      try {
        fileItem.hash = await calculateFileHash(fileItem.file);
      } catch (hashError) {
        console.error(`计算文件哈希失败 ${fileItem.name}:`, hashError);
        // 如果哈希计算失败，使用备用方案
        fileItem.hash = `fallback_${fileItem.file.name}_${fileItem.file.size}_${Date.now()}`;
      }
      
      const formData = new FormData();
      formData.append('file', fileItem.file);
      formData.append('title', `${formModel.title} - ${Date.now()}`);
      formData.append('file_hash', fileItem.hash);
      formData.append('gallery_id', props.gallery.id);
      formData.append('gallery_folder', `gallery_${props.gallery.id}`);
      
      if (formModel.description) formData.append('description', formModel.description);
      if (formModel.tags) formData.append('tags', formModel.tags);
      if (formModel.category_id) formData.append('category_id', formModel.category_id);
      if (formModel.topic_id) formData.append('topic_id', formModel.topic_id);
      
      const response = await apiClient.post('/images/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      
      // 将新上传的图片添加到现有图片列表
      existingImages.value.push({
        ...response.data,
        image_url: response.data.image_url,
        isDragging: false
      });
      
      uploadedCount++;
      
    } catch (error) {
      console.error(`上传图片 ${fileItem.name} 失败:`, error);
      failedCount++;
      
      // 显示具体的错误信息
      const errorMessage = error.response?.data?.detail || error.message || '未知错误';
      message.error(`上传图片 ${fileItem.name} 失败: ${errorMessage}`);
    }
  }
  
  // 显示上传结果
  if (uploadedCount > 0) {
    message.success(`成功上传 ${uploadedCount} 张图片`);
  }
  if (failedCount > 0) {
    message.warning(`${failedCount} 张图片上传失败，请检查文件格式和大小`);
  }
  
  // 清空新文件列表
  newFileList.value = [];
}

// 更新图片顺序（如果API支持）
async function updateImageOrder() {
  // 如果后端API支持批量更新图片顺序，可以在这里实现
  // 目前只是确保第一张图片作为封面
}

// 设置为封面图片
function setCoverImage(index) {
  if (index === 0) {
    message.info('该图片已经是封面图片');
    return;
  }
  
  // 将选择的图片移动到第一位
  const selectedImage = existingImages.value[index];
  existingImages.value.splice(index, 1);
  existingImages.value.unshift(selectedImage);
  
  message.success('封面图片已更新');
}

onMounted(() => {
  loadStores();
});
</script>

<style scoped>
.modal-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
}

.header-icon {
  color: #f59e0b;
}

.edit-modal-content {
  max-height: 70vh;
  overflow-y: auto;
}

.edit-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 区块样式 */
.images-section,
.gallery-info-section {
  background: #f8fafc;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid #e5e7eb;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}

.section-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.section-header p {
  margin: 0;
  font-size: 12px;
  color: #6b7280;
  margin-left: auto;
}

.section-icon {
  color: #10b981;
  font-size: 18px;
}

/* 现有图片网格 */
.existing-images {
  margin-bottom: 16px;
}

.images-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.image-item {
  position: relative;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  border: 2px solid transparent;
  transition: all 0.3s ease;
  cursor: move;
}

.image-item:hover {
  border-color: #10b981;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);
}

.image-item.is-cover {
  border-color: #f59e0b;
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
}

.image-item.dragging {
  opacity: 0.5;
  transform: scale(0.95);
}

.cover-badge {
  position: absolute;
  top: 6px;
  left: 6px;
  z-index: 10;
}

.cover-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  background: linear-gradient(135deg, #f59e0b, #d97706);
  border-radius: 50%;
  color: white;
  font-size: 10px;
}

.drag-handle {
  position: absolute;
  top: 6px;
  right: 6px;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  background: rgba(0, 0, 0, 0.5);
  border-radius: 4px;
  color: white;
  cursor: grab;
}

.drag-handle:active {
  cursor: grabbing;
}

.image-preview {
  width: 100%;
  height: 120px;
  overflow: hidden;
}

.preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-info {
  padding: 8px;
}

.image-title {
  font-size: 12px;
  font-weight: 500;
  color: #1f2937;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 4px;
}

.image-meta {
  font-size: 10px;
  color: #6b7280;
}

.image-actions {
  position: absolute;
  bottom: 6px;
  right: 6px;
  display: flex;
  gap: 4px;
}

.cover-btn {
  background: rgba(245, 158, 11, 0.1);
  backdrop-filter: blur(10px);
}

.cover-btn:hover {
  background: rgba(245, 158, 11, 0.2);
}

.delete-btn {
  background: rgba(239, 68, 68, 0.1);
  backdrop-filter: blur(10px);
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2);
}

/* 上传区域 */
.upload-area {
  margin-bottom: 16px;
}

.custom-upload {
  width: 100%;
}

.upload-dragger {
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  background: #f9fafb;
  transition: all 0.3s ease;
  min-height: 120px;
}

.upload-dragger:hover {
  border-color: #10b981;
  background: #f0fdf4;
}

.upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 16px;
  text-align: center;
}

.upload-icon-wrapper {
  margin-bottom: 8px;
}

.upload-icon {
  color: #10b981;
}

.upload-text h4 {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.upload-hint {
  margin: 0;
  color: #6b7280;
  font-size: 12px;
}

/* 新文件列表 */
.new-files-section {
  margin-top: 16px;
}

.new-files-section h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.new-files-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.new-file-item {
  display: flex;
  align-items: center;
  padding: 8px;
  background: white;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
}

.file-preview {
  width: 40px;
  height: 40px;
  border-radius: 4px;
  overflow: hidden;
  margin-right: 12px;
  background: #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: center;
}

.file-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.file-info {
  flex: 1;
}

.file-name {
  font-size: 12px;
  font-weight: 500;
  color: #1f2937;
  margin-bottom: 2px;
}

.file-size {
  font-size: 10px;
  color: #6b7280;
}

/* 表单网格 */
.form-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* 模态窗口操作 */
.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .images-grid {
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    gap: 8px;
  }
  
  .image-preview {
    height: 100px;
  }
  
  .upload-content {
    padding: 12px;
  }
}
</style> 