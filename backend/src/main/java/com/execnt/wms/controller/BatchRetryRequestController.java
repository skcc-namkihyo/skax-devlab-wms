package com.execnt.wms.controller;

import com.execnt.common.openapi.OpenApiExamples;
import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.BatchRetryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/batch-retry-requests")
@Tag(name = "배치 재처리", description = "재처리 요청 접수 (교육용 검증만, 실제 Job 미연동)")
public class BatchRetryRequestController {

    private final BatchRetryService batchRetryService;

    public BatchRetryRequestController(BatchRetryService batchRetryService) {
        this.batchRetryService = batchRetryService;
    }

    @PostMapping
    @Operation(
            summary = "재처리 요청 접수",
            description =
                    "body 키: batch_log_id(필수), ref_no(선택), remark(선택). "
                            + "동일 batch_log_id+ref_no에 retry_status=RESOLVED 가 있으면 E1002")
    public ResponseEntity<Map<String, Object>> request(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            description = "재처리 대상 Map",
                            required = true,
                            content =
                                    @Content(
                                            mediaType = "application/json",
                                            examples = {
                                                @ExampleObject(
                                                        name = "전체 필드",
                                                        value = OpenApiExamples.BATCH_RETRY_REQUEST),
                                                @ExampleObject(
                                                        name = "batch_log_id만",
                                                        value = "{\"batch_log_id\":1}")
                                            }))
                    @RequestBody
                    Map<String, Object> body)
            throws Exception {
        Map<String, Object> data = batchRetryService.requestRetry(body);
        return ResponseEntity.ok(ResponseUtil.success(data));
    }
}
