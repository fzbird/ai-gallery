<template>
  <n-modal
    v-model:show="showModal"
    preset="card"
    style="width: 95vw; height: 95vh; max-width: none"
    :mask-closable="true"
    :closable="false"
    @update:show="handleModalClose"
  >
    <template #header>
      <div class="viewer-header">
        <div class="image-info">
          <h3 class="image-title">{{ imageTitle }}</h3>
          <span class="image-meta">{{ imageSize }}</span>
        </div>
        <div class="header-actions">
          <n-button text @click="resetTransform">
            <template #icon>
              <n-icon size="18"><RefreshOutline /></n-icon>
            </template>
          </n-button>
          <n-button text @click="closeModal">
            <template #icon>
              <n-icon size="18"><CloseOutline /></n-icon>
            </template>
          </n-button>
        </div>
      </div>
    </template>

    <div class="image-viewer-container" @wheel="handleWheel" @keydown="handleKeydown" tabindex="0">
      <div
        class="image-wrapper"
        ref="imageWrapper"
        :style="imageWrapperStyle"
        @mousedown="handleMouseDown"
        @mousemove="handleMouseMove"
        @mouseup="handleMouseUp"
        @mouseleave="handleMouseUp"
        @touchstart="handleTouchStart"
        @touchmove="handleTouchMove"
        @touchend="handleTouchEnd"
      >
        <img
          ref="imageRef"
          :src="imageSrc"
          :alt="imageTitle"
          class="main-image"
          @load="handleImageLoad"
          @error="handleImageError"
          @dragstart.prevent
        />
      </div>

      <!-- 工具栏 -->
      <div class="toolbar">
        <div class="toolbar-group">
          <n-button circle @click="zoomOut" :disabled="scale <= minScale" title="缩小 (-)">
            <template #icon>
              <n-icon size="20"><RemoveOutline /></n-icon>
            </template>
          </n-button>
          
          <div class="zoom-info">{{ Math.round(scale * 100) }}%</div>
          
          <n-button circle @click="zoomIn" :disabled="scale >= maxScale" title="放大 (+)">
            <template #icon>
              <n-icon size="20"><AddOutline /></n-icon>
            </template>
          </n-button>
        </div>

        <div class="toolbar-group">
          <n-button circle @click="rotateLeft" title="逆时针旋转 (Shift+R)">
            <template #icon>
              <n-icon size="20"><ArrowBackOutline /></n-icon>
            </template>
          </n-button>
          
          <n-button circle @click="rotateRight" title="顺时针旋转 (R)">
            <template #icon>
              <n-icon size="20"><ArrowForwardOutline /></n-icon>
            </template>
          </n-button>
        </div>

        <div class="toolbar-group">
          <n-button circle @click="fitToScreen" title="适应屏幕 (F)">
            <template #icon>
              <n-icon size="20"><ExpandOutline /></n-icon>
            </template>
          </n-button>
          
          <n-button circle @click="actualSize" title="实际尺寸 (0)">
            <template #icon>
              <n-icon size="20"><CropOutline /></n-icon>
            </template>
          </n-button>
        </div>

        <div class="toolbar-group">
          <n-button circle @click="downloadImage" title="下载图片">
            <template #icon>
              <n-icon size="20"><DownloadOutline /></n-icon>
            </template>
          </n-button>
        </div>
      </div>

      <!-- 加载提示 -->
      <div v-if="loading" class="loading-overlay">
        <n-spin size="large">
          <template #description>加载中...</template>
        </n-spin>
      </div>
    </div>
  </n-modal>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue';
import { 
  NModal, NButton, NIcon, NSpin, useMessage
} from 'naive-ui';
import {
  CloseOutline, RefreshOutline, AddOutline, RemoveOutline,
  DownloadOutline, ExpandOutline, CropOutline, ArrowBackOutline, ArrowForwardOutline
} from '@vicons/ionicons5';

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  imageSrc: {
    type: String,
    required: true
  },
  imageTitle: {
    type: String,
    default: '图片预览'
  },
  imageSize: {
    type: String,
    default: ''
  },
  downloadName: {
    type: String,
    default: 'image'
  }
});

const emit = defineEmits(['update:show']);

const message = useMessage();

// 响应式数据
const showModal = ref(false);
const loading = ref(true);
const imageRef = ref(null);
const imageWrapper = ref(null);

// 变换参数
const scale = ref(1);
const rotation = ref(0);
const translateX = ref(0);
const translateY = ref(0);

// 约束参数
const minScale = 0.1;
const maxScale = 5;
const zoomStep = 0.2;

// 拖拽相关
const isDragging = ref(false);
const dragStart = ref({ x: 0, y: 0 });
const dragOffset = ref({ x: 0, y: 0 });

// 触摸相关
const isTouch = ref(false);
const touchStart = ref({ x: 0, y: 0, distance: 0 });

// 计算样式
const imageWrapperStyle = computed(() => ({
  transform: `translate(${translateX.value}px, ${translateY.value}px) scale(${scale.value}) rotate(${rotation.value}deg)`,
  transformOrigin: 'center center',
  transition: isDragging.value ? 'none' : 'transform 0.3s ease',
  cursor: isDragging.value ? 'grabbing' : 'grab'
}));

