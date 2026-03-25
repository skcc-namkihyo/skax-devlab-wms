package com.execnt.wms.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface BatchJobLogMapper {

    List<Map<String, Object>> selectBatchJobLogList(Map<String, Object> params);

    int countBatchJobLogList(Map<String, Object> params);

    Map<String, Object> selectBatchJobLogById(Map<String, Object> params);

    List<Map<String, Object>> selectBatchErrorLogByBatchLogId(Map<String, Object> params);

    int countBatchErrorLogByBatchLogId(Map<String, Object> params);

    /** 재처리 중복 검사 — 동일 ref_no 가 이미 RESOLVED 인 경우 */
    int countResolvedRetryForRef(Map<String, Object> params);
}
