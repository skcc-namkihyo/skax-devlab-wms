---
description: "BE 공통모듈 초기 생성 | Spring Boot Common Module Setup (Security, JWT, Swagger, Exception)"
---

# be-common-module

## 개요

Spring Boot 프로젝트의 공통 모듈을 초기 생성합니다. 이 Skill은 프로젝트에 공통 모듈이 아직 존재하지 않을 때만 실행됩니다.

**사용 시점**: `/dev-be` 또는 `/init-module` 실행 시 공통 모듈이 없는 경우
**선행 조건**: 프로젝트 변수가 설정되어야 함 (project.init.mdc 참조)

## 프로젝트 변수

이 Skill의 모든 코드에서 다음 변수를 치환해야 합니다:

| 변수 | 설명 | 예시 |
|------|------|------|
| `{PROJECT_NAME}` | 프로젝트 전체명 | WMS 창고관리시스템 |
| `{PROJECT_SIMPLE_NAME}` | 프로젝트 간단명 (PascalCase) | Wms |
| `{PROJECT_SIMPLE_NAME_LOWER}` | 프로젝트 간단명 (소문자) | wms |
| `{BASE_PACKAGE}` | Java 기본 패키지 | com.execnt |
| `{BASE_PACKAGE_PATH}` | 패키지 경로 (슬래시) | com/execnt |
| `{DB_SCHEMA}` | DB 스키마명 | wms |
| `{AUTHOR}` | JavaDoc 작성자 | 시스템 |
| `{DATE}` | 생성 날짜 (YYYY-MM-DD) | 2025-11-21 |

## 생성 파일 목록

| # | 파일 | 경로 |
|---|------|------|
| 1 | Application.java | `{BASE_PACKAGE_PATH}/{PROJECT_SIMPLE_NAME}Application.java` |
| 2 | SecurityConfig.java | `{BASE_PACKAGE_PATH}/config/SecurityConfig.java` |
| 3 | SwaggerConfig.java | `{BASE_PACKAGE_PATH}/config/SwaggerConfig.java` |
| 4 | MessageSourceConfig.java | `{BASE_PACKAGE_PATH}/config/MessageSourceConfig.java` |
| 5 | BizException.java | `{BASE_PACKAGE_PATH}/common/exception/BizException.java` |
| 6 | GlobalExceptionHandler.java | `{BASE_PACKAGE_PATH}/common/exception/GlobalExceptionHandler.java` |
| 7 | ResponseUtil.java | `{BASE_PACKAGE_PATH}/common/utils/ResponseUtil.java` |
| 8 | HealthController.java | `{BASE_PACKAGE_PATH}/common/controller/HealthController.java` |
| 9 | DbHealthController.java | `{BASE_PACKAGE_PATH}/common/controller/DbHealthController.java` |
| 10 | JwtUtil.java | `{BASE_PACKAGE_PATH}/auth/util/JwtUtil.java` |
| 11 | JwtAuthenticationFilter.java | `{BASE_PACKAGE_PATH}/auth/filter/JwtAuthenticationFilter.java` |
| 12 | application.yml | `src/main/resources/application.yml` |
| 13 | messages.properties | `src/main/resources/messages/messages.properties` |

## 코드 템플릿

> ⚠️ 아래 코드는 **예시가 아닌 실제 생성 코드**입니다. 변수 치환 후 동일하게 생성하세요.

### 1. {PROJECT_SIMPLE_NAME}Application.java

```java
package {BASE_PACKAGE};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * {PROJECT_NAME}의 메인 애플리케이션 클래스.
 *
 * Spring Boot 애플리케이션의 진입점으로, 애플리케이션을 시작합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@SpringBootApplication
public class {PROJECT_SIMPLE_NAME}Application {

    public static void main(String[] args) {
        SpringApplication.run({PROJECT_SIMPLE_NAME}Application.class, args);
    }

}
```

### 2. SecurityConfig.java

