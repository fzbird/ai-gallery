<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { NTag } from 'naive-ui';
import { useSettingsStore } from '@/stores/settings';
import { storeToRefs } from 'pinia';
import apiClient from '@/api/api.js';

const router = useRouter();
const settingsStore = useSettingsStore();
const { settings } = storeToRefs(settingsStore);

const friendlyLinks = ref([]);
const hotTags = ref([]);
const isLoading = ref(false);

// 计算站点名称
const siteName = computed(() => settings.value?.site_name || 'MyGallery');

// 获取友情链接
async function fetchFriendlyLinks() {
  try {
    const response = await apiClient.get('/links/', { params: { limit: 10 } });
    friendlyLinks.value = response.data;
  } catch (error) {
    console.error('获取友情链接失败:', error);
    // 如果API失败，使用默认数据
    friendlyLinks.value = [
      { id: 1, title: '曲阜师大附中官网', url: 'http://fz.qfnu.edu.cn' },
      { id: 2, title: '曲阜师范大学', url: 'http://www.qfnu.edu.cn' },
      { id: 3, title: '曲阜师大附中新应用平台', url: '#' },
      { id: 4, title: '曲阜师大附中AI平台', url: 'http://192.168.5.117:3000' },
      { id: 5, title: '曲阜师大附中AI教育创新实践案例', url: '/曲阜师大附中 AI教育创新实践案例.html' },
      { id: 6, title: '曲阜师大附中AI绘画平台', url: 'http://192.168.5.117:7860' }
    ];
  }
}

// 获取热门标签
async function fetchHotTags() {
  try {
    const response = await apiClient.get('/tags/popular', { params: { limit: 25 } });
    hotTags.value = response.data;
  } catch (error) {
    console.error('获取热门标签失败:', error);
    // 如果API失败，使用默认数据
    hotTags.value = [
      { id: 1, name: '头像' },
      { id: 2, name: '高清' },
      { id: 3, name: '美丽' },
      { id: 4, name: '人物' },
      { id: 5, name: '自然' },
      { id: 6, name: '动物' },
      { id: 7, name: '美食' },
      { id: 8, name: '绘画' },
      { id: 9, name: 'AI作品' },
      { id: 10, name: '建筑' },
      { id: 11, name: '摄影' },
      { id: 12, name: '时尚' }
    ];
  }
}

// 处理标签点击
function handleTagClick(tagName) {
  router.push({ name: 'search', query: { q: tagName } });
}

onMounted(async () => {
  isLoading.value = true;
  try {
    await Promise.all([
      settingsStore.fetchSettings(),
      fetchFriendlyLinks(),
      fetchHotTags()
    ]);
  } finally {
    isLoading.value = false;
  }
});

// 定义props来接收主题颜色
const props = defineProps({
  themeColor: {
    type: String,
    default: '#1f2937'
  }
});
</script>

<template>
  <div class="app-footer">
    <!-- 友情链接和标签区域 -->
    <div class="links-section">
      <div class="container">
        <div class="links-content">
          <!-- 友情链接 -->
          <div class="links-group">
            <h4 class="footer-section-title">友情链接</h4>
            <div class="links-grid">
              <a 
                v-for="link in friendlyLinks" 
                :key="link.id" 
                :href="link.url"
                class="link-item"
                target="_blank"
                rel="noopener noreferrer"
              >
                {{ link.title }}
              </a>
            </div>
          </div>
          
          <!-- 热门标签 -->
          <div class="tags-group">
            <h4 class="footer-section-title">热门标签</h4>
            <div class="hot-tags">
              <n-tag 
                v-for="tag in hotTags" 
                :key="tag.id" 
                class="hot-tag"
                clickable
                @click="handleTagClick(tag.name)"
              >
                {{ tag.name }}
              </n-tag>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="container">
        <div class="footer-content">
          <p>&copy; 2024 {{ siteName }}. 保留所有权利.</p>
          <div class="footer-links">
            <a href="#">联系我们</a>
            <a href="#">用户协议</a>
            <a href="#">隐私政策</a>
            <a href="#">帮助中心</a>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* 友情链接和标签区域 */
.links-section {
  background: #f9fafb;
  padding: 60px 0;
  border-top: 1px solid #e5e7eb;
}

.container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 24px;
}

.links-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
}

.footer-section-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 20px 0;
}

.links-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
}

.link-item {
  color: #6b7280;
  text-decoration: none;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.2s ease;
  font-size: 14px;
}

.link-item:hover {
  color: v-bind(themeColor);
  background: color-mix(in srgb, v-bind(themeColor) 10%, transparent);
}

.hot-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.hot-tag {
  transition: all 0.2s ease;
}

.hot-tag:hover {
  transform: translateY(-1px);
}

/* 页脚 */
.footer {
  background: #1f2937;
  color: white;
  padding: 40px 0;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-content p {
  margin: 0;
  color: #9ca3af;
}

.footer-links {
  display: flex;
  gap: 24px;
}

.footer-links a {
  color: #9ca3af;
  text-decoration: none;
  transition: color 0.2s ease;
}

.footer-links a:hover {
  color: white;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .container {
    padding: 0 16px;
  }

  .links-content {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  
  .footer-content {
    flex-direction: column;
    text-align: center;
  }
  
  .footer-links {
    justify-content: center;
  }
}
</style> 