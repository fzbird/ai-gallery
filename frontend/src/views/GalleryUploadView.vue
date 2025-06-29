<template>
  <div class="gallery-upload-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>图集上传</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <n-icon class="title-icon"><FolderOpenOutline /></n-icon>
            图集上传
          </h1>
          <p class="page-subtitle">
            创建图集，批量上传相关图片，让作品更有组织性
          </p>
        </div>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="main-content">
      <div class="container">
        <div class="upload-container">
          <n-spin :show="isLoading">
            <n-form ref="formRef" :model="model" :rules="rules" class="upload-form">
              
              <!-- 文件上传区域 -->
              <div class="upload-section">
                <div class="section-header">
                  <n-icon class="section-icon"><ImagesOutline /></n-icon>
                  <h3>选择图片</h3>
                  <p>支持 {{ supportedFormatsText }} 等图片格式，单个文件最大 {{ maxFileSizeText }}</p>
                </div>
                
                <n-form-item path="files">
                  <n-upload
                    multiple
                    directory-dnd
                    :default-upload="false"
                    @change="handleFileChange"
                    :show-file-list="false"
                    :accept="acceptAttribute"
                    class="custom-upload"
                  >
                    <n-upload-dragger class="upload-dragger">
                      <div class="upload-content">
                        <div class="upload-icon-wrapper">
                          <n-icon size="64" class="upload-icon">
                            <CloudUploadOutline />
                          </n-icon>
                        </div>
                        <div class="upload-text">
                          <h4>拖拽图片文件到这里，或点击选择</h4>
                          <p class="upload-hint">
                            <n-icon><FolderOutline /></n-icon>
                            支持多文件和文件夹批量上传，建议按主题组织图片
                          </p>
                                                      <div class="supported-formats">
                              <span 
                                v-for="format in allowedFileTypes" 
                                :key="format" 
                                class="format-badge"
                              >
                                {{ format.toUpperCase() }}
                              </span>
                            </div>
                        </div>
                      </div>
                    </n-upload-dragger>
                  </n-upload>
                </n-form-item>
              </div>

              <!-- 文件列表区域 -->
              <div v-if="fileList.length > 0" class="file-list-section">
                <div class="section-header">
                  <n-icon class="section-icon"><ListOutline /></n-icon>
                  <h3>文件列表</h3>
                  <p>已选择 {{ fileList.length }} 个文件，拖拽调整顺序，第一个文件为封面图</p>
                </div>
                
                <div class="file-list-container" ref="fileListContainer">
                  <div 
                    v-for="(item, index) in fileList" 
                    :key="item.id" 
                    class="file-item"
                    :class="{ 'dragging': item.isDragging }"
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
                    
                    <div class="file-info">
                      <div class="file-preview">
                        <img v-if="item.preview" :src="item.preview" alt="预览" class="preview-image" />
                        <n-icon v-else size="24" class="file-icon"><ImageOutline /></n-icon>
                      </div>
                      <div class="file-details">
                        <div class="file-name">
                          {{ item.name }}
                          <span v-if="index === 0" class="cover-text">（封面）</span>
                        </div>
                        <div class="file-meta">
                          <span class="file-size">{{ formatFileSize(item.file.size) }}</span>
                          <span class="file-status" :class="item.status">
                            {{ getStatusText(item.status) }}
                            <n-icon v-if="item.status === 'duplicate'" class="status-icon"><CheckmarkCircleOutline /></n-icon>
                          </span>
                        </div>
                      </div>
                    </div>
                    <div class="file-actions">
                      <n-button 
                        size="small" 
                        type="error" 
                        quaternary 
                        @click="removeFile(index)"
                        :disabled="item.status === 'uploading'"
                      >
                        <template #icon>
                          <n-icon><TrashOutline /></n-icon>
                        </template>
                      </n-button>
                    </div>
                    <div class="file-progress">
                      <n-progress
                        type="line"
                        :status="getProgressStatus(item.status)"
                        :percentage="item.percentage"
                        :processing="item.status === 'uploading' || item.status === 'hashing'"
                        :show-indicator="false"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <!-- 图集信息区域 -->
              <div class="gallery-info-section">
                <div class="section-header">
                  <n-icon class="section-icon"><DocumentTextOutline /></n-icon>
                  <h3>图集信息</h3>
                  <p>为您的图集设置基本信息，这些信息将帮助用户更好地发现您的作品</p>
                </div>
                
                <div class="form-grid">
                  <n-form-item label="图集标题" path="title" class="form-item" required>
                    <n-input 
                      v-model:value="model.title" 
                      placeholder="请输入图集标题（必填，2-100个字符）" 
                      class="custom-input"
                      clearable
                    />
                  </n-form-item>
                  
                  <!-- 分类字段各占一行 -->
                  <n-form-item label="作品分类" path="category_id" class="form-item" style="display: block; width: 100%; margin-bottom: 10px;">
                    <n-select
                      v-model:value="model.category_id"
                      :options="categoryStore.selectOptions"
                      placeholder="选择图集分类（可选）"
                      clearable
                      class="custom-select"
                    />
                  </n-form-item>
                  
                  <n-form-item label="专题分类" path="topic_id" class="form-item" style="display: block; width: 100%; margin-bottom: 10px;">
                    <n-select
                      v-model:value="model.topic_id"
                      :options="topicStore.activeSelectOptions"
                      placeholder="选择相关专题（可选）"
                      clearable
                      class="custom-select"
                    >
                      <template #option="{ node, option }">
                        <div class="topic-option">
                          <div class="topic-name">{{ option.label }}</div>
                          <div class="topic-desc" v-if="option.description">{{ option.description }}</div>
                        </div>
                      </template>
                    </n-select>
                  </n-form-item>
                  
                  <n-form-item label="图集描述" path="description" class="form-item">
                    <n-input 
                      v-model:value="model.description" 
                      type="textarea" 
                      placeholder="描述图集的主题、创作背景或其他相关信息..."
                      :autosize="{ minRows: 3, maxRows: 6 }"
                      class="custom-input"
                    />
                  </n-form-item>
                  
                  <n-form-item label="标签" path="tags" class="form-item">
                    <n-input 
                      v-model:value="model.tags" 
                      placeholder="用逗号分隔，例如: 风景摄影,自然,户外" 
                      class="custom-input"
                    />
                  </n-form-item>
                </div>
              </div>

              <!-- 提交按钮 -->
              <div class="submit-section">
                <n-button 
                  type="primary" 
                  @click="handleUpload" 
                  size="large"
                  :loading="isLoading || isHashing" 
                  :disabled="!canUpload"
                  class="upload-btn"
                >
                  <template #icon>
                    <n-icon><CloudUploadOutline /></n-icon>
                  </template>
                  {{ uploadButtonText }}
                </n-button>
                
                <div class="upload-tips">
                  <n-alert type="info" :show-icon="false" class="tip-alert">
                    <p><strong>上传说明：</strong></p>
                    <ul>
                      <li>图集将创建专门文件夹，便于管理</li>
                      <li>系统自动检测重复文件，支持秒传</li>
                      <li>建议一次上传相关主题的图片</li>
                    </ul>
                  </n-alert>
                </div>
              </div>
            </n-form>
          </n-spin>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <AppFooter theme-color="#10b981" />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue';
