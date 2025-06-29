<script setup>
import { computed, h, ref, onMounted, onUnmounted, watch } from 'vue';
import { RouterLink } from 'vue-router';
import { NLayoutHeader, NAvatar, NDropdown, NButton, NSpace, NIcon, NInput, NModal, NCard, NForm, NFormItem, useMessage } from 'naive-ui';
import { useAuthStore } from '@/stores/auth';
import { useCategoryStore } from '@/stores/category';
import { useDepartmentStore } from '@/stores/department';
import { useSettingsStore } from '@/stores/settings';
import { usePageTitle } from '@/utils/page-title';
import { storeToRefs } from 'pinia';
import { useRouter } from 'vue-router';
import { PersonCircleOutline as UserIcon, LogOutOutline as LogoutIcon, KeyOutline as PasswordIcon, SearchOutline as SearchIcon, CloudUploadOutline as UploadIcon, SettingsOutline as AdminIcon, ImageOutline as ImageIcon, FolderOutline as FolderIcon, ChevronDownOutline as ChevronDownIcon } from '@vicons/ionicons5';
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
  }
}

onMounted(async () => {
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
  // Cleanup logic if needed
});
</script>

<template>
  <n-layout-header bordered class="header">
    <div class="header-content">
      <!-- Logo区域 - 点击返回首页 -->
      <router-link to="/" class="logo-section">
        <div class="logo">
          <img 
            v-if="siteLogo && logoExists" 
            :src="`${API_BASE_URL}${siteLogo}`" 
            :alt="systemName"
            class="logo-image"
            @error="handleLogoError"
          />
          <span v-else class="logo-text">{{ systemName }}</span>
                </div>
      </router-link>
      
      <!-- 导航菜单区域 -->
      <div class="nav-menu">
        <router-link to="/categories" class="nav-link">分类</router-link>
        <router-link to="/topics" class="nav-link">专题</router-link>
        <router-link to="/departments" class="nav-link">部门</router-link>
        <!-- <router-link to="/users" class="nav-link">用户</router-link> -->
        <router-link to="/daily" class="nav-link">每日更新</router-link>
        <!-- <router-link to="/timeline" class="nav-link">时间线</router-link> -->
        <router-link to="/popular" class="nav-link">魅力榜</router-link>
        <router-link to="/favorites" class="nav-link">收藏榜</router-link>
        <router-link to="/downloads" class="nav-link">下载榜</router-link>
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
            <router-link to="/gallery/upload">
              <n-button type="primary" size="medium">
                <template #icon>
                  <n-icon><UploadIcon /></n-icon>
                </template>
                图片上传
              </n-button>
            </router-link>
            <router-link v-if="user?.is_superuser" to="/admin">
              <n-button size="medium">
                <template #icon>
                  <n-icon><AdminIcon /></n-icon>
                </template>
                管理后台
              </n-button>
            </router-link>
            <n-dropdown trigger="hover" :options="userDropdownOptions" @select="handleUserDropdown">
              <n-avatar round size="medium" style="cursor: pointer; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                {{ user.username.charAt(0).toUpperCase() }}
              </n-avatar>
            </n-dropdown>
          </n-space>
          <n-space v-else :size="8">
            <router-link to="/login">
              <n-button size="medium">登录</n-button>
            </router-link>
            <router-link v-if="isRegistrationEnabled" to="/register">
              <n-button type="primary" size="medium">注册</n-button>
            </router-link>
          </n-space>
        </div>
      </div>
    </div>

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

/* 导航菜单样式 */
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

@media (max-width: 768px) {
  .nav-menu {
    display: none; /* 移动端隐藏导航菜单，后续可添加汉堡菜单 */
  }
  
  .header-content {
    gap: 16px;
  }
  
  .search-container {
    width: 180px;
  }
}
</style> 