```java
package {BASE_PACKAGE}.config;

import {BASE_PACKAGE}.auth.filter.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * Spring Security 설정을 담당하는 구성 클래스.
 *
 * JWT 인증 필터, 보안 필터 체인, 세션 관리, CORS 설정 등의 보안 설정을 구성합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:4000",
            "http://localhost:5500",
            "http://127.0.0.1:3000",
            "http://127.0.0.1:4000",
            "http://127.0.0.1:5500"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/health/**").permitAll()
                .requestMatchers(
                    "/swagger-ui.html",
                    "/swagger-ui/**",
                    "/v3/api-docs/**",
                    "/api-docs/**",
                    "/swagger-resources/**",
                    "/webjars/**"
                ).permitAll()
                .anyRequest().authenticated()
            );

        return http.build();
    }
}
```

### 3. SwaggerConfig.java

```java
package {BASE_PACKAGE}.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springdoc.core.models.GroupedOpenApi;
import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;
import java.util.Map;

/**
 * Swagger API 문서화 설정을 담당하는 구성 클래스.
 *
 * OpenAPI 3.0 스펙을 기반으로 API 문서를 자동 생성하고, JWT 인증 방식을 설정합니다.
 * Map<String, Object> 타입을 Object 스키마로 처리하도록 설정합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@Configuration
public class SwaggerConfig {

    static {
        try {
            SpringDocUtils.getConfig().replaceWithSchema(Map.class, new ObjectSchema());
            SpringDocUtils.getConfig().replaceWithSchema(java.util.HashMap.class, new ObjectSchema());
            SpringDocUtils.getConfig().replaceWithSchema(java.util.LinkedHashMap.class, new ObjectSchema());
        } catch (Exception e) {
            System.err.println("Swagger Map schema configuration failed: " + e.getMessage());
        }
    }

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "bearerAuth";
        return new OpenAPI()
            .info(new Info()
                .title("{PROJECT_NAME} API")
                .version("1.0.0")
                .description("{PROJECT_NAME} REST API 문서")
                .contact(new Contact()
                    .name("WMS Team")
                    .email("support@wms.com")))
            .servers(List.of(
                new Server().url("http://localhost:8080").description("로컬 개발 서버")
            ))
            .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
            .components(new Components()
                .addSecuritySchemes(securitySchemeName,
                    new SecurityScheme()
                        .name(securitySchemeName)
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")));
    }

    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder()
            .group("public")
            .pathsToMatch("/api/**")
            .build();
    }
}
```

### 4. MessageSourceConfig.java

```java
package {BASE_PACKAGE}.config;

import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ResourceBundleMessageSource;

/**
 * 메시지 소스 설정을 담당하는 구성 클래스.
 *
 * 다국어 지원 및 에러 메시지 관리를 위한 메시지 소스를 설정합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@Configuration
public class MessageSourceConfig {

    @Bean
    public MessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("messages/messages");
        messageSource.setDefaultEncoding("UTF-8");
        messageSource.setUseCodeAsDefaultMessage(true);
        return messageSource;
    }
}
```

### 5. BizException.java

```java
package {BASE_PACKAGE}.common.exception;

/**
 * 비즈니스 로직 처리 중 발생하는 예외를 나타내는 클래스.
 *
 * 비즈니스 규칙 위반, 유효성 검증 실패 등의 비즈니스 예외를 처리하기 위해 사용됩니다.
 * 에러 코드를 포함하여 메시지 소스에서 다국어 메시지를 조회할 수 있습니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
public class BizException extends RuntimeException {

    private final String errorCode;

    public BizException(String errorCode) {
        super();
        this.errorCode = errorCode;
    }

    public BizException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public BizException(String errorCode, Throwable cause) {
        super(cause);
        this.errorCode = errorCode;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
```

### 6. GlobalExceptionHandler.java

