package com.execnt.common.utils;

import java.util.HashMap;
import java.util.Map;

/**
 * API 응답 표준 형식 — result_code / result_message / data
 */
public final class ResponseUtil {

    private ResponseUtil() {}

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

    /** 목록·상세 등 일반 성공 (I0001) */
    public static Map<String, Object> success(Object data) {
        return createSuccessResponse("I0001", "정상적으로 처리되었습니다.", data);
    }

    public static Map<String, Object> createErrorResponse(String errorCode, String errorMessage) {
        Map<String, Object> response = new HashMap<>();
        response.put("result_code", errorCode);
        response.put("result_message", errorMessage);
        return response;
    }
}
