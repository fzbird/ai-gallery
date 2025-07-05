/**
 * 动态 API 配置
 * 根据当前环境自动设置后端 API 地址
 */

// 获取当前域名和协议
const getCurrentHost = () => {
  if (typeof window !== 'undefined') {
    return `${window.location.protocol}//${window.location.hostname}`;
  }
  return 'http://localhost';
};

// 动态配置 API 基础 URL
export const getApiBaseUrl = () => {
  // 1. 优先使用环境变量
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  
  // 2. 开发环境检测
  if (import.meta.env.DEV) {
    return 'http://localhost:8000';
  }
  
  // 3. 生产环境自动检测
  if (typeof window !== 'undefined') {
    const currentHost = getCurrentHost();
    const currentPort = window.location.port;
    
    // 如果是通过特定端口访问前端，推测后端端口
    if (currentPort === '3300') {
      // 前端在 3300，后端在 8000
      return `${window.location.protocol}//${window.location.hostname}:8000`;
    } else if (currentPort === '80' || currentPort === '443' || !currentPort) {
      // 标准端口，使用反向代理（同域名）
      return currentHost;
    } else {
      // 其他情况，尝试 8000 端口
      return `${window.location.protocol}//${window.location.hostname}:8000`;
    }
  }
  
  // 4. 默认回退
  return 'http://localhost:8000';
};

export const API_CONFIG = {
  BASE_URL: getApiBaseUrl(),
  TIMEOUT: 10000,
  RETRY_TIMES: 3
}; 