<template>
  <div class="admin-settings-page">
    <n-spin :show="isLoading">
      <div class="header">
        <h1 class="title">系统设置</h1>
        <p class="subtitle">在这里集中管理和配置系统的各项核心参数</p>
      </div>

      <n-form ref="settingsFormRef" :model="settingsData" label-placement="left" label-width="120px" :style="{ maxWidth: '1400px', margin: '0 auto' }">
        <div class="settings-container">
          <!-- 第一行：站点信息 (占满整行) -->
          <div class="settings-row full-width">
            <n-card title="站点信息" class="settings-card site-info-card" :bordered="false">
              <template #header-extra>
                <n-icon size="20" color="#3b82f6"><InformationCircleOutline /></n-icon>
              </template>
              <div class="site-info-grid">
                <div class="site-basic-info">
                  <n-form-item label="站点名称" path="site_name">
                    <n-input v-model:value="settingsData.site_name" placeholder="输入站点名称" />
                  </n-form-item>
                  <n-form-item label="站点描述" path="site_description">
                    <n-input v-model:value="settingsData.site_description" type="textarea" :rows="3" placeholder="输入站点描述" />
                  </n-form-item>
                  <n-form-item label="程序设计" path="program_developer">
                    <n-input v-model:value="settingsData.program_developer" placeholder="开发者或团队名称" />
                  </n-form-item>
                </div>
                <div class="logo-section">
                  <n-form-item label="站点 Logo" path="site_logo" class="logo-form-item">
                    <div class="logo-upload-container">
                      <!-- Logo预览区域 -->
                      <div class="logo-preview-section" @click="triggerFileUpload">
                        <div class="logo-preview" v-if="settingsData.site_logo">
                          <img :src="logoPreviewUrl" alt="站点Logo" @error="handleImageError" />
                          <div class="logo-overlay">
                            <n-icon size="24" :component="CloudUploadOutline" />
                            <span>点击更换</span>
                          </div>
                        </div>
                        <div class="logo-placeholder" v-else>
                          <n-icon size="40" :component="ImageOutline" />
                          <span>点击上传Logo</span>
                          <small>支持 JPG, PNG, GIF, WebP</small>
                        </div>
                      </div>
                      
                      <!-- 输入和上传控制区域 -->
                      <div class="logo-controls">
                        <n-input 
                          v-model:value="settingsData.site_logo" 
                          placeholder="输入 Logo URL 或点击上传图片" 
                          @input="updateLogoPreview"
                          class="logo-url-input"
                        />
                        <n-button 
                          type="primary" 
                          @click="triggerFileUpload" 
                          :loading="isUploadingLogo"
                          class="upload-button"
                        >
                          <template #icon>
                            <n-icon :component="CloudUploadOutline" />
                          </template>
                          上传Logo
                        </n-button>
                        
                        <!-- 隐藏的文件输入 -->
                        <input 
                          ref="logoFileInput"
                          type="file" 
                          accept="image/*" 
                          style="display: none" 
                          @change="handleLogoFileChange"
                        />
                      </div>
                    </div>
                  </n-form-item>
                </div>
              </div>
            </n-card>
          </div>

          <!-- 第二行：功能设置 (2列) -->
          <div class="settings-row two-columns">
            <!-- 功能与注册 -->
            <n-card title="功能控制" class="settings-card" :bordered="false">
              <template #header-extra>
                <n-icon size="20" color="#10b981"><ToggleOutline /></n-icon>
              </template>
              <div class="form-items-container">
                <n-form-item label="开放注册" class="switch-item">
                  <div class="switch-container">
                    <n-switch v-model:value="settingsData.enable_registration" />
                    <span class="switch-description">允许新用户注册账户</span>
                  </div>
                </n-form-item>
                <n-form-item label="开放评论" class="switch-item">
                  <div class="switch-container">
                    <n-switch v-model:value="settingsData.enable_comments" />
                    <span class="switch-description">允许用户发表评论</span>
                  </div>
                </n-form-item>
              </div>
            </n-card>

            <!-- 内容与显示 -->
            <n-card title="内容配置" class="settings-card" :bordered="false">
              <template #header-extra>
                <n-icon size="20" color="#f59e0b"><NewspaperOutline /></n-icon>
              </template>
              <div class="form-items-container">
                <n-form-item label="每页项目数" path="items_per_page">
                  <n-input-number v-model:value="settingsData.items_per_page" :min="1" :max="100" style="width: 100%" />
                </n-form-item>
                <n-form-item label="精选内容数" path="featured_content_count">
                  <n-input-number v-model:value="settingsData.featured_content_count" :min="0" :max="50" style="width: 100%" />
                </n-form-item>
              </div>
            </n-card>
          </div>

          <!-- 第三行：文件上传和AI服务 (2列) -->
          <div class="settings-row two-columns">
            <!-- 文件上传 -->
            <n-card title="文件上传" class="settings-card" :bordered="false">
              <template #header-extra>
                <n-icon size="20" color="#8b5cf6"><CloudUploadOutline /></n-icon>
              </template>
              <div class="form-items-container">
                <n-form-item label="最大文件大小" path="max_upload_size">
                  <div class="input-with-unit">
                    <n-input-number v-model:value="maxUploadSizeMB" :min="1" :max="100" style="flex: 1" />
                    <span class="unit-label">MB</span>
                  </div>
                </n-form-item>
                <n-form-item label="允许的文件类型" path="allowed_file_types">
                  <n-dynamic-tags v-model:value="allowedFileTypes" />
                </n-form-item>
              </div>
            </n-card>

            <!-- AI 服务 -->
            <n-card title="AI 服务配置" class="settings-card" :bordered="false">
              <template #header-extra>
                <n-icon size="20" color="#ef4444"><SparklesOutline /></n-icon>
              </template>
              <div class="form-items-container">
                <n-form-item label="Ollama API" path="ollama_api">
                  <n-input v-model:value="settingsData.ollama_api" placeholder="http://localhost:11434" />
                </n-form-item>
                <n-form-item label="LLM 模型" path="llm_model">
                  <n-input v-model:value="settingsData.llm_model" placeholder="例如: gemma3:27b" />
                </n-form-item>
              </div>
            </n-card>
          </div>
        </div>

        <!-- 底部操作按钮 -->
        <div class="footer-actions">
          <n-button 
            type="primary" 
            size="large" 
            @click="saveAllSettings" 
            :loading="isSaving" 
            :disabled="isLoading"
            class="save-button"
          >
            <template #icon><n-icon :component="SaveOutline" /></template>
            保存所有设置
          </n-button>
        </div>
      </n-form>

      <template #description>
        <div class="loading-description">
          <n-icon size="20" :component="CloudUploadOutline" />
          正在加载配置...
        </div>
      </template>
    </n-spin>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useSettingsStore } from '@/stores/settings';
