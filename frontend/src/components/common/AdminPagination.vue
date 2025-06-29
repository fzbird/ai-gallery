<template>
  <div class="pagination-container" v-if="itemCount > 0">
    <n-pagination
      :page="page"
      :page-size="pageSize"
      :item-count="itemCount"
      :page-sizes="[10, 20, 30, 40]"
      show-size-picker
      show-quick-jumper
      :prefix="({ itemCount }) => `共 ${itemCount} 条`"
      @update:page="$emit('update:page', $event)"
      @update:page-size="$emit('update:pageSize', $event)"
      style="justify-content: flex-end; margin-top: 20px;"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { NPagination } from 'naive-ui';

const props = defineProps({
  page: {
    type: Number,
    required: true,
  },
  pageSize: {
    type: Number,
    required: true,
  },
  itemCount: {
    type: Number,
    required: true,
  },
});

defineEmits(['update:page', 'update:pageSize']);

const pageCount = computed(() => {
  if (props.itemCount === 0) return 1;
  return Math.ceil(props.itemCount / props.pageSize);
});
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style> 