<script setup>
import { h, computed, onMounted, watch } from 'vue';
import { RouterLink, useRoute } from 'vue-router';
import { NLayout, NLayoutSider, NMenu, NIcon, NBreadcrumb, NBreadcrumbItem } from 'naive-ui';
import { SpeedometerOutline, PeopleOutline, ImagesOutline, ListOutline, SettingsOutline, BusinessOutline } from '@vicons/ionicons5';
import { usePageTitle } from '@/utils/page-title';
import { useSettingsStore } from '@/stores/settings';
import { storeToRefs } from 'pinia';

const route = useRoute();
const settingsStore = useSettingsStore();
const { settings } = storeToRefs(settingsStore);

// 获取站点名称
const siteName = computed(() => {
  return settings.value?.site_name || 'AI Gallery';
});

// 使用页面标题工具
const { setTitle } = usePageTitle(siteName.value);

function renderIcon(icon) {
  return () => h(NIcon, null, { default: () => h(icon) });
}

// 动态计算面包屑和标题
const pageInfo = computed(() => {
  const matched = route.matched;
  const lastMatch = matched[matched.length - 1];
  const breadcrumbs = matched.map(record => ({
    label: record.meta.title || record.name,
    path: record.path
  }));
  
  return {
    title: lastMatch?.meta.title || '管理后台',
    breadcrumbs: breadcrumbs
  };
});

// 管理后台页面标题映射
const adminPageTitleMap = {
  '/admin': '仪表盘',
  '/admin/dashboard': '仪表盘', 
  '/admin/users': '用户管理',
  '/admin/departments': '部门管理',
  '/admin/galleries': '图集管理',
  '/admin/topics': '专题管理',
  '/admin/categories': '分类管理',
  '/admin/comments': '评论管理',
  '/admin/settings': '系统设置'
};

// 设置页面标题
const updatePageTitle = () => {
  const adminTitle = adminPageTitleMap[route.path] || '管理后台';
  const fullTitle = `${adminTitle} - 管理后台 - ${siteName.value}`;
  setTitle(fullTitle);
  document.title = fullTitle;
};

// 初始化设置
onMounted(async () => {
  // 如果设置还没有加载，先加载设置
  if (!settings.value) {
    await settingsStore.fetchSettings();
  }
  updatePageTitle();
});

// 监听路由变化更新标题
watch(() => route.path, updatePageTitle);

// 监听站点名称变化更新标题
watch(siteName, updatePageTitle);

const menuOptions = [
  {
    label: () => h(RouterLink, { to: { name: 'admin-dashboard' } }, { default: () => '仪表盘' }),
    key: 'admin-dashboard',
    icon: renderIcon(SpeedometerOutline),
    meta: { title: '仪表盘' }
  },
  {
    label: '内容管理',
    key: 'content-management',
    icon: renderIcon(ImagesOutline),
    children: [
       {
        label: () => h(RouterLink, { to: { name: 'admin-galleries' } }, { default: () => '图集管理' }),
        key: 'admin-galleries',
        meta: { title: '图集管理' }
      },
      {
        label: () => h(RouterLink, { to: { name: 'admin-topics' } }, { default: () => '专题管理' }),
        key: 'admin-topics',
        meta: { title: '专题管理' }
      },
      {
        label: () => h(RouterLink, { to: { name: 'admin-categories' } }, { default: () => '分类管理' }),
        key: 'admin-categories',
        meta: { title: '分类管理' }
      },
      {
        label: () => h(RouterLink, { to: { name: 'admin-comments' } }, { default: () => '评论管理' }),
        key: 'admin-comments',
        meta: { title: '评论管理' }
      },
    ],
  },
  {
    label: '用户管理',
    key: 'user-management',
    icon: renderIcon(PeopleOutline),
    children: [
      {
        label: () => h(RouterLink, { to: { name: 'admin-users' } }, { default: () => '用户列表' }),
        key: 'admin-users',
        meta: { title: '用户列表' }
      },
      {
        label: () => h(RouterLink, { to: { name: 'admin-departments' } }, { default: () => '部门管理' }),
        key: 'admin-departments',
        meta: { title: '部门管理' }
      },
    ],
  },
  {
    label: () => h(RouterLink, { to: { name: 'admin-settings' } }, { default: () => '系统设置' }),
    key: 'admin-settings',
    icon: renderIcon(SettingsOutline),
    meta: { title: '系统设置' }
  },
];
</script>

