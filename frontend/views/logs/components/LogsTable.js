const { defineComponent } = Vue;

/**
 * 배치 로그 / 상태 이력 / 화면 접근 로그 테이블 (variant 분기)
 */
export default defineComponent({
  name: "LogsTable",
  props: {
    variant: {
      type: String,
      default: "batch",
      validator: (v) => ["batch", "status_hist", "screen_access"].includes(v),
    },
    rows: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
    highlightCurrent: { type: Boolean, default: false },
  },
  emits: ["row-click", "open-detail"],
  template: `
    <el-table
      v-if="variant === 'batch'"
      :data="rows"
      v-loading="loading"
      border
      stripe
      class="w-full"
      :highlight-current-row="highlightCurrent"
      @row-click="(row) => $emit('row-click', row)"
    >
      <el-table-column prop="batch_log_id" label="ID" width="72" />
      <el-table-column prop="batch_name" label="배치명" min-width="120" />
      <el-table-column label="상태" width="100">
        <template #default="{ row }">
          <el-tag :type="statusTagType(row.status)" size="small">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="처리건수" width="220">
        <template #default="{ row }">
          성공 {{ row.success_count }} / 오류 {{ row.error_count }} / 스킵 {{ row.skip_count }}
        </template>
      </el-table-column>
      <el-table-column prop="error_message" label="요약 오류" min-width="140" show-overflow-tooltip />
      <el-table-column label="기간" min-width="200">
        <template #default="{ row }">
          {{ row.start_datetime }} ~ {{ row.end_datetime }}
        </template>
      </el-table-column>
      <el-table-column label="상세" width="72" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click.stop="$emit('open-detail', row)">보기</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-table
      v-else-if="variant === 'status_hist'"
      :data="rows"
      v-loading="loading"
      border
      size="small"
      class="w-full"
    >
      <el-table-column prop="record_key" label="레코드키" min-width="140" />
      <el-table-column prop="change_type" label="유형" width="90" />
      <el-table-column prop="old_status" label="이전" width="88" />
      <el-table-column prop="new_status" label="이후" width="88" />
      <el-table-column prop="changed_by" label="변경자" width="96" />
      <el-table-column prop="changed_at" label="일시" min-width="140" />
    </el-table>

    <el-table
      v-else
      :data="rows"
      v-loading="loading"
      border
      size="small"
      class="w-full"
    >
      <el-table-column prop="userid" label="사용자" width="100" />
      <el-table-column prop="screen_name" label="화면" min-width="120" />
      <el-table-column prop="access_type" label="유형" width="100" />
      <el-table-column prop="ip_address" label="IP" width="120" />
      <el-table-column prop="accessed_at" label="일시" min-width="140" />
    </el-table>
  `,
  setup() {
    const statusTagType = (s) => {
      if (s === "FAILED") return "danger";
      if (s === "PARTIAL") return "warning";
      if (s === "COMPLETED") return "success";
      return "info";
    };
    return { statusTagType };
  },
});
