const { defineComponent, ref, defineAsyncComponent } = Vue;
import router from "../../../router.js";

/**
 * 로그 등록 페이지 — 스켈레톤
 */
export default defineComponent({
  name: "LogsCreatePage",
  components: {
    LogsForm: defineAsyncComponent(() => import("../components/LogsForm.js")),
  },
  template: `
    <div>
      <el-page-header @back="goBack" content="로그 등록" class="mb-4" />
      <el-card shadow="never">
        <LogsForm v-model="form" @submit="onSubmit" @cancel="goBack" />
      </el-card>
    </div>
  `,
  setup() {
    const form = ref({ name: "", remark: "" });

    const goBack = () => router.push("/logs/list");

    const onSubmit = () => {
      ElMessage.info("스캐폴드: /dev-fe에서 API 저장을 구현하세요.");
      goBack();
    };

    return { form, goBack, onSubmit };
  },
});
