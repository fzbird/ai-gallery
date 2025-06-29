<template>
  <div class="admin-dashboard">
    <!-- 页面头部 -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="header-text">
          <h1 class="dashboard-title">
            <n-icon size="28" class="title-icon"><BarChartOutline /></n-icon>
            数据仪表盘
          </h1>
          <p class="dashboard-subtitle">实时监控系统运行状态与核心指标</p>
        </div>
        <div class="header-actions">
          <n-button type="primary" ghost @click="loadAllStats" :loading="isLoadingAllStats">
            <template #icon>
              <n-icon><RefreshOutline /></n-icon>
            </template>
            刷新数据
          </n-button>
        </div>
      </div>
    </div>

    <div v-if="isLoadingAllStats" class="loading-state">
      <n-grid cols="1 s:2 m:4" responsive="screen" :x-gap="24" :y-gap="24">
        <n-gi v-for="i in 8" :key="i">
          <n-card class="stat-card loading-card">
            <n-skeleton text style="width: 40%; margin-bottom: 8px;" />
            <n-skeleton text style="font-size: 2em; width: 60%;" />
          </n-card>
        </n-gi>
      </n-grid>
      
      <n-grid cols="1 m:2 l:3" responsive="screen" :x-gap="24" :y-gap="24" style="margin-top: 32px;">
        <n-gi v-for="i in 6" :key="i">
          <n-card class="chart-card">
            <n-skeleton text style="width: 30%; margin-bottom: 16px;" />
            <n-skeleton height="300px" />
          </n-card>
        </n-gi>
      </n-grid>
    </div>

    <div v-else-if="dashboardStats" class="dashboard-content">
      <!-- 核心指标概览 -->
      <div class="section-header stats-section-header">
        <h2 class="section-title">
          <n-icon size="20" class="section-icon"><StatsChartOutline /></n-icon>
          核心指标概览
        </h2>
        <p class="section-subtitle">系统关键数据统计</p>
      </div>
      
      <div class="stats-container">
        <n-grid cols="1 s:2 m:3 l:4 xl:4" responsive="screen" :x-gap="24" :y-gap="24" class="stats-grid">
        <n-gi>
          <n-card class="stat-card users-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><PeopleOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_users }}</div>
                <div class="stat-label">总用户数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card galleries-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><FolderOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_galleries || 0 }}</div>
                <div class="stat-label">总图集数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card images-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><ImagesOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_images }}</div>
                <div class="stat-label">总图片数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card topics-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><BookOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_topics || 0 }}</div>
                <div class="stat-label">总专题数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card likes-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><HeartOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ (dashboardStats.total_gallery_likes || 0) + (dashboardStats.total_likes || 0) }}</div>
                <div class="stat-label">总点赞数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card bookmarks-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><BookmarkOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_gallery_bookmarks || 0 }}</div>
                <div class="stat-label">总收藏数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card views-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><EyeOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_gallery_views || 0 }}</div>
                <div class="stat-label">总浏览数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
        
        <n-gi>
          <n-card class="stat-card comments-card">
            <div class="stat-content">
              <div class="stat-icon">
                <n-icon size="32"><ChatbubbleOutline /></n-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ dashboardStats.total_comments }}</div>
                <div class="stat-label">总评论数</div>
              </div>
            </div>
          </n-card>
        </n-gi>
      </n-grid>
      </div>

      <!-- 数据分析图表 -->
      <div class="section-header charts-section">
        <h2 class="section-title">
          <n-icon size="20" class="section-icon"><PieChartOutline /></n-icon>
          数据分析图表
        </h2>
        <p class="section-subtitle">深度数据洞察与趋势分析</p>
      </div>
      
      <div class="charts-grid">
        <!-- 用户相关图表 -->
        <div class="chart-group">
          <h3 class="group-title">用户数据分析</h3>
          <n-grid cols="1 l:2" responsive="screen" :x-gap="20" :y-gap="20">
            <!-- 用户部门分布 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#8b5cf6"><BusinessOutline /></n-icon>
                    <span>用户部门分布</span>
                  </div>
                </template>
                
                <div v-if="departmentUserChartData" class="chart-container">
                  <Pie :data="departmentUserChartData" :options="pieChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>

            <!-- 最活跃创作者 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#3b82f6"><TrophyOutline /></n-icon>
                    <span>最活跃创作者</span>
                  </div>
                </template>
                
                <div v-if="activeCreatorChartData" class="chart-container">
                  <Bar :data="activeCreatorChartData" :options="barChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </div>

        <!-- 内容相关图表 -->
        <div class="chart-group">
          <h3 class="group-title">内容数据分析</h3>
          <n-grid cols="1 l:2" responsive="screen" :x-gap="20" :y-gap="20">

            <!-- 图集分类分布 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#10b981"><GridOutline /></n-icon>
                    <span>图集分类分布</span>
                  </div>
                </template>
                
                <div v-if="galleriesByCategoryChartData" class="chart-container">
                  <Pie :data="galleriesByCategoryChartData" :options="pieChartOptionsSecondary" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>

            <!-- 最受欢迎图集 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#3b82f6"><StarOutline /></n-icon>
                    <span>最受欢迎图集</span>
                  </div>
                </template>
                
                <div v-if="popularGalleryChartData" class="chart-container">
                  <Bar :data="popularGalleryChartData" :options="horizontalBarChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </div>

        <!-- 专题与互动数据 -->
        <div class="chart-group">
          <h3 class="group-title">专题与互动分析</h3>
          <n-grid cols="1 l:3" responsive="screen" :x-gap="20" :y-gap="20">
            <!-- 专题图集分布 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#f59e0b"><LayersOutline /></n-icon>
                    <span>专题图集分布</span>
                  </div>
                </template>
                
                <div v-if="topicGalleryChartData" class="chart-container">
                  <Bar :data="topicGalleryChartData" :options="barChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>

            <!-- 热门专题 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#f59e0b"><FlameOutline /></n-icon>
                    <span>热门专题</span>
                  </div>
                </template>
                
                <div v-if="hotTopicChartData" class="chart-container">
                  <Bar :data="hotTopicChartData" :options="horizontalBarChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>

            <!-- 最活跃评论用户 -->
            <n-gi>
              <n-card class="chart-card">
                <template #header>
                  <div class="chart-header">
                    <n-icon size="20" color="#ec4899"><ChatbubbleOutline /></n-icon>
                    <span>最活跃评论用户</span>
                  </div>
                </template>
                
                <div v-if="activeCommentUserChartData" class="chart-container">
                  <Bar :data="activeCommentUserChartData" :options="barChartOptions" />
                </div>
                <div v-else class="no-data">
                  <n-empty description="暂无数据" />
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </div>
      </div>
    </div>
    
    <div v-else class="error-state">
      <n-card class="error-card">
        <n-empty description="无法加载仪表盘数据" size="large">
          <template #icon>
            <n-icon size="48"><AlertCircleOutline /></n-icon>
          </template>
          <template #extra>
            <n-button type="primary" @click="loadAllStats">
              重新加载
            </n-button>
          </template>
        </n-empty>
      </n-card>
    </div>
  </div>
