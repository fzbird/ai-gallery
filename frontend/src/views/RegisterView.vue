<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { useSettingsStore } from '@/stores/settings';
import { useDepartmentStore } from '@/stores/department';
import { NCard, NForm, NFormItem, NInput, NButton, useMessage, NIcon, NSpace, NAlert, NSelect } from 'naive-ui';
import { PersonAddOutline as RegisterIcon, WarningOutline } from '@vicons/ionicons5';

const authStore = useAuthStore();
const settingsStore = useSettingsStore();
const departmentStore = useDepartmentStore();
const message = useMessage();
const router = useRouter();

const formRef = ref(null);
const model = reactive({
  username: '',
  email: '',
  password: '',
  department_id: null
});

// 检查是否开放注册
const isRegistrationEnabled = computed(() => {
  const settings = settingsStore.settings;
  return !settings || settings.enable_registration === undefined || settings.enable_registration === 'true' || settings.enable_registration === true;
});

// 部门选择选项
const departmentOptions = computed(() => {
  const options = [
    { label: '不选择部门', value: null }
  ];
  
  departmentStore.departments.forEach(dept => {
    options.push({
      label: dept.name,
      value: dept.id
    });
  });
  
  return options;
});

const rules = {
  username: {
    required: true,
    message: '请输入用户名',
    trigger: 'blur'
  },
  email: {
    required: true,
    type: 'email',
    message: '请输入有效的邮箱地址',
    trigger: ['input', 'blur']
  },
  password: {
    required: true,
    message: '请输入密码',
    trigger: 'blur'
  }
};

const handleRegister = (e) => {
  e.preventDefault();
  
  if (!isRegistrationEnabled.value) {
    message.error('注册功能已被管理员关闭');
    return;
  }
  
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      try {
        await authStore.register(model);
        message.success('注册成功，已自动为您登录');
        router.push('/');
      } catch (error) {
        if (error.response?.status === 403) {
          message.error('注册功能已被管理员关闭');
        } else {
          message.error(error.response?.data?.detail || '注册失败');
        }
      }
    }
  });
};

// 页面加载时获取系统设置和部门列表
onMounted(async () => {
  if (!settingsStore.settings) {
    await settingsStore.fetchSettings();
  }
  
  // 获取部门列表供注册时选择
  try {
    await departmentStore.fetchDepartments(1, 100); // 获取所有部门
  } catch (error) {
    console.error('Failed to load departments:', error);
  }
});
</script>

<template>
  <div class="auth-container">
    <n-card class="auth-card">
      <div class="card-header">
        <n-icon :component="RegisterIcon" size="40" />
        <h1>创建新账户</h1>
      </div>
      
      <!-- 注册关闭提示 -->
      <n-alert v-if="!isRegistrationEnabled" type="warning" class="registration-disabled-alert">
        <template #icon>
          <n-icon :component="WarningOutline" />
        </template>
        <template #header>
          注册功能已关闭
        </template>
        管理员已暂时关闭用户注册功能。如需注册账户，请联系管理员。
      </n-alert>
      
      <n-form 
        ref="formRef" 
        :model="model" 
        :rules="rules" 
        :disabled="!isRegistrationEnabled"
        @submit.prevent="handleRegister"
      >
        <n-form-item path="username" label="用户名">
          <n-input 
            v-model:value="model.username" 
            placeholder="请输入用户名" 
            size="large" 
            :disabled="!isRegistrationEnabled"
          />
        </n-form-item>
        <n-form-item path="email" label="邮箱">
          <n-input 
            v-model:value="model.email" 
            placeholder="请输入邮箱" 
            size="large" 
            :disabled="!isRegistrationEnabled"
          />
        </n-form-item>
        <n-form-item path="password" label="密码">
          <n-input
            v-model:value="model.password"
            type="password"
            placeholder="请输入密码"
            show-password-on="mousedown"
            size="large"
            :disabled="!isRegistrationEnabled"
          />
        </n-form-item>
        <n-form-item path="department_id" label="所属部门">
          <n-select
            v-model:value="model.department_id"
            :options="departmentOptions"
            placeholder="请选择所属部门（可选）"
            clearable
            size="large"
            :disabled="!isRegistrationEnabled"
          />
        </n-form-item>
        <n-button 
          type="primary" 
          @click="handleRegister" 
          block 
          attr-type="submit" 
          size="large" 
          class="auth-button"
          :disabled="!isRegistrationEnabled"
        >
          {{ isRegistrationEnabled ? '注册' : '注册已关闭' }}
        </n-button>
      </n-form>
      <div class="card-footer">
        <n-space justify="center">
          <span>已经有账户了？</span>
          <n-button text type="primary" @click="router.push('/login')">立即登录</n-button>
        </n-space>
      </div>
    </n-card>
  </div>
</template>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding-top: 0;
  background: linear-gradient(135deg, #8e2de2 0%, #4a00e0 100%);
}

.auth-card {
  width: 100%;
  max-width: 420px;
  background-color: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.1);
  color: white;
}

.card-header {
  text-align: center;
  margin-bottom: 24px;
}

.card-header h1 {
  font-size: 24px;
  font-weight: 600;
  margin-top: 8px;
  color: white;
}

.auth-card :deep(.n-form-item-label) {
  color: rgba(255, 255, 255, 0.8);
}

.auth-card :deep(.n-input) {
  background-color: rgba(255, 255, 255, 0.15) !important;
  border-color: rgba(255, 255, 255, 0.3) !important;
  color: white !important;
}

.auth-card :deep(.n-input__input-el),
.auth-card :deep(.n-input__placeholder) {
  color: white !important;
}

.auth-button {
  margin-top: 8px;
  background: linear-gradient(90deg, #3b82f6, #8b5cf6);
  border: none;
  transition: all 0.3s ease;
}

.auth-button:hover {
  box-shadow: 0 0 15px rgba(139, 92, 246, 0.6);
  transform: translateY(-2px);
}

.card-footer {
  text-align: center;
  margin-top: 20px;
  color: rgba(255, 255, 255, 0.8);
}

.card-footer :deep(.n-button) {
  color: white;
  font-weight: 600;
}

.registration-disabled-alert {
  margin-bottom: 20px;
  background-color: rgba(255, 193, 7, 0.1) !important;
  border-color: rgba(255, 193, 7, 0.3) !important;
}

.registration-disabled-alert :deep(.n-alert__icon),
.registration-disabled-alert :deep(.n-alert__content) {
  color: #ffc107 !important;
}
</style> 