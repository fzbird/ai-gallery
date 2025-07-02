<template>
  <div class="category-tree-node" :class="{ 'is-expanded': isExpanded, 'has-children': node.children && node.children.length > 0 }">
    <!-- 节点内容 -->
    <div class="node-content" @click="handleClick">
      <!-- 展开/折叠按钮 -->
      <div class="expand-button" @click.stop="toggleExpand" v-if="node.children && node.children.length > 0">
        <n-icon size="16" :class="{ 'expanded': isExpanded }">
          <ChevronRightIcon />
        </n-icon>
      </div>
      <div class="expand-placeholder" v-else></div>
      
      <!-- 节点图标 -->
      <div class="node-icon">
        <n-icon size="20" :color="getNodeColor()">
          <component :is="getNodeIcon()" />
        </n-icon>
      </div>
      
      <!-- 节点信息 -->
      <div class="node-info">
        <div class="node-name" :class="{ 'highlighted': isHighlighted }">
          {{ node.name }}
        </div>
        <div class="node-meta">
          <span class="level-badge">L{{ node.level }}</span>
          <span class="content-count">{{ node.content_count }} 个图集</span>
          <span v-if="node.all_content_count > node.content_count" class="total-count">
            (含子分类: {{ node.all_content_count }})
          </span>
        </div>
        <div v-if="node.description" class="node-description">
          {{ node.description }}
        </div>
      </div>
      
      <!-- 快速操作 -->
      <div class="node-actions">
        <n-button size="small" type="primary" ghost @click.stop="$emit('view-category', node.id)">
          查看
        </n-button>
      </div>
    </div>
    
    <!-- 子节点 -->
    <div v-if="isExpanded && node.children && node.children.length > 0" class="children-container">
      <CategoryTreeNode
        v-for="child in node.children"
        :key="child.id"
        :node="child"
        :search-query="searchQuery"
        @view-category="$emit('view-category', $event)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { NIcon, NButton } from 'naive-ui'
import { 
  ChevronForward as ChevronRightIcon,
  Folder as FolderOutline,
  FolderOpen as FolderOpenOutline,
  Document as DocumentOutline
} from '@vicons/ionicons5'

const props = defineProps({
  node: {
    type: Object,
    required: true
  },
  searchQuery: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['view-category'])

// 所有节点默认收起状态，不自动展开
const isExpanded = ref(false)

// 监听搜索查询，如果有搜索且节点或子节点匹配，则展开
watch(() => props.searchQuery, (newQuery) => {
  if (newQuery && newQuery.trim()) {
    // 检查当前节点或任何子节点是否匹配搜索
    if (hasMatchingDescendant(props.node, newQuery)) {
      isExpanded.value = true
    }
  } else {
    // 搜索清空时，重置为收起状态
    isExpanded.value = false
  }
}, { immediate: true })

// 检查节点或其后代是否匹配搜索查询
function hasMatchingDescendant(node, query) {
  const lowerQuery = query.toLowerCase()
  
  // 检查当前节点是否匹配
  const nodeMatches = node.name.toLowerCase().includes(lowerQuery) ||
                     (node.description && node.description.toLowerCase().includes(lowerQuery))
  
  if (nodeMatches) return true
  
  // 递归检查子节点
  if (node.children && node.children.length > 0) {
    return node.children.some(child => hasMatchingDescendant(child, query))
  }
  
  return false
}

const isHighlighted = computed(() => {
  if (!props.searchQuery) return false
  return props.node.name.toLowerCase().includes(props.searchQuery.toLowerCase()) ||
         (props.node.description && props.node.description.toLowerCase().includes(props.searchQuery.toLowerCase()))
})

function toggleExpand() {
  isExpanded.value = !isExpanded.value
}

function handleClick() {
  if (props.node.children && props.node.children.length > 0) {
    toggleExpand()
  } else {
    emit('view-category', props.node.id)
  }
}

function getNodeIcon() {
  if (props.node.children && props.node.children.length > 0) {
    return isExpanded.value ? FolderOpenOutline : FolderOutline
  }
  return DocumentOutline
}

function getNodeColor() {
  const colors = ['#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ef4444']
  return colors[props.node.level % colors.length] || '#10b981'
}
</script>

<style scoped>
.category-tree-node {
  margin-bottom: 4px;
}

.node-content {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.2s ease;
  gap: 12px;
}

.node-content:hover {
  background: #f8fafc;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  transform: translateY(-1px);
}

.expand-button {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.expand-button:hover {
  background: #e5e7eb;
}

.expand-button .n-icon {
  transition: transform 0.2s ease;
}

.expand-button .n-icon.expanded {
  transform: rotate(90deg);
}

.expand-placeholder {
  width: 20px;
}

.node-icon {
  flex-shrink: 0;
}

.node-info {
  flex: 1;
  min-width: 0;
}

.node-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.node-name.highlighted {
  color: #10b981;
  background: linear-gradient(120deg, #10b981 0%, #059669 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.node-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.level-badge {
  background: #e0f2fe;
  color: #0277bd;
  padding: 2px 6px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.content-count {
  color: #10b981;
  font-size: 13px;
  font-weight: 500;
}

.total-count {
  color: #6b7280;
  font-size: 12px;
}

.node-description {
  color: #6b7280;
  font-size: 13px;
  line-height: 1.4;
  margin-top: 4px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.node-actions {
  flex-shrink: 0;
}

.children-container {
  margin-left: 32px;
  margin-top: 8px;
  padding-left: 16px;
  border-left: 2px solid #e5e7eb;
}

/* 动画效果 */
.children-container {
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .node-content {
    padding: 10px 12px;
    gap: 8px;
  }
  
  .node-name {
    font-size: 15px;
  }
  
  .children-container {
    margin-left: 20px;
    padding-left: 12px;
  }
}
</style> 