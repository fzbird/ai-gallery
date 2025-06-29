import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import apiClient from '@/api/api.js';
import { categories as categoriesAPI } from '@/api/api.js';

export const useCategoryStore = defineStore('category', () => {
  const categories = ref([]);
  const categoryTree = ref([]);
  const isLoading = ref(false);
  const isLoadingTree = ref(false);

  /**
   * A getter that formats categories for use in Naive UI select components.
   */
  const selectOptions = computed(() => 
    categories.value.map(cat => ({ 
      label: cat.full_path || cat.name, 
      value: cat.id,
      level: cat.level || 0,
      disabled: false
    }))
  );

  /**
   * A getter that formats categories for tree select components (hierarchical).
   */
  const treeSelectOptions = computed(() => {
    const buildTreeOptions = (nodes) => {
      return nodes.map(node => ({
        label: node.name,
        value: node.id,
        level: node.level,
        children: node.children && node.children.length > 0 ? buildTreeOptions(node.children) : undefined
      }));
    };
    return buildTreeOptions(categoryTree.value);
  });

  /**
   * Get root categories only
   */
  const rootCategories = computed(() => 
    categories.value.filter(cat => !cat.parent_id || cat.level === 0)
  );

  /**
   * Fetches all categories from the API.
   */
  async function fetchCategories(params = {}) {
    isLoading.value = true;
    try {
      const response = await categoriesAPI.getCategories(params);
      categories.value = response.data;
    } catch (error) {
      console.error('Error fetching categories:', error);
      categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Fetches category tree structure for hierarchical display.
   */
  async function fetchCategoryTree(maxLevel = null) {
    isLoadingTree.value = true;
    try {
      const response = await categoriesAPI.getCategoryTree(maxLevel);
      categoryTree.value = response.data;
    } catch (error) {
      console.error('Error fetching category tree:', error);
      categoryTree.value = [];
    } finally {
      isLoadingTree.value = false;
    }
  }

  /**
   * Fetches only root categories (no parent).
   */
  async function fetchRootCategories() {
    isLoading.value = true;
    try {
      const response = await categoriesAPI.getRootCategories();
      categories.value = response.data;
    } catch (error) {
      console.error('Error fetching root categories:', error);
      categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /**
   * Fetches children of a specific category.
   */
  async function fetchCategoryChildren(categoryId) {
    try {
      const response = await categoriesAPI.getCategoryChildren(categoryId);
      return response.data;
    } catch (error) {
      console.error('Error fetching category children:', error);
      return [];
    }
  }

  /**
   * Fetches ancestors path of a category (for breadcrumb).
   */
  async function fetchCategoryAncestors(categoryId) {
    try {
      const response = await categoriesAPI.getCategoryAncestors(categoryId);
      return response.data;
    } catch (error) {
      console.error('Error fetching category ancestors:', error);
      return [];
    }
  }

  /**
   * Gets a category by ID with full details.
   */
  async function getCategoryById(categoryId) {
    try {
      const response = await categoriesAPI.getCategoryById(categoryId);
      return response.data;
    } catch (error) {
      console.error('Error fetching category by ID:', error);
      return null;
    }
  }

  /**
   * Creates a new category.
   * @param {object} categoryData - The data for the new category.
   */
  async function createCategory(categoryData) {
    try {
      await categoriesAPI.createCategory(categoryData);
      await fetchCategories(); // Refresh the list
      if (categoryTree.value.length > 0) {
        await fetchCategoryTree(); // Refresh tree if it was loaded
      }
    } catch (error) {
      console.error('Error creating category:', error);
      throw error;
    }
  }

  /**
   * Updates an existing category.
   * @param {number} categoryId - The ID of the category to update.
   * @param {object} categoryData - The updated category data.
   */
  async function updateCategory(categoryId, categoryData) {
    try {
      await categoriesAPI.updateCategory(categoryId, categoryData);
      await fetchCategories(); // Refresh the list
      if (categoryTree.value.length > 0) {
        await fetchCategoryTree(); // Refresh tree if it was loaded
      }
    } catch (error) {
      console.error('Error updating category:', error);
      throw error;
    }
  }

  /**
   * Moves a category to a new parent.
   * @param {number} categoryId - The ID of the category to move.
   * @param {number|null} newParentId - The ID of the new parent (null for root).
   */
  async function moveCategory(categoryId, newParentId) {
    try {
      await categoriesAPI.moveCategory(categoryId, newParentId);
      await fetchCategories(); // Refresh the list
      if (categoryTree.value.length > 0) {
        await fetchCategoryTree(); // Refresh tree if it was loaded
      }
    } catch (error) {
      console.error('Error moving category:', error);
      throw error;
    }
  }

  /**
   * Deletes a category.
   * @param {number} categoryId - The ID of the category to delete.
   * @param {number|null} moveContentTo - Optional ID to move content to.
   */
  async function deleteCategory(categoryId, moveContentTo = null) {
    try {
      await categoriesAPI.deleteCategory(categoryId, moveContentTo);
      await fetchCategories(); // Refresh the list
      if (categoryTree.value.length > 0) {
        await fetchCategoryTree(); // Refresh tree if it was loaded
      }
    } catch (error) {
      console.error('Error deleting category:', error);
      throw error;
    }
  }

  /**
   * Helper function to find a category in the tree by ID.
   */
  function findCategoryInTree(tree, categoryId) {
    for (const node of tree) {
      if (node.id === categoryId) {
        return node;
      }
      if (node.children && node.children.length > 0) {
        const found = findCategoryInTree(node.children, categoryId);
        if (found) return found;
      }
    }
    return null;
  }

  /**
   * Helper function to get category path as breadcrumb array.
   */
  function getCategoryPath(categoryId) {
    const category = categories.value.find(cat => cat.id === categoryId);
    if (!category) return [];
    
    return category.full_path ? 
      category.full_path.split(' > ').map((name, index, arr) => ({
        name,
        isLast: index === arr.length - 1
      })) : 
      [{ name: category.name, isLast: true }];
  }

  return {
    // State
    categories,
    categoryTree,
    isLoading,
    isLoadingTree,
    
    // Computed
    selectOptions,
    treeSelectOptions,
    rootCategories,
    
    // Methods
    fetchCategories,
    fetchCategoryTree,
    fetchRootCategories,
    fetchCategoryChildren,
    fetchCategoryAncestors,
    getCategoryById,
    createCategory,
    updateCategory,
    moveCategory,
    deleteCategory,
    
    // Helper methods
    findCategoryInTree,
    getCategoryPath,
  };
}); 