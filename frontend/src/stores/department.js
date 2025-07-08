import { defineStore } from 'pinia';
import { ref } from 'vue';
import apiClient from '@/api/api';
import { useAuthStore } from './auth';

export const useDepartmentStore = defineStore('department', () => {
  const departments = ref([]);
  const isLoading = ref(false);

  // 新增：部门分页状态
  const departmentPagination = ref({
    page: 1,
    pageSize: 10,
    total: 0
  });

  async function fetchDepartments(page = 1, limit = 10, filters = {}) {
    isLoading.value = true;
    try {
      const skip = (page - 1) * limit;
      const params = { 
        skip, 
        limit,
        search: filters.search || '',
        sort: filters.sort || 'name',
        order: filters.order || 'asc'
      };
      
      // 并行请求部门数据和总数
      const [departmentsResponse, countResponse] = await Promise.all([
        apiClient.get('/departments/', { params }),
        apiClient.get('/departments/count', { params: { search: params.search } })
      ]);
      
      departments.value = departmentsResponse.data;
      
      // 更新分页信息
      departmentPagination.value = {
        page,
        pageSize: limit,
        total: countResponse.data.total
      };
    } catch (error) {
      console.error('Failed to fetch departments:', error);
      departments.value = [];
      departmentPagination.value.total = 0;
      // Handle error, maybe show a notification to the user
    } finally {
      isLoading.value = false;
    }
  }

  async function createDepartment(name) {
    try {
      const response = await apiClient.post('/departments/', { name });
      // 刷新当前页面
      await fetchDepartments(departmentPagination.value.page, departmentPagination.value.pageSize);
    } catch (error) {
      console.error('Failed to create department:', error);
      throw error; // Re-throw to be caught in the component
    }
  }

  async function updateDepartment(id, name) {
    try {
      const response = await apiClient.put(`/departments/${id}`, { name });
      // 刷新当前页面
      await fetchDepartments(departmentPagination.value.page, departmentPagination.value.pageSize);
    } catch (error) {
      console.error('Failed to update department:', error);
      throw error;
    }
  }

  async function deleteDepartment(id) {
    try {
      await apiClient.delete(`/departments/${id}`);
      // 刷新当前页面
      await fetchDepartments(departmentPagination.value.page, departmentPagination.value.pageSize);
    } catch (error) {
      console.error('Failed to delete department:', error);
      throw error;
    }
  }

  return {
    departments,
    isLoading,
    departmentPagination,
    fetchDepartments,
    createDepartment,
    updateDepartment,
    deleteDepartment,
  };
}); 