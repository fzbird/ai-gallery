<script setup>
import { computed, h, ref, onMounted, onUnmounted, watch, nextTick } from 'vue';
import { RouterLink } from 'vue-router';
import { NLayoutHeader, NAvatar, NDropdown, NButton, NSpace, NIcon, NInput, NModal, NCard, NForm, NFormItem, useMessage } from 'naive-ui';
import { useAuthStore } from '@/stores/auth';
import { useCategoryStore } from '@/stores/category';
import { useDepartmentStore } from '@/stores/department';
import { useSettingsStore } from '@/stores/settings';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { useRouter } from 'vue-router';
import { PersonCircleOutline as UserIcon, LogOutOutline as LogoutIcon, KeyOutline as PasswordIcon, SearchOutline as SearchIcon, CloudUploadOutline as UploadIcon, SettingsOutline as AdminIcon, ImageOutline as ImageIcon, FolderOutline as FolderIcon, ChevronDownOutline as ChevronDownIcon, MenuOutline as MenuIcon, CloseOutline as CloseIcon } from '@vicons/ionicons5';
import { API_BASE_URL } from '@/api/api.js';

const router = useRouter();
const authStore = useAuthStore();
const categoryStore = useCategoryStore();
const departmentStore = useDepartmentStore();
const settingsStore = useSettingsStore();
const { currentTitle, updateCategoryNames, updateDepartmentNames } = usePageTitle();

const { isAuthenticated, user } = storeToRefs(authStore);
const { categories } = storeToRefs(categoryStore);
const { departments } = storeToRefs(departmentStore);
const { settings } = storeToRefs(settingsStore);

const message = useMessage();
const searchQuery = ref('');
const showPasswordModal = ref(false);
const passwordFormRef = ref(null);
const passwordModel = ref({
  current_password: '',
  new_password: '',
  confirm_password: ''
});

// 移动端菜单控制
const isMobileMenuOpen = ref(false);
const isMobile = ref(false);

const systemName = computed(() => settings.value?.site_name || 'AI Gallery');
const siteLogo = computed(() => settings.value?.site_logo || null);
const logoExists = ref(true);

// 检查是否开放注册
const isRegistrationEnabled = computed(() => {
  const settingsValue = settings.value;
  return !settingsValue || settingsValue.enable_registration === undefined || settingsValue.enable_registration === 'true' || settingsValue.enable_registration === true;
});

// 处理logo加载错误
function handleLogoError() {
  logoExists.value = false;
}

// 切换移动端菜单
function toggleMobileMenu() {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
}

// 关闭移动端菜单
function closeMobileMenu() {
  isMobileMenuOpen.value = false;
}

