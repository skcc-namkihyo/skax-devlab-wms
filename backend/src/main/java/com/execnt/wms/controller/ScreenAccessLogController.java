package com.execnt.wms.controller;

import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.ScreenAccessLogService;
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
@RequestMapping("/api/screen-access-logs")
@Tag(name = "화면 접근 로그", description = "wms.screen_access_log 조회 (PII 화면 감사)")
public class ScreenAccessLogController {

    private final ScreenAccessLogService screenAccessLogService;
    private final MessageSource messageSource;

    public ScreenAccessLogController(
            ScreenAccessLogService screenAccessLogService, MessageSource messageSource) {
        this.screenAccessLogService = screenAccessLogService;
        this.messageSource = messageSource;
    }

    @GetMapping
    @Operation(
            summary = "화면 접근 이력 검색",
            description = "페이징 목록. access_type 예: SEARCH, DOWNLOAD, EXPORT. 응답 data: list, total, page, pageSize")
    public ResponseEntity<Map<String, Object>> list(
            @Parameter(description = "페이지 번호(1부터)", example = "1") @RequestParam(required = false)
                    Integer page,
            @Parameter(description = "페이지 크기", example = "20") @RequestParam(required = false)
                    Integer pageSize)
            throws Exception {
        Map<String, Object> query = new HashMap<>();
        query.put("page", page);
        query.put("pageSize", pageSize);
        Map<String, Object> data = screenAccessLogService.findList(query);
        String msg = messageSource.getMessage("I0002", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, data));
    }
}