</template>

<script setup>
import { onMounted, computed } from 'vue';
import { useAdminStore } from '@/stores/admin';
import { storeToRefs } from 'pinia';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js';
import { Bar, Pie } from 'vue-chartjs';
import {
  PeopleOutline,
  FolderOutline,
  ImagesOutline,
  BookOutline,
  HeartOutline,
  BookmarkOutline,
  EyeOutline,
  ChatbubbleOutline,
  BarChartOutline,
  LayersOutline,
  RefreshOutline,
  StatsChartOutline,
  PieChartOutline,
  AlertCircleOutline,
  BusinessOutline,
  TrophyOutline,
  GridOutline,
  StarOutline,
  FlameOutline
} from '@vicons/ionicons5';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

const adminStore = useAdminStore();
const { 
  dashboardStats, 
  isLoadingStats, 
  userStats, 
  departmentStats,
  galleryStats,
  categoryStats,
  topicStats,
  commentStats
} = storeToRefs(adminStore);

// 计算是否正在加载所有统计数据
const isLoadingAllStats = computed(() => {
  return isLoadingStats.value;
});

// 用户部门分布图表数据
const departmentUserChartData = computed(() => {
  if (!userStats.value?.users_by_department) return null;
  
  const stats = userStats.value.users_by_department;
  return {
    labels: stats.map(item => item.name),
    datasets: [{
      data: stats.map(item => item.count),
      backgroundColor: [
        '#8b5cf6',
        '#3b82f6',
        '#10b981',
        '#f59e0b',
        '#ef4444',
        '#8b5cf6',
        '#06b6d4'
      ],
      borderWidth: 0
    }]
  };
});

// 最活跃创作者图表数据
const activeCreatorChartData = computed(() => {
  if (!userStats.value?.top_gallery_creators) return null;
  
  const creators = userStats.value.top_gallery_creators.slice(0, 8);
  return {
    labels: creators.map(creator => creator.username),
    datasets: [{
      label: '图集数量',
      data: creators.map(creator => creator.count),
      backgroundColor: '#3b82f6',
      borderColor: '#1d4ed8',
      borderWidth: 1
    }]
  };
});

