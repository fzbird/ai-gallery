import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import apiClient from '@/api/api.js';
import { message } from '@/utils/discrete-api';

export const useSettingsStore = defineStore('settings', () => {
  const settings = ref(null);
  const isLoading = ref(false);
  const isSaving = ref(false);

  /**
   * Fetches the current system settings from the backend.
   */
  async function fetchSettings() {
    isLoading.value = true;
    try {
      const response = await apiClient.get('/admin/settings');
      settings.value = response.data;
    } catch (error) {
      // Global handler will show a message
      settings.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Saves the updated settings to the backend.
   * @param {object} updatedSettings - The new settings object to save.
   */
  async function saveSettings(updatedSettings) {
    isSaving.value = true;
    try {
      const response = await apiClient.put('/admin/settings', updatedSettings);
      settings.value = response.data; // Update state with the saved data
      message.success('设置已成功保存！');
    } catch (error) {
      // Global handler will show an error message, but we can add more specific messages if needed
      message.error('保存设置失败');
      throw error; // Re-throw for component to handle if needed
    } finally {
      isSaving.value = false;
    }
  }

  // Computed properties for easy access to formatted settings
  const allowedFileTypes = computed(() => {
    if (!settings.value?.allowed_file_types) return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'tiff', 'svg', 'bmp'];
    return settings.value.allowed_file_types.split(',').map(type => type.trim().toLowerCase());
  });

  const maxUploadSize = computed(() => {
    return parseInt(settings.value?.max_upload_size) || (50 * 1024 * 1024);
  });

  const maxUploadSizeMB = computed(() => {
    return Math.round(maxUploadSize.value / (1024 * 1024));
  });

  const isLoaded = computed(() => {
    return settings.value !== null;
  });

  return {
    settings,
    isLoading,
    isSaving,
    isLoaded,
    allowedFileTypes,
    maxUploadSize,
    maxUploadSizeMB,
    fetchSettings,
    saveSettings,
  };
}); 