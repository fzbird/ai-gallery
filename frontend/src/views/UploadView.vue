<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue';
import { useImageStore } from '@/stores/image';
import { useCategoryStore } from '@/stores/category';
import { useTopicStore } from '@/stores/topic';
import { useSettingsStore } from '@/stores/settings';
import { usePageTitle } from '@/utils/page-title';
import { NCard, NForm, NFormItem, NInput, NButton, NUpload, NSelect, NSpin, useMessage, NIcon, NThing, NProgress, NList, NListItem, NText, NSpace, NBreadcrumb, NBreadcrumbItem } from 'naive-ui';
import { useRouter } from 'vue-router';
import { DocumentAttachOutline, CloudUploadOutline, ImagesOutline, FolderOutline, TimeOutline } from '@vicons/ionicons5';
import { calculateFileHash } from '@/utils/file-hasher';
import AppFooter from '@/components/AppFooter.vue';
import apiClient from '@/api/api.js';

const imageStore = useImageStore();
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

// 验证文件类型
const validateFileType = (file) => {
  const fileName = file.name.toLowerCase();
  const fileType = file.type;
  
  // 检查文件扩展名
  const hasValidExtension = allowedExtensions.value.some(ext => fileName.endsWith(ext));
  
  // 检查MIME类型
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

const handleFileChange = (data) => {
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
    message.error(`请选择有效的图片文件！支持格式：${supportedFormatsText.value}`);
    return;
  }

  fileList.value = validFiles.map(file => ({
    id: file.id,
    name: file.name,
    status: 'pending',
    file: file.file,
    percentage: 0,
    hash: null
  }));

  if (validFiles.length > 0) {
    message.success(`已选择 ${validFiles.length} 个有效图片文件`);
  }
};

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

  // 检查图集标题是否为空
  if (!model.title || model.title.trim() === '') {
    message.error('请输入图集标题');
    return;
  }

  isHashing.value = true;
  isLoading.value = true;
  message.info('正在计算文件哈希值...');

  const hashPromises = fileList.value.map(async (fileItem) => {
    try {
      fileItem.status = 'hashing';
      fileItem.hash = await calculateFileHash(fileItem.file, (progress) => {
        fileItem.percentage = progress;
      });
      fileItem.status = 'hashed';
    } catch (error) {
      fileItem.status = 'error';
      message.error(`${fileItem.name} 哈希计算失败: ${error.message}`);
    }
  });
  await Promise.all(hashPromises);

  isHashing.value = false;
  message.success('哈希计算完成，开始与后端校验文件...');
  
  // --- Step 2: Pre-check hashes with the backend ---
  const allHashes = fileList.value.filter(f => f.hash).map(f => f.hash);
  
  if (allHashes.length === 0) {
    isLoading.value = false;
    return;
  }
  
  let existingHashes = [];
  try {
    const response = await apiClient.post('/images/check-hashes', { hashes: allHashes });
    existingHashes = response.data;
  } catch (error) {
    message.error('校验文件失败，请稍后重试');
    isLoading.value = false;
    return;
  }
  
  fileList.value.forEach(item => {
    if (item.hash && existingHashes.includes(item.hash)) {
      item.status = 'skipped';
      item.percentage = 100;
    }
  });

  const filesToUpload = fileList.value
    .filter(f => f.status === 'hashed')
    .map((f, index) => {
      // 生成友好的图片标题
      const fileName = f.name.replace(/\.[^/.]+$/, ""); // 移除文件扩展名
      let imageTitle;
      
      if (fileList.value.length === 1) {
        // 只有一个文件时，直接使用图集标题
        imageTitle = model.title.trim();
      } else {
        // 多个文件时，使用 "图集标题 - 序号" 格式
        imageTitle = `${model.title.trim()} - ${String(index + 1).padStart(2, '0')}`;
      }
      
      return {
        file: f.file,
        hash: f.hash,
        title: imageTitle,
        description: model.description,
        tags: model.tags,
        category_id: model.category_id,
        topic_id: model.topic_id,
        _fileItem: f, // Pass reference to update UI
      };
    });

  if (filesToUpload.length === 0) {
    message.success('所有文件均已存在或处理完毕。');
    isLoading.value = false;
    return;
  }
  
  message.info(`准备上传 ${filesToUpload.length} 个新文件...`);

  try {
    await imageStore.uploadImagesBatch(filesToUpload);
    message.success('所有上传任务已完成!');
    // setTimeout(() => router.push('/'), 2000); // Redirect after a short delay
  } catch (error) {
    message.error('上传流程遇到严重错误');
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  setTitle('作品上传');
  
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
  if (router.currentRoute.value.name !== 'Upload') {
    clearCustomTitle();
  }
});
</script>

