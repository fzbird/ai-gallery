import axios from 'axios';
import { useAuthStore } from '@/stores/auth';
import { message } from '@/utils/discrete-api';
import { getApiBaseUrl } from '@/config/api';

// 动态获取API基础URL的函数
export const getAPIBaseURL = () => {
  const url = getApiBaseUrl(true); // 强制刷新
  return url;
};

// 动态API_BASE_URL - 现在是一个getter函数，确保每次访问都重新计算
export const API_BASE_URL = () => getAPIBaseURL();

// 创建动态axios实例的函数
const createApiClient = () => {
  const baseURL = `${getApiBaseUrl()}/api/v1`;
  
  return axios.create({
    baseURL,
    headers: {
      'Content-Type': 'application/json',
    },
  });
};

// 获取动态API客户端
const getApiClient = () => {
  // 每次都创建新的客户端实例，确保使用最新的baseURL
  const client = createApiClient();
  
  // Request interceptor to add the auth token to headers
  client.interceptors.request.use(
    (config) => {
      const authStore = useAuthStore();
      const token = authStore.token;
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor for global error handling
  client.interceptors.response.use(
    (response) => {
      // Any status code that lie within the range of 2xx cause this function to trigger
      return response;
    },
    (error) => {
      // Any status codes that falls outside the range of 2xx cause this function to trigger
      const authStore = useAuthStore();

      if (error.response) {
        const { status, data } = error.response;
        // Handle common errors
        if (status === 401) {
          // Unauthorized: token might be expired or invalid, triggers logout
          // No message needed here as it will redirect to login.
          authStore.logout();
        } else {
          // For other errors (4xx, 5xx), show a global message
          const errorMessage = data?.detail || '请求失败，请稍后重试';
          message.error(errorMessage);
        }
      } else if (error.request) {
        // The request was made but no response was received
        message.error('网络连接失败，请检查您的网络设置');
      } else {
        // Something happened in setting up the request that triggered an Error
        message.error('请求发送失败');
      }
      
      // Forward the error so it can be handled locally if needed
      return Promise.reject(error);
    }
  );
  
  return client;
};

// 专题相关API
export const topics = {
  // 获取专题列表
  getTopics: (params = {}) => getApiClient().get('/topics', { params }),
  
  // 获取专题总数
  getTopicsCount: (params = {}) => getApiClient().get('/topics/count', { params }),
  
  // 搜索专题
  searchTopics: (query, params = {}) => getApiClient().get('/topics/search', { 
    params: { q: query, ...params } 
  }),
  
  // 获取专题详情
  getTopicDetail: (topicId) => getApiClient().get(`/topics/${topicId}`),
  
  // 获取专题下的图集
  getTopicGalleries: (topicId, params = {}) => getApiClient().get(`/topics/${topicId}/galleries`, { params }),
  
  // 根据slug获取专题
  getTopicBySlug: (slug) => getApiClient().get(`/topics/slug/${slug}`),
  
  // 创建专题（管理员）
  createTopic: (topicData) => getApiClient().post('/topics', topicData),
  
  // 更新专题（管理员）
  updateTopic: (topicId, topicData) => getApiClient().put(`/topics/${topicId}`, topicData),
  
  // 删除专题（管理员）
  deleteTopic: (topicId) => getApiClient().delete(`/topics/${topicId}`),
  
  // 获取所有专题（管理员）
  getAllTopicsAdmin: (params = {}) => getApiClient().get('/topics/admin/all', { params }),
  
  // 上传专题封面图片（管理员）
  uploadTopicCover: (topicId, file) => {
    const formData = new FormData();
    formData.append('file', file);
    
    // 获取当前认证token
    const authStore = useAuthStore();
    const token = authStore.token;
    
    if (!token) {
      throw new Error('用户未登录');
    }
    
    return getApiClient().post(`/topics/${topicId}/upload-cover`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        'Authorization': `Bearer ${token}`,
      },
    });
  }
};

// 分类相关API
export const categories = {
  getCategories: (params = {}) => getApiClient().get('/categories/', { params }),
  getCategoryTree: (maxLevel = null) => {
    const params = maxLevel ? { max_level: maxLevel } : {};
    return getApiClient().get('/categories/tree', { params });
  },
  getRootCategories: () => getApiClient().get('/categories/roots'),
  getCategoryChildren: (categoryId) => getApiClient().get(`/categories/${categoryId}/children`),
  getCategoryAncestors: (categoryId) => getApiClient().get(`/categories/${categoryId}/ancestors`),
  getCategoryById: (categoryId) => getApiClient().get(`/categories/${categoryId}`),
  getCategoryStats: () => getApiClient().get('/categories/stats'),
  createCategory: (data) => getApiClient().post('/categories/', data),
  updateCategory: (id, data) => getApiClient().put(`/categories/${id}`, data),
  moveCategory: (categoryId, newParentId) => getApiClient().put(`/categories/${categoryId}/move`, null, {
    params: { new_parent_id: newParentId }
  }),
  deleteCategory: (id, moveContentTo = null) => {
    const params = moveContentTo ? { move_content_to: moveContentTo } : {};
    return getApiClient().delete(`/categories/${id}`, { params });
  }
}

// 部门相关API
export const departments = {
  getDepartments: () => getApiClient().get('/departments/'),
  getDepartmentStats: () => getApiClient().get('/departments/stats'),
  createDepartment: (data) => getApiClient().post('/departments/', data),
  updateDepartment: (id, data) => getApiClient().put(`/departments/${id}`, data),
  deleteDepartment: (id) => getApiClient().delete(`/departments/${id}`),
  checkDepartmentDeletion: (id) => getApiClient().get(`/departments/${id}/deletion-check`)
}

// 为了兼容现有代码，导出动态生成的apiClient
export default getApiClient(); 