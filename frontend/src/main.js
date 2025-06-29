import { createApp } from 'vue'
import { createPinia } from 'pinia'
import naive from 'naive-ui'

import App from './App.vue'
import router from './router'

// 全局错误处理
window.addEventListener('unhandledrejection', (event) => {
  // 过滤浏览器扩展相关的错误
  if (event.reason && (
    (event.reason.cmd && event.reason.cmd.includes('background-')) ||
    (event.reason.message && event.reason.message.includes('message channel closed'))
  )) {
    event.preventDefault();
    return;
  }
});

const app = createApp(App)

// Vue应用级错误处理
app.config.errorHandler = (err, vm, info) => {
  // 过滤浏览器扩展相关错误
  if (err && err.message && err.message.includes('background-')) {
    return;
  }
  
  // 其他错误正常处理
  console.error('Vue应用错误:', err, info);
};

app.use(createPinia())
app.use(naive)
app.use(router)

app.mount('#app') 