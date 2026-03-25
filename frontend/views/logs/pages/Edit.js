const { defineComponent, ref, computed, watch } = Vue;
import router from "../../../router.js";
import { useLogs } from "../../../composables/useLogs.js";

export default defineComponent({
  name: "LogsEditPage",
  template: `
    <div>
      <el-page-header @back="goBack" :content="'배치 로그 상세 #' + (routeId || '-')" class="mb-4" />
      <el-card v-loading="detailLoading" shadow="never" class="mb-4">
        <template #header>
          <span>실행 요약</span>
        </template>
        <el-empty v-if="!detail && !detailLoading" description="데이터를 불러오지 못했습니다." />
        <el-descriptions v-else-if="detail" :column="2" border size="small">
          <el-descriptions-item label="batch_log_id">{{ detail.batch_log_id }}</el-descriptions-item>
          <el-descriptions-item label="창고">{{ detail.wh_cd }}</el-descriptions-item>
          <el-descriptions-item label="배치유형">{{ detail.batch_type }}</el-descriptions-item>
          <el-descriptions-item label="배치명">{{ detail.batch_name }}</el-descriptions-item>
          <el-descriptions-item label="상태">
            <el-tag :type="statusTagType(detail.status)" size="small">{{ detail.status }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="처리건수">
            총 {{ detail.total_count }} / 성공 {{ detail.success_count }} / 오류 {{ detail.error_count }} / 스킵
            {{ detail.skip_count }}
          </el-descriptions-item>
          <el-descriptions-item label="시작">{{ detail.start_datetime }}</el-descriptions-item>
          <el-descriptions-item label="종료">{{ detail.end_datetime }}</el-descriptions-item>
          <el-descriptions-item label="요약 오류" :span="2">{{ detail.error_message || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>

      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center">
            <span>오류 상세</span>
            <el-button size="small" :loading="errorsLoading" @click="loadErrors">새로고침</el-button>
          </div>
        </template>
        <el-table :data="errorRows" v-loading="errorsLoading" border size="small">
          <el-table-column prop="ref_no" label="참조번호" width="140" />
          <el-table-column prop="error_code" label="코드" width="80" />
          <el-table-column prop="error_message" label="메시지" min-width="120" show-overflow-tooltip />
          <el-table-column prop="retry_status" label="재시도상태" width="100" />
          <el-table-column prop="retry_count" label="횟수" width="64" />
        </el-table>
      </el-card>
    </div>
  `,
  setup() {
    const { fetchBatchJobLogDetail, fetchBatchJobLogErrors } = useLogs();

    const routeId = computed(() => router.currentRoute.value.params.id || "");
    const detailLoading = ref(false);
    const errorsLoading = ref(false);
    const detail = ref(null);
    const errorRows = ref([]);

    const statusTagType = (s) => {
      if (s === "FAILED") return "danger";
      if (s === "PARTIAL") return "warning";
      if (s === "COMPLETED") return "success";
      return "info";
    };

    const loadDetail = async () => {
      const id = routeId.value;
      if (!id) {
        detail.value = null;
        return;
      }
      detailLoading.value = true;
      try {
        const res = await fetchBatchJobLogDetail(id);
        detail.value = res?.data ?? res ?? null;
      } catch {
        detail.value = null;
      } finally {
        detailLoading.value = false;
      }
    };

    const loadErrors = async () => {
      const id = routeId.value;
      if (!id) {
        errorRows.value = [];
        return;
      }
      errorsLoading.value = true;
      try {
        const res = await fetchBatchJobLogErrors(id);
        errorRows.value = res?.data?.list ?? [];
      } catch {
        errorRows.value = [];
      } finally {
        errorsLoading.value = false;
      }
    };

    watch(
      routeId,
      () => {
        loadDetail();
        loadErrors();
      },
      { immediate: true },
    );

    const goBack = () => router.push("/logs/list");

    return {
      routeId,
      detailLoading,
      errorsLoading,
      detail,
      errorRows,
      statusTagType,
      loadErrors,
      goBack,
    };
  },
});
