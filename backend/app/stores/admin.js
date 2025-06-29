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

async function deleteUser(userId) {
  // ... existing code ...
} 