const { defineComponent, reactive, watch } = Vue;

/**
 * 재처리 요청 폼 — POST /batch-retry-requests Body(Map) 연동
 */
export default defineComponent({
  name: "LogsForm",
  props: {
    modelValue: { type: Object, default: () => ({}) },
    readonly: { type: Boolean, default: false },
    submitLoading: { type: Boolean, default: false },
  },
  emits: ["update:modelValue", "submit", "cancel"],
  template: `
    <el-form ref="formRef" :model="form" :rules="rules" label-width="140px" class="max-w-xl">
      <el-form-item label="배치 로그 ID" prop="batch_log_id">
        <el-input
          v-model="form.batch_log_id"
          :disabled="readonly"
          placeholder="예: 1001"
          clearable
        />
      </el-form-item>
      <el-form-item label="참조번호(선택)" prop="ref_no">
        <el-input v-model="form.ref_no" :disabled="readonly" placeholder="재처리 대상 ref_no" clearable />
      </el-form-item>
      <el-form-item label="비고(선택)" prop="remark">
        <el-input v-model="form.remark" type="textarea" :rows="3" :disabled="readonly" />
      </el-form-item>
      <el-form-item v-if="!readonly">
        <el-button type="primary" :loading="submitLoading" @click="onSubmit">재처리 요청</el-button>
        <el-button @click="$emit('cancel')">취소</el-button>
      </el-form-item>
    </el-form>
  `,
  setup(props, { emit }) {
    const formRef = Vue.ref(null);

    const form = reactive({
      batch_log_id: "",
      ref_no: "",
      remark: "",
    });

    const rules = {
      batch_log_id: [
        { required: true, message: "배치 로그 ID를 입력하세요.", trigger: "blur" },
        {
          validator: (_r, v, cb) => {
            const n = Number(String(v).trim());
            if (!Number.isFinite(n) || n <= 0) {
              cb(new Error("유효한 숫자 ID를 입력하세요."));
            } else {
              cb();
            }
          },
          trigger: "blur",
        },
      ],
    };

    watch(
      () => props.modelValue,
      (v) => {
        form.batch_log_id =
          v?.batch_log_id != null && v?.batch_log_id !== "" ? String(v.batch_log_id) : "";
        form.ref_no = v?.ref_no ?? "";
        form.remark = v?.remark ?? "";
      },
      { immediate: true, deep: true },
    );

    const onSubmit = async () => {
      const elForm = formRef.value;
      if (!elForm) return;
      try {
        await elForm.validate();
      } catch {
        return;
      }
      const batch_log_id = Number(String(form.batch_log_id).trim());
      const payload = {
        batch_log_id,
        ref_no: form.ref_no?.trim() || undefined,
        remark: form.remark?.trim() || undefined,
      };
      emit("update:modelValue", payload);
      emit("submit", payload);
    };

    return { formRef, form, rules, onSubmit };
  },
});