// 图集分类分布图表数据
const galleriesByCategoryChartData = computed(() => {
  if (!categoryStats.value?.category_gallery_stats) return null;
  
  const stats = categoryStats.value.category_gallery_stats;
  return {
    labels: stats.map(item => item.name),
    datasets: [{
      data: stats.map(item => item.gallery_count),
      backgroundColor: [
        '#10b981',
        '#3b82f6',
        '#8b5cf6',
        '#f59e0b',
        '#ef4444',
        '#06b6d4',
        '#84cc16'
      ],
      borderWidth: 0
    }]
  };
});

// 最受欢迎图集图表数据
const popularGalleryChartData = computed(() => {
  if (!galleryStats.value?.top_liked_galleries) return null;
  
  const galleries = galleryStats.value.top_liked_galleries.slice(0, 6);
  return {
    labels: galleries.map(gallery => gallery.title.length > 10 ? gallery.title.substring(0, 10) + '...' : gallery.title),
    datasets: [{
      label: '点赞数',
      data: galleries.map(gallery => gallery.count),
      backgroundColor: '#3b82f6',
      borderColor: '#1d4ed8',
      borderWidth: 1
    }]
  };
});

// 专题图集分布图表数据
const topicGalleryChartData = computed(() => {
  if (!topicStats.value?.topics_by_galleries) return null;
  
  const topics = topicStats.value.topics_by_galleries.slice(0, 8);
  return {
    labels: topics.map(topic => topic.name.length > 8 ? topic.name.substring(0, 8) + '...' : topic.name),
    datasets: [{
      label: '图集数量',
      data: topics.map(topic => topic.count),
      backgroundColor: '#f59e0b',
      borderColor: '#d97706',
      borderWidth: 1
    }]
  };
});

// 热门专题图表数据
const hotTopicChartData = computed(() => {
  if (!topicStats.value?.top_topics) return null;
  
  const topics = topicStats.value.top_topics.slice(0, 6);
  return {
    labels: topics.map(topic => topic.name.length > 12 ? topic.name.substring(0, 12) + '...' : topic.name),
    datasets: [{
      label: '图集数量',
      data: topics.map(topic => topic.count),
      backgroundColor: '#f59e0b',
      borderColor: '#d97706',
      borderWidth: 1
    }]
  };
});

// 最活跃评论用户图表数据
const activeCommentUserChartData = computed(() => {
  if (!commentStats.value?.top_commenters) return null;
  
  const commenters = commentStats.value.top_commenters.slice(0, 8);
  return {
    labels: commenters.map(user => user.username),
    datasets: [{
      label: '评论数量',
      data: commenters.map(user => user.count),
      backgroundColor: '#ec4899',
      borderColor: '#db2777',
      borderWidth: 1
    }]
  };
});

// 图表配置选项
const pieChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        padding: 20,
        usePointStyle: true
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: 'white',
      bodyColor: 'white',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1,
      cornerRadius: 8,
      padding: 12
    }
  }
};

const pieChartOptionsSecondary = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        padding: 20,
        usePointStyle: true
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: 'white',
      bodyColor: 'white',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1,
      cornerRadius: 8,
      padding: 12
    }
  }
};

const barChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: 'white',
      bodyColor: 'white',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1,
      cornerRadius: 8,
      padding: 12
    }
  },
  scales: {
    y: {
      beginAtZero: true,
      grid: {
        color: 'rgba(0, 0, 0, 0.1)'
      }
    },
    x: {
      grid: {
        display: false
      }
    }
  }
};

const horizontalBarChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  indexAxis: 'y',
  plugins: {
    legend: {
      display: false
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: 'white',
      bodyColor: 'white',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1,
      cornerRadius: 8,
      padding: 12
    }
  },
  scales: {
    x: {
      beginAtZero: true,
      grid: {
        color: 'rgba(0, 0, 0, 0.1)'
      }
    },
    y: {
      grid: {
        display: false
      }
    }
  }
};

// 加载所有统计数据
async function loadAllStats() {
  await Promise.all([
    adminStore.fetchDashboardStats(),
    adminStore.fetchUserStats(),
    adminStore.fetchDepartmentStats(),
    adminStore.fetchGalleryStats(),
    adminStore.fetchCategoryStats(),
    adminStore.fetchTopicStats(),
    adminStore.fetchCommentStats()
  ]);
}

onMounted(() => {
  loadAllStats();
});
</script>

<style scoped>
.admin-dashboard {
  min-height: 100%;
  padding: 0 4px;
}

/* 页面头部 */
.dashboard-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  margin-bottom: 32px;
  padding: 32px;
  color: white;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.3);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
}