import { useAuthStore } from '@/stores/auth';
import { storeToRefs } from 'pinia';
import { useMessage, NSpin, NCard, NForm, NFormItem, NInput, NInputNumber, NSwitch, NButton, NIcon, NInputGroup, NDynamicTags } from 'naive-ui';
import { 
  InformationCircleOutline, ToggleOutline, NewspaperOutline, CloudUploadOutline, 
  SparklesOutline, SaveOutline, ImageOutline 
} from '@vicons/ionicons5';

const settingsStore = useSettingsStore();
const authStore = useAuthStore();
const message = useMessage();
const { settings: storeSettings, isLoading, isSaving } = storeToRefs(settingsStore);

const settingsFormRef = ref(null);
const settingsData = ref({});
const logoFileInput = ref(null);
const isUploadingLogo = ref(false);

// 将字节转换为MB，用于UI显示
const maxUploadSizeMB = computed({
  get: () => settingsData.value.max_upload_size ? Math.round(settingsData.value.max_upload_size / 1024 / 1024) : 0,
  set: (val) => {
    settingsData.value.max_upload_size = val * 1024 * 1024;
  }
});

// 将逗号分隔的字符串与数组进行转换
const allowedFileTypes = computed({
  get: () => {
    if (typeof settingsData.value.allowed_file_types === 'string' && settingsData.value.allowed_file_types) {
      return settingsData.value.allowed_file_types.split(',').map(t => t.trim()).filter(Boolean);
    }
    return Array.isArray(settingsData.value.allowed_file_types) ? settingsData.value.allowed_file_types : [];
  },
  set: (val) => {
    settingsData.value.allowed_file_types = val.join(',');
  }
});