// 监听显示状态
watch(() => props.show, (newVal) => {
  showModal.value = newVal;
  if (newVal) {
    // 初始化状态
    scale.value = 1;
    rotation.value = 0;
    translateX.value = 0;
    translateY.value = 0;
    loading.value = true;
    
    nextTick(() => {
      if (imageWrapper.value) {
        imageWrapper.value.focus();
      }
      // 延迟一点时间，确保DOM完全渲染后再适应屏幕
      setTimeout(() => {
        if (imageRef.value && imageRef.value.complete && imageRef.value.naturalWidth) {
          loading.value = false;
          fitToScreen();
        }
      }, 200); // 增加延迟时间，确保图片完全加载
    });
  }
});

watch(showModal, (newVal) => {
  emit('update:show', newVal);
});

// 图片加载完成
const handleImageLoad = () => {
  console.log('Image loaded, natural size:', imageRef.value?.naturalWidth, 'x', imageRef.value?.naturalHeight);
  loading.value = false;
  // 确保DOM更新后再执行适应屏幕
  nextTick(() => {
    setTimeout(() => {
      fitToScreen();
    }, 100);
  });
};

// 图片加载错误
const handleImageError = () => {
  loading.value = false;
  message.error('图片加载失败');
};

// 重置变换
const resetTransform = () => {
  scale.value = 1;
  rotation.value = 0;
  translateX.value = 0;
  translateY.value = 0;
  loading.value = true;
  
  // 强制重新加载图片
  if (imageRef.value) {
    const src = imageRef.value.src;
    imageRef.value.src = '';
    nextTick(() => {
      imageRef.value.src = src;
    });
  }
};

// 缩放操作
const zoomIn = () => {
  const newScale = Math.min(scale.value + zoomStep, maxScale);
  scale.value = newScale;
};

const zoomOut = () => {
  const newScale = Math.max(scale.value - zoomStep, minScale);
  scale.value = newScale;
};

// 旋转操作
const rotateLeft = () => {
  rotation.value -= 90;
};

const rotateRight = () => {
  rotation.value += 90;
};

// 适应屏幕
const fitToScreen = () => {
  if (!imageRef.value) return;
  
  // 等待图片自然尺寸可用
  if (!imageRef.value.naturalWidth || !imageRef.value.naturalHeight) {
    setTimeout(() => fitToScreen(), 100);
    return;
  }
  
  // 获取查看器容器的实际尺寸
  const container = document.querySelector('.image-viewer-container');
  if (!container) {
    console.log('Container not found');
    return;
  }
  
  const containerRect = container.getBoundingClientRect();
  console.log('Container rect:', containerRect);
  
  // 计算可用空间，预留边距和工具栏空间
  const padding = 60; // 增加边距，让图片显示更大
  const toolbarHeight = 80; // 工具栏高度
  
  const availableWidth = containerRect.width - (padding * 2);
  const availableHeight = containerRect.height - toolbarHeight - padding;
  
  // 获取图片原始尺寸
  const imageWidth = imageRef.value.naturalWidth;
  const imageHeight = imageRef.value.naturalHeight;
  
  console.log('Image natural size:', imageWidth, 'x', imageHeight);
  console.log('Available space:', availableWidth, 'x', availableHeight);
  
  // 计算两个方向的缩放比例
  const scaleX = availableWidth / imageWidth;
  const scaleY = availableHeight / imageHeight;
  
  // 取较小的比例，确保图片完全显示
  let newScale = Math.min(scaleX, scaleY);
  
  // 如果图片比可用空间小，则放大到至少50%的可用空间
  if (newScale > 1) {
    // 图片较小，可以适当放大
    const minScale = Math.min(scaleX, scaleY) * 0.8; // 放大到80%的可用空间
    newScale = Math.max(minScale, 0.5); // 最小50%
  } else {
    // 图片较大，需要缩小以适应屏幕
    newScale = Math.max(0.1, newScale); // 最小10%
  }
  
  // 限制缩放范围：最小10%，最大300%
  newScale = Math.max(0.1, Math.min(newScale, 3));
  
  console.log('Calculated scale:', newScale);
  
  // 重置位置并应用缩放
  translateX.value = 0;
  translateY.value = 0;
  scale.value = newScale;
};

// 实际尺寸
const actualSize = () => {
  scale.value = 1;
  translateX.value = 0;
  translateY.value = 0;
};

// 鼠标滚轮缩放
const handleWheel = (e) => {
  e.preventDefault();
  const delta = e.deltaY > 0 ? -zoomStep : zoomStep;
  const newScale = Math.max(minScale, Math.min(maxScale, scale.value + delta));
  scale.value = newScale;
};

// 鼠标拖拽
const handleMouseDown = (e) => {
  e.preventDefault();
  isDragging.value = true;
  dragStart.value = { x: e.clientX, y: e.clientY };
  dragOffset.value = { x: translateX.value, y: translateY.value };
};

