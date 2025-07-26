<template>
  <div class="slideshow-container">
    <!-- 幻灯片显示区域 -->
    <div class="slideshow-viewport">
      <div 
        class="slideshow-track" 
        :style="{ transform: `translateX(-${currentIndex * 100}%)` }"
      >
        <div 
          v-for="(image, index) in images" 
          :key="image.id"
          class="slide"
          @click="handleImageClick(image.id)"
        >
          <img 
            :src="`${API_BASE_URL()}${image.image_url}`" 
            :alt="image.title"
            loading="lazy"
            @error="handleImageError"
          />
          <div class="slide-overlay">
            <div class="slide-info">
              <h3 class="slide-title">{{ image.title }}</h3>
              <div class="slide-stats">
                <span class="stat">
                  <n-icon><EyeOutline /></n-icon>
                  {{ image.views_count || 0 }}
                </span>
                <span class="stat">
                  <n-icon><HeartOutline /></n-icon>
                  {{ image.likes_count || 0 }}
                </span>
                <span class="stat">
                  <n-icon><BookmarkOutline /></n-icon>
                  {{ image.bookmarks_count || 0 }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 控制按钮 -->
    <div class="slideshow-controls">
      <!-- 上一张 -->
      <n-button 
        class="control-btn prev-btn"
        type="primary"
        ghost
        circle
        size="large"
        @click="previousSlide"
        :disabled="currentIndex === 0"
      >
        <template #icon>
          <n-icon><ChevronBackOutline /></n-icon>
        </template>
      </n-button>
      
      <!-- 下一张 -->
      <n-button 
        class="control-btn next-btn"
        type="primary"
        ghost
        circle
        size="large"
        @click="nextSlide"
        :disabled="currentIndex === images.length - 1"
      >
        <template #icon>
          <n-icon><ChevronForwardOutline /></n-icon>
        </template>
      </n-button>
    </div>
    
    <!-- 指示器 -->
    <div class="slideshow-indicators" v-if="images.length > 1">
      <div 
        v-for="(image, index) in images" 
        :key="image.id"
        class="indicator"
        :class="{ active: index === currentIndex }"
        @click="goToSlide(index)"
      >
        <img 
          :src="`${API_BASE_URL()}${image.image_url}`" 
          :alt="image.title"
          loading="lazy"
        />
      </div>
    </div>
    
    <!-- 播放控制 -->
    <div class="playback-controls">
      <n-button 
        class="play-btn"
        type="primary"
        ghost
        circle
        size="medium"
        @click="toggleAutoPlay"
      >
        <template #icon>
          <n-icon :component="isAutoPlaying ? PauseOutline : PlayOutline" />
        </template>
      </n-button>
      
      <span class="slide-counter">
        {{ currentIndex + 1 }} / {{ images.length }}
      </span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue';
import { NButton, NIcon } from 'naive-ui';
import { 
  ChevronBackOutline, ChevronForwardOutline, PlayOutline, PauseOutline,
  EyeOutline, HeartOutline, BookmarkOutline
} from '@vicons/ionicons5';
import { API_BASE_URL } from '@/api/api.js';

const props = defineProps({
  images: {
    type: Array,
    required: true
  },
  autoPlayInterval: {
    type: Number,
    default: 5000 // 5秒
  }
});

const emit = defineEmits(['image-click']);

const currentIndex = ref(0);
const isAutoPlaying = ref(true);
let autoPlayTimer = null;

// 切换到下一张
function nextSlide() {
  if (currentIndex.value < props.images.length - 1) {
    currentIndex.value++;
  } else {
    currentIndex.value = 0; // 循环播放
  }
}

// 切换到上一张
function previousSlide() {
  if (currentIndex.value > 0) {
    currentIndex.value--;
  } else {
    currentIndex.value = props.images.length - 1; // 循环播放
  }
}

// 跳转到指定幻灯片
function goToSlide(index) {
  currentIndex.value = index;
}

// 切换自动播放
function toggleAutoPlay() {
  isAutoPlaying.value = !isAutoPlaying.value;
  if (isAutoPlaying.value) {
    startAutoPlay();
  } else {
    stopAutoPlay();
  }
}

// 开始自动播放
function startAutoPlay() {
  if (props.images.length <= 1) return;
  
  stopAutoPlay();
  autoPlayTimer = setInterval(() => {
    nextSlide();
  }, props.autoPlayInterval);
}

// 停止自动播放
function stopAutoPlay() {
  if (autoPlayTimer) {
    clearInterval(autoPlayTimer);
    autoPlayTimer = null;
  }
}

// 处理图片点击
function handleImageClick(imageId) {
  emit('image-click', imageId);
}

// 处理图片加载错误
function handleImageError() {
  // Handle image loading error
}

// 监听自动播放状态变化
watch(isAutoPlaying, (newValue) => {
  if (newValue) {
    startAutoPlay();
  } else {
    stopAutoPlay();
  }
});

// 监听当前索引变化，重置自动播放计时器
watch(currentIndex, () => {
  if (isAutoPlaying.value) {
    startAutoPlay();
  }
});

// 组件挂载时开始自动播放
onMounted(() => {
  if (isAutoPlaying.value && props.images.length > 1) {
    startAutoPlay();
  }
});

// 组件卸载时清理定时器
onBeforeUnmount(() => {
  stopAutoPlay();
});
</script>

<style scoped>
.slideshow-container {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  background: #000;
  display: flex;
  flex-direction: column;
}

.slideshow-viewport {
  flex: 1;
  width: 100%;
  overflow: hidden;
  position: relative;
}

.slideshow-track {
  display: flex;
  width: 100%;
  height: 100%;
  transition: transform 0.5s ease-in-out;
}

.slide {
  flex-shrink: 0;
  width: 100%;
  height: 100%;
  position: relative;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.slide img {
  max-width: 100%;
  max-height: 100%;
  width: auto;
  height: auto;
  object-fit: contain;
  background: #000;
  border-radius: 8px;
}

.slide-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0, 0, 0, 0.7));
  color: white;
  padding: 20px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.slide:hover .slide-overlay {
  opacity: 1;
}