// 更可靠的移动端检测 - 减少对屏幕宽度的依赖
function detectMobileDevice() {
  if (typeof window === 'undefined') return false;
  
  let isMobileDevice = false;
  let confidence = 0; // 信心度评分
  const reasons = [];
  
  // 获取各种尺寸信息
  const viewportWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 0;
  const viewportHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0;
  const devicePixelRatio = window.devicePixelRatio || 1;
  
  // 方法1: User-Agent检测（最可靠） - 权重：40
  const userAgent = navigator.userAgent || navigator.vendor || window.opera;
  const mobileRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i;
  if (mobileRegex.test(userAgent)) {
    confidence += 40;
    reasons.push('UserAgent');
  }
  
  // 方法2: 特殊移动端浏览器检测（高可靠性） - 权重：35
  const isWechat = /MicroMessenger/i.test(userAgent);
  const isMiuiBrowser = /MiuiBrowser/i.test(userAgent);
  const isQQBrowser = /QQBrowser/i.test(userAgent);
  const isUCBrowser = /UCBrowser/i.test(userAgent);
  const isBaiduBrowser = /BaiduBrowser/i.test(userAgent);
  const isHuaweiBrowser = /HuaweiBrowser/i.test(userAgent);
  
  if (isWechat || isMiuiBrowser || isQQBrowser || isUCBrowser || isBaiduBrowser || isHuaweiBrowser) {
    confidence += 35;
    reasons.push('SpecialMobileBrowser');
  }
  
  // 方法3: 触摸屏检测（较可靠） - 权重：25
  const hasTouchScreen = 'ontouchstart' in window || navigator.maxTouchPoints > 0 || navigator.msMaxTouchPoints > 0;
  if (hasTouchScreen) {
    confidence += 15; // 基础分
    reasons.push('TouchScreen');
    
    // 如果有触摸屏且视口较小，增加权重
    if (viewportWidth <= 768) {
      confidence += 10;
      reasons.push('TouchScreen+SmallViewport');
    }
  }
  
  // 方法4: 视口宽度检测（作为辅助参考） - 权重：20
  if (viewportWidth <= 480) {
    confidence += 20; // 非常小的视口，很可能是手机
    reasons.push('VerySmallViewport');
  } else if (viewportWidth <= 768) {
    confidence += 10; // 较小的视口，可能是手机或平板
    reasons.push('SmallViewport');
  }
  
  // 方法5: 设备像素比检测（作为辅助） - 权重：10
  if (devicePixelRatio >= 2 && viewportWidth <= 768) {
    confidence += 10; // 高像素比且小视口，很可能是现代手机
    reasons.push('HighDPI+SmallViewport');
  }
  
  // 方法6: 屏幕方向检测 - 权重：5
  if (window.orientation !== undefined) {
    confidence += 5; // 支持屏幕方向的设备通常是移动设备
    reasons.push('OrientationSupport');
  }
  
  // 方法7: 检测是否是桌面环境的特征（负权重）
  const isDesktopUA = /Windows NT|Macintosh|Linux x86/i.test(userAgent) && !/Mobile|Tablet/i.test(userAgent);
  if (isDesktopUA && viewportWidth > 1024) {
    confidence -= 30; // 明显的桌面环境
    reasons.push('DesktopEnvironment');
  }
  
  // 根据信心度判断是否为移动设备
  isMobileDevice = confidence >= 30; // 信心度阈值为30
  
  return isMobileDevice;
}

// 检查屏幕尺寸和设备类型
function checkScreenSize() {
  const newIsMobile = detectMobileDevice();
  if (isMobile.value !== newIsMobile) {
    isMobile.value = newIsMobile;
  }
  
  if (!isMobile.value) {
    isMobileMenuOpen.value = false;
  }
}

// 导航链接数据
const navLinks = [
  { to: '/categories', label: '分类' },
  { to: '/topics', label: '专题' },
  { to: '/departments', label: '部门' },
  { to: '/daily', label: '每日更新' },
  { to: '/popular', label: '魅力榜' },
  { to: '/favorites', label: '收藏榜' },
  { to: '/downloads', label: '下载榜' }
];

const userDropdownOptions = [
  {
    label: '个人主页',
    key: 'profile',
    icon: () => h(NIcon, null, { default: () => h(UserIcon) })
  },
  {
    label: '修改密码',
    key: 'change-password',
    icon: () => h(NIcon, null, { default: () => h(PasswordIcon) })
  },
  {
    type: 'divider',
    key: 'd1'
  },
  {
    label: '退出登录',
    key: 'logout',
    icon: () => h(NIcon, null, { default: () => h(LogoutIcon) })
  }
];

function handleUserDropdown(key) {
  if (key === 'logout') {
    authStore.logout();
    router.push('/');
  }
  if (key === 'profile') {
    router.push({ name: 'profile', params: { username: user.value.username } });
  }
  if (key === 'change-password') {
    passwordModel.value = { current_password: '', new_password: '', confirm_password: '' };
    showPasswordModal.value = true;
  }
}

async function handleChangePassword() {
  if (passwordModel.value.new_password !== passwordModel.value.confirm_password) {
    message.error("新密码和确认密码不匹配。");
    return;
  }
  if (passwordModel.value.new_password.length < 8) {
    message.error("新密码长度不能少于8位。");
    return;
  }

  try {
    await authStore.changePassword({
      current_password: passwordModel.value.current_password,
      new_password: passwordModel.value.new_password
    });
    message.success("密码修改成功！");
    showPasswordModal.value = false;
  } catch (error) {
    const errorMessage = error.response?.data?.detail || '密码修改失败，请检查您的当前密码是否正确。';
    message.error(errorMessage);
  }
}

function performSearch() {
  if (searchQuery.value.trim()) {
    router.push({ name: 'search', query: { q: searchQuery.value } });
    searchQuery.value = '';
    closeMobileMenu(); // 搜索后关闭移动端菜单
  }
}

