package com.execnt.common.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/health/db")
@Tag(name = "DB 헬스체크")
public class DbHealthController {

    private final JdbcTemplate jdbcTemplate;

    public DbHealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    @Operation(
            summary = "PostgreSQL 연결 확인",
            description = "SELECT 1 프로브. 요청 파라미터 없음. 인증 불필요(permitAll). 실패 시 HTTP 503")
    public ResponseEntity<Map<String, Object>> dbHealth() {
        Map<String, Object> body = new HashMap<>();
        try {
            Integer one = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            body.put("status", "UP");
            body.put("message", "데이터베이스 연결이 정상입니다.");
            body.put("database", "PostgreSQL");
            body.put("probe", one);
            return ResponseEntity.ok(body);
        } catch (Exception e) {
            body.put("status", "DOWN");
            body.put("message", "데이터베이스 연결 실패: " + e.getMessage());
            return ResponseEntity.status(503).body(body);
        }
    }
}
