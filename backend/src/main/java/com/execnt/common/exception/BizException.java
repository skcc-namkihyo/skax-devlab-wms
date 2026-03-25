package com.execnt.common.exception;

/**
 * 비즈니스 예외 — 메시지 코드(E1001 등) 기반
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

    public String getErrorCode() {
        return errorCode;
    }
}