```java
package {BASE_PACKAGE}.common.exception;

import {BASE_PACKAGE}.common.utils.ResponseUtil;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;

/**
 * 전역 예외 처리를 담당하는 핸들러 클래스.
 *
 * 애플리케이션 전역에서 발생하는 예외를 처리하고 표준 형식의 에러 응답을 반환합니다.
 * BizException과 일반 Exception을 처리하며, 메시지 소스를 통해 다국어 메시지를 제공합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@ControllerAdvice
@Hidden
public class GlobalExceptionHandler {

    private final MessageSource messageSource;

    public GlobalExceptionHandler(MessageSource messageSource) {
        this.messageSource = messageSource;
    }

    @ExceptionHandler(BizException.class)
    public ResponseEntity<Map<String, Object>> handleBizException(BizException e) {
        String message = messageSource.getMessage(
            e.getErrorCode(),
            null,
            e.getMessage() != null ? e.getMessage() : "알 수 없는 오류가 발생했습니다.",
            LocaleContextHolder.getLocale()
        );

        return ResponseEntity
            .status(HttpStatus.BAD_REQUEST)
            .body(ResponseUtil.createErrorResponse(e.getErrorCode(), message));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException(Exception e) {
        String className = e.getClass().getName();
        if (className.startsWith("org.springdoc") || className.startsWith("io.swagger")) {
            throw new RuntimeException(e);
        }

        String errorMessage = "시스템 오류가 발생했습니다.";
        if (e.getMessage() != null) {
            errorMessage += " (" + e.getMessage() + ")";
        }
        e.printStackTrace();
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ResponseUtil.createErrorResponse("E9999", errorMessage));
    }
}
```

### 7. ResponseUtil.java

```java
package {BASE_PACKAGE}.common.utils;

import java.util.HashMap;
import java.util.Map;

/**
 * API 응답 생성을 위한 유틸리티 클래스.
 *
 * 성공 및 에러 응답을 표준 형식으로 생성하는 정적 메서드를 제공합니다.
 * 모든 API 응답은 이 유틸리티를 통해 일관된 형식으로 생성됩니다.
 *
 * **API 응답 형식**:
 * - 성공 응답: `{result_code: "I0001", result_message: "...", data: {...}}`
 * - 에러 응답: `{result_code: "E1001", result_message: "..."}`
 * - ⚠️ `success` 필드는 사용하지 않습니다. `result_code`로만 성공/에러 여부를 판단합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
public class ResponseUtil {

    public static Map<String, Object> createSuccessResponse(String resultCode, String resultMessage, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("result_code", resultCode);
        response.put("result_message", resultMessage);
        if (data != null) {
            response.put("data", data);
        }
        return response;
    }

    public static Map<String, Object> createSuccessResponse(String resultCode, String resultMessage) {
        return createSuccessResponse(resultCode, resultMessage, null);
    }

    public static Map<String, Object> createErrorResponse(String errorCode, String errorMessage) {
        Map<String, Object> response = new HashMap<>();
        response.put("result_code", errorCode);
        response.put("result_message", errorMessage);
        return response;
    }
}
```

### 8. HealthController.java

```java
package {BASE_PACKAGE}.common.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 서버 상태 확인을 위한 헬스체크 컨트롤러.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@RestController
@RequestMapping("/api/health")
@Tag(name = "헬스체크", description = "서버 상태 확인 API")
public class HealthController {

    @GetMapping
    @Operation(summary = "서버 상태 확인", description = "애플리케이션 서버의 실행 상태를 확인합니다.")
    @ApiResponse(responseCode = "200", description = "서버 정상 실행 중",
        content = @Content(mediaType = "application/json", schema = @Schema(type = "object"),
            examples = @ExampleObject(name = "서버 정상",
                value = "{\"status\": \"UP\", \"message\": \"서버가 정상적으로 실행 중입니다.\"}")))
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "서버가 정상적으로 실행 중입니다.");
        return ResponseEntity.ok(response);
    }
}
```

### 9. DbHealthController.java

