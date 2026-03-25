---
description: "REST API 컨트롤러 생성 | Create REST Controller with ResponseEntity and error handling"
---

# be-controller

## 개요

Spring Boot REST 컨트롤러를 생성합니다. @RestController 구조, ResponseEntity 래핑, 표준화된 에러 핸들링을 포함합니다. WMS 엔티티별 CRUD 엔드포인트를 생성하는 데 사용됩니다.

**사용 시점**: 새로운 REST API 엔드포인트가 필요할 때

## 템플릿 / 패턴

### 컨트롤러 기본 구조

```java
package com.execnt.wms.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.UserService;
import java.util.Map;

/**
 * 사용자 관리 REST API
 * @author Team
 * @date 2025-03-18
 */
@RestController
@RequestMapping("/api/user")
@Tag(name = "사용자 관리", description = "사용자 관리 API")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 사용자 목록 조회.
     * @param params 조회 파라미터 (userName, isActive, limit, offset 등)
     * @return 사용자 목록
     * @throws Exception 시스템 예외
     */
    @GetMapping("/list")
    @Operation(summary = "사용자 목록 조회")
    public ResponseEntity<Map<String, Object>> list(
            @RequestParam(required = false) String userName,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "10") Integer limit,
            @RequestParam(defaultValue = "0") Integer offset) throws Exception {

        Map<String, Object> params = new java.util.HashMap<>();
        params.put("userName", userName);
        params.put("isActive", isActive);
        params.put("limit", limit);
        params.put("offset", offset);

        Map<String, Object> result = userService.getUserList(params);
        return ResponseEntity.ok(ResponseUtil.success(result));
    }

    /**
     * 사용자 상세 조회.
     * @param userId 사용자 ID
     * @return 사용자 정보
     * @throws Exception 시스템 예외
     */
    @GetMapping("/{userId}")
    @Operation(summary = "사용자 상세 조회")
    public ResponseEntity<Map<String, Object>> detail(@PathVariable Long userId) throws Exception {
        Map<String, Object> result = userService.getUserById(userId);
        return ResponseEntity.ok(ResponseUtil.success(result));
    }

    /**
     * 사용자 생성.
     * @param params 사용자 정보 (userName, userEmail, password, isActive)
     * @return 생성된 사용자 정보
     * @throws Exception 시스템 예외 또는 비즈니스 예외
     */
    @PostMapping
    @Operation(summary = "사용자 생성")
    public ResponseEntity<Map<String, Object>> create(
            @RequestBody Map<String, Object> params) throws Exception {
        Map<String, Object> result = userService.createUser(params);
        return ResponseEntity.ok(ResponseUtil.success(result));
    }

    /**
     * 사용자 수정.
     * @param userId 사용자 ID
     * @param params 수정할 사용자 정보
     * @return 수정된 사용자 정보
     * @throws Exception 시스템 예외 또는 비즈니스 예외
     */
    @PutMapping("/{userId}")
    @Operation(summary = "사용자 수정")
    public ResponseEntity<Map<String, Object>> update(
            @PathVariable Long userId,
            @RequestBody Map<String, Object> params) throws Exception {
        params.put("userId", userId);
        Map<String, Object> result = userService.updateUser(params);
        return ResponseEntity.ok(ResponseUtil.success(result));
    }

    /**
     * 사용자 삭제.
     * @param userId 사용자 ID
     * @return 삭제 결과
     * @throws Exception 시스템 예외 또는 비즈니스 예외
     */
    @DeleteMapping("/{userId}")
    @Operation(summary = "사용자 삭제")
    public ResponseEntity<Map<String, Object>> delete(@PathVariable Long userId) throws Exception {
        Map<String, Object> params = new java.util.HashMap<>();
        params.put("userId", userId);
        userService.deleteUser(params);
        return ResponseEntity.ok(ResponseUtil.success("사용자가 삭제되었습니다."));
    }

    /**
     * 사용자 일괄 삭제.
     * @param params 삭제할 사용자 ID 목록 (userIds)
     * @return 삭제 결과
     * @throws Exception 시스템 예외
     */
    @DeleteMapping("/batch")
    @Operation(summary = "사용자 일괄 삭제")
    public ResponseEntity<Map<String, Object>> batchDelete(
            @RequestBody Map<String, Object> params) throws Exception {
        userService.deleteUsersBatch(params);
        return ResponseEntity.ok(ResponseUtil.success("사용자가 삭제되었습니다."));
    }
}
```

### ResponseUtil 활용

```json
응답 형식:
{
  "result_code": "I0001",
  "result_message": "정상적으로 처리되었습니다.",
  "data": { ... }
}
```

## Swagger 상세 구성 가이드

