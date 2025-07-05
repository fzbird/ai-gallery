import axios from 'axios';
import { useAuthStore } from '@/stores/auth';
import { message } from '@/utils/discrete-api';
import { getApiBaseUrl } from '@/config/api';

// Create a new Axios instance
export const API_BASE_URL = getApiBaseUrl();
const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add the auth token to headers
apiClient.interceptors.request.use(
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
apiClient.interceptors.response.use(
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

// 专题相关API
export const topics = {
  // 获取专题列表
  getTopics: (params = {}) => apiClient.get('/topics', { params }),
  
  // 获取专题总数
  getTopicsCount: (params = {}) => apiClient.get('/topics/count', { params }),
  
  // 搜索专题
  searchTopics: (query, params = {}) => apiClient.get('/topics/search', { 
    params: { q: query, ...params } 
  }),
  
  // 获取专题详情
  getTopicDetail: (topicId) => apiClient.get(`/topics/${topicId}`),
  
  // 获取专题下的图集
  getTopicGalleries: (topicId, params = {}) => apiClient.get(`/topics/${topicId}/galleries`, { params }),
  
  // 根据slug获取专题
  getTopicBySlug: (slug) => apiClient.get(`/topics/slug/${slug}`),
  
  // 创建专题（管理员）
  createTopic: (topicData) => apiClient.post('/topics', topicData),
  
  // 更新专题（管理员）
  updateTopic: (topicId, topicData) => apiClient.put(`/topics/${topicId}`, topicData),
  
  // 删除专题（管理员）
  deleteTopic: (topicId) => apiClient.delete(`/topics/${topicId}`),
  
  // 获取所有专题（管理员）
  getAllTopicsAdmin: (params = {}) => apiClient.get('/topics/admin/all', { params })
};

// 分类相关API
export const categories = {
  getCategories: (params = {}) => apiClient.get('/categories/', { params }),
  getCategoryTree: (maxLevel = null) => {
    const params = maxLevel ? { max_level: maxLevel } : {};
    return apiClient.get('/categories/tree', { params });
  },
  getRootCategories: () => apiClient.get('/categories/roots'),
  getCategoryChildren: (categoryId) => apiClient.get(`/categories/${categoryId}/children`),
  getCategoryAncestors: (categoryId) => apiClient.get(`/categories/${categoryId}/ancestors`),
  getCategoryById: (categoryId) => apiClient.get(`/categories/${categoryId}`),
  getCategoryStats: () => apiClient.get('/categories/stats'),
  createCategory: (data) => apiClient.post('/categories/', data),
  updateCategory: (id, data) => apiClient.put(`/categories/${id}`, data),
  moveCategory: (categoryId, newParentId) => apiClient.put(`/categories/${categoryId}/move`, null, {
    params: { new_parent_id: newParentId }
  }),
  deleteCategory: (id, moveContentTo = null) => {
    const params = moveContentTo ? { move_content_to: moveContentTo } : {};
    return apiClient.delete(`/categories/${id}`, { params });
  }
}

// 部门相关API
export const departments = {
  getDepartments: () => apiClient.get('/departments/'),
  getDepartmentStats: () => apiClient.get('/departments/stats'),
  createDepartment: (data) => apiClient.post('/departments/', data),
  updateDepartment: (id, data) => apiClient.put(`/departments/${id}`, data),
  deleteDepartment: (id) => apiClient.delete(`/departments/${id}`),
  checkDepartmentDeletion: (id) => apiClient.get(`/departments/${id}/deletion-check`)
}

export default apiClient; 