// Logo预览URL计算属性
const logoPreviewUrl = computed(() => {
  const logoUrl = settingsData.value.site_logo;
  if (!logoUrl) return '';
  
  // 如果是相对路径，添加基础URL
  if (logoUrl.startsWith('/')) {
    return `${window.location.origin}${logoUrl}`;
  }
  
  // 如果是完整URL，直接返回
  return logoUrl;
});

// 当从 store 加载数据时，初始化 settingsData
watch(storeSettings, (newSettings) => {
  if (newSettings && Object.keys(newSettings).length > 0) {
    settingsData.value = JSON.parse(JSON.stringify(newSettings));
    
    // 特殊处理布尔值
    settingsData.value.enable_registration = newSettings.enable_registration === 'true' || newSettings.enable_registration === true;
    settingsData.value.enable_comments = newSettings.enable_comments === 'true' || newSettings.enable_comments === true;
    
    // 特殊处理数字
    settingsData.value.items_per_page = parseInt(newSettings.items_per_page, 10);
    settingsData.value.featured_content_count = parseInt(newSettings.featured_content_count, 10);
    settingsData.value.max_upload_size = parseInt(newSettings.max_upload_size, 10);
  }
}, { immediate: true, deep: true });

async function saveAllSettings() {
  try {
    await settingsFormRef.value?.validate();

    // 创建一个用于提交的副本
    const payload = { ...settingsData.value };

    // 显式将布尔值转换为字符串 "true" 或 "false"
    payload.enable_registration = String(payload.enable_registration);
    payload.enable_comments = String(payload.enable_comments);

    await settingsStore.saveSettings(payload);
    message.success('设置保存成功！');
  } catch (errors) {
    console.error("表单验证或保存失败:", errors);
    message.error('请检查所有设置项是否填写正确。');
  }
}

// Logo上传相关函数
function triggerFileUpload() {
  logoFileInput.value?.click();
}

async function handleLogoFileChange(event) {
  const file = event.target.files?.[0];
  if (!file) return;

  // 验证文件类型
  if (!file.type.startsWith('image/')) {
    message.error('请选择图片文件');
    return;
  }

  // 验证文件大小（限制为2MB）
  const maxSize = 2 * 1024 * 1024; // 2MB
  if (file.size > maxSize) {
    message.error('图片文件大小不能超过2MB');
    return;
  }

  try {
    isUploadingLogo.value = true;
    
    // 创建FormData
    const formData = new FormData();
    formData.append('file', file);

    // 调用上传API
    const response = await fetch('/api/v1/admin/upload-logo', {
      method: 'POST',
      body: formData,
      headers: {
        'Authorization': `Bearer ${authStore.token}`
        // 不设置Content-Type，让浏览器自动设置
      },
    });

    if (!response.ok) {
      throw new Error(`上传失败: ${response.status}`);
    }

    const result = await response.json();
    
    // 更新Logo路径
    settingsData.value.site_logo = result.logo_url;
    message.success('Logo上传成功！');
    
  } catch (error) {
    console.error('Logo上传失败:', error);
    message.error('Logo上传失败，请重试');
  } finally {
    isUploadingLogo.value = false;
    // 清空文件输入，允许重新选择同一文件
    if (logoFileInput.value) {
      logoFileInput.value.value = '';
    }
  }
}

function updateLogoPreview() {
  // 当手动输入URL时，触发预览更新
  // 由于使用了computed属性，这里不需要额外处理
}

function handleImageError() {
  message.warning('Logo图片加载失败，请检查URL是否正确');
}

onMounted(() => {
  if (!settingsStore.isLoaded) {
    settingsStore.fetchSettings();
  }
});
</script>

<style scoped>
.admin-settings-page {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
}

.header {
  margin-bottom: 40px;
  text-align: center;
}

.title {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.subtitle {
  font-size: 16px;
  color: #64748b;
  max-width: 600px;
  margin: 0 auto;
}

.settings-container {
  display: flex;
  flex-direction: column;
  gap: 32px;
  max-width: 1400px;
  margin: 0 auto;
}

.settings-row {
  display: flex;
  gap: 24px;
  width: 100%;
}

.full-width {
  width: 100%;
}

.two-columns {
  width: 100%;
}

.two-columns .settings-card {
  flex: 1;
}

.settings-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -2px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}

.settings-card:hover {
  transform: translateY(-2px);
  box-shadow: 
    0 12px 20px -4px rgba(0, 0, 0, 0.15),
    0 4px 6px -2px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.2);
}

