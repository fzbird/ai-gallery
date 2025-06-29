import { defineStore } from 'pinia'
import { ref } from 'vue'
import apiClient from '@/api/api.js'

export const useImageStore = defineStore('image', () => {
  const images = ref([])
  const currentImage = ref(null)
  const isLoading = ref(false)
  const hasMore = ref(true)
  let currentPage = 1

  const searchResults = ref([])
  const isSearching = ref(false)

  async function fetchImages(isInitialLoad = false) {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;
    
    if(isInitialLoad) {
      images.value = []
      currentPage = 1
      hasMore.value = true
    }

    try {
      const response = await apiClient.get(`/images/all?skip=${(currentPage - 1) * 20}&limit=20`);
      if (response.data.length > 0) {
        images.value.push(...response.data);
        currentPage++;
      } else {
        hasMore.value = false;
      }
    } catch (error) {
      console.error('Error fetching images:', error);
    } finally {
      isLoading.value = false;
    }
  }

  async function fetchFeedImages(isInitialLoad = false) {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;

    if(isInitialLoad) {
      images.value = []
      currentPage = 1
      hasMore.value = true
    }

    try {
      const response = await apiClient.get(`/images/feed?skip=${(currentPage - 1) * 20}&limit=20`);
      if (response.data.length > 0) {
        images.value.push(...response.data);
        currentPage++;
      } else {
        hasMore.value = false;
      }
    } catch (error) {
      console.error('Error fetching feed images:', error);
      hasMore.value = false; // Stop trying if there's an error like 401
    } finally {
      isLoading.value = false;
    }
  }
  
  async function fetchImageById(id) {
    isLoading.value = true;
    try {
      const response = await apiClient.get(`/images/${id}`);
      currentImage.value = response.data;
      // 浏览量会在后端自动增加，这里获取到的是更新后的数据
    } catch (error) {
      console.error(`Error fetching image ${id}:`, error);
      currentImage.value = null;
    } finally {
      isLoading.value = false;
    }
  }
  
  async function uploadImage(data) {
    const formData = new FormData();
    formData.append('file', data.file);
    formData.append('title', data.title);
    if (data.description) {
      formData.append('description', data.description);
    }
    if (data.tags) {
      formData.append('tags', data.tags);
    }
    if (data.category_id) {
      formData.append('category_id', data.category_id);
    }

    const response = await apiClient.post('/images/', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    // Add the new image to the top of the list
    images.value.unshift(response.data);
    return response.data;
  }
  
  const toggleLike = async (imageId) => {
    try {
      const response = await apiClient.post(`/images/${imageId}/like`);
      await fetchImageById(imageId); // Refresh image data to get updated like status
      return response.data;
    } catch (error) {
      console.error('Error toggling like:', error);
      throw error;
    }
  };

  const toggleBookmark = async (imageId) => {
    try {
      const response = await apiClient.post(`/images/${imageId}/bookmark`);
      await fetchImageById(imageId); // Refresh image data to get updated bookmark status
      return response.data;
    } catch (error) {
      console.error('Error toggling bookmark:', error);
      throw error;
    }
  };
  
  async function searchImages(query) {
    if (!query) {
      searchResults.value = []
      return
    }
    isSearching.value = true
    try {
      const response = await apiClient.get(`/images/search/?q=${query}`)
      searchResults.value = response.data
    } catch (error) {
      console.error('Error searching images:', error)
      searchResults.value = []
    } finally {
      isSearching.value = false
    }
  }
  
  /**
   * Handles the batch upload of multiple images.
   * This process involves checking for duplicates on the backend via hashes
   * before uploading new files.
   * @param {Array<object>} filesToUpload - Array of file objects to upload.
   * Each object contains file, hash, title, description, etc.
   */
  async function uploadImagesBatch(filesToUpload) {
    if (!filesToUpload || filesToUpload.length === 0) {
      return;
    }

    const uploadPromises = filesToUpload.map(fileData => {
      // Update UI status before starting upload
      if (fileData._fileItem) {
        fileData._fileItem.status = 'uploading';
        fileData._fileItem.percentage = 0; // Reset percentage for upload progress
      }
      
      const formData = new FormData();
      formData.append('file', fileData.file);
      formData.append('title', fileData.title);
      formData.append('file_hash', fileData.hash);
      if (fileData.description) formData.append('description', fileData.description);
      if (fileData.tags) formData.append('tags', fileData.tags);
      if (fileData.category_id) formData.append('category_id', fileData.category_id);
      if (fileData.topic_id) formData.append('topic_id', fileData.topic_id);
      
      return apiClient.post('/images/', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        onUploadProgress: (progressEvent) => {
          if (fileData._fileItem) {
            const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
            fileData._fileItem.percentage = percentCompleted;
          }
        }
      });
    });

    const results = await Promise.allSettled(uploadPromises);
    
    results.forEach((result, index) => {
      const originalFileItem = filesToUpload[index]._fileItem;
      if (!originalFileItem) return;

      if (result.status === 'fulfilled') {
        const newImage = result.value.data;
        newImage.ai_status = 'pending';
        originalFileItem.status = 'finished';
        images.value.unshift(newImage);
      } else {
        originalFileItem.status = 'error';
        console.error("An upload failed:", result.reason);
      }
    });
  }
  
  // To be implemented: like, bookmark, etc.
  
  return { images, currentImage, isLoading, hasMore, searchResults, isSearching, fetchImages, fetchFeedImages, fetchImageById, searchImages, uploadImage, toggleLike, toggleBookmark, uploadImagesBatch }
}) 