<template>
  <div class="upload-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item href="/">首页</n-breadcrumb-item>
          <n-breadcrumb-item>作品上传</n-breadcrumb-item>
        </n-breadcrumb>

        <!-- 页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">
            <n-icon class="title-icon"><CloudUploadOutline /></n-icon>
            作品上传
          </h1>
          <p class="page-subtitle">
            分享您的创作，让更多人欣赏您的作品
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
                  <h3>选择文件</h3>
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
                            支持多文件和文件夹批量上传，仅限图片格式
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

              <!-- 文件列表 -->
              <div v-if="fileList.length > 0" class="file-list-section">
                <div class="section-header">
                  <n-icon class="section-icon"><DocumentAttachOutline /></n-icon>
                  <h3>文件列表</h3>
                  <p>已选择 {{ fileList.length }} 个文件</p>
                </div>
                
                <div class="file-list">
                  <div v-for="item in fileList" :key="item.id" class="file-item">
                    <div class="file-info">
                      <div class="file-icon">
                        <n-icon><ImagesOutline /></n-icon>
                      </div>
                      <div class="file-details">
                        <div class="file-name">{{ item.name }}</div>
                        <div class="file-status">
                          <n-text v-if="item.status === 'pending'" depth="3">等待处理</n-text>
                          <n-text v-if="item.status === 'hashing'" type="info">正在计算哈希...</n-text>
                          <n-text v-if="item.status === 'hashed'" type="success">等待上传</n-text>
                          <n-text v-if="item.status === 'uploading'" type="warning">上传中...</n-text>
                          <n-text v-if="item.status === 'skipped'" type="info">已跳过 (文件已存在)</n-text>
                          <n-space v-if="item.status === 'finished'" align="center">
                            <n-text type="success">上传成功</n-text>
                            <n-text depth="3">(AI 处理中...)</n-text>
                          </n-space>
                          <n-text v-if="item.status === 'error'" type="error">上传失败</n-text>
                        </div>
                      </div>
                    </div>
                    <div class="file-progress">
                      <n-progress
                        type="line"
                        :status="item.status === 'error' ? 'error' : (item.status === 'finished' || item.status === 'skipped' ? 'success' : 'default')"
                        :percentage="item.percentage"
                        :processing="item.status === 'uploading' || item.status === 'hashing'"
                        :show-indicator="false"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <!-- 作品信息区域 -->
              <div class="metadata-section">
                <div class="section-header">
                  <n-icon class="section-icon"><DocumentAttachOutline /></n-icon>
                  <h3>作品信息</h3>
                  <p>为您的作品添加描述信息，图集标题为必填项</p>
                </div>
                
                <div class="form-grid">
                  <n-form-item label="图集标题" path="title" class="form-item" required>
                    <n-input 
                      v-model:value="model.title" 
                      placeholder="请输入图集标题（必填，2-100个字符）" 
                      class="custom-input"
                      clearable
                    />
                    <template #feedback>
                      <n-text depth="3" style="font-size: 12px;">
                        {{ fileList.length <= 1 ? '单个文件时，图片标题将使用图集标题' : `多个文件时，图片标题格式为：${model.title || '图集标题'} - 01, ${model.title || '图集标题'} - 02...` }}
                      </n-text>
                    </template>
                  </n-form-item>
                  
                  <!-- 分类字段各占一行 -->
                  <n-form-item label="作品分类" path="category_id" class="form-item" style="display: block; width: 100%; margin-bottom: 12px;">
                      <n-select 
                        v-model:value="model.category_id" 
                        :options="categoryStore.selectOptions" 
                        placeholder="选择最适合的分类" 
                        clearable 
                        :loading="categoryStore.isLoading"
                        class="custom-select"
                      />
                    </n-form-item>
                    
                  <n-form-item label="专题分类" path="topic_id" class="form-item" style="display: block; width: 100%; margin-bottom: 12px;">
                      <n-select 
                        v-model:value="model.topic_id" 
                        :options="topicStore.activeSelectOptions" 
                        placeholder="选择专题（可选）" 
                        clearable 
                        :loading="topicStore.isLoading"
                        class="custom-select"
                      >
                        <template #option="{ node, option }">
                          <div class="topic-option">
                            <div class="topic-name">{{ option.label }}</div>
                            <div class="topic-description" v-if="option.description">
                              {{ option.description }}
                            </div>
                          </div>
                        </template>
                        <template #empty>
                          <div style="padding: 12px; text-align: center;">
                            <n-text depth="3">暂无可用专题</n-text>
                          </div>
                        </template>
                      </n-select>
                      <template #feedback>
                        <n-text depth="3" style="font-size: 12px;">
                          专题分类帮助用户发现相关主题的作品，可提高作品曝光度
                        </n-text>
                      </template>
                    </n-form-item>
                  
                  <n-form-item label="作品描述" path="description" class="form-item">
                    <n-input 
                      v-model:value="model.description" 
                      type="textarea" 
                      placeholder="描述您的创作理念、使用的技术或其他相关信息..."
                      :autosize="{ minRows: 3, maxRows: 6 }"
                      class="custom-input"
                    />
                  </n-form-item>
                  
                  <n-form-item label="标签" path="tags" class="form-item">
                    <n-input 
                      v-model:value="model.tags" 
                      placeholder="用逗号分隔，例如: AI绘画,风景,数字艺术" 
                      class="custom-input"
                    />
                  </n-form-item>
                </div>
              </div>

              <!-- 上传按钮 -->
              <div class="submit-section">
                <n-button 
                  type="primary" 
                  @click="handleUpload" 
                  size="large"
                  :loading="isLoading" 
                  :disabled="isHashing || fileList.length === 0 || !model.title || model.title.trim() === ''"
                  class="upload-btn"
                >
                  <template #icon>
                    <n-icon><CloudUploadOutline /></n-icon>
                  </template>
                  {{ 
                    isHashing ? '正在计算哈希...' : 
                    fileList.length === 0 ? '请先选择文件' : 
                    (!model.title || model.title.trim() === '') ? '请输入图集标题' : 
                    `上传 ${fileList.length} 个文件` 
                  }}
                </n-button>
              </div>
            </n-form>
          </n-spin>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <AppFooter theme-color="#6366f1" />
  </div>
