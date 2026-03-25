const { defineComponent, ref, defineAsyncComponent, onMounted } = Vue;
import router from "../../../router.js";
import { useLogs } from "../../../composables/useLogs.js";

export default defineComponent({
  name: "LogsCreatePage",
  components: {
    LogsForm: defineAsyncComponent(() => import("../components/LogsForm.js")),
  },
  template: `
    <div>
      <el-page-header @back="goBack" content="재처리 요청" class="mb-4" />
      <el-card shadow="never">
        <p class="text-sm text-gray-500 mb-4">
          배치 실행 단위 재처리를 요청합니다. 서버는 E1002 등으로 중복·정책 위반 시 거절할 수 있습니다.
        </p>
        <LogsForm v-model="form" :submit-loading="submitLoading" @submit="onSubmit" @cancel="goBack" />
      </el-card>
    </div>
  `,
  setup() {
    const { postBatchRetryRequest } = useLogs();
    const form = ref({ batch_log_id: "", ref_no: "", remark: "" });
    const submitLoading = ref(false);

    const goBack = () => router.push("/logs/list");

    const onSubmit = async (payload) => {
      submitLoading.value = true;
      try {
        await postBatchRetryRequest(payload);
        ElMessage.success("재처리 요청이 접수되었습니다.");
        goBack();
      } catch {
        /* useApi에서 메시지 처리 */
      } finally {
        submitLoading.value = false;
      }
    };

    onMounted(() => {
      const q = router.currentRoute.value.query || {};
      if (q.batch_log_id != null && q.batch_log_id !== "") {
        form.value = { ...form.value, batch_log_id: String(q.batch_log_id) };
      }
    });

    return { form, submitLoading, goBack, onSubmit };
  },
});
