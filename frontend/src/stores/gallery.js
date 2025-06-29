import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import apiClient from '@/api/api.js';

export const useGalleryStore = defineStore('gallery', () => {
  const galleries = ref([]);
  const isLoading = ref(false);
  const hasMore = ref(true);
  const currentPage = ref(1);
  const limit = ref(30);

  /**
   * 获取图集列表 - 支持多种筛选和排序方式
   */
  async function fetchGalleries(reset = false, options = {}) {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      if (reset) {
        currentPage.value = 1;
        galleries.value = [];
        hasMore.value = true;
      }

      const skip = (currentPage.value - 1) * limit.value;
      const params = {
        skip,
        limit: limit.value,
        ...options
      };

      let endpoint = '/galleries';
      
      // 根据不同类型选择不同的API端点
      switch (options.type) {
        case 'popular':
          endpoint = '/galleries/popular';
          break;
        case 'recent':
          endpoint = '/galleries/recent';
          break;
        case 'category':
          params.category_id = options.categoryId;
          break;
        case 'department':
          params.department_id = options.departmentId;
          break;
        case 'daily':
          // 使用默认端点，前端进行今日筛选
          endpoint = '/galleries';
          break;
        case 'timeline':
          params.sort = 'created_at';
          params.order = 'desc';
          break;
        case 'likes':
          params.sort = 'likes_count';
          params.order = 'desc';
          break;
        case 'bookmarks':
          params.sort = 'bookmarks_count';
          params.order = 'desc';
          break;
        case 'downloads':
          params.sort = 'downloads_count';
          params.order = 'desc';
          break;
      }

      const response = await apiClient.get(endpoint, { params });
      
      if (reset) {
        galleries.value = response.data;
      } else {
        galleries.value.push(...response.data);
      }

      if (response.data.length < limit.value) {
        hasMore.value = false;
      } else {
        currentPage.value++;
      }
    } catch (error) {
      console.error('Error fetching galleries:', error);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * 按分类获取图集
   */
  async function fetchGalleriesByCategory(categoryId, reset = false) {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      if (reset) {
        currentPage.value = 1;
        galleries.value = [];
        hasMore.value = true;
      }

      const skip = (currentPage.value - 1) * limit.value;
      const params = {
        skip,
        limit: limit.value,
        category_id: categoryId
      };

      const response = await apiClient.get('/galleries/', { params });
      
      if (reset) {
        galleries.value = response.data;
      } else {
        galleries.value.push(...response.data);
      }

      if (response.data.length < limit.value) {
        hasMore.value = false;
      } else {
        currentPage.value++;
      }
    } catch (error) {
      console.error('Error fetching galleries by category:', error);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * 按部门获取图集
   */
  async function fetchGalleriesByDepartment(departmentId, reset = false) {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      if (reset) {
        currentPage.value = 1;
        galleries.value = [];
        hasMore.value = true;
      }

      const skip = (currentPage.value - 1) * limit.value;
      const params = {
        skip,
        limit: limit.value,
        department_id: departmentId
      };

      const response = await apiClient.get('/galleries/', { params });
      
      if (reset) {
        galleries.value = response.data;
      } else {
        galleries.value.push(...response.data);
      }

      if (response.data.length < limit.value) {
        hasMore.value = false;
      } else {
        currentPage.value++;
      }
    } catch (error) {
      console.error('Error fetching galleries by department:', error);
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * 获取每日更新图集
   */
  async function fetchDailyGalleries(reset = false) {
    return fetchGalleries(reset, { type: 'daily' });
  }

  /**
   * 获取时间线图集
   */
  async function fetchTimelineGalleries(reset = false) {
    return fetchGalleries(reset, { type: 'timeline' });
  }

  /**
   * 获取热门图集（魅力榜）
   */
  async function fetchPopularGalleries(reset = false) {
    return fetchGalleries(reset, { type: 'likes' });
  }

  /**
   * 获取收藏榜图集
   */
  async function fetchBookmarkedGalleries(reset = false) {
    return fetchGalleries(reset, { type: 'bookmarks' });
  }

  /**
   * 获取下载榜图集
   */
  async function fetchDownloadGalleries(reset = false) {
    return fetchGalleries(reset, { type: 'downloads' });
  }

  /**
   * 创建新图集
   */
  async function createGallery(galleryData) {
    try {
      const response = await apiClient.post('/galleries/', galleryData);
      galleries.value.unshift(response.data);
      return response.data;
    } catch (error) {
      console.error('Error creating gallery:', error);
      throw error;
    }
  }

  /**
   * 更新图集
   */
  async function updateGallery(galleryId, galleryData) {
    try {
      const response = await apiClient.put(`/galleries/${galleryId}`, galleryData);
      const index = galleries.value.findIndex(g => g.id === galleryId);
      if (index !== -1) {
        galleries.value[index] = response.data;
      }
      return response.data;
    } catch (error) {
      console.error('Error updating gallery:', error);
      throw error;
    }
  }

  /**
   * 删除图集
   */
  async function deleteGallery(galleryId) {
    try {
      await apiClient.delete(`/galleries/${galleryId}`);
      galleries.value = galleries.value.filter(g => g.id !== galleryId);
    } catch (error) {
      console.error('Error deleting gallery:', error);
      throw error;
    }
  }

  /**
   * 获取单个图集详情
   */
  async function fetchGallery(galleryId) {
    try {
      const response = await apiClient.get(`/galleries/${galleryId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching gallery:', error);
      throw error;
    }
  }

  /**
   * 喜欢/取消喜欢图集
   */
  async function toggleLike(galleryId) {
    try {
      const response = await apiClient.post(`/galleries/${galleryId}/like`);
      const gallery = galleries.value.find(g => g.id === galleryId);
      if (gallery) {
        gallery.liked_by_current_user = response.data.liked;
        gallery.likes_count = response.data.likes_count;
      }
      return response.data;
    } catch (error) {
      console.error('Error toggling gallery like:', error);
      throw error;
    }
  }

  /**
   * 收藏/取消收藏图集
   */
  async function toggleBookmark(galleryId) {
    try {
      const response = await apiClient.post(`/galleries/${galleryId}/bookmark`);
      const gallery = galleries.value.find(g => g.id === galleryId);
      if (gallery) {
        gallery.bookmarked_by_current_user = response.data.bookmarked;
        gallery.bookmarks_count = response.data.bookmarks_count;
      }
      return response.data;
    } catch (error) {
      console.error('Error toggling gallery bookmark:', error);
      throw error;
    }
  }

  /**
   * 搜索图集
   */
  async function searchGalleries(query, reset = false) {
    if (!query.trim()) {
      galleries.value = [];
      return;
    }

    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      if (reset) {
        currentPage.value = 1;
        galleries.value = [];
        hasMore.value = true;
      }

      const skip = (currentPage.value - 1) * limit.value;
      const params = {
        skip,
        limit: limit.value,
        q: query.trim()
      };

      const response = await apiClient.get('/galleries/search', { params });
      
      if (reset) {
        galleries.value = response.data;
      } else {
        galleries.value.push(...response.data);
      }

      if (response.data.length < limit.value) {
        hasMore.value = false;
      } else {
        currentPage.value++;
      }
    } catch (error) {
      console.error('Error searching galleries:', error);
      galleries.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * 重置状态
   */
  function resetState() {
    galleries.value = [];
    isLoading.value = false;
    hasMore.value = true;
    currentPage.value = 1;
  }

  return {
    galleries,
    isLoading,
    hasMore,
    fetchGalleries,
    fetchGalleriesByCategory,
    fetchGalleriesByDepartment,
    fetchDailyGalleries,
    fetchTimelineGalleries,
    fetchPopularGalleries,
    fetchBookmarkedGalleries,
    fetchDownloadGalleries,
    searchGalleries,
    createGallery,
    updateGallery,
    deleteGallery,
    fetchGallery,
    toggleLike,
    toggleBookmark,
    resetState,
  };
}); 