const handleMouseMove = (e) => {
  if (!isDragging.value) return;
  
  const deltaX = e.clientX - dragStart.value.x;
  const deltaY = e.clientY - dragStart.value.y;
  
  translateX.value = dragOffset.value.x + deltaX;
  translateY.value = dragOffset.value.y + deltaY;
};

const handleMouseUp = () => {
  isDragging.value = false;
};

// 触摸操作
const handleTouchStart = (e) => {
  e.preventDefault();
  
  if (e.touches.length === 1) {
    // 单指拖拽
    isDragging.value = true;
    isTouch.value = true;
    dragStart.value = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    dragOffset.value = { x: translateX.value, y: translateY.value };
  } else if (e.touches.length === 2) {
    // 双指缩放
    const touch1 = e.touches[0];
    const touch2 = e.touches[1];
    const distance = Math.sqrt(
      Math.pow(touch2.clientX - touch1.clientX, 2) + 
      Math.pow(touch2.clientY - touch1.clientY, 2)
    );
    
    touchStart.value = {
      x: (touch1.clientX + touch2.clientX) / 2,
      y: (touch1.clientY + touch2.clientY) / 2,
      distance: distance
    };
  }
};

const handleTouchMove = (e) => {
  e.preventDefault();
  
  if (e.touches.length === 1 && isDragging.value) {
    // 单指拖拽
    const deltaX = e.touches[0].clientX - dragStart.value.x;
    const deltaY = e.touches[0].clientY - dragStart.value.y;
    
    translateX.value = dragOffset.value.x + deltaX;
    translateY.value = dragOffset.value.y + deltaY;
  } else if (e.touches.length === 2) {
    // 双指缩放
    const touch1 = e.touches[0];
    const touch2 = e.touches[1];
    const distance = Math.sqrt(
      Math.pow(touch2.clientX - touch1.clientX, 2) + 
      Math.pow(touch2.clientY - touch1.clientY, 2)
    );
    
    const scaleChange = distance / touchStart.value.distance;
    const newScale = Math.max(minScale, Math.min(maxScale, scale.value * scaleChange));
    scale.value = newScale;
    
    touchStart.value.distance = distance;
  }
};

const handleTouchEnd = () => {
  isDragging.value = false;
  isTouch.value = false;
};

// 键盘操作
const handleKeydown = (e) => {
  switch (e.key) {
    case 'Escape':
      closeModal();
      break;
    case '+':
    case '=':
      zoomIn();
      break;
    case '-':
      zoomOut();
      break;
    case '0':
      actualSize();
      break;
    case 'f':
    case 'F':
      fitToScreen();
      break;
    case 'r':
    case 'R':
      if (e.shiftKey) {
        rotateLeft();
      } else {
        rotateRight();
      }
      break;
  }
};

// 下载图片
const downloadImage = () => {
  const a = document.createElement('a');
  a.href = props.imageSrc;
  a.download = props.downloadName;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  message.success('图片下载已开始');
};

// 关闭模态框
const closeModal = () => {
  showModal.value = false;
};

const handleModalClose = (show) => {
  if (!show) {
    // 模态框关闭时重置状态，但不触发重新加载
    scale.value = 1;
    rotation.value = 0;
    translateX.value = 0;
    translateY.value = 0;
    loading.value = false;
  }
};
</script>

<style scoped>
.viewer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.image-info {
  flex: 1;
}

.image-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

.image-meta {
  font-size: 12px;
  color: #6b7280;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.image-viewer-container {
  position: relative;
  width: 100%;
  height: calc(95vh - 140px);
  overflow: hidden;
  background: #f8fafc;
  border-radius: 8px;
  outline: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.image-wrapper {
  transform-origin: center center;
  will-change: transform;
}

.main-image {
  display: block;
  max-width: none;
  max-height: none;
  user-select: none;
  pointer-events: none;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  border-radius: 4px;
}

.toolbar {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 20px;
  background: rgba(0, 0, 0, 0.8);
  padding: 12px 20px;
  border-radius: 30px;
  backdrop-filter: blur(10px);
}

.toolbar-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.zoom-info {
  padding: 0 12px;
  color: white;
  font-size: 14px;
  font-weight: 500;
  min-width: 60px;
  text-align: center;
}

.toolbar :deep(.n-button) {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  width: 40px;
  height: 40px;
}

.toolbar :deep(.n-button:hover) {
  background: rgba(255, 255, 255, 0.2) !important;
  border-color: rgba(255, 255, 255, 0.3) !important;
}

.toolbar :deep(.n-button:disabled) {
  background: rgba(255, 255, 255, 0.05) !important;
  border-color: rgba(255, 255, 255, 0.1) !important;
  color: rgba(255, 255, 255, 0.4) !important;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(248, 250, 252, 0.9);
  backdrop-filter: blur(5px);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .toolbar {
    flex-wrap: wrap;
    padding: 8px 16px;
    gap: 12px;
  }
  
  .toolbar-group {
    gap: 6px;
  }
  
  .toolbar :deep(.n-button) {
    width: 36px;
    height: 36px;
  }
  
  .zoom-info {
    padding: 0 8px;
    font-size: 12px;
    min-width: 50px;
  }
}
</style> 