.header-text {
  flex: 1;
}

.dashboard-title {
  font-size: 32px;
  font-weight: bold;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

.title-icon {
  opacity: 0.9;
}

.dashboard-subtitle {
  font-size: 16px;
  opacity: 0.9;
  margin: 0;
}

.header-actions {
  flex-shrink: 0;
}

/* 章节标题 */
.section-header {
  margin-bottom: 24px;
}

.stats-section-header {
  margin-bottom: 32px;
  text-align: center;
  padding: 0 20px;
}

.charts-section {
  margin-top: 56px;
}

.section-title {
  font-size: 24px;
  font-weight: bold;
  color: #1f2937;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-icon {
  color: #667eea;
}

.section-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

/* 统计卡片 */
.stats-container {
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 20px;
  padding: 40px 32px;
  margin-bottom: 48px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
  max-width: 1200px;
  margin-left: auto;
  margin-right: auto;
}

.stats-grid {
  width: 100%;
}

.stat-card {
  border-radius: 18px;
  box-shadow: 0 3px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  background: white;
  border: 1px solid #f1f5f9;
  min-height: 140px;
  display: flex;
  align-items: center;
  position: relative;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.stat-card:hover::before {
  opacity: 1;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
  border-color: #e2e8f0;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px;
  width: 100%;
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  border-radius: 16px;
  color: white;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.users-card .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.galleries-card .stat-icon {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.images-card .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.topics-card .stat-icon {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
}

.likes-card .stat-icon {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.bookmarks-card .stat-icon {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.views-card .stat-icon {
  background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
}

.comments-card .stat-icon {
  background: linear-gradient(135deg, #84cc16 0%, #65a30d 100%);
}

.stat-info {
  flex: 1;
}

.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  line-height: 1.1;
  margin-bottom: 6px;
  letter-spacing: -0.02em;
}

.stat-label {
  font-size: 15px;
  color: #64748b;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* 图表组 */
.charts-grid {
  max-width: 1200px;
  margin: 0 auto;
}

.chart-group {
  margin-bottom: 40px;
}

.group-title {
  font-size: 18px;
  font-weight: 600;
  color: #374151;
  margin: 0 0 20px 0;
  padding-left: 4px;
  border-left: 4px solid #667eea;
}

/* 图表卡片 */
.chart-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  background: white;
  border: 1px solid #f1f5f9;
  transition: all 0.3s ease;
}

.chart-card:hover {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  border-color: #e2e8f0;
}

.chart-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.chart-container {
  height: 350px;
  padding: 16px;
}

.no-data {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 加载状态 */
.loading-state .loading-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

/* 错误状态 */
.error-state {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.error-card {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  padding: 40px;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 20px;
  }
  
  .charts-grid {
    padding: 0 16px;
  }
}

@media (max-width: 768px) {
  .admin-dashboard {
    padding: 0 12px;
  }
  
  .dashboard-header {
    padding: 24px 20px;
    margin-bottom: 24px;
  }
  
  .dashboard-title {
    font-size: 24px;
  }
  
  .dashboard-subtitle {
    font-size: 14px;
  }
  
  .section-title {
    font-size: 20px;
  }
  
  .stats-container {
    padding: 32px 20px;
    margin-bottom: 36px;
  }
  
  .stat-card {
    min-height: 120px;
  }
  
  .stat-content {
    gap: 16px;
    padding: 20px;
  }
  
  .stat-icon {
    width: 56px;
    height: 56px;
  }
  
  .stat-icon :deep(.n-icon) {
    font-size: 28px !important;
  }
  
  .stat-value {
    font-size: 28px;
  }
  
  .stat-label {
    font-size: 14px;
  }
  
  .chart-container {
    height: 280px;
    padding: 12px;
  }
  
  .chart-group {
    margin-bottom: 32px;
  }
  
  .group-title {
    font-size: 16px;
    margin-bottom: 16px;
  }
}

@media (max-width: 480px) {
  .dashboard-header {
    padding: 20px 16px;
  }
  
  .dashboard-title {
    font-size: 20px;
  }
  
  .stats-container {
    padding: 20px 12px;
  }
  
  .stat-card {
    min-height: 90px;
  }
  
  .stat-content {
    padding: 14px;
    gap: 12px;
  }
  
  .stat-icon {
    width: 44px;
    height: 44px;
  }
  
  .stat-icon :deep(.n-icon) {
    font-size: 20px !important;
  }
  
  .stat-value {
    font-size: 22px;
  }
  
  .stat-label {
    font-size: 12px;
  }
  
  .chart-container {
    height: 250px;
    padding: 8px;
  }
}
</style> 