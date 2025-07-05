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

// 强制清除任何可能的缓存，重新检测
let cachedApiUrl = null;
let lastDetectionTime = 0;
const CACHE_DURATION = 5000; // 5秒缓存

// 动态配置 API 基础 URL
export const getApiBaseUrl = (forceRefresh = false) => {
  const now = Date.now();
  
  // 如果不强制刷新且有缓存，返回缓存值
  if (!forceRefresh && cachedApiUrl && (now - lastDetectionTime) < CACHE_DURATION) {
    return cachedApiUrl;
  }
  
  // 1. 优先使用环境变量（如果明确配置）
  if (import.meta.env.VITE_API_URL) {
    cachedApiUrl = import.meta.env.VITE_API_URL;
    lastDetectionTime = now;
    return cachedApiUrl;
  }
  
  // 2. 基于当前访问地址智能检测
  if (typeof window !== 'undefined') {
    const protocol = window.location.protocol;
    const hostname = window.location.hostname;
    
    let detectedUrl;
    
    // 如果是IP地址访问（非localhost）
    if (hostname !== 'localhost' && hostname !== '127.0.0.1') {
      detectedUrl = `${protocol}//${hostname}:8000`;
    }
    // 如果是localhost访问
    else {
      detectedUrl = 'http://localhost:8000';
    }
    
    cachedApiUrl = detectedUrl;
    lastDetectionTime = now;
    return cachedApiUrl;
  }
  
  // 3. 默认回退
  cachedApiUrl = 'http://localhost:8000';
  lastDetectionTime = now;
  return cachedApiUrl;
};

// 强制刷新API地址的函数
export const refreshApiBaseUrl = () => {
  cachedApiUrl = null;
  lastDetectionTime = 0;
  return getApiBaseUrl(true);
};

export const API_CONFIG = {
  get BASE_URL() {
    return getApiBaseUrl();
  },
  TIMEOUT: 10000,
  RETRY_TIMES: 3
}; 