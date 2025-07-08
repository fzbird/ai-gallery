import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { topics } from '@/api/api';

export const useTopicStore = defineStore('topic', () => {
  const topicList = ref([]);
  const isLoading = ref(false);
  const error = ref(null);
  
  // 分页状态
  const topicPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });

  // 计算选项用于select组件
  const selectOptions = computed(() => {
    return topicList.value.map(topic => ({
      label: topic.name,
      value: topic.id,
      description: topic.description
    }));
  });

  // 活跃的专题选项
  const activeSelectOptions = computed(() => {
    return topicList.value
      .filter(topic => topic.is_active !== false) // 显示is_active为true或undefined的专题
      .map(topic => ({
        label: topic.name,
        value: topic.id,
        description: topic.description
      }));
  });

  // 获取专题列表 - 重构为支持分页
  const fetchTopics = async (page = 1, limit = 10, params = {}) => {
    if (isLoading.value) return;
    
    isLoading.value = true;
    error.value = null;
    
    try {
      const skip = (page - 1) * limit;
      const requestParams = {
        skip,
        limit,
        ...params
      };
      
      // 并行请求数据和总数
      const [topicsResponse, countResponse] = await Promise.all([
        topics.getTopics(requestParams),
        topics.getTopicsCount(params)
      ]);
      
      topicList.value = topicsResponse.data || [];
      
      // 更新分页信息
      topicPagination.value = {
        page,
        pageSize: limit,
        total: countResponse.data?.total || 0
      };
    } catch (err) {
      error.value = err.response?.data?.detail || '获取专题列表失败';
      console.error('获取专题失败:', err);
      topicList.value = [];
      topicPagination.value.total = 0;
    } finally {
      isLoading.value = false;
    }
  };

  // 获取所有专题 (管理员功能)
  const fetchAdminTopics = async (page = 1, limit = 10, params = {}) => {
    isLoading.value = true;
    error.value = null;
    try {
      const response = await topics.getAllTopicsAdmin({ page, limit, ...params });
      const data = response.data;
      topicList.value = data.items || [];
      topicPagination.value = {
        page,
        pageSize: limit,
        total: data.total || 0,
      };
    } catch (err) {
      error.value = err.response?.data?.detail || '获取所有专题列表失败';
      console.error('获取所有专题失败:', err);
      topicList.value = [];
      topicPagination.value.total = 0;
    } finally {
      isLoading.value = false;
    }
  };

  // 搜索专题
  const searchTopics = async (query, params = {}) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.searchTopics(query, params);
      return response.data || [];
    } catch (err) {
      error.value = err.response?.data?.detail || '搜索专题失败';
      console.error('搜索专题失败:', err);
      return [];
    } finally {
      isLoading.value = false;
    }
  };

  // 获取专题详情
  const getTopicDetail = async (topicId) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.getTopicDetail(topicId);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.detail || '获取专题详情失败';
      console.error('获取专题详情失败:', err);
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 根据slug获取专题
  const getTopicBySlug = async (slug) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.getTopicBySlug(slug);
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.detail || '获取专题失败';
      console.error('获取专题失败:', err);
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 获取专题下的图集
  const getTopicGalleries = async (topicId, params = {}) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.getTopicGalleries(topicId, params);
      return response.data || [];
    } catch (err) {
      error.value = err.response?.data?.detail || '获取专题图集失败';
      console.error('获取专题图集失败:', err);
      return [];
    } finally {
      isLoading.value = false;
    }
  };

  // 创建专题 (管理员功能)
  const createTopic = async (topicData, isAdmin = false) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.createTopic(topicData);
      // 刷新列表
      isAdmin ? await fetchAdminTopics() : await fetchTopics();
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.detail || '创建专题失败';
      console.error('创建专题失败:', err);
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 更新专题 (管理员功能)
  const updateTopic = async (topicId, topicData, isAdmin = false) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      const response = await topics.updateTopic(topicId, topicData);
      // 刷新列表
      isAdmin ? await fetchAdminTopics() : await fetchTopics();
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.detail || '更新专题失败';
      console.error('更新专题失败:', err);
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 删除专题 (管理员功能)
  const deleteTopic = async (topicId, isAdmin = false) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      await topics.deleteTopic(topicId);
      // 刷新列表
      isAdmin ? await fetchAdminTopics() : await fetchTopics();
    } catch (err) {
      error.value = err.response?.data?.detail || '删除专题失败';
      console.error('删除专题失败:', err);
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 上传专题封面图片 (管理员功能)
  const uploadTopicCover = async (topicId, file) => {
    isLoading.value = true;
    error.value = null;
    
    try {
      console.log('Uploading cover for topic:', topicId);
      console.log('File info:', { name: file.name, size: file.size, type: file.type });
      
      const response = await topics.uploadTopicCover(topicId, file);
      console.log('Upload successful:', response.data);
      
      // 刷新专题列表以更新封面显示
      await fetchAdminTopics();
      return response;
    } catch (err) {
      console.error('上传封面失败:', err);
      console.error('Error details:', {
        status: err.response?.status,
        data: err.response?.data,
        message: err.message
      });
      
      error.value = err.response?.data?.detail || err.message || '上传封面失败';
      throw err;
    } finally {
      isLoading.value = false;
    }
  };

  // 重置状态
  const reset = () => {
    topicList.value = [];
    isLoading.value = false;
    error.value = null;
  };

  return {
    // 状态
    topics: topicList, // 添加别名，以匹配AdminTopics.vue中的使用
    topicList,
    isLoadingTopics: isLoading, // 添加别名
    isLoading,
    error,
    topicPagination,
    
    // 计算属性
    selectOptions,
    activeSelectOptions,
    
    // 方法
    fetchTopics,
    fetchAdminTopics,
    searchTopics,
    getTopicDetail,
    getTopicBySlug,
    getTopicGalleries,
    createTopic,
    updateTopic,
    deleteTopic,
    uploadTopicCover,
    reset
  };
}); 