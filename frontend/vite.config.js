import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// 检查是否禁用代理
const isProxyDisabled = process.env.NO_PROXY === 'true';

console.log('Vite 配置信息:', {
  NO_PROXY: process.env.NO_PROXY,
  isProxyDisabled,
  NODE_ENV: process.env.NODE_ENV
});

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3300,
    // 根据环境变量决定是否使用代理
    proxy: isProxyDisabled ? undefined : {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      },
      '/uploads': {
        target: 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
}) 