import { useGalleryStore } from '@/stores/gallery';
import { useCategoryStore } from '@/stores/category';
import { useTopicStore } from '@/stores/topic';
import { useSettingsStore } from '@/stores/settings';
import { usePageTitle } from '@/utils/page-title';
import { 
  NCard, NForm, NFormItem, NInput, NButton, NUpload, NSelect, NSpin, NProgress,
  NAlert, NBreadcrumb, NBreadcrumbItem, useMessage, NIcon, NTooltip
} from 'naive-ui';
import { useRouter } from 'vue-router';
import { 
  DocumentTextOutline, CloudUploadOutline, ImagesOutline, FolderOutline, 
  FolderOpenOutline, ListOutline, ImageOutline, CheckmarkCircleOutline,
  TrashOutline, StarOutline, ReorderThreeOutline
} from '@vicons/ionicons5';
import { calculateFileHash } from '@/utils/file-hasher';
import AppFooter from '@/components/AppFooter.vue';
import apiClient from '@/api/api.js';

const galleryStore = useGalleryStore();
const categoryStore = useCategoryStore();
const topicStore = useTopicStore();
const settingsStore = useSettingsStore();
const router = useRouter();
const message = useMessage();
const { setTitle, clearCustomTitle } = usePageTitle();

const formRef = ref(null);
const fileList = ref([]);
const model = reactive({
  title: '',
  description: '',
  tags: '',
  category_id: null,
  topic_id: null,
});
const isLoading = ref(false);
const isHashing = ref(false);

// 拖拽相关状态
const draggedIndex = ref(-1);
const dragOverIndex = ref(-1);

