import { defineStore } from 'pinia';
import { ref } from 'vue';
import apiClient from '@/api/api.js';

export const useUserStore = defineStore('user', () => {
  const profile = ref(null);
  const uploadedImages = ref([]);
  const likedImages = ref([]);
  const users = ref([]);
  const isLoadingProfile = ref(false);
  const isLoadingUploaded = ref(false);
  const isLoadingLiked = ref(false);
  const isLoadingUsers = ref(false);
  const hasMoreUsers = ref(true);

  async function fetchUserProfile(username) {
    isLoadingProfile.value = true;
    try {
      const response = await apiClient.get(`/users/${username}`);
      profile.value = response.data;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      if (error.response?.status === 404) {
        profile.value = null;
      } else {
        // 对于其他错误，设置一个默认的用户对象
        profile.value = {
          username: username,
          bio: null,
          followers_count: 0,
          following_count: 0,
          is_following: false,
          created_at: null,
          department: null
        };
      }
    } finally {
      isLoadingProfile.value = false;
    }
  }

  async function fetchUploadedImages(username, page = 1, limit = 20) {
    isLoadingUploaded.value = true;
    try {
      const response = await apiClient.get(`/users/${username}/images?page=${page}&limit=${limit}`);
      uploadedImages.value = response.data;
    } catch (error) {
      console.error('Error fetching uploaded images:', error);
      uploadedImages.value = [];
    } finally {
      isLoadingUploaded.value = false;
    }
  }

  async function fetchLikedImages(username, page = 1, limit = 20) {
    isLoadingLiked.value = true;
    try {
      const response = await apiClient.get(`/users/${username}/likes?page=${page}&limit=${limit}`);
      likedImages.value = response.data;
    } catch (error) {
      console.error('Error fetching liked images:', error);
      likedImages.value = [];
    } finally {
      isLoadingLiked.value = false;
    }
  }

  async function toggleFollow(username) {
    if (!profile.value || profile.value.username !== username) {
      console.error("Profile data is not loaded for this user.");
      return;
    }

    const isCurrentlyFollowing = profile.value.is_following;
    const userId = profile.value.id;
    
    // Optimistic update
    profile.value.is_following = !isCurrentlyFollowing;
    if (isCurrentlyFollowing) {
      profile.value.followers_count--;
    } else {
      profile.value.followers_count++;
    }

    try {
      if (isCurrentlyFollowing) {
        await apiClient.delete(`/users/${userId}/follow`);
      } else {
        await apiClient.post(`/users/${userId}/follow`);
      }
      // Fetch fresh data from server to ensure consistency
      await fetchUserProfile(username);
    } catch (error) {
      console.error('Error toggling follow:', error);
      // Revert optimistic update on error
      profile.value.is_following = isCurrentlyFollowing;
       if (isCurrentlyFollowing) {
        profile.value.followers_count++;
      } else {
        profile.value.followers_count--;
      }
    }
  }

  // 搜索用户
  async function searchUsers(query, isNewSearch = true, skip = 0, limit = 20) {
    if (isNewSearch) {
      isLoadingUsers.value = true;
      users.value = [];
      hasMoreUsers.value = true;
    }

    try {
      const response = await apiClient.get('/users/', {
        params: {
          search: query,
          skip: skip,
          limit: limit,
          sort: 'created_at',
          order: 'desc'
        }
      });
      
      if (isNewSearch) {
        users.value = response.data;
      } else {
        users.value.push(...response.data);
      }
      
      // 如果返回的数据少于限制数量，说明没有更多数据了
      hasMoreUsers.value = response.data.length === limit;
    } catch (error) {
      console.error('Error searching users:', error);
      if (isNewSearch) {
        users.value = [];
      }
      hasMoreUsers.value = false;
    } finally {
      if (isNewSearch) {
        isLoadingUsers.value = false;
      }
    }
  }

  // 重置用户搜索状态
  function resetUsersState() {
    users.value = [];
    isLoadingUsers.value = false;
    hasMoreUsers.value = true;
  }

  return {
    profile,
    uploadedImages,
    likedImages,
    users,
    isLoadingProfile,
    isLoadingUploaded,
    isLoadingLiked,
    isLoadingUsers,
    hasMoreUsers,
    fetchUserProfile,
    fetchUploadedImages,
    fetchLikedImages,
    toggleFollow,
    searchUsers,
    resetUsersState,
  };
}); 