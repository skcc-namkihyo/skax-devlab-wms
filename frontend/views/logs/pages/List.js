const { defineComponent, ref, defineAsyncComponent } = Vue;
import router from "../../../router.js";

/**
 * 로그 목록 페이지 — /gen-ui 스캐폴드 (배치·이력 조회 UI의 진입점 placeholder)
 */
export default defineComponent({
  name: "LogsListPage",
  components: {
    LogsTable: defineAsyncComponent(() => import("../components/LogsTable.js")),
  },
  template: `
    <div class="logs-list-page">
      <el-page-header @back="goHome" content="로그 목록" class="mb-4" />
      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center">
            <span>로그·이력 (스캐폴드)</span>
            <div class="flex gap-4">
              <el-button type="primary" @click="goCreate">등록</el-button>
            </div>
          </div>
        </template>
        <p class="text-gray-500 mb-3">Task: wms-005 — 배치 로그·상태 이력·화면 접근 로그 API는 /dev-fe에서 연동합니다.</p>
        <LogsTable :rows="rows" :loading="loading" @edit="onEdit" />
      </el-card>
    </div>
  `,
  setup() {
    const loading = ref(false);
    const rows = ref([
      { id: 1, name: "batch_job_log 조회", status: "TODO" },
      { id: 2, name: "status_change_history 조회", status: "TODO" },
    ]);

    const goHome = () => router.push("/");
    const goCreate = () => router.push("/logs/create");
    const onEdit = (row) => {
      router.push("/logs/edit/" + encodeURIComponent(row.id));
    };

    return {
      loading,
      rows,
      goHome,
      goCreate,
      onEdit,
    };
  },
});
