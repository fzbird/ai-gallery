<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { NCard, NForm, NFormItem, NInput, NButton, useMessage, NIcon, NSpace, NCheckbox } from 'naive-ui';
import { PersonCircleOutline as UserIcon } from '@vicons/ionicons5';

const authStore = useAuthStore();
const message = useMessage();
const router = useRouter();

const formRef = ref(null);
const rememberPassword = ref(false);
const model = reactive({
  username: '',
  password: ''
});

const rules = {
  username: {
    required: true,
    message: '请输入用户名',
    trigger: 'blur'
  },
  password: {
    required: true,
    message: '请输入密码',
    trigger: 'blur'
  }
};

// 保存登录凭据到localStorage
const saveCredentials = (username, password) => {
  if (rememberPassword.value) {
    const credentials = {
      username,
      password: btoa(password), // base64编码密码
      timestamp: Date.now(),
      expires: Date.now() + (30 * 24 * 60 * 60 * 1000) // 30天后过期
    };
    localStorage.setItem('rememberedCredentials', JSON.stringify(credentials));
  } else {
    // 如果没有选择记住密码，清除已保存的凭据
    localStorage.removeItem('rememberedCredentials');
  }
};

// 加载保存的登录凭据
const loadCredentials = () => {
  try {
    const saved = localStorage.getItem('rememberedCredentials');
    if (saved) {
      const credentials = JSON.parse(saved);
      
      // 检查是否过期
      if (credentials.expires && Date.now() > credentials.expires) {
        localStorage.removeItem('rememberedCredentials');
        return;
      }
      
      // 填充表单
      model.username = credentials.username || '';
      model.password = credentials.password ? atob(credentials.password) : '';
      rememberPassword.value = true;
    }
  } catch (error) {
    console.warn('Failed to load saved credentials:', error);
    localStorage.removeItem('rememberedCredentials');
  }
};

// 清除保存的凭据
const clearCredentials = () => {
  localStorage.removeItem('rememberedCredentials');
  rememberPassword.value = false;
  message.info('已清除保存的登录信息');
};

const handleLogin = (e) => {
  e.preventDefault();
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      try {
        await authStore.login(model);
        
        // 保存凭据（如果用户选择记住密码）
        saveCredentials(model.username, model.password);
        
        message.success('登录成功');
        router.push('/');
      } catch (error) {
        message.error(error.response?.data?.detail || '登录失败');
      }
    }
  });
};

// 组件挂载时加载保存的凭据
onMounted(() => {
  loadCredentials();
});
</script>

<template>
  <div class="auth-container">
    <n-card class="auth-card">
      <div class="card-header">
        <n-icon :component="UserIcon" size="40" />
        <h1>欢迎回来</h1>
      </div>
      <n-form ref="formRef" :model="model" :rules="rules" @submit.prevent="handleLogin">
        <n-form-item path="username" label="用户名">
          <n-input v-model:value="model.username" placeholder="请输入用户名" size="large" />
        </n-form-item>
        <n-form-item path="password" label="密码">
          <n-input
            v-model:value="model.password"
            type="password"
            placeholder="请输入密码"
            show-password-on="mousedown"
            size="large"
          />
        </n-form-item>
        
        <!-- 记住密码选项 -->
        <div class="remember-section">
          <n-checkbox v-model:checked="rememberPassword" class="remember-checkbox">
            记住密码（30天）
          </n-checkbox>
          <n-button
            v-if="rememberPassword && (model.username || model.password)"
            text
            size="small"
            @click="clearCredentials"
            class="clear-button"
          >
            清除记住的密码
          </n-button>
        </div>
        
        <n-button type="primary" @click="handleLogin" block attr-type="submit" size="large" class="auth-button">
          登录
        </n-button>
      </n-form>
      <div class="card-footer">
        <n-space justify="center">
          <span>还没有账户？</span>
          <n-button text type="primary" @click="router.push('/register')">立即注册</n-button>
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

/* 记住密码区域样式 */
.remember-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 16px 0;
  padding: 8px 0;
}

.remember-checkbox :deep(.n-checkbox__label) {
  color: rgba(255, 255, 255, 0.9) !important;
  font-size: 14px;
}

.remember-checkbox :deep(.n-checkbox-box) {
  border-color: rgba(255, 255, 255, 0.4) !important;
  background-color: rgba(255, 255, 255, 0.1) !important;
}

.remember-checkbox :deep(.n-checkbox-box__border) {
  border-color: rgba(255, 255, 255, 0.4) !important;
}

.remember-checkbox :deep(.n-checkbox--checked .n-checkbox-box) {
  background-color: rgba(59, 130, 246, 0.8) !important;
  border-color: rgba(59, 130, 246, 0.8) !important;
}

.clear-button {
  color: rgba(255, 255, 255, 0.7) !important;
  font-size: 12px;
  text-decoration: underline;
  transition: color 0.3s ease;
}

.clear-button:hover {
  color: rgba(255, 255, 255, 1) !important;
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

/* 响应式设计 */
@media (max-width: 480px) {
  .auth-container {
    padding: 16px;
    align-items: flex-start;
    padding-top: 20vh;
  }
  
  .auth-card {
    max-width: 100%;
    padding: 20px;
  }
  
  .card-header h1 {
    font-size: 20px;
  }
  
  .remember-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    margin: 12px 0;
  }
  
  .clear-button {
    align-self: flex-end;
    margin-top: 4px;
  }
}
</style> 