// 从系统设置获取的动态参数
const systemSettings = computed(() => settingsStore.settings || {});

// 动态获取允许的文件类型
const allowedFileTypes = computed(() => {
  const types = systemSettings.value.allowed_file_types || 'jpg,jpeg,png,gif,webp,tiff,svg,bmp';
  return types.split(',').map(type => type.trim().toLowerCase());
});

// 动态生成MIME类型列表
const allowedImageTypes = computed(() => {
  const mimeMap = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',
    'tiff': 'image/tiff',
    'svg': 'image/svg+xml'
  };
  
  return allowedFileTypes.value.map(type => mimeMap[type]).filter(Boolean);
});

// 动态生成扩展名列表
const allowedExtensions = computed(() => {
  return allowedFileTypes.value.map(type => `.${type}`);
});

// 动态获取文件大小限制
const maxFileSize = computed(() => {
  return parseInt(systemSettings.value.max_upload_size) || (50 * 1024 * 1024);
});

// 生成格式化的文件大小限制文本
const maxFileSizeText = computed(() => {
  const sizeInMB = Math.round(maxFileSize.value / (1024 * 1024));
  return `${sizeInMB}MB`;
});

// 生成支持格式的显示文本
const supportedFormatsText = computed(() => {
  return allowedFileTypes.value.map(type => type.toUpperCase()).join('、');
});

// 生成accept属性
const acceptAttribute = computed(() => {
  return allowedExtensions.value.join(',') + ',image/*';
});

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
  },
  files: { 
    validator: () => fileList.value.length > 0, 
    message: '请至少选择一个图片文件' 
  }
};

// 计算属性
const canUpload = computed(() => {
  return fileList.value.length > 0 && 
         model.title && 
         model.title.trim() !== '' && 
         !isHashing.value;
});

const uploadButtonText = computed(() => {
  if (isHashing.value) return '正在计算文件哈希...';
  if (fileList.value.length === 0) return '请先选择文件';
  if (!model.title || model.title.trim() === '') return '请输入图集标题';
  return `创建图集并上传 ${fileList.value.length} 个文件`;
});

// 验证文件类型
const validateFileType = (file) => {
  const fileName = file.name.toLowerCase();
  const fileType = file.type;
  
  const hasValidExtension = allowedExtensions.value.some(ext => fileName.endsWith(ext));
  const hasValidMimeType = allowedImageTypes.value.includes(fileType);
  
  return hasValidExtension || hasValidMimeType;
};

// 验证文件大小
const validateFileSize = (file) => {
  return file.size <= maxFileSize.value;
};

// 格式化文件大小显示
const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 创建文件预览
const createFilePreview = (file) => {
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
};

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    pending: '待上传',
    hashing: '计算哈希中...',
    hashed: '准备上传',
    uploading: '上传中...',
    finished: '上传完成',
    duplicate: '文件已存在（秒传）',
    error: '上传失败'
  };
  return statusMap[status] || status;
};

// 获取进度条状态
const getProgressStatus = (status) => {
  if (status === 'error') return 'error';
  if (status === 'finished' || status === 'duplicate') return 'success';
  return 'default';
};

// 移除文件
const removeFile = (index) => {
  fileList.value.splice(index, 1);
};

// 拖拽处理函数
const handleDragStart = (index, event) => {
  draggedIndex.value = index;
  fileList.value[index].isDragging = true;
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('text/html', index.toString());
};

const handleDragOver = (event) => {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
};

const handleDragEnter = (index, event) => {
  event.preventDefault();
  dragOverIndex.value = index;
};

const handleDragLeave = (event) => {
  // 只有当鼠标真正离开当前元素时才清除
  if (!event.currentTarget.contains(event.relatedTarget)) {
    dragOverIndex.value = -1;
  }
};

const handleDrop = (dropIndex, event) => {
  event.preventDefault();
  const dragIndex = draggedIndex.value;
  
  if (dragIndex !== -1 && dragIndex !== dropIndex) {
    // 执行拖拽排序
    const draggedItem = fileList.value[dragIndex];
    fileList.value.splice(dragIndex, 1);
    fileList.value.splice(dropIndex, 0, draggedItem);
    
    message.success(`文件已移动${dropIndex === 0 ? '，现在是封面图片' : ''}`);
  }
  
  // 重置拖拽状态
  handleDragEnd();
};

const handleDragEnd = () => {
  // 清除所有拖拽状态
  fileList.value.forEach(item => {
    item.isDragging = false;
  });
  draggedIndex.value = -1;
  dragOverIndex.value = -1;
};

