<script setup>
import { NMessageProvider, NDialogProvider, NNotificationProvider, NConfigProvider, NGlobalStyle } from 'naive-ui'
import { watch } from 'vue'
import { usePageTitle } from '@/utils/page-title'
import TheHeader from './components/TheHeader.vue';

const themeOverrides = {
  common: {
    primaryColor: '#2d6cdf',
    primaryColorHover: '#3b82f6',
    primaryColorPressed: '#1e40af',
  }
}

// 页面标题管理
const { currentTitle } = usePageTitle();

// 监听标题变化，更新document.title
watch(currentTitle, (newTitle) => {
  if (newTitle && newTitle !== 'AI Gallery') {
    document.title = `${newTitle} - AI Gallery`;
  } else {
    document.title = 'AI Gallery';
  }
}, { immediate: true });
</script>

<template>
  <n-config-provider :theme-overrides="themeOverrides">
    <n-global-style />
    <n-message-provider>
      <n-dialog-provider>
        <n-notification-provider>
          <div class="app-container">
            <TheHeader />
            <main class="main-content">
              <router-view />
            </main>
          </div>
        </n-notification-provider>
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1;
  /* 移除padding，让页面内容自己控制间距 */
}
</style> 