```java
package {BASE_PACKAGE}.common.controller;

import {BASE_PACKAGE}.domain.user.mapper.UserMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 데이터베이스 연결 상태 확인을 위한 헬스체크 컨트롤러.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@RestController
@RequestMapping("/api/health/db")
@Tag(name = "헬스체크", description = "데이터베이스 연결 상태 확인 API")
public class DbHealthController {

    private final UserMapper userMapper;

    public DbHealthController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @GetMapping
    @Operation(summary = "데이터베이스 연결 상태 확인", description = "PostgreSQL 데이터베이스 연결 상태를 확인합니다.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "데이터베이스 연결 정상",
            content = @Content(mediaType = "application/json", schema = @Schema(type = "object"),
                examples = @ExampleObject(name = "DB 연결 정상",
                    value = "{\"status\": \"UP\", \"message\": \"데이터베이스 연결이 정상입니다.\", \"database\": \"PostgreSQL\"}"))),
        @ApiResponse(responseCode = "503", description = "데이터베이스 연결 실패",
            content = @Content(mediaType = "application/json", schema = @Schema(type = "object"),
                examples = @ExampleObject(name = "DB 연결 실패",
                    value = "{\"status\": \"DOWN\", \"message\": \"데이터베이스 연결 실패: Connection refused\", \"error\": \"SQLException\"}")))
    })
    public ResponseEntity<Map<String, Object>> dbHealth() {
        Map<String, Object> response = new HashMap<>();

        try {
            userMapper.selectUserByEmail("test@test.com");
            response.put("status", "UP");
            response.put("message", "데이터베이스 연결이 정상입니다.");
            response.put("database", "PostgreSQL");
        } catch (Exception e) {
            response.put("status", "DOWN");
            response.put("message", "데이터베이스 연결 실패: " + e.getMessage());
            response.put("error", e.getClass().getSimpleName());
            return ResponseEntity.status(503).body(response);
        }

        return ResponseEntity.ok(response);
    }
}
```

### 10. JwtUtil.java

```java
package {BASE_PACKAGE}.auth.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 토큰 생성 및 검증을 담당하는 유틸리티 클래스.
 *
 * Access Token과 Refresh Token을 생성하고, 토큰의 유효성을 검증하며,
 * 토큰에서 사용자 정보를 추출하는 기능을 제공합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@Component
public class JwtUtil {

    private final SecretKey secretKey;
    private final long accessTokenExpiration;
    private final long refreshTokenExpiration;

    public JwtUtil(
        @Value("${jwt.secret}") String secret,
        @Value("${jwt.access-token-expiration}") long accessTokenExpiration,
        @Value("${jwt.refresh-token-expiration}") long refreshTokenExpiration
    ) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
    }

    public String generateAccessToken(Long userId, String email, String userType) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("email", email);
        claims.put("userType", userType);

        return Jwts.builder()
            .claims(claims)
            .subject(String.valueOf(userId))
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + accessTokenExpiration))
            .signWith(secretKey)
            .compact();
    }

    public String generateRefreshToken(Long userId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("type", "refresh");

        return Jwts.builder()
            .claims(claims)
            .subject(String.valueOf(userId))
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + refreshTokenExpiration))
            .signWith(secretKey)
            .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Claims getClaimsFromToken(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload();
    }

    public Long getUserIdFromToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return Long.parseLong(claims.getSubject());
    }

    public boolean isTokenExpired(String token) {
        try {
            Claims claims = getClaimsFromToken(token);
            return claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return true;
        }
    }
}
```

### 11. JwtAuthenticationFilter.java

