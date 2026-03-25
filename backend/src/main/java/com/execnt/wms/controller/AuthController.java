package com.execnt.wms.controller;

import com.execnt.common.openapi.OpenApiExamples;
import com.execnt.common.utils.ResponseUtil;
import com.execnt.wms.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "인증", description = "JWT 발급 (교육용 데모 계정)")
public class AuthController {

    private final AuthService authService;
    private final MessageSource messageSource;

    public AuthController(AuthService authService, MessageSource messageSource) {
        this.authService = authService;
        this.messageSource = messageSource;
    }

    @PostMapping("/login")
    @Operation(
            summary = "로그인",
            description =
                    "요청 body(Map): userid, password (필수). 데모: admin / admin. "
                            + "응답 data에 accessToken, refreshToken, userid, username, usergroupcode")
    public ResponseEntity<Map<String, Object>> login(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                            description = "로그인 요청 Map",
                            required = true,
                            content =
                                    @Content(
                                            mediaType = "application/json",
                                            examples = {
                                                @ExampleObject(
                                                        name = "데모 관리자",
                                                        value = OpenApiExamples.AUTH_LOGIN)
                                            }))
                    @org.springframework.web.bind.annotation.RequestBody
                    Map<String, Object> body)
            throws Exception {
        Map<String, Object> data = authService.login(body);
        String msg = messageSource.getMessage("I0003", null, LocaleContextHolder.getLocale());
        return ResponseEntity.ok(ResponseUtil.createSuccessResponse("I0001", msg, data));
    }
}
