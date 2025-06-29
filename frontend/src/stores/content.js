import { defineStore } from 'pinia'
import apiClient from '@/api/api'

export const useContentStore = defineStore('content', {
  state: () => ({
    contents: [],
    isLoading: false,
    hasMore: true,
    currentContent: null,
    searchResults: [],
    popularContents: [],
    recentContents: []
  }),

  actions: {
    // 获取内容流
    async getContentFeed(params = {}) {
      try {
        const response = await apiClient.get('/contents/feed', { params })
        return response.data
      } catch (error) {
        console.error('获取内容流失败:', error)
        throw error
      }
    },

    // 获取热门内容
    async getPopularContents(params = {}) {
      this.isLoading = true
      try {
        const response = await apiClient.get('/contents/popular', { params })
        this.popularContents = response.data.items || []
        return response.data
      } catch (error) {
        console.error('获取热门内容失败:', error)
        throw error
      } finally {
        this.isLoading = false
      }
    },

    // 获取最新内容
    async getRecentContents(params = {}) {
      this.isLoading = true
      try {
        const response = await apiClient.get('/contents/recent', { params })
        this.recentContents = response.data.items || []
        return response.data
      } catch (error) {
        console.error('获取最新内容失败:', error)
        throw error
      } finally {
        this.isLoading = false
      }
    },

    // 搜索内容
    async searchContents(query, params = {}) {
      this.isLoading = true
      try {
        const response = await apiClient.get('/contents/search', { 
          params: { query, ...params } 
        })
        this.searchResults = response.data.items || []
        return response.data
      } catch (error) {
        console.error('搜索内容失败:', error)
        throw error
      } finally {
        this.isLoading = false
      }
    },

    // 获取单个内容详情
    async getContentById(id) {
      this.isLoading = true
      try {
        const response = await apiClient.get(`/contents/${id}`)
        this.currentContent = response.data
        return response.data
      } catch (error) {
        console.error('获取内容详情失败:', error)
        throw error
      } finally {
        this.isLoading = false
      }
    },

    // 点赞内容
    async likeContent(id) {
      try {
        const response = await apiClient.post(`/contents/${id}/like`)
        // 更新本地状态
        if (this.currentContent && this.currentContent.id === id) {
          this.currentContent.user_liked = response.data.liked
          this.currentContent.likes_count = response.data.likes_count
        }
        return response.data
      } catch (error) {
        console.error('点赞失败:', error)
        throw error
      }
    },

    // 收藏内容
    async bookmarkContent(id) {
      try {
        const response = await apiClient.post(`/contents/${id}/bookmark`)
        // 更新本地状态
        if (this.currentContent && this.currentContent.id === id) {
          this.currentContent.user_bookmarked = response.data.bookmarked
          this.currentContent.bookmarks_count = response.data.bookmarks_count
        }
        return response.data
      } catch (error) {
        console.error('收藏失败:', error)
        throw error
      }
    },

    // 获取图片内容
    async getImages(params = {}) {
      try {
        const response = await apiClient.get('/contents/images', { params })
        return response.data
      } catch (error) {
        console.error('获取图片失败:', error)
        throw error
      }
    },

    // 获取图集内容
    async getGalleries(params = {}) {
      try {
        const response = await apiClient.get('/contents/galleries', { params })
        return response.data
      } catch (error) {
        console.error('获取图集失败:', error)
        throw error
      }
    },

    // 清除状态
    clearState() {
      this.contents = []
      this.searchResults = []
      this.popularContents = []
      this.recentContents = []
      this.currentContent = null
      this.hasMore = true
    }
  }
}) 