// 处理文件选择
const handleFileChange = async (data) => {
  // 过滤出有效的图片文件
  const validFiles = data.fileList.filter(file => {
    const isValidType = validateFileType(file.file);
    const isValidSize = validateFileSize(file.file);
    
    if (!isValidType) {
      message.warning(`文件 "${file.name}" 不是支持的图片格式，已跳过`);
      return false;
    }
    
    if (!isValidSize) {
      message.warning(`文件 "${file.name}" 超过大小限制（${maxFileSizeText.value}），已跳过`);
      return false;
    }
    
    return true;
  });

  if (validFiles.length === 0 && data.fileList.length > 0) {
    message.error('请选择有效的图片文件！支持格式：' + supportedFormatsText.value);
    return;
  }

  // 创建文件项并生成预览
  const newFiles = [];
  for (const file of validFiles) {
    const preview = await createFilePreview(file.file);
    newFiles.push({
      id: file.id || Date.now() + Math.random(), // 确保每个文件有唯一ID
      name: file.name,
      status: 'pending',
      file: file.file,
      percentage: 0,
      hash: null,
      preview,
      isDragging: false
    });
  }

  fileList.value = newFiles;

  if (validFiles.length > 0) {
    message.success(`已选择 ${validFiles.length} 个有效图片文件`);
  }
};

// 处理图集上传
const handleUpload = async (e) => {
  e.preventDefault();
  
  // 验证表单
  try {
    await formRef.value?.validate();
  } catch (error) {
    message.error('请完善必填信息后再上传');
    return;
  }
  
  if (fileList.value.length === 0) {
    message.error('请至少选择一个文件');
    return;
  }

  isHashing.value = true;
  isLoading.value = true;

  try {
    // 第一步：计算所有文件的哈希值
    message.info('正在计算文件哈希值...');
    for (const fileItem of fileList.value) {
      fileItem.status = 'hashing';
      fileItem.percentage = 0;
      
      try {
        const hash = await calculateFileHash(fileItem.file);
        fileItem.hash = hash;
        fileItem.status = 'hashed';
        fileItem.percentage = 100;
      } catch (error) {
        console.error(`Failed to hash file ${fileItem.name}:`, error);
        fileItem.status = 'error';
        fileItem.percentage = 0;
      }
    }

    isHashing.value = false;

    // 第二步：创建图集
    message.info('正在创建图集...');
    const galleryData = {
      title: model.title.trim(),
      description: model.description || '',
      category_id: model.category_id,
      topic_id: model.topic_id
    };

    const gallery = await galleryStore.createGallery(galleryData);
    message.success('图集创建成功！');

    // 第三步：准备上传数据
    const filesToUpload = fileList.value
      .filter(f => f.status === 'hashed')
      .map((f, index) => ({
        file: f.file,
        hash: f.hash,
        title: `${gallery.title} - ${String(index + 1).padStart(2, '0')}`,
        description: model.description,
        tags: model.tags,
        category_id: model.category_id,
        topic_id: model.topic_id,
        gallery_id: gallery.id,
        gallery_folder: `gallery_${gallery.id}`, // 专门的图集文件夹
        _fileItem: f
      }));

    if (filesToUpload.length === 0) {
      message.warning('没有可上传的文件');
      isLoading.value = false;
      return;
    }

    // 第四步：批量上传图片
    message.info(`准备上传 ${filesToUpload.length} 个图片到图集...`);
    const uploadResults = await uploadGalleryImages(filesToUpload);
    
    // 第五步：设置第一个成功上传的图片为图集封面
    const successfulUploads = uploadResults.filter(result => result.success && result.imageData);
    if (successfulUploads.length > 0) {
      try {
        // 使用API调用设置封面图片
        await apiClient.put(`/galleries/${gallery.id}`, {
          cover_image_id: successfulUploads[0].imageData.id
        });
        message.success(`图集上传完成，封面图片已设置！成功上传 ${successfulUploads.length} 张图片`);
      } catch (error) {
        console.error('Failed to set cover image:', error);
        message.success(`图集上传完成！成功上传 ${successfulUploads.length} 张图片`);
      }
    } else {
      message.warning('图集创建成功，但没有图片上传成功');
    }
    
    // 跳转到图集详情页
    setTimeout(() => {
      router.push({ name: 'gallery', params: { id: gallery.id } });
    }, 2000);

  } catch (error) {
    console.error('Gallery upload failed:', error);
    message.error('图集上传失败：' + (error.response?.data?.detail || error.message));
  } finally {
    isLoading.value = false;
    isHashing.value = false;
  }
};