onMounted(async () => {
  // 立即检查初始屏幕尺寸和设备类型
  checkScreenSize();
  
  // 使用多个时机确保检测准确
  setTimeout(() => checkScreenSize(), 100);
  setTimeout(() => checkScreenSize(), 500);
  setTimeout(() => checkScreenSize(), 1000);
  
  // 使用nextTick确保DOM完全渲染后再次检查
  await nextTick(() => {
    checkScreenSize();
  });
  
  // 监听窗口大小变化和方向变化
  window.addEventListener('resize', checkScreenSize);
  window.addEventListener('orientationchange', () => {
    setTimeout(checkScreenSize, 500); // 延迟检测，等待方向变化完成
  });
  
  // 并行加载基础数据，但不阻塞页面渲染
  try {
    await Promise.allSettled([
      authStore.initializeAuth(),
      categoryStore.fetchCategories(),
      departmentStore.fetchDepartments(),
      settingsStore.fetchSettings()
    ]);
  } catch (error) {
    console.warn('Failed to load some header data:', error);
  }
});

// 监听分类和部门数据更新，同步到页面标题管理
watch(categories, (newCategories) => {
  if (newCategories.length > 0) {
    updateCategoryNames(newCategories);
  }
}, { immediate: true });

watch(departments, (newDepartments) => {
  if (newDepartments.length > 0) {
    updateDepartmentNames(newDepartments);
  }
}, { immediate: true });

onUnmounted(() => {
  window.removeEventListener('resize', checkScreenSize);
  window.removeEventListener('orientationchange', checkScreenSize);
});
</script>

<template>
  <n-layout-header bordered class="header">
    <div class="header-content">
      <!-- Logo区域 - 点击返回首页 -->
      <router-link to="/" class="logo-section" @click="closeMobileMenu">
        <div class="logo">
          <img 
            v-if="siteLogo && logoExists" 
            :src="`${API_BASE_URL()}${siteLogo}`" 
            :alt="systemName"
            class="logo-image"
          />
          <span v-else class="logo-text">{{ systemName }}</span>
        </div>
      </router-link>
      
      <!-- 桌面端导航菜单 -->
      <div class="nav-menu desktop-nav">
        <router-link 
          v-for="link in navLinks" 
          :key="link.to"
          :to="link.to" 
          class="nav-link"
        >
          {{ link.label }}
        </router-link>
      </div>

      <!-- 右侧功能区 -->
      <div class="action-section">
        <!-- 搜索栏 -->
        <div class="search-container">
          <n-input
            v-model:value="searchQuery"
            placeholder="搜索作品/作者/标签"
            @keyup.enter="performSearch"
            clearable
            class="search-input"
          >
            <template #suffix>
              <n-icon @click="performSearch" style="cursor: pointer;">
                <SearchIcon />
              </n-icon>
            </template>
          </n-input>
        </div>

        <!-- 用户功能区 -->
        <div class="user-section">
          <n-space v-if="isAuthenticated && user" align="center" :size="12">
            <router-link to="/gallery/upload" @click="closeMobileMenu">
              <n-button type="primary" size="medium">
                <template #icon>
                  <n-icon><UploadIcon /></n-icon>
                </template>
                <span class="button-text">图片上传</span>
              </n-button>
            </router-link>
            <router-link v-if="user?.is_superuser" to="/admin" @click="closeMobileMenu">
              <n-button size="medium">
                <template #icon>
                  <n-icon><AdminIcon /></n-icon>
                </template>
                <span class="button-text">管理后台</span>
              </n-button>
            </router-link>
            <n-dropdown trigger="hover" :options="userDropdownOptions" @select="handleUserDropdown">
              <n-avatar round size="medium" style="cursor: pointer; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                {{ user.username.charAt(0).toUpperCase() }}
              </n-avatar>
            </n-dropdown>
          </n-space>
          <n-space v-else :size="8">
            <router-link to="/login" @click="closeMobileMenu">
              <n-button size="medium">登录</n-button>
            </router-link>
            <router-link v-if="isRegistrationEnabled" to="/register" @click="closeMobileMenu">
              <n-button type="primary" size="medium">注册</n-button>
            </router-link>
          </n-space>
        </div>

        <!-- 移动端汉堡菜单按钮 - 主要由CSS控制显示 -->
        <n-button 
          class="mobile-menu-button"
          quaternary
          @click="toggleMobileMenu"
          :class="{ 'menu-open': isMobileMenuOpen }"
        >
          <template #icon>
            <n-icon size="20">
              <MenuIcon v-if="!isMobileMenuOpen" />
              <CloseIcon v-else />
            </n-icon>
          </template>
        </n-button>
      </div>
    </div>

    <!-- 移动端导航菜单 - 主要由CSS控制显示 -->
    <div class="mobile-nav" :class="{ 'mobile-nav-open': isMobileMenuOpen }">
      <div class="mobile-nav-content">
        <router-link 
          v-for="link in navLinks" 
          :key="link.to"
          :to="link.to" 
          class="mobile-nav-link"
          @click="closeMobileMenu"
        >
          {{ link.label }}
        </router-link>
      </div>
    </div>

    <!-- 移动端菜单遮罩 -->
    <div 
      v-if="isMobileMenuOpen" 
      class="mobile-nav-overlay"
      @click="closeMobileMenu"
    ></div>

    <!-- 修改密码模态框 -->
    <n-modal v-model:show="showPasswordModal" preset="card" style="width: 500px" title="修改密码" :mask-closable="false">
      <n-form ref="passwordFormRef" :model="passwordModel" @submit.prevent="handleChangePassword">
        <n-form-item path="current_password" label="当前密码">
          <n-input
            v-model:value="passwordModel.current_password"
            type="password"
            show-password-on="mousedown"
            placeholder="请输入您的当前密码"
          />
        </n-form-item>
        <n-form-item path="new_password" label="新密码">
          <n-input
            v-model:value="passwordModel.new_password"
            type="password"
            show-password-on="mousedown"
            placeholder="请输入至少8位的新密码"
          />
        </n-form-item>
        <n-form-item path="confirm_password" label="确认新密码">
          <n-input
            v-model:value="passwordModel.confirm_password"
            type="password"
            show-password-on="mousedown"
            placeholder="请再次输入新密码"
          />
        </n-form-item>
        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 16px;">
          <n-button @click="showPasswordModal = false">取消</n-button>
          <n-button type="primary" @click="handleChangePassword">确认修改</n-button>
        </div>
      </n-form>
    </n-modal>
  </n-layout-header>
