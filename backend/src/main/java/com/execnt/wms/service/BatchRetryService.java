package com.execnt.wms.service;

import com.execnt.common.exception.BizException;
import com.execnt.wms.mapper.BatchJobLogMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

/**
 * 재처리 요청 — 교육용: 검증 후 접수 응답만 수행 (실제 Job 큐 연동은 생략).
 *
 * <p>{@code requestRetry} body 키: {@code batch_log_id}(필수·양의 정수), {@code ref_no}(선택·중복 검사),
 * {@code remark}(선택·현재 로직 미사용, API 확장용)
 */
@Service
public class BatchRetryService {

    private final BatchJobLogMapper batchJobLogMapper;

    public BatchRetryService(BatchJobLogMapper batchJobLogMapper) {
        this.batchJobLogMapper = batchJobLogMapper;
    }

    /**
     * 재처리 요청 검증 후 접수 결과 반환.
     *
     * @param body {@code batch_log_id} 필수; {@code ref_no} 있으면 RESOLVED 건 존재 시 E1002
     * @return {@code accepted=true}, {@code batch_log_id}
     */
    @Transactional(readOnly = true)
    public Map<String, Object> requestRetry(Map<String, Object> body) throws Exception {
        Object idObj = body.get("batch_log_id");
        if (idObj == null) {
            throw new BizException("E1001", "batch_log_id가 필요합니다.");
        }
        int batchLogId;
        try {
            batchLogId = Integer.parseInt(idObj.toString().trim());
        } catch (NumberFormatException e) {
            throw new BizException("E1001", "batch_log_id 형식이 올바르지 않습니다.");
        }
        if (batchLogId <= 0) {
            throw new BizException("E1001", "batch_log_id가 올바르지 않습니다.");
        }

        Map<String, Object> p = new HashMap<>();
        p.put("batch_log_id", batchLogId);
        Map<String, Object> job = batchJobLogMapper.selectBatchJobLogById(p);
        if (job == null || job.isEmpty()) {
            throw new BizException("E2001");
        }

        Object ref = body.get("ref_no");
        if (ref != null && !ref.toString().trim().isEmpty()) {
            p.put("ref_no", ref.toString().trim());
            int resolved = batchJobLogMapper.countResolvedRetryForRef(p);
            if (resolved > 0) {
                throw new BizException("E1002");
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("accepted", true);
        data.put("batch_log_id", batchLogId);
        return data;
    }
}
