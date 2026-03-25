const { defineComponent } = Vue;

/**
 * 로그 목록 테이블 스켈레톤 — /dev-fe에서 API·컬럼 연동
 */
export default defineComponent({
  name: "LogsTable",
  props: {
    rows: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
  },
  emits: ["row-click", "edit"],
  template: `
    <el-table :data="rows" v-loading="loading" stripe border style="width: 100%" @row-click="(row) => $emit('row-click', row)">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="항목(placeholder)" min-width="160" />
      <el-table-column prop="status" label="상태" width="100" />
      <el-table-column label="작업" width="120" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click.stop="$emit('edit', row)">수정</el-button>
        </template>
      </el-table-column>
    </el-table>
  `,
});
