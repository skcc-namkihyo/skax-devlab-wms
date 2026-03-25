package com.execnt.wms.service;

import com.execnt.auth.util.JwtUtil;
import com.execnt.common.exception.BizException;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 교육용 간이 인증 — 운영 시 DB·암호화 연동으로 교체.
 *
 * <p>{@code login} body 키: {@code userid}, {@code password} (문자열, 공백 불가). 데모 계정: userid·password 모두 {@code admin}.
 */
@Service
public class AuthService {

    private final JwtUtil jwtUtil;

    public AuthService(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    /**
     * 로그인 성공 시 JWT 및 사용자 표시용 필드를 담은 Map 반환 (Controller가 result_code 래핑).
     *
     * @param body {@code userid}, {@code password}
     * @return {@code accessToken}, {@code refreshToken}, {@code userid}, {@code username}, {@code usergroupcode}
     */
    public Map<String, Object> login(Map<String, Object> body) throws Exception {
        String userid = body.get("userid") != null ? body.get("userid").toString().trim() : "";
        String password = body.get("password") != null ? body.get("password").toString() : "";
        if (userid.isEmpty() || password.isEmpty()) {
            throw new BizException("E1004");
        }
        // 데모 계정 (Task/FE 교육용)
        if (!("admin".equals(userid) && "admin".equals(password))) {
            throw new BizException("E1004");
        }
        String access = jwtUtil.generateAccessToken(userid, "관리자", "ADMIN");
        String refresh = jwtUtil.generateRefreshToken(userid);
        Map<String, Object> data = new HashMap<>();
        data.put("accessToken", access);
        data.put("refreshToken", refresh);
        data.put("userid", userid);
        data.put("username", "관리자");
        data.put("usergroupcode", "ADMIN");
        return data;
    }
}