.settings-card :deep(.n-card-header) {
  font-size: 18px;
  font-weight: 600;
  padding: 20px 24px 16px 24px;
  border-bottom: 1px solid rgba(229, 231, 235, 0.5);
}

.settings-card :deep(.n-card__content) {
  padding: 24px;
}

.site-info-card {
  width: 100%;
}

.site-info-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 32px;
  align-items: start;
}

.site-basic-info {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo-form-item :deep(.n-form-item__label) {
  text-align: center;
  width: 100%;
  margin-bottom: 16px;
  font-weight: 600;
}

.logo-upload-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  width: 100%;
}

.logo-preview-section {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 140px;
  height: 140px;
  border: 3px dashed #d1d5db;
  border-radius: 16px;
  background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
  overflow: hidden;
  transition: all 0.3s ease;
  position: relative;
}

.logo-preview-section:hover {
  border-color: #3b82f6;
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  cursor: pointer;
  transform: scale(1.02);
}

.logo-preview {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-preview img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 8px;
}

.logo-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  color: #9ca3af;
  text-align: center;
}

.logo-placeholder span {
  font-size: 14px;
  font-weight: 500;
}

.logo-placeholder small {
  font-size: 12px;
  color: #9ca3af;
  font-weight: 400;
}

.logo-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(59, 130, 246, 0.9);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.3s ease;
  border-radius: 16px;
  color: white;
  font-size: 12px;
  font-weight: 600;
}

.logo-preview:hover .logo-overlay {
  opacity: 1;
}

.logo-controls {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.logo-url-input {
  width: 100%;
}

.upload-button {
  width: 100%;
  height: 44px;
  font-weight: 600;
  border-radius: 8px;
}

.form-items-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.switch-item :deep(.n-form-item__blank) {
  width: 100%;
}

.switch-container {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(248, 250, 252, 0.8);
  border-radius: 8px;
  border: 1px solid rgba(229, 231, 235, 0.5);
  transition: all 0.2s ease;
}

.switch-container:hover {
  background: rgba(239, 246, 255, 0.8);
  border-color: rgba(59, 130, 246, 0.3);
}

.switch-description {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
}

.input-with-unit {
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(248, 250, 252, 0.8);
  padding: 8px 12px;
  border-radius: 8px;
  border: 1px solid rgba(229, 231, 235, 0.5);
}

.unit-label {
  font-size: 14px;
  color: #64748b;
  font-weight: 600;
  background: rgba(59, 130, 246, 0.1);
  padding: 4px 8px;
  border-radius: 4px;
  min-width: 32px;
  text-align: center;
}

.footer-actions {
  margin-top: 40px;
  display: flex;
  justify-content: center;
  padding: 32px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  box-shadow: 
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.save-button {
  min-width: 200px;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  border: none;
  transition: all 0.3s ease;
}

.save-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 16px -4px rgba(59, 130, 246, 0.4);
}

.loading-description {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #64748b;
  font-weight: 500;
}

/* Form item优化 */
:deep(.n-form-item__label) {
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}

:deep(.n-input__input-el) {
  border-radius: 8px;
}

:deep(.n-input-number) {
  border-radius: 8px;
}

:deep(.n-switch__rail) {
  background: #e5e7eb;
}

:deep(.n-switch--active .n-switch__rail) {
  background: #3b82f6;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .settings-container {
    max-width: 100%;
    padding: 0 16px;
  }
  
  .title {
    font-size: 28px;
  }
}

@media (max-width: 768px) {
  .admin-settings-page {
    padding: 16px;
  }
  
  .title {
    font-size: 24px;
  }
  
  .subtitle {
    font-size: 14px;
  }
  
  .settings-row {
    flex-direction: column;
  }
  
  .site-info-grid {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .logo-section {
    order: -1;
  }
  
  .logo-preview-section {
    width: 120px;
    height: 120px;
  }
  
  .settings-container {
    gap: 24px;
  }
  
  .footer-actions {
    padding: 24px 16px;
  }
  
  .save-button {
    width: 100%;
    min-width: auto;
  }
}

@media (max-width: 480px) {
  .admin-settings-page {
    padding: 12px;
  }
  
  .settings-card :deep(.n-card__content) {
    padding: 16px;
  }
  
  .settings-card :deep(.n-card-header) {
    padding: 16px 16px 12px 16px;
  }
  
  .logo-preview-section {
    width: 100px;
    height: 100px;
  }
}
</style> 