</template>

<style scoped>
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  height: 64px;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.header-content {
  display: flex;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
  height: 100%;
  gap: 32px;
}

/* Logo样式 */
.logo-section {
  text-decoration: none;
  color: inherit;
  flex-shrink: 0;
}

.logo {
  display: flex;
  align-items: center;
  transition: all 0.2s ease;
}

.logo-section:hover .logo {
  transform: scale(1.05);
}

.logo-image {
  height: 36px;
  max-width: 160px;
  object-fit: contain;
}

.logo-text {
  font-size: 20px;
  font-weight: bold;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: -0.5px;
}

/* 桌面端导航菜单样式 */
.nav-menu {
  display: flex;
  align-items: center;
  gap: 24px;
  flex: 1;
}

.nav-link {
  color: #374151;
  text-decoration: none;
  font-weight: 500;
  font-size: 15px;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.2s ease;
  position: relative;
}

.nav-link:hover {
  color: #667eea;
  background: rgba(102, 126, 234, 0.08);
}

.nav-link.router-link-active {
  color: #667eea;
  background: rgba(102, 126, 234, 0.12);
}

/* 右侧功能区样式 */
.action-section {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-shrink: 0;
}

.search-container {
  width: 280px;
}

.search-input {
  border-radius: 20px;
}

.user-section {
  display: flex;
  align-items: center;
}

/* 移动端汉堡菜单按钮 - 主要由CSS控制显示 */
.mobile-menu-button {
  display: none;
  width: 48px;
  height: 48px;
  border-radius: 8px;
  transition: all 0.2s ease;
  background: rgba(102, 126, 234, 0.1);
  border: 2px solid rgba(102, 126, 234, 0.3);
}

.mobile-menu-button:hover {
  background: rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.4);
}

.mobile-menu-button.menu-open {
  background: rgba(102, 126, 234, 0.2);
  color: #667eea;
  border-color: rgba(102, 126, 234, 0.5);
}

/* 移动端导航菜单 - 主要由CSS控制显示 */
.mobile-nav {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-100%);
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  z-index: 999;
  display: none; /* 默认隐藏 */
}

.mobile-nav-open {
  transform: translateY(0);
  opacity: 1;
  visibility: visible;
}

