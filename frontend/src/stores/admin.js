import { defineStore } from 'pinia';
import { ref } from 'vue';
import apiClient from '@/api/api.js';

export const useAdminStore = defineStore('admin', () => {
  const users = ref([]);
  const isLoadingUsers = ref(false);
  const images = ref([]);
  const isLoadingImages = ref(false);
  const categories = ref([]);
  const isLoadingCategories = ref(false);
  const dashboardStats = ref(null);
  const isLoadingStats = ref(false);
  
  // 新增：图集管理
  const galleries = ref([]);
  const isLoadingGalleries = ref(false);
  const galleryPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });

  // 新增：评论管理
  const comments = ref([]);
  const isLoadingComments = ref(false);
  const commentPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });
  const commentStats = ref(null);

  // 新增：分类管理分页
  const categoryPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });

  // 新增：用户管理分页
  const userPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });

  // 新增：统计数据
  const categoryStats = ref(null);
  const userStats = ref(null);
  const departmentStats = ref(null);
  const galleryStats = ref(null);
  const topicStats = ref(null);

  async function fetchUsers(page = 1, limit = 10, filters = {}) {
    isLoadingUsers.value = true;
    try {
      const skip = (page - 1) * limit;
      const params = { 
        skip, 
        limit,
        search: filters.search || '',
        status: filters.status || '',
        role: filters.role || '',
        sort: filters.sort || 'created_at',
        order: filters.order || 'desc'
      };
      
      // 并行请求用户数据和总数
      const [usersResponse, countResponse] = await Promise.all([
        apiClient.get('/users/admin', { params }),
        apiClient.get('/users/count', { params: { search: params.search } })
      ]);
      
      users.value = usersResponse.data;
      
      // 更新分页信息
      userPagination.value = {
        page,
        pageSize: limit,
        total: countResponse.data?.total || 0
      };
    } catch (error) {
      console.error('Error fetching users:', error);
      users.value = [];
      userPagination.value.total = 0;
    } finally {
      isLoadingUsers.value = false;
    }
  }

  async function fetchImages(page = 1, limit = 10) {
    isLoadingImages.value = true;
    try {
      const response = await apiClient.get(`/images/all?skip=${(page - 1) * limit}&limit=${limit}`);
      images.value = response.data;
    } catch (error) {
      console.error('Error fetching images:', error);
      images.value = [];
    } finally {
      isLoadingImages.value = false;
    }
  }

  async function fetchCategories(page = 1, limit = 100) {
    isLoadingCategories.value = true;
    try {
      // 获取所有分类（不使用分页，因为分类数量通常不多）
      const response = await apiClient.get('/categories', { 
        params: { skip: 0, limit: 1000 } // 设置较大的limit获取所有分类
      });
      
      categories.value = response.data;
      
      // 更新分页信息
      categoryPagination.value = {
        page: 1,
        pageSize: response.data.length,
        total: response.data.length
      };
    } catch (error) {
      console.error('Error fetching categories:', error);
      categories.value = [];
      categoryPagination.value.total = 0;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  async function fetchDashboardStats() {
    isLoadingStats.value = true;
    try {
      const response = await apiClient.get('/admin/stats');
      dashboardStats.value = response.data;
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
      dashboardStats.value = null; // Clear on error
    } finally {
      isLoadingStats.value = false;
    }
  }

  // 新增：图集管理功能（优化性能）
  async function fetchGalleries(page = 1, limit = 10, filters = {}) {
    isLoadingGalleries.value = true;
    try {
      const skip = (page - 1) * limit;
      const params = {
        skip,
        limit,
        ...filters
      };

      // 并行请求图集数据和总数
      const [galleriesResponse, countResponse] = await Promise.all([
        apiClient.get('/galleries/', { params }),
        apiClient.get('/galleries/count', { params: filters })
      ]);
      
      galleries.value = galleriesResponse.data;
      
      // 更新分页信息
      galleryPagination.value = {
        page,
        pageSize: limit,
        total: countResponse.data.total
      };
    } catch (error) {
      console.error('Error fetching galleries:', error);
      galleries.value = [];
      galleryPagination.value.total = 0;
    } finally {
      isLoadingGalleries.value = false;
    }
  }

  async function deleteGallery(galleryId) {
    try {
      await apiClient.delete(`/galleries/${galleryId}`);
      // 刷新图集列表
      await fetchGalleries(galleryPagination.value.page, galleryPagination.value.pageSize);
    } catch (error) {
      console.error('Error deleting gallery:', error);
      throw error;
    }
  }

  async function updateGallery(galleryId, galleryData) {
    try {
      await apiClient.put(`/galleries/${galleryId}`, galleryData);
      // 刷新图集列表
      await fetchGalleries(galleryPagination.value.page, galleryPagination.value.pageSize);
    } catch (error) {
      console.error('Error updating gallery:', error);
      throw error;
    }
  }

  // 新增：评论管理功能（修复分页估算）
  async function fetchComments(page = 1, limit = 10, filters = {}) {
    isLoadingComments.value = true;
    try {
      const skip = (page - 1) * limit;
      const params = {
        skip,
        limit,
        ...filters
      };

      // 并行请求评论数据和统计信息
      const [commentsResponse, statsResponse] = await Promise.all([
        apiClient.get('/admin/comments', { params }),
        apiClient.get('/admin/comments/stats')
      ]);
      
      comments.value = commentsResponse.data;
      
      // 更新分页信息
      commentPagination.value = {
        page,
        pageSize: limit,
        total: statsResponse.data.total_comments || 0
      };
    } catch (error) {
      console.error('Error fetching comments:', error);
      comments.value = [];
      commentPagination.value.total = 0;
    } finally {
      isLoadingComments.value = false;
    }
  }

  async function deleteComment(commentId) {
    try {
      await apiClient.delete(`/admin/comments/${commentId}`);
      // 刷新评论列表
      await fetchComments(commentPagination.value.page, commentPagination.value.pageSize);
    } catch (error) {
      console.error('Error deleting comment:', error);
      throw error;
    }
  }

  async function fetchCommentStats() {
    try {
      const response = await apiClient.get('/admin/comments/stats');
      commentStats.value = response.data;
    } catch (error) {
      console.error('Error fetching comment stats:', error);
      commentStats.value = null;
    }
  }

  // 新增：获取分类统计数据
  async function fetchCategoryStats() {
    try {
      const response = await apiClient.get('/categories/stats');
      categoryStats.value = response.data;
    } catch (error) {
      console.error('Error fetching category stats:', error);
      categoryStats.value = null;
    }
  }

  // 新增：获取用户统计数据
  async function fetchUserStats() {
    try {
      // 添加时间戳避免缓存问题
      const response = await apiClient.get('/users/stats', {
        params: { _t: Date.now() }
      });
      userStats.value = response.data;
    } catch (error) {
      console.error('Error fetching user stats:', error);
      userStats.value = null;
    }
  }

  // 新增：获取部门统计数据
  async function fetchDepartmentStats() {
    try {
      const response = await apiClient.get('/departments/stats');
      departmentStats.value = response.data;
    } catch (error) {
      console.error('Error fetching department stats:', error);
      departmentStats.value = null;
    }
  }

  // 新增：获取图集统计数据
  async function fetchGalleryStats() {
    try {
      const response = await apiClient.get('/galleries/stats');
      galleryStats.value = response.data;
    } catch (error) {
      console.error('Error fetching gallery stats:', error);
      galleryStats.value = null;
    }
  }

  // 新增：获取专题统计数据
  async function fetchTopicStats() {
    try {
      const response = await apiClient.get('/topics/stats');
      topicStats.value = response.data;
    } catch (error) {
      console.error('Error fetching topic stats:', error);
      topicStats.value = null;
    }
  }

  async function checkUserDeletionEligibility(userId) {
    try {
      const response = await apiClient.get(`/users/${userId}/deletion-check`);
      return response.data;
    } catch (error) {
      console.error('Error checking user deletion eligibility:', error);
      throw error;
    }
  }

  async function deleteUser(userId) {
    try {
      await apiClient.delete(`/users/${userId}`);
      // Refresh user list with current pagination
      await fetchUsers(userPagination.value.page, userPagination.value.pageSize);
    } catch (error) {
      console.error('Error deleting user:', error);
      // Optionally show an error message to the user
      throw error;
    }
  }

  async function deleteImage(imageId) {
    try {
      await apiClient.delete(`/images/${imageId}`);
      await fetchImages(); // Refresh image list
    } catch (error) {
      console.error('Error deleting image:', error);
      throw error;
    }
  }

  async function deleteCategory(categoryId) {
    try {
      await apiClient.delete(`/categories/${categoryId}`);
      await fetchCategories(); // Refresh category list
    } catch (error) {
      console.error('Error deleting category:', error);
      throw error;
    }
  }

  async function updateUser(userId, userData) {
    try {
      await apiClient.put(`/users/${userId}`, userData);
      // Refresh user list with current pagination
      await fetchUsers(userPagination.value.page, userPagination.value.pageSize);
    } catch (error) {
      console.error('Error updating user:', error);
      // Optionally show an error message to the user
      throw error;
    }
  }

  async function createCategory(categoryData) {
    try {
      await apiClient.post('/categories', categoryData);
      await fetchCategories(); // Refresh the list
    } catch (error) {
      console.error('Error creating category:', error);
      throw error;
    }
  }

  async function updateCategory(categoryId, categoryData) {
    try {
      await apiClient.put(`/categories/${categoryId}`, categoryData);
      await fetchCategories(); // Refresh the list
    } catch (error) {
      console.error('Error updating category:', error);
      throw error;
    }
  }

  async function resetUserPassword(userId) {
    try {
      const response = await apiClient.post(`/users/${userId}/reset-password`);
      return response.data.new_password;
    } catch (error) {
      console.error('Error resetting password:', error);
      throw error;
    }
  }

  return {
    users,
    isLoadingUsers,
    userPagination,
    images,
    isLoadingImages,
    categories,
    isLoadingCategories,
    categoryPagination,
    dashboardStats,
    isLoadingStats,
    
    // 新增：图集管理
    galleries,
    isLoadingGalleries,
    galleryPagination,
    
    // 新增：评论管理
    comments,
    isLoadingComments,
    commentPagination,
    commentStats,
    
    // 新增：分类管理分页
    categoryPagination,
    
    // 新增：统计数据
    categoryStats,
    userStats,
    departmentStats,
    galleryStats,
    topicStats,
    
    fetchUsers,
    fetchImages,
    fetchCategories,
    fetchDashboardStats,
    
    // 新增：图集管理方法
    fetchGalleries,
    deleteGallery,
    updateGallery,
    
    // 新增：评论管理方法
    fetchComments,
    deleteComment,
    fetchCommentStats,
    
    // 新增：统计方法
    fetchCategoryStats,
    fetchUserStats,
    fetchDepartmentStats,
    fetchGalleryStats,
    fetchTopicStats,
    
    checkUserDeletionEligibility,
    deleteUser,
    deleteImage,
    deleteCategory,
    updateUser,
    createCategory,
    updateCategory,
    resetUserPassword,
  };
}); 