import { defineStore } from 'pinia';
import { ref } from 'vue';
import apiClient from '@/api/api.js';

export const useCommentStore = defineStore('comment', () => {
  const isSubmitting = ref(false);

  /**
   * Posts a new comment for a specific image.
   * @param {object} commentData - The data for the new comment.
   * @param {number|string} commentData.imageId - The ID of the image.
   * @param {string} commentData.content - The content of the comment.
   * @returns {Promise<object>} The newly created comment object from the API.
   */
  async function postComment({ imageId, content }) {
    if (!content?.trim()) {
      return Promise.reject(new Error('Comment content cannot be empty.'));
    }
    
    isSubmitting.value = true;
    try {
      const response = await apiClient.post(`/images/${imageId}/comments`, {
        content,
      });
      // Return the new comment so the component can update its state
      return response.data;
    } catch (error) {
      // The global error handler in api.js will show a message.
      // Re-throw the error so the component knows the submission failed.
      throw error;
    } finally {
      isSubmitting.value = false;
    }
  }

  /**
   * Posts a new comment for a specific gallery.
   * @param {object} commentData - The data for the new comment.
   * @param {number|string} commentData.galleryId - The ID of the gallery.
   * @param {string} commentData.content - The content of the comment.
   * @returns {Promise<object>} The newly created comment object from the API.
   */
  async function postGalleryComment({ galleryId, content }) {
    if (!content?.trim()) {
      return Promise.reject(new Error('Comment content cannot be empty.'));
    }
    
    isSubmitting.value = true;
    try {
      const response = await apiClient.post(`/galleries/${galleryId}/comments`, {
        content,
      });
      // Return the new comment so the component can update its state
      return response.data;
    } catch (error) {
      // The global error handler in api.js will show a message.
      // Re-throw the error so the component knows the submission failed.
      throw error;
    } finally {
      isSubmitting.value = false;
    }
  }

  /**
   * Deletes a comment by its ID.
   * @param {number|string} commentId - The ID of the comment to delete.
   * @returns {Promise<object>} The deleted comment object from the API.
   */
  async function deleteComment(commentId) {
    try {
      const response = await apiClient.delete(`/comments/${commentId}`);
      return response.data;
    } catch (error) {
      // The global error handler in api.js will show a message.
      // Re-throw the error so the component knows the deletion failed.
      throw error;
    }
  }

  return {
    isSubmitting,
    postComment,
    postGalleryComment,
    deleteComment,
  };
}); 