// 批量上传图集图片
const uploadGalleryImages = async (filesToUpload) => {
  const uploadPromises = filesToUpload.map(async (fileData, index) => {
    // 更新UI状态
    if (fileData._fileItem) {
      fileData._fileItem.status = 'uploading';
      fileData._fileItem.percentage = 0;
    }
    
    const formData = new FormData();
    formData.append('file', fileData.file);
    formData.append('title', fileData.title);
    formData.append('file_hash', fileData.hash);
    formData.append('gallery_id', fileData.gallery_id);
    formData.append('gallery_folder', fileData.gallery_folder);
    if (fileData.description) formData.append('description', fileData.description);
    if (fileData.tags) formData.append('tags', fileData.tags);
    if (fileData.category_id) formData.append('category_id', fileData.category_id);
    if (fileData.topic_id) formData.append('topic_id', fileData.topic_id);
    
    try {
      const response = await apiClient.post('/images/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        onUploadProgress: (progressEvent) => {
          if (fileData._fileItem) {
            const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
            fileData._fileItem.percentage = percentCompleted;
          }
        }
      });
      
      return {
        success: true,
        imageData: response.data,
        index,
        fileData
      };
    } catch (error) {
      return {
        success: false,
        error,
        index,
        fileData
      };
    }
  });

  const results = await Promise.all(uploadPromises);
  
  // 更新UI状态
  results.forEach((result) => {
    const originalFileItem = result.fileData._fileItem;
    if (!originalFileItem) return;

    if (result.success) {
      originalFileItem.status = 'finished';
    } else {
      const error = result.error;
      if (error.response?.status === 409) {
        // 文件已存在，秒传
        originalFileItem.status = 'duplicate';
        originalFileItem.percentage = 100;
      } else {
        originalFileItem.status = 'error';
        console.error("Upload failed:", error);
      }
    }
  });
  
  return results;
};

onMounted(async () => {
  setTitle('图集上传');
  
  // 并行加载所有必要的数据
  const loadTasks = [];
  
  if (!categoryStore.categories.length) {
    loadTasks.push(
      categoryStore.fetchCategories().catch(error => {
        console.error('Failed to load categories:', error);
        message.error('加载分类失败');
      })
    );
  }
  
  if (!topicStore.topics.length) {
    loadTasks.push(
      topicStore.fetchTopics().catch(error => {
        console.error('Failed to load topics:', error);
        message.error('加载专题失败');
      })
    );
  }
  
  if (!settingsStore.settings) {
    loadTasks.push(
      settingsStore.fetchSettings().catch(error => {
        console.error('Failed to load settings:', error);
        message.error('加载系统设置失败');
      })
    );
  }
  
  await Promise.all(loadTasks);
});

// 组件卸载时清理标题
watch(() => router.currentRoute.value.name, () => {
  if (router.currentRoute.value.name !== 'GalleryUpload') {
    clearCustomTitle();
  }
});
</script>

<style scoped>
.gallery-upload-page {
  padding-top: 64px;
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #10b981 0%, #059669 50%, #047857 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 20px 0 24px 0;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 16px;
}

.page-title-section {
  text-align: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 36px;
  font-weight: bold;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.title-icon {
  font-size: 40px;
}

.page-subtitle {
  font-size: 16px;
  margin: 0;
  opacity: 0.9;
  font-weight: 300;
}

/* 主要内容 */
.main-content {
  padding: 24px 0 48px 0;
}

.upload-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 0 24px;
}

.upload-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 区块样式 */
.gallery-info-section,
.upload-section,
.file-list-section,
.submit-section {
  background: white;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  border: 1px solid #e5e7eb;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-header p {
  margin: 0;
  font-size: 14px;
  color: #6b7280;
  margin-left: auto;
}

.section-icon {
  font-size: 20px;
  color: #10b981;
}

/* 表单网格 */
.form-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 10px;
}

/* 表单项样式 */
.form-item {
  margin-bottom: 10px;
}

.custom-input,
.custom-select {
  width: 100%;
}