.mobile-nav-content {
  padding: 20px 24px;
  max-height: 70vh;
  overflow-y: auto;
}

.mobile-nav-link {
  display: block;
  color: #374151;
  text-decoration: none;
  font-weight: 500;
  font-size: 18px;
  padding: 16px 20px;
  margin: 6px 0;
  border-radius: 12px;
  transition: all 0.2s ease;
  border: 2px solid transparent;
  text-align: center;
}

.mobile-nav-link:hover {
  color: #667eea;
  background: rgba(102, 126, 234, 0.08);
  border-color: rgba(102, 126, 234, 0.2);
}

.mobile-nav-link.router-link-active {
  color: #667eea;
  background: rgba(102, 126, 234, 0.12);
  border-color: rgba(102, 126, 234, 0.3);
  font-weight: 600;
}

/* 移动端菜单遮罩 */
.mobile-nav-overlay {
  position: fixed;
  top: 64px;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 998;
  backdrop-filter: blur(2px);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .header-content {
    padding: 0 16px;
    gap: 20px;
  }
  
  .nav-menu {
    gap: 16px;
  }
  
  .search-container {
    width: 240px;
  }
}

@media (max-width: 992px) {
  .nav-menu {
    gap: 12px;
  }
  
  .nav-link {
    padding: 6px 8px;
    font-size: 14px;
  }
  
  .search-container {
    width: 200px;
  }
}

/* 平板设备适配 */
@media (max-width: 896px) {
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    order: 10;
  }
  
  .mobile-nav {
    display: block !important;
  }
}

/* 手机设备适配 - 使用多种查询确保兼容性 */
@media (max-width: 768px), 
       (max-device-width: 768px), 
       (hover: none) and (pointer: coarse) and (max-width: 1024px) {
  .header-content {
    gap: 12px;
    padding: 0 5px; /* 左右边距统一为5px，让内容更好地撑满屏幕 */
  }
  
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    order: 10;
  }
  
  .mobile-nav {
    display: block !important;
  }
  
  .search-container {
    width: 140px; /* 增加搜索框宽度，更好利用屏幕空间 */
  }
  
  .search-input {
    border-radius: 16px;
  }
  
  .button-text {
    display: none;
  }
  
  .user-section .n-space {
    gap: 6px !important;
  }
  
  .logo-text {
    font-size: 16px;
  }
  
  .logo-image {
    height: 28px;
    max-width: 100px;
  }
  
  .mobile-nav-link {
    min-height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

/* 超小屏幕适配 */
@media (max-width: 480px) {
  .header-content {
    gap: 8px;
    padding: 0 5px; /* 超小屏幕也保持5px左右边距，确保一致性 */
  }
  
  .search-container {
    width: 100px; /* 增加超小屏幕搜索框宽度，更好利用空间 */
  }
  
  .search-input :deep(.n-input__input-el) {
    font-size: 13px;
  }
  
  .search-input :deep(.n-input__placeholder) {
    font-size: 11px;
  }
  
  .logo-text {
    font-size: 14px;
  }
  
  .user-section .n-button {
    min-width: 36px !important;
    padding: 0 8px !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    margin-right: 5px; 
  }
  
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-nav {
    display: block !important;
  }
}

/* 针对触摸设备的额外保障 */
@media (hover: none) and (pointer: coarse) {
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    margin-right: 5px; /* 触摸设备向右移动16px，显著减少右边空白 */
  }
  
  .mobile-nav {
    display: block !important;
  }
  
  .mobile-nav-link {
    min-height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

/* 特殊设备支持 - 确保在所有可能的移动设备上都能正常显示 */
@media screen and (max-device-width: 896px) {
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    margin-right: 5px; /* 特殊设备向右移动16px，显著减少右边空白 */
  }
  
  .mobile-nav {
    display: block !important;
  }
}

/* iOS Safari 特殊处理 */
@media screen and (-webkit-min-device-pixel-ratio: 1) and (max-device-width: 896px) {
  .desktop-nav {
    display: none !important;
  }
  
  .mobile-menu-button {
    display: flex !important;
    align-items: center;
    justify-content: right;
    margin-right: 5px; /* iOS Safari 向右移动16px，显著减少右边空白 */
  }
  
  .mobile-nav {
    display: block !important;
  }
}
</style> 