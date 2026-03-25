package com.execnt.common.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health")
@Tag(name = "헬스체크")
public class HealthController {

    @GetMapping
    @Operation(
            summary = "애플리케이션 상태",
            description = "요청 파라미터 없음. 인증 불필요(permitAll).")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> body = new HashMap<>();
        body.put("status", "UP");
        body.put("message", "서버가 정상적으로 실행 중입니다.");
        return ResponseEntity.ok(body);
    }
}
