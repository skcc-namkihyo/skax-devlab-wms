import api from "../api.js";

const { ref } = Vue;

/**
 * 공통 API 요청 Composable — 응답 { result_code, result_message, data } 규칙 처리
 */
export const useApi = () => {
  const loading = ref(false);
  const error = ref(null);

  /**
   * @param {string} method get|post|put|delete
   * @param {string} url baseURL 이후 경로 (예: /batch-job-logs)
   * @param {object|null} data GET이면 params, 그 외는 body
   * @param {object} config axios 추가 설정
   */
  const request = async (method, url, data = null, config = {}) => {
    loading.value = true;
    error.value = null;
    try {
      let raw;
      const m = String(method || "get").toLowerCase();
      if (m === "get") {
        raw = await api.get(url, { params: data || {}, ...config });
      } else if (m === "post") {
        raw = await api.post(url, data ?? {}, config);
      } else if (m === "put") {
        raw = await api.put(url, data ?? {}, config);
      } else if (m === "delete") {
        raw = await api.delete(url, { data, ...config });
      } else {
        throw new Error(`지원하지 않는 HTTP 메서드: ${method}`);
      }

      const code = raw?.result_code;
      if (code != null && String(code).startsWith("E")) {
        const msg = raw?.result_message || "요청이 거절되었습니다.";
        error.value = msg;
        ElMessage.error(msg);
        const err = new Error(msg);
        err.resultCode = code;
        err.resultBody = raw;
        throw err;
      }

      return raw;
    } catch (err) {
      if (err.resultCode) {
        throw err;
      }
      const msg =
        err.response?.data?.result_message ||
        err.response?.data?.message ||
        err.message ||
        "요청 처리 중 오류가 발생했습니다.";
      error.value = msg;
      ElMessage.error(msg);
      throw err;
    } finally {
      loading.value = false;
    }
  };

  return { loading, error, request };
};
