package com.execnt.common.exception;

import com.execnt.common.utils.ResponseUtil;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.util.Map;

/**
 * 전역 예외 처리
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
                e.getMessage() != null ? e.getMessage() : "처리할 수 없습니다.",
                LocaleContextHolder.getLocale());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
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
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ResponseUtil.createErrorResponse("E9999", errorMessage));
    }
}
