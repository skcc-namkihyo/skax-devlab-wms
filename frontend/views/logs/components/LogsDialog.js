const { defineComponent, computed } = Vue;

/**
 * 재처리 확인 등 단순 확인 다이얼로그
 */
export default defineComponent({
  name: "LogsDialog",
  props: {
    visible: { type: Boolean, default: false },
    title: { type: String, default: "확인" },
    /** 선택 행 요약 등 표시용 객체 */
    context: { type: Object, default: () => ({}) },
    confirmLoading: { type: Boolean, default: false },
  },
  emits: ["update:visible", "confirm"],
  template: `
    <el-dialog
      :model-value="visible"
      :title="title"
      width="480px"
      @update:model-value="$emit('update:visible', $event)"
      @close="close"
    >
      <el-alert type="warning" show-icon :closable="false" class="mb-3" title="재처리는 서버 정책(E1002 등)에 따라 거절될 수 있습니다." />
      <p v-if="summaryLines.length" class="text-sm text-gray-600 space-y-1">
        <span v-for="(line, i) in summaryLines" :key="i" class="block">{{ line }}</span>
      </p>
      <template #footer>
        <el-button @click="close" :disabled="confirmLoading">취소</el-button>
        <el-button type="primary" :loading="confirmLoading" @click="onConfirm">재처리 요청</el-button>
      </template>
    </el-dialog>
  `,
  setup(props, { emit }) {
    const summaryLines = computed(() => {
      const c = props.context || {};
      const lines = [];
      if (c.batch_log_id != null) lines.push(`batch_log_id: ${c.batch_log_id}`);
      if (c.batch_name) lines.push(`배치명: ${c.batch_name}`);
      if (c.status) lines.push(`상태: ${c.status}`);
      return lines;
    });

    const close = () => emit("update:visible", false);
    const onConfirm = () => emit("confirm");

    return { summaryLines, close, onConfirm };
  },
});