> ⚠️ 모든 API에 상세한 Swagger 어노테이션을 추가하여 완전한 API 문서를 생성합니다.

### Swagger 어노테이션 구성 규칙

| 어노테이션 | 용도 | 필수 |
|-----------|------|------|
| `@Tag` | 컨트롤러 그룹 | ✅ |
| `@Operation` | API 설명 (summary + description) | ✅ |
| `@io.swagger.v3.oas.annotations.parameters.RequestBody` | POST/PUT 요청 바디 | ✅ |
| `@Parameter` | GET 파라미터 | ✅ |
| `@ApiResponses` | 응답 코드별 정의 | ✅ |
| `@ExampleObject` | JSON 예시 값 | ✅ |
| `@Schema` | 타입/필수필드 정의 | 권장 |

### POST 요청 Swagger 패턴

```java
@PostMapping
@Operation(
    summary = "사용자 생성",
    description = "이메일과 비밀번호로 사용자를 등록합니다."
)
@io.swagger.v3.oas.annotations.parameters.RequestBody(
    description = "사용자 등록 정보",
    required = true,
    content = @Content(
        mediaType = "application/json",
        schema = @Schema(
            type = "object",
            requiredProperties = {"email", "password", "name", "userType"}
        ),
        examples = @ExampleObject(
            name = "사용자 등록 예시",
            value = "{\"email\": \"user@example.com\", \"password\": \"Password123!\", \"name\": \"홍길동\", \"userType\": \"CUSTOMER\"}"
        )
    )
)
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "200", description = "등록 성공",
        content = @Content(mediaType = "application/json", schema = @Schema(type = "object"),
            examples = @ExampleObject(name = "성공",
                value = "{\"result_code\": \"I0002\", \"result_message\": \"회원가입이 완료되었습니다.\", \"data\": {\"userId\": 1}}"))),
    @ApiResponse(responseCode = "400", description = "유효성 검증 실패 또는 중복")
})
public ResponseEntity<Map<String, Object>> create(
        @org.springframework.web.bind.annotation.RequestBody Map<String, Object> params) throws Exception {
    // ...
}
```

### GET 요청 Swagger 패턴

```java
@GetMapping("/{id}")
@Operation(summary = "사용자 상세 조회", description = "사용자 ID로 프로필 정보를 조회합니다.")
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "200", description = "조회 성공",
        content = @Content(mediaType = "application/json", schema = @Schema(type = "object"),
            examples = @ExampleObject(name = "프로필 조회",
                value = "{\"result_code\": \"I0001\", \"result_message\": \"정상적으로 처리되었습니다.\", \"data\": {\"userId\": 1, \"email\": \"user@example.com\"}}"))),
    @ApiResponse(responseCode = "400", description = "사용자 없음")
})
public ResponseEntity<Map<String, Object>> detail(
        @Parameter(description = "사용자 ID", required = true, example = "1",
            schema = @Schema(type = "integer", format = "int64"))
        @PathVariable Long id) throws Exception {
    // ...
}
```

### GroupedOpenApi 도메인 그룹화 (선택)

```java
// SwaggerConfig.java에서 도메인별 API 그룹 추가
@Bean
public GroupedOpenApi userApi() {
    return GroupedOpenApi.builder()
        .group("사용자")
        .pathsToMatch("/api/user/**", "/api/auth/**")
        .build();
}

@Bean
public GroupedOpenApi warehouseApi() {
    return GroupedOpenApi.builder()
        .group("창고관리")
        .pathsToMatch("/api/inbound/**", "/api/outbound/**", "/api/inventory/**")
        .build();
}
```

## 사용 가이드

1. **도메인별 패키지 생성**: `wms/controller/[Domain]Controller.java`
2. **기본 패턴 복사**: 위의 템플릿을 기반으로 작성
3. **메서드명 정의**: CRUD 기준 list, detail, create, update, delete
4. **파라미터 정의**: @RequestParam (GET), @RequestBody (POST/PUT)
5. **에러 처리**: throws Exception으로 GlobalExceptionHandler에 위임
6. **JavaDoc 작성**: 모든 public 메서드에 필수
7. **Swagger 어노테이션**: @Operation으로 API 문서화

## 체크리스트

- [ ] 컨트롤러 클래스 생성 (@RestController)
- [ ] 기본 CRUD 메서드 작성 (list, detail, create, update, delete)
- [ ] ResponseEntity로 응답 래핑
- [ ] throws Exception으로 에러 처리
- [ ] @RequestMapping으로 엔드포인트 정의 (/api/domain)
- [ ] Swagger @Tag, @Operation 추가
- [ ] JavaDoc 작성
- [ ] 서비스 주입 (생성자 주입)
- [ ] 테스트 케이스 작성
