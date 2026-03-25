import { useApi } from "./useApi.js";

/**
 * 로그·이력 모듈 API (wms-005 배치 로그, wms-006 상태/화면 접근 이력)
 */
export const useLogs = () => {
  const { loading, error, request } = useApi();

  /** 배치 실행 이력 목록 — GET /batch-job-logs */
  const fetchBatchJobLogs = (params) => request("get", "/batch-job-logs", params);

  /** 배치 실행 이력 상세 — GET /batch-job-logs/:id */
  const fetchBatchJobLogDetail = (batchLogId) =>
    request("get", `/batch-job-logs/${encodeURIComponent(batchLogId)}`);

  /** 배치 오류 상세 — GET /batch-job-logs/:id/errors */
  const fetchBatchJobLogErrors = (batchLogId) =>
    request("get", `/batch-job-logs/${encodeURIComponent(batchLogId)}/errors`);

  /** 재처리 요청 — POST /batch-retry-requests */
  const postBatchRetryRequest = (body) => request("post", "/batch-retry-requests", body);

  /** 상태 변경 이력 — GET /status-change-histories */
  const fetchStatusChangeHistories = (params) =>
    request("get", "/status-change-histories", params);

  /** 화면 접근 이력 — GET /screen-access-logs */
  const fetchScreenAccessLogs = (params) =>
    request("get", "/screen-access-logs", params);

  return {
    loading,
    error,
    fetchBatchJobLogs,
    fetchBatchJobLogDetail,
    fetchBatchJobLogErrors,
    postBatchRetryRequest,
    fetchStatusChangeHistories,
    fetchScreenAccessLogs,
  };
};
