const { defineComponent, ref, reactive, defineAsyncComponent, onMounted } = Vue;
import router from "../../../router.js";
import { useLogs } from "../../../composables/useLogs.js";

export default defineComponent({
  name: "LogsListPage",
  components: {
    LogsTable: defineAsyncComponent(() => import("../components/LogsTable.js")),
    LogsDialog: defineAsyncComponent(() => import("../components/LogsDialog.js")),
  },
  template: `
    <div class="logs-list-page">
      <el-page-header @back="goHome" content="로그·이력" class="mb-4" />
      <el-card shadow="never">
        <template #header>
          <div class="flex justify-between items-center flex-wrap gap-2">
            <span>배치 로그 · 상태 이력 · 화면 접근</span>
            <el-button type="primary" plain @click="goRetryForm">재처리 요청</el-button>
          </div>
        </template>

        <el-tabs v-model="activeTab" @tab-change="onTabChange">
          <el-tab-pane label="배치 실행 이력" name="batch">
            <div v-loading="batchLoading">
              <el-form :inline="true" class="mb-3 flex flex-wrap gap-2">
                <el-form-item label="창고코드">
                  <el-input v-model="filters.wh_cd" placeholder="WH01" clearable class="w-36" />
                </el-form-item>
                <el-form-item label="배치유형">
                  <el-select v-model="filters.batch_type" placeholder="전체" clearable class="w-44">
                    <el-option v-for="o in batchTypeOptions" :key="o.value" :label="o.label" :value="o.value" />
                  </el-select>
                </el-form-item>
                <el-form-item label="상태">
                  <el-select v-model="filters.status" placeholder="전체" clearable class="w-40">
                    <el-option v-for="o in statusOptions" :key="o.value" :label="o.label" :value="o.value" />
                  </el-select>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="onSearchBatch">조회</el-button>
                  <el-button @click="onResetBatch">초기화</el-button>
                </el-form-item>
              </el-form>

              <div class="flex flex-wrap gap-2 mb-3">
                <el-button type="warning" plain @click="openErrorDrawer">오류 상세</el-button>
                <el-button type="danger" plain @click="openRetryDialog">재처리 요청</el-button>
              </div>

              <p class="text-sm text-gray-500 mb-2">행을 클릭하여 선택한 뒤 오류 상세·재처리를 사용하세요.</p>
              <LogsTable
                variant="batch"
                :rows="batchRows"
                :loading="batchLoading"
                :highlight-current="true"
                @row-click="onBatchRowClick"
                @open-detail="onOpenBatchDetail"
              />
              <div class="mt-4 flex justify-end">
                <el-pagination
                  layout="total, prev, pager, next, sizes"
                  :total="batchTotal"
                  v-model:current-page="batchPage"
                  v-model:page-size="batchPageSize"
                  :page-sizes="[10, 20, 50]"
                  @current-change="loadBatchList"
                  @size-change="onBatchSizeChange"
                />
              </div>
            </div>
          </el-tab-pane>

          <el-tab-pane label="상태 변경 이력" name="hist">
            <div class="mb-2 flex justify-end">
              <el-button size="small" @click="loadHistList" :loading="histLoading">새로고침</el-button>
            </div>
            <LogsTable variant="status_hist" :rows="histRows" :loading="histLoading" />
            <div class="mt-4 flex justify-end">
              <el-pagination
                layout="total, prev, pager, next"
                :total="histTotal"
                v-model:current-page="histPage"
                :page-size="histPageSize"
                @current-change="loadHistList"
              />
            </div>
          </el-tab-pane>

          <el-tab-pane label="화면 접근(PII)" name="access">
            <div class="mb-2 flex justify-end">
              <el-button size="small" @click="loadAccessList" :loading="accessLoading">새로고침</el-button>
            </div>
            <LogsTable variant="screen_access" :rows="accessRows" :loading="accessLoading" />
            <div class="mt-4 flex justify-end">
              <el-pagination
                layout="total, prev, pager, next"
                :total="accessTotal"
                v-model:current-page="accessPage"
                :page-size="accessPageSize"
                @current-change="loadAccessList"
              />
            </div>
          </el-tab-pane>
        </el-tabs>
      </el-card>

      <el-drawer v-model="drawerVisible" title="배치 오류 상세" size="520px">
        <div v-loading="errorLoading">
          <p v-if="selectedBatchRow" class="text-sm mb-2">batch_log_id: {{ selectedBatchRow.batch_log_id }}</p>
          <el-table :data="errorRows" border size="small">
            <el-table-column prop="ref_no" label="참조번호" width="140" />
            <el-table-column prop="error_code" label="코드" width="80" />
            <el-table-column prop="error_message" label="메시지" min-width="120" show-overflow-tooltip />
            <el-table-column prop="retry_status" label="재시도상태" width="100" />
            <el-table-column prop="retry_count" label="횟수" width="64" />
          </el-table>
          <div class="mt-4">
            <el-button @click="drawerVisible = false">닫기</el-button>
            <el-button type="primary" plain class="ml-2" @click="goDetailFromDrawer">배치 상세 화면</el-button>
          </div>
        </div>
      </el-drawer>

      <LogsDialog
        v-model:visible="retryDialogVisible"
        title="재처리 확인"
        :context="retryContext"
        :confirm-loading="retrySubmitting"
        @confirm="confirmRetry"
      />
    </div>
  `,
  setup() {
    const {
      fetchBatchJobLogs,
      fetchBatchJobLogErrors,
      postBatchRetryRequest,
      fetchStatusChangeHistories,
      fetchScreenAccessLogs,
    } = useLogs();

    const activeTab = ref("batch");

    const filters = reactive({ wh_cd: "", batch_type: "", status: "" });
    const batchTypeOptions = [
      { label: "전체", value: "" },
      { label: "입고주문생성", value: "INBOUND_ORDER" },
      { label: "출고주문생성", value: "OUTBOUND_ORDER" },
    ];
    const statusOptions = [
      { label: "전체", value: "" },
      { label: "실행중", value: "RUNNING" },
      { label: "완료", value: "COMPLETED" },
      { label: "실패", value: "FAILED" },
      { label: "부분완료", value: "PARTIAL" },
    ];

    const batchLoading = ref(false);
    const batchRows = ref([]);
    const batchTotal = ref(0);
    const batchPage = ref(1);
    const batchPageSize = ref(10);
    const selectedBatchRow = ref(null);

    const drawerVisible = ref(false);
    const errorLoading = ref(false);
    const errorRows = ref([]);

    const retryDialogVisible = ref(false);
    const retrySubmitting = ref(false);

    const histLoading = ref(false);
    const histRows = ref([]);
    const histTotal = ref(0);
    const histPage = ref(1);
    const histPageSize = ref(20);

    const accessLoading = ref(false);
    const accessRows = ref([]);
    const accessTotal = ref(0);
    const accessPage = ref(1);
    const accessPageSize = ref(20);

    const retryContext = ref({});

    const buildBatchParams = () => {
      const q = {
        page: batchPage.value,
        pageSize: batchPageSize.value,
      };
      const w = filters.wh_cd?.trim();
      if (w) q.wh_cd = w;
      if (filters.batch_type) q.batch_type = filters.batch_type;
      if (filters.status) q.status = filters.status;
      return q;
    };

    const loadBatchList = async () => {
      batchLoading.value = true;
      try {
        const res = await fetchBatchJobLogs(buildBatchParams());
        const data = res?.data ?? {};
        const rows = data.list ?? [];
        batchRows.value = rows;
        batchTotal.value = data.total ?? rows.length;
      } catch {
        batchRows.value = [];
        batchTotal.value = 0;
      } finally {
        batchLoading.value = false;
      }
    };

    const loadHistList = async () => {
      histLoading.value = true;
      try {
        const res = await fetchStatusChangeHistories({
          page: histPage.value,
          pageSize: histPageSize.value,
        });
        const data = res?.data ?? {};
        histRows.value = data.list ?? [];
        histTotal.value = data.total ?? histRows.value.length;
      } catch {
        histRows.value = [];
        histTotal.value = 0;
      } finally {
        histLoading.value = false;
      }
    };

    const loadAccessList = async () => {
      accessLoading.value = true;
      try {
        const res = await fetchScreenAccessLogs({
          page: accessPage.value,
          pageSize: accessPageSize.value,
        });
        const data = res?.data ?? {};
        accessRows.value = data.list ?? [];
        accessTotal.value = data.total ?? accessRows.value.length;
      } catch {
        accessRows.value = [];
        accessTotal.value = 0;
      } finally {
        accessLoading.value = false;
      }
    };

    const onTabChange = (name) => {
      if (name === "hist" && histRows.value.length === 0 && !histLoading.value) loadHistList();
      if (name === "access" && accessRows.value.length === 0 && !accessLoading.value) loadAccessList();
    };

    const onSearchBatch = () => {
      batchPage.value = 1;
      loadBatchList();
    };

    const onResetBatch = () => {
      filters.wh_cd = "";
      filters.batch_type = "";
      filters.status = "";
      batchPage.value = 1;
      loadBatchList();
    };

    const onBatchSizeChange = () => {
      batchPage.value = 1;
      loadBatchList();
    };

    const onBatchRowClick = (row) => {
      selectedBatchRow.value = row;
    };

    const onOpenBatchDetail = (row) => {
      if (row?.batch_log_id == null) return;
      selectedBatchRow.value = row;
      router.push("/logs/edit/" + encodeURIComponent(row.batch_log_id));
    };

    const openErrorDrawer = async () => {
      if (!selectedBatchRow.value) {
        ElMessage.warning("행을 선택하세요.");
        return;
      }
      drawerVisible.value = true;
      errorLoading.value = true;
      errorRows.value = [];
      try {
        const id = selectedBatchRow.value.batch_log_id;
        const res = await fetchBatchJobLogErrors(id);
        errorRows.value = res?.data?.list ?? [];
      } catch {
        errorRows.value = [];
      } finally {
        errorLoading.value = false;
      }
    };

    const openRetryDialog = () => {
      if (!selectedBatchRow.value) {
        ElMessage.warning("행을 선택하세요.");
        return;
      }
      retryContext.value = { ...selectedBatchRow.value };
      retryDialogVisible.value = true;
    };

    const confirmRetry = async () => {
      const row = selectedBatchRow.value;
      if (!row?.batch_log_id) {
        retryDialogVisible.value = false;
        return;
      }
      retrySubmitting.value = true;
      try {
        await postBatchRetryRequest({ batch_log_id: row.batch_log_id });
        ElMessage.success("재처리 요청이 접수되었습니다.");
        retryDialogVisible.value = false;
        await loadBatchList();
      } catch {
        /* 메시지는 useApi에서 처리 */
      } finally {
        retrySubmitting.value = false;
      }
    };

    const goDetailFromDrawer = () => {
      const id = selectedBatchRow.value?.batch_log_id;
      if (id == null) return;
      drawerVisible.value = false;
      router.push("/logs/edit/" + encodeURIComponent(id));
    };

    const goHome = () => router.push("/");
    const goRetryForm = () => {
      const id = selectedBatchRow.value?.batch_log_id;
      if (id != null) {
        router.push({
          path: "/logs/create",
          query: { batch_log_id: String(id) },
        });
      } else {
        router.push("/logs/create");
      }
    };

    onMounted(() => {
      loadBatchList();
    });

    return {
      activeTab,
      filters,
      batchTypeOptions,
      statusOptions,
      batchLoading,
      batchRows,
      batchTotal,
      batchPage,
      batchPageSize,
      selectedBatchRow,
      drawerVisible,
      errorLoading,
      errorRows,
      retryDialogVisible,
      retrySubmitting,
      retryContext,
      histLoading,
      histRows,
      histTotal,
      histPage,
      histPageSize,
      accessLoading,
      accessRows,
      accessTotal,
      accessPage,
      accessPageSize,
      goHome,
      goRetryForm,
      onTabChange,
      loadBatchList,
      loadHistList,
      loadAccessList,
      onSearchBatch,
      onResetBatch,
      onBatchSizeChange,
      onBatchRowClick,
      onOpenBatchDetail,
      openErrorDrawer,
      openRetryDialog,
      confirmRetry,
      goDetailFromDrawer,
    };
  },
});
