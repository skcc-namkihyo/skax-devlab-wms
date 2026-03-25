package com.execnt.common.openapi;

/**
 * Swagger UI Example Value용 JSON (Map RequestBody)
 */
public final class OpenApiExamples {

    private OpenApiExamples() {}

    public static final String AUTH_LOGIN = "{\"userid\":\"admin\",\"password\":\"admin\"}";

    public static final String BATCH_RETRY_REQUEST =
            "{\"batch_log_id\":1,\"ref_no\":\"IN-20260325-0001\",\"remark\":\"운영 재처리 요청\"}";
}
