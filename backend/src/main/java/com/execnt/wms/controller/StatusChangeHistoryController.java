package com.execnt.wms.controller;

import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.StatusChangeHistoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/status-change-histories")
@Tag(name = "상태 변경 이력", description = "wms.status_change_history 조회")
public class StatusChangeHistoryController {

    private final StatusChangeHistoryService statusChangeHistoryService;
    private final MessageSource messageSource;

    public StatusChangeHistoryController(
            StatusChangeHistoryService statusChangeHistoryService, MessageSource messageSource) {
        this.statusChangeHistoryService = statusChangeHistoryService;
        this.messageSource = messageSource;
    }

    @GetMapping
    @Operation(
            summary = "상태 변경 이력 검색",
            description = "페이징 목록. 응답 data: list, total, page, pageSize")
    public ResponseEntity<Map<String, Object>> list(
            @Parameter(description = "페이지 번호(1부터)", example = "1") @RequestParam(required = false)
                    Integer page,
            @Parameter(description = "페이지 크기", example = "20") @RequestParam(required = false)
                    Integer pageSize)
            throws Exception {
        Map<String, Object> query = new HashMap<>();
        query.put("page", page);
        query.put("pageSize", pageSize);
        Map<String, Object> data = statusChangeHistoryService.findList(query);
        String msg = messageSource.getMessage("I0002", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, data));
    }
}