```java
package {BASE_PACKAGE}.auth.filter;

import {BASE_PACKAGE}.auth.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * JWT 토큰 기반 인증을 처리하는 필터 클래스.
 *
 * HTTP 요청의 Authorization 헤더에서 JWT 토큰을 추출하고 검증하여,
 * SecurityContext에 인증 정보를 설정합니다.
 *
 * @author {AUTHOR}
 * @Date {DATE}
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    public JwtAuthenticationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        try {
            if (jwtUtil.validateToken(token) && !jwtUtil.isTokenExpired(token)) {
                Long userId = jwtUtil.getUserIdFromToken(token);
                io.jsonwebtoken.Claims claims = jwtUtil.getClaimsFromToken(token);
                String userType = (String) claims.get("userType");

                List<SimpleGrantedAuthority> authorities = Collections.singletonList(
                    new SimpleGrantedAuthority("ROLE_" + (userType != null ? userType : "USER"))
                );

                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(userId, null, authorities);
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.debug("JWT token validation failed: " + e.getMessage(), e);
        }

        filterChain.doFilter(request, response);
    }
}
```

### 12. application.yml

```yaml
spring:
  application:
    name: {PROJECT_SIMPLE_NAME_LOWER}-backend

  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://localhost:5432/wmsdb
    username: wms_api
    password: Api@123
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

mybatis:
  mapper-locations: classpath:mappers/**/*.xml
  type-aliases-package: {BASE_PACKAGE}.domain
  configuration:
    map-underscore-to-camel-case: true
    default-fetch-size: 100
    default-statement-timeout: 30

jwt:
  secret: {PROJECT_SIMPLE_NAME_LOWER}-jwt-secret-key-for-development-only-change-in-production
  access-token-expiration: 3600000
  refresh-token-expiration: 604800000

springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    enabled: true
    config-url: /v3/api-docs/swagger-config
    url: /v3/api-docs
  default-consumes-media-type: application/json
  default-produces-media-type: application/json
  show-actuator: false
  packages-to-scan: {BASE_PACKAGE}.domain
  paths-to-match: /api/**
  model-and-view-allowed: false

logging:
  level:
    {BASE_PACKAGE}: DEBUG
    org.springframework.security: DEBUG
    org.mybatis: DEBUG
```

### 13. messages.properties

```properties
# 성공 메시지
I0001=정상적으로 처리되었습니다.
I0002=회원가입이 완료되었습니다.
I0003=로그인되었습니다.
I0004=로그아웃되었습니다.
I0005=토큰이 갱신되었습니다.

# 에러 메시지
E1001=이미 등록된 이메일입니다.
E1002=올바른 이메일 형식이 아닙니다.
E1003=비밀번호는 8자 이상, 영문/숫자/특수문자 조합이어야 합니다.
E1004=이메일 또는 비밀번호가 올바르지 않습니다.
E1005=토큰이 만료되었습니다.
E1006=유효하지 않은 토큰입니다.
E9999=시스템 오류가 발생했습니다.
```

## 실행 순서

1. 프로젝트 변수 확인 (project.init.mdc 또는 사용자 질의)
2. 공통 모듈 존재 여부 확인 (`{BASE_PACKAGE_PATH}` 하위 config/, common/, auth/ 디렉토리)
3. 없는 경우에만 위 13개 파일 생성 (변수 치환 적용)
4. `./gradlew build` 또는 IDE 빌드로 컴파일 검증

## 체크리스트

- [ ] 모든 `{변수명}`이 실제 값으로 치환되었는가?
- [ ] Application.java 클래스명이 PascalCase인가?
- [ ] SecurityConfig에 CORS 설정이 포함되었는가?
- [ ] SwaggerConfig에 Map 스키마 처리가 있는가?
- [ ] BizException에 errorCode 필드가 있는가?
- [ ] GlobalExceptionHandler가 BizException과 Exception을 모두 처리하는가?
- [ ] ResponseUtil이 result_code/result_message 형식을 사용하는가? (success 필드 없음)
- [ ] JwtUtil에 Access/Refresh Token 생성이 모두 있는가?
- [ ] application.yml에 mybatis, jwt, springdoc 설정이 있는가?
- [ ] messages.properties에 I/E 코드가 정의되었는가?
