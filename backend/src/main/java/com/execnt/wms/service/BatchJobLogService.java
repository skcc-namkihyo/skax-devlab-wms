package com.execnt.wms.service;

import com.execnt.wms.mapper.BatchJobLogMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 배치 실행 이력·오류 상세 조회 서비스.
 *
 * <p>Controller/문서와 동일한 query·응답 키(snake_case)를 사용합니다.
 */
@Service
public class BatchJobLogService {

    private final BatchJobLogMapper batchJobLogMapper;

    public BatchJobLogService(BatchJobLogMapper batchJobLogMapper) {
        this.batchJobLogMapper = batchJobLogMapper;
    }

    /**
     * 배치 로그 목록 (페이징·필터).
     *
     * @param query 선택/필수 키: {@code wh_cd}(부분일치), {@code batch_type}, {@code status},
     *     {@code page}(기본 1), {@code pageSize}(기본 10)
     * @return {@code list}, {@code total}, {@code page}, {@code pageSize} 를 담은 Map
     */
    public Map<String, Object> findList(Map<String, Object> query) throws Exception {
        int page = parsePositiveInt(query.get("page"), 1);
        int pageSize = parsePositiveInt(query.get("pageSize"), 10);
        int offset = (page - 1) * pageSize;

        Map<String, Object> params = new HashMap<>();
        copyIfPresent(query, params, "wh_cd");
        copyIfPresent(query, params, "batch_type");
        copyIfPresent(query, params, "status");
        params.put("limit", pageSize);
        params.put("offset", offset);

        List<Map<String, Object>> list = batchJobLogMapper.selectBatchJobLogList(params);
        int total = batchJobLogMapper.countBatchJobLogList(params);

        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("total", total);
        data.put("page", page);
        data.put("pageSize", pageSize);
        return data;
    }

    /**
     * 배치 로그 단건 (없으면 null 또는 빈 Map — Controller에서 E2001 처리).
     *
     * @param batchLogId {@code wms.batch_job_log.batch_log_id}
     */
    public Map<String, Object> findById(int batchLogId) throws Exception {
        Map<String, Object> params = new HashMap<>();
        params.put("batch_log_id", batchLogId);
        return batchJobLogMapper.selectBatchJobLogById(params);
    }

    /**
     * 해당 배치 로그에 연결된 오류 행 목록.
     *
     * @param batchLogId {@code wms.batch_error_log.batch_log_id} FK
     * @return {@code batch_log_id}, {@code list}, {@code total}
     */
    public Map<String, Object> findErrors(int batchLogId) throws Exception {
        Map<String, Object> params = new HashMap<>();
        params.put("batch_log_id", batchLogId);
        List<Map<String, Object>> list = batchJobLogMapper.selectBatchErrorLogByBatchLogId(params);
        int total = batchJobLogMapper.countBatchErrorLogByBatchLogId(params);
        Map<String, Object> data = new HashMap<>();
        data.put("batch_log_id", batchLogId);
        data.put("list", list);
        data.put("total", total);
        return data;
    }

    private static void copyIfPresent(Map<String, Object> src, Map<String, Object> dst, String key) {
        Object v = src.get(key);
        if (v != null && !v.toString().isEmpty()) {
            dst.put(key, v.toString().trim());
        }
    }

    private static int parsePositiveInt(Object raw, int defaultVal) {
        if (raw == null) {
            return defaultVal;
        }
        try {
            int n = Integer.parseInt(raw.toString().trim());
            return n > 0 ? n : defaultVal;
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }
}