<template>
  <div class="admin-layout-wrapper">
    <!-- 标准页面头部 -->
    <div class="page-header">
      <div class="container">
        <!-- 动态面包屑导航 -->
        <n-breadcrumb class="breadcrumb">
          <n-breadcrumb-item>
            <router-link to="/">首页</router-link>
          </n-breadcrumb-item>
          <n-breadcrumb-item v-for="crumb in pageInfo.breadcrumbs" :key="crumb.path">
            <router-link :to="crumb.path">{{ crumb.label }}</router-link>
          </n-breadcrumb-item>
        </n-breadcrumb>
        
        <!-- 动态页面标题 -->
        <div class="page-title-section">
          <h1 class="page-title">{{ pageInfo.title }}</h1>
          <p class="page-subtitle">在此管理和配置您的网站内容与设置</p>
        </div>
      </div>
    </div>

    <!-- 管理后台主体 -->
    <div class="main-content">
      <div class="container">
        <n-layout has-sider class="admin-layout">
          <n-layout-sider 
            bordered 
            collapse-mode="width" 
            :collapsed-width="64" 
            :width="240" 
            show-trigger
            class="admin-sider"
          >
            <n-menu 
              :options="menuOptions" 
              :collapsed-width="64" 
              :collapsed-icon-size="22"
              class="admin-menu"
            />
          </n-layout-sider>
          
          <n-layout class="admin-main-content">
            <div class="content-wrapper">
              <router-view />
            </div>
          </n-layout>
        </n-layout>
      </div>
    </div>

    <!-- 版权信息 -->
    <div class="admin-footer">
      <div class="container">
        <div class="footer-content">
          <p class="copyright">
            © {{ new Date().getFullYear() }} {{ siteName }}. 保留所有权利.
          </p>
          <div class="footer-links">
            <span class="footer-link">联系我们</span>
            <span class="footer-separator">|</span>
            <span class="footer-link">用户协议</span>
            <span class="footer-separator">|</span>
            <span class="footer-link">隐私政策</span>
            <span class="footer-separator">|</span>
            <span class="footer-link">帮助中心</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-layout-wrapper {
  padding-top: 64px; /* 主Header高度 */
  min-height: 100vh;
  background-color: #f8fafc;
}

/* 统一页面头部样式 */
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 24px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.breadcrumb {
  margin-bottom: 16px;
}

.breadcrumb :deep(.n-breadcrumb-item__link),
.breadcrumb :deep(.n-breadcrumb-item__separator) {
  color: rgba(255, 255, 255, 0.8) !important;
}

.breadcrumb :deep(.n-breadcrumb-item__link:hover) {
  color: white !important;
}

.page-title-section {
  margin-top: 0; /* 移除顶部外边距，因为面包屑已经有了 */
  text-align: center; /* 改回居中对齐，与其他页面保持一致 */
  margin-bottom: 24px; /* 添加下边距，匹配其他页面的search-section高度 */
}

.page-title {
  font-size: 32px;
  font-weight: bold;
  color: white;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.page-subtitle {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

/* 主内容区 */
.main-content {
  padding: 32px 0;
}

.admin-layout {
  display: flex;
  background-color: transparent;
}

.admin-sider {
  background-color: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.admin-menu {
  border-right: none;
}

.admin-main-content {
  background-color: transparent;
  padding-left: 24px;
}

.content-wrapper {
  background-color: white;
  padding: 24px;
  border-radius: 12px;
  min-height: calc(100vh - 64px - 142px - 64px - 80px); /* 视口 - 顶部header - 页面header - 上下padding - 底部footer */
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

/* 版权信息样式 */
.admin-footer {
  background-color: #f8fafc;
  border-top: 1px solid #e2e8f0;
  padding: 20px 0;
  margin-top: 32px;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.copyright {
  margin: 0;
  font-size: 14px;
  color: #64748b;
}

.footer-links {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.footer-link {
  color: #64748b;
  cursor: pointer;
  transition: color 0.2s ease;
}

.footer-link:hover {
  color: #3b82f6;
}

.footer-separator {
  color: #cbd5e1;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    text-align: center;
  }
  
  .footer-links {
    flex-wrap: wrap;
    justify-content: center;
  }
}
</style> 