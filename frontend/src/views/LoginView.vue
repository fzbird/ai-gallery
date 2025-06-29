<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { NCard, NForm, NFormItem, NInput, NButton, useMessage, NIcon, NSpace } from 'naive-ui';
import { PersonCircleOutline as UserIcon } from '@vicons/ionicons5';

const authStore = useAuthStore();
const message = useMessage();
const router = useRouter();

const formRef = ref(null);
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

const handleLogin = (e) => {
  e.preventDefault();
  formRef.value?.validate(async (errors) => {
    if (!errors) {
      try {
        await authStore.login(model);
        message.success('登录成功');
        router.push('/');
      } catch (error) {
        message.error(error.response?.data?.detail || '登录失败');
      }
    }
  });
};
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
</style> 