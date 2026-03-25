const { defineComponent, reactive, watch } = Vue;

/**
 * 로그 등록/수정 폼 스켈레톤 — /dev-fe에서 필드·검증 연동
 */
export default defineComponent({
  name: "LogsForm",
  props: {
    modelValue: { type: Object, default: () => ({}) },
    readonly: { type: Boolean, default: false },
  },
  emits: ["update:modelValue", "submit", "cancel"],
  template: `
    <el-form :model="form" label-width="120px" class="max-w-xl">
      <el-form-item label="이름(placeholder)">
        <el-input v-model="form.name" :disabled="readonly" placeholder="스캐폴드" />
      </el-form-item>
      <el-form-item label="비고">
        <el-input v-model="form.remark" type="textarea" :rows="3" :disabled="readonly" />
      </el-form-item>
      <el-form-item v-if="!readonly">
        <el-button type="primary" @click="onSubmit">저장</el-button>
        <el-button @click="$emit('cancel')">취소</el-button>
      </el-form-item>
    </el-form>
  `,
  setup(props, { emit }) {
    const form = reactive({ name: "", remark: "" });

    watch(
      () => props.modelValue,
      (v) => {
        form.name = v?.name ?? "";
        form.remark = v?.remark ?? "";
      },
      { immediate: true, deep: true },
    );

    const onSubmit = () => {
      emit("update:modelValue", { ...form });
      emit("submit", { ...form });
    };

    return { form, onSubmit };
  },
});
