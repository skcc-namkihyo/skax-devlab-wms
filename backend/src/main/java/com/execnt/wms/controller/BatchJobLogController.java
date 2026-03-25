package com.execnt.wms.controller;

import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.BatchJobLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/batch-job-logs")
@Tag(name = "배치 작업 로그", description = "배치 실행 이력·오류 상세 조회 (wms.batch_job_log / batch_error_log)")
public class BatchJobLogController {

    private final BatchJobLogService batchJobLogService;
    private final MessageSource messageSource;

    public BatchJobLogController(BatchJobLogService batchJobLogService, MessageSource messageSource) {
        this.batchJobLogService = batchJobLogService;
        this.messageSource = messageSource;
    }

    @GetMapping
    @Operation(
            summary = "배치 실행 이력 목록",
            description = "검색 조건·페이징으로 목록 조회. 응답 data: list, total, page, pageSize")
    @ApiResponse(
            responseCode = "200",
            description = "성공 시 result_code=I0001, data.list에 배치 행 배열",
            content =
                    @Content(
                            mediaType = "application/json",
                            examples = {
                                @ExampleObject(
                                        name = "성공 예시",
                                        value =
                                                "{\"result_code\":\"I0001\",\"result_message\":\"조회되었습니다.\",\"data\":{\"list\":[],\"total\":0,\"page\":1,\"pageSize\":10}}")
                            }))
    public ResponseEntity<Map<String, Object>> list(
            @Parameter(description = "창고 코드(부분 일치, ILIKE)", example = "WH01")
                    @RequestParam(required = false)
                    String wh_cd,
            @Parameter(
                            description = "배치 유형 코드 (예: INBOUND_ORDER, OUTBOUND_ORDER, INB_CREATE)",
                            example = "INBOUND_ORDER")
                    @RequestParam(required = false)
                    String batch_type,
            @Parameter(
                            description = "실행 상태: RUNNING, COMPLETED, FAILED, PARTIAL",
                            example = "COMPLETED")
                    @RequestParam(required = false)
                    String status,
            @Parameter(description = "페이지 번호(1부터)", example = "1") @RequestParam(required = false)
                    Integer page,
            @Parameter(description = "페이지 크기", example = "10") @RequestParam(required = false)
                    Integer pageSize)
            throws Exception {
        Map<String, Object> query = new HashMap<>();
        query.put("wh_cd", wh_cd);
        query.put("batch_type", batch_type);
        query.put("status", status);
        query.put("page", page);
        query.put("pageSize", pageSize);
        Map<String, Object> data = batchJobLogService.findList(query);
        String msg = messageSource.getMessage("I0002", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, data));
    }

    @GetMapping("/{batch_log_id}/errors")
    @Operation(
            summary = "배치 오류 상세 목록",
            description = "지정 배치 로그에 속한 batch_error_log 행 목록. data: batch_log_id, list, total")
    public ResponseEntity<Map<String, Object>> errors(
            @Parameter(
                            description = "배치 로그 PK (wms.batch_job_log.batch_log_id)",
                            example = "1",
                            required = true)
                    @PathVariable("batch_log_id")
                    int batchLogId)
            throws Exception {
        Map<String, Object> data = batchJobLogService.findErrors(batchLogId);
        String msg = messageSource.getMessage("I0002", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, data));
    }

    @GetMapping("/{batch_log_id}")
    @Operation(
            summary = "배치 실행 이력 상세",
            description = "단건 조회. 미존재 시 HTTP 200 + result_code=E2001")
    public ResponseEntity<Map<String, Object>> detail(
            @Parameter(
                            description = "배치 로그 PK (wms.batch_job_log.batch_log_id)",
                            example = "1",
                            required = true)
                    @PathVariable("batch_log_id")
                    int batchLogId)
            throws Exception {
        Map<String, Object> row = batchJobLogService.findById(batchLogId);
        if (row == null || row.isEmpty()) {
            String msg = messageSource.getMessage("E2001", null, LocaleContextHolder.getLocale());
            return ResponseEntity.ok(ResponseUtil.createErrorResponse("E2001", msg));
        }
        String msg = messageSource.getMessage("I0002", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, row));
    }
}
