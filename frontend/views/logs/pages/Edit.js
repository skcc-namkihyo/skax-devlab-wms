const { defineComponent, ref, computed, watch, defineAsyncComponent } = Vue;
import router from "../../../router.js";

/**
 * 로그 수정 페이지 — 스켈레톤
 */
export default defineComponent({
  name: "LogsEditPage",
  components: {
    LogsForm: defineAsyncComponent(() => import("../components/LogsForm.js")),
  },
  template: `
    <div>
      <el-page-header @back="goBack" :content="'로그 수정 #' + (routeId || '-')" class="mb-4" />
      <el-card shadow="never">
        <LogsForm v-model="form" @submit="onSubmit" @cancel="goBack" />
      </el-card>
    </div>
  `,
  setup() {
    const form = ref({ name: "", remark: "" });

    const routeId = computed(() => router.currentRoute.value.params.id || "");

    watch(
      routeId,
      (id) => {
        if (id) {
          form.value = { name: "placeholder-" + id, remark: "" };
        }
      },
      { immediate: true },
    );

    const goBack = () => router.push("/logs/list");

    const onSubmit = () => {
      ElMessage.info("스캐폴드: /dev-fe에서 API 수정을 구현하세요.");
      goBack();
    };

    return { form, routeId, goBack, onSubmit };
  },
});