</template>

<style scoped>
.upload-page {
  padding-top: 64px; /* Header高度 */
  min-height: 100vh;
  background: #f8fafc;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%);
  color: white;
  border-bottom: 1px solid #e5e7eb;
  padding: 24px 0 32px 0;
}

.container {
  max-width: 900px;
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
  margin-bottom: 32px;
}

.page-title {
  font-size: 32px;
  font-weight: bold;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.title-icon {
  font-size: 36px;
}

.page-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

/* 主要内容区域 */
.main-content {
  padding: 40px 0;
}

.upload-container {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.upload-form {
  padding: 0;
}

/* 区域样式 */
.upload-section,
.file-list-section,
.metadata-section,
.submit-section {
  padding: 16px;
}

.submit-section {
  border-bottom: none;
  background: #fafbfc;
  text-align: center;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1e293b;
}

.section-header p {
  margin: 0;
  font-size: 14px;
  color: #64748b;
  margin-left: auto;
}

.section-icon {
  font-size: 20px;
  color: #6366f1;
}

/* 文件上传区域 */
.custom-upload {
  width: 100%;
}

.upload-dragger {
  border: 2px dashed #d1d5db !important;
  border-radius: 12px !important;
  background: #fafbfc !important;
  transition: all 0.3s ease;
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-dragger:hover {
  border-color: #6366f1 !important;
  background: #f8fafc !important;
}

.upload-content {
  text-align: center;
  padding: 20px 16px;
}

.upload-icon-wrapper {
  margin-bottom: 16px;
}

.upload-icon {
  color: #6366f1;
  opacity: 0.7;
}

.upload-text h4 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
}

.upload-hint {
  margin: 0 0 16px 0;
  color: #64748b;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.supported-formats {
  display: flex;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 8px;
}

.format-badge {
  background: rgba(99, 102, 241, 0.1);
  color: #6366f1;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  border: 1px solid rgba(99, 102, 241, 0.2);
}

/* 专题选项样式 */
.topic-option {
  padding: 4px 0;
}

.topic-name {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 2px;
}

.topic-description {
  font-size: 12px;
  color: #64748b;
  line-height: 1.4;
}

/* 文件列表 */
.file-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.file-item {
  background: #f8fafc;
  border-radius: 8px;
  padding: 16px;
  border: 1px solid #e2e8f0;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.file-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 18px;
}

.file-details {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-weight: 500;
  color: #1e293b;
  margin-bottom: 4px;
  word-break: break-all;
}

.file-status {
  font-size: 14px;
}

.file-progress {
  margin-top: 8px;
}

/* 表单网格 - 强制垂直布局 */
.form-grid {
  display: flex !important;
  flex-direction: column !important;
  gap: 12px;
  width: 100%;
}

.form-grid .form-item {
  display: block !important;
  width: 100% !important;
  margin-bottom: 0 !important;
}

.form-item :deep(.n-form-item-label) {
  font-weight: 600;
  color: #374151;
  font-size: 14px;
}

.custom-input,
.custom-select {
  border-radius: 8px;
}

.custom-input :deep(.n-input__input-el) {
  font-size: 15px;
}

.custom-input :deep(.n-input--focus) {
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2);
}

/* 上传按钮 */
.upload-btn {
  min-width: 200px;
  height: 48px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 16px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
  transition: all 0.3s ease;
}

.upload-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
}

.upload-btn:disabled {
  background: #e5e7eb;
  color: #9ca3af;
  box-shadow: none;
  cursor: not-allowed;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .page-title {
    font-size: 28px;
  }

  .page-subtitle {
    font-size: 14px;
  }

  .page-header {
    padding: 16px 0 24px 0;
  }

  .upload-section,
  .file-list-section,
  .metadata-section,
  .submit-section {
    padding: 16px;
  }

  .upload-content {
    padding: 20px 16px;
  }

  .upload-text h4 {
    font-size: 16px;
  }

  .form-grid {
    gap: 12px;
  }

  .upload-btn {
    width: 100%;
    min-width: unset;
  }
}
</style> 