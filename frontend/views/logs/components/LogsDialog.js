const { defineComponent, ref, watch, defineAsyncComponent } = Vue;

/**
 * 로그 상세/확인 다이얼로그 스켈레톤
 */
export default defineComponent({
  name: "LogsDialog",
  components: {
    LogsForm: defineAsyncComponent(() => import("./LogsForm.js")),
  },
  props: {
    visible: { type: Boolean, default: false },
    title: { type: String, default: "상세" },
    payload: { type: Object, default: () => ({}) },
  },
  emits: ["update:visible", "confirm"],
  template: `
    <el-dialog
      :model-value="visible"
      :title="title"
      width="520px"
      @update:model-value="$emit('update:visible', $event)"
      @close="close"
    >
      <LogsForm v-model="inner" readonly />
      <template #footer>
        <el-button @click="close">닫기</el-button>
        <el-button type="primary" @click="onConfirm">확인</el-button>
      </template>
    </el-dialog>
  `,
  setup(props, { emit }) {
    const inner = ref({ ...props.payload });

    watch(
      () => props.visible,
      (v) => {
        if (v) inner.value = { ...props.payload };
      },
    );

    watch(
      () => props.payload,
      (v) => {
        inner.value = { ...v };
      },
      { deep: true },
    );

    const close = () => emit("update:visible", false);
    const onConfirm = () => {
      emit("confirm", { ...inner.value });
      close();
    };

    return { inner, close, onConfirm };
  },
});