/* 专题选项样式 */
.topic-option {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.topic-name {
  font-weight: 500;
  color: #1f2937;
}

.topic-desc {
  font-size: 12px;
  color: #6b7280;
  line-height: 1.4;
}

/* 上传区域 */
.custom-upload {
  width: 100%;
}

.upload-dragger {
  width: 100%;
  min-height: 200px;
  border: 2px dashed #d1d5db;
  border-radius: 12px;
  background: #fafafa;
  transition: all 0.3s ease;
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
  padding: 16px 12px;
  text-align: center;
}

.upload-icon-wrapper {
  margin-bottom: 16px;
}

.upload-icon {
  color: #10b981;
}

.upload-text h4 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.upload-hint {
  margin: 0 0 16px 0;
  color: #6b7280;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.supported-formats {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
}

.format-badge {
  background: #10b981;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

/* 文件列表 */
.file-list-container {
  display: grid;
  gap: 10px;
}

.file-item {
  display: flex;
  align-items: center;
  padding: 12px;
  background: #f9fafb;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  position: relative;
  cursor: move;
  transition: all 0.3s ease;
}

.file-item:hover {
  background: #f3f4f6;
  border-color: #d1d5db;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.file-item.dragging {
  opacity: 0.5;
  transform: scale(0.95);
  z-index: 1000;
}

/* 拖拽手柄 */
.drag-handle {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  margin-right: 12px;
  color: #9ca3af;
  cursor: grab;
  transition: color 0.3s ease;
}

.drag-handle:hover {
  color: #6b7280;
}

.drag-handle:active {
  cursor: grabbing;
}

/* 封面标识 */
.cover-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 10;
}

.cover-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background: linear-gradient(135deg, #f59e0b, #d97706);
  border-radius: 50%;
  color: white;
  font-size: 14px;
  box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
  animation: coverPulse 2s infinite;
}

@keyframes coverPulse {
  0%, 100% {
    transform: scale(1);
    box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
  }
  50% {
    transform: scale(1.05);
    box-shadow: 0 4px 16px rgba(245, 158, 11, 0.5);
  }
}

.cover-text {
  color: #f59e0b;
  font-weight: 600;
  font-size: 12px;
  margin-left: 8px;
}

.file-info {
  display: flex;
  align-items: center;
  flex: 1;
  gap: 12px;
}

.file-preview {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  overflow: hidden;
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.file-icon {
  color: #9ca3af;
}

.file-details {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-weight: 500;
  color: #1f2937;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  color: #6b7280;
}

.file-status {
  display: flex;
  align-items: center;
  gap: 4px;
  font-weight: 500;
}

.file-status.duplicate {
  color: #059669;
}

.file-status.finished {
  color: #059669;
}

.file-status.error {
  color: #dc2626;
}

.status-icon {
  font-size: 14px;
}

.file-actions {
  margin-left: 12px;
}

.file-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
  border-radius: 0 0 12px 12px;
  overflow: hidden;
}

/* 提交区域 */
.submit-section {
  text-align: center;
}

.upload-btn {
  min-width: 240px;
  height: 48px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 16px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
  transition: all 0.3s ease;
  margin-bottom: 24px;
}

.upload-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
}

.upload-btn:disabled {
  background: #e5e7eb;
  color: #9ca3af;
  box-shadow: none;
  cursor: not-allowed;
}

.upload-tips {
  max-width: 500px;
  margin: 0 auto;
}

.tip-alert {
  text-align: left;
  border-radius: 12px;
}

.tip-alert ul {
  margin: 8px 0 0 0;
  padding-left: 20px;
}

.tip-alert li {
  margin-bottom: 4px;
  font-size: 14px;
  color: #374151;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .upload-container {
    padding: 0 16px;
  }

  .page-header {
    padding: 16px 0 20px 0;
  }

  .page-title {
    font-size: 28px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-title-section {
    margin-bottom: 20px;
  }

  .main-content {
    padding: 20px 0 40px 0;
  }

  .upload-form {
    gap: 20px;
  }

  .gallery-info-section,
  .upload-section,
  .file-list-section,
  .submit-section {
    padding: 12px;
  }

  .section-header {
    margin-bottom: 10px;
  }

  .section-header h3 {
    font-size: 16px;
  }

  .section-header p {
    font-size: 12px;
  }

  .form-grid {
    gap: 8px;
  }

  .form-item {
    margin-bottom: 8px;
  }

  .upload-content {
    padding: 12px 8px;
  }

  .upload-text h4 {
    font-size: 16px;
  }

  .file-item {
    padding: 10px;
  }

  .file-list-container {
    gap: 8px;
  }

  .upload-btn {
    min-width: 200px;
    height: 44px;
    font-size: 14px;
    margin-bottom: 16px;
  }
}
</style>