.slide-info {
  text-align: center;
}

.slide-title {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
}

.slide-stats {
  display: flex;
  justify-content: center;
  gap: 16px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
}

/* 控制按钮 */
.slideshow-controls {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  transform: translateY(-50%);
  display: flex;
  justify-content: space-between;
  padding: 0 20px;
  pointer-events: none;
}

.control-btn {
  pointer-events: auto;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  border: none;
}

.control-btn:hover {
  background: rgba(255, 255, 255, 1);
}

/* 指示器 */
.slideshow-indicators {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
  background: rgba(0, 0, 0, 0.5);
  padding: 8px;
  border-radius: 20px;
  backdrop-filter: blur(4px);
}

.indicator {
  width: 40px;
  height: 30px;
  border-radius: 4px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.indicator img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.indicator.active {
  border-color: #10b981;
  transform: scale(1.1);
}

.indicator:hover {
  transform: scale(1.05);
}

/* 播放控制 */
.playback-controls {
  position: absolute;
  top: 20px;
  right: 20px;
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(0, 0, 0, 0.5);
  padding: 8px 12px;
  border-radius: 20px;
  backdrop-filter: blur(4px);
}

.play-btn {
  background: rgba(255, 255, 255, 0.9);
  border: none;
}

.slide-counter {
  color: white;
  font-size: 14px;
  font-weight: 500;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .slideshow-controls {
    padding: 0 16px;
  }
  
  .control-btn {
    width: 48px;
    height: 48px;
  }
  
  .slideshow-indicators {
    bottom: 16px;
    gap: 6px;
    padding: 6px;
  }
  
  .indicator {
    width: 35px;
    height: 26px;
  }
  
  .playback-controls {
    top: 16px;
    right: 16px;
    padding: 6px 10px;
  }
  
  .slide-counter {
    font-size: 13px;
  }
}

@media (max-width: 768px) {
  .slideshow-controls {
    padding: 0 12px;
  }
  
  .control-btn {
    width: 44px;
    height: 44px;
  }
  
  .slideshow-indicators {
    bottom: 12px;
    gap: 4px;
    padding: 4px;
  }
  
  .indicator {
    width: 30px;
    height: 22px;
  }
  
  .playback-controls {
    top: 12px;
    right: 12px;
    padding: 4px 8px;
  }
  
  .slide-counter {
    font-size: 12px;
  }
  
  .slide-overlay {
    padding: 16px;
  }
  
  .slide-title {
    font-size: 16px;
  }
  
  .slide-stats {
    gap: 12px;
  }
  
  .stat {
    font-size: 13px;
  }
}

@media (max-width: 480px) {
  .slideshow-controls {
    padding: 0 8px;
  }
  
  .control-btn {
    width: 40px;
    height: 40px;
  }
  
  .slideshow-indicators {
    bottom: 8px;
    gap: 3px;
    padding: 3px;
  }
  
  .indicator {
    width: 25px;
    height: 18px;
  }
  
  .playback-controls {
    top: 8px;
    right: 8px;
    padding: 3px 6px;
  }
  
  .slide-counter {
    font-size: 11px;
  }
  
  .slide-overlay {
    padding: 12px;
  }
  
  .slide-title {
    font-size: 14px;
  }
  
  .slide-stats {
    gap: 8px;
  }
  
  .stat {
    font-size: 12px;
  }
}
</style> 