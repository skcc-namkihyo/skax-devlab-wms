---
description: "Map 값 추출 유틸리티 | Map value extraction utility methods"
---

# be-map-util

## 개요

Map<String, Object>에서 값을 안전하게 추출하는 유틸리티 메서드 모음입니다. Long, String, Boolean 등 주요 타입 변환을 처리합니다. 모든 서비스/컨트롤러에서 재사용 가능합니다.

**사용 시점**: Map 데이터에서 값을 추출할 때

## 템플릿 / 패턴

```java
package com.execnt.common.utils;

import java.util.Map;

/**
 * Map 값 추출 유틸리티
 * @author Team
 * @date 2025-03-18
 */
public class MapUtil {

    /**
     * Map에서 Long 값 추출.
     * camelCase 먼저 확인, 없으면 snake_case 확인
     * @param map 대상 Map
     * @param key 키 (camelCase)
     * @return Long 값, null이면 null 반환
     */
    public static Long extractLong(Map<String, Object> map, String key) {
        if (map == null || key == null) return null;

        Object value = map.get(key);
        if (value == null) {
            // snake_case로 재시도
            String snakeKey = camelToSnake(key);
            value = map.get(snakeKey);
        }

        if (value == null) return null;

        if (value instanceof Number) {
            return ((Number) value).longValue();
        }

        try {
            return Long.parseLong(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Map에서 Integer 값 추출.
     * @param map 대상 Map
     * @param key 키 (camelCase)
     * @return Integer 값, null이면 null 반환
     */
    public static Integer extractInteger(Map<String, Object> map, String key) {
        if (map == null || key == null) return null;

        Object value = map.get(key);
        if (value == null) {
            String snakeKey = camelToSnake(key);
            value = map.get(snakeKey);
        }

        if (value == null) return null;

        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Map에서 String 값 추출.
     * @param map 대상 Map
     * @param key 키 (camelCase)
     * @return String 값, null이면 null 반환
     */
    public static String extractString(Map<String, Object> map, String key) {
        if (map == null || key == null) return null;

        Object value = map.get(key);
        if (value == null) {
            String snakeKey = camelToSnake(key);
            value = map.get(snakeKey);
        }

        return value != null ? value.toString().trim() : null;
    }

    /**
     * Map에서 Boolean 값 추출.
     * PostgreSQL은 여러 형태로 반환: Boolean, String ("true", "t", "1"), Number (0, 1)
     * @param map 대상 Map
     * @param key 키 (camelCase)
     * @return Boolean 값, null이면 null 반환
     */
    public static Boolean extractBoolean(Map<String, Object> map, String key) {
        if (map == null || key == null) return null;

        Object value = map.get(key);
        if (value == null) {
            String snakeKey = camelToSnake(key);
            value = map.get(snakeKey);
        }

        if (value == null) return null;

        // Boolean 타입
        if (value instanceof Boolean) {
            return (Boolean) value;
        }

        // String 타입
        if (value instanceof String) {
            String s = ((String) value).trim().toLowerCase();
            if ("true".equals(s) || "t".equals(s) || "1".equals(s)) {
                return true;
            }
            if ("false".equals(s) || "f".equals(s) || "0".equals(s)) {
                return false;
            }
        }

        // Number 타입
        if (value instanceof Number) {
            return ((Number) value).intValue() != 0;
        }

        return null;
    }

    /**
     * Map에서 Double 값 추출.
     * @param map 대상 Map
     * @param key 키 (camelCase)
     * @return Double 값, null이면 null 반환
     */
    public static Double extractDouble(Map<String, Object> map, String key) {
        if (map == null || key == null) return null;

        Object value = map.get(key);
        if (value == null) {
            String snakeKey = camelToSnake(key);
            value = map.get(snakeKey);
        }

        if (value == null) return null;

        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }

        try {
            return Double.parseDouble(value.toString());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * camelCase를 snake_case로 변환.
     * @param camelCase 입력 문자열
     * @return snake_case 문자열
     */
    private static String camelToSnake(String camelCase) {
        if (camelCase == null || camelCase.isEmpty()) return camelCase;
        return camelCase.replaceAll("([a-z])([A-Z]+)", "$1_$2").toLowerCase();
    }
}
```

## 사용 예시

```java
// Service에서 사용
Map<String, Object> user = userMapper.selectUserById(params);

Long userId = MapUtil.extractLong(user, "userId");        // user_id도 확인
String userName = MapUtil.extractString(user, "userName");  // user_name도 확인
Boolean isActive = MapUtil.extractBoolean(user, "isActive"); // is_active도 확인
Integer quantity = MapUtil.extractInteger(user, "quantity");

// null 안전
if (userId == null) {
    throw new BizException("E0001");  // ID 누락
}
```

## 사용 가이드

1. **유틸리티 메서드 호출**: 모든 추출에서 MapUtil.extract*() 사용
2. **null 체크**: 필수 값은 추출 후 null 확인
3. **camelCase 우선**: 먼저 camelCase로 조회, 없으면 snake_case 자동 변환
4. **예외 처리**: 숫자 변환 실패 시 null 반환 (예외 발생 안 함)
5. **Boolean 다양성**: PostgreSQL 다양한 형식 자동 처리

## 체크리스트

- [ ] MapUtil 클래스 생성 또는 확인
- [ ] Long, Integer, String, Boolean, Double 메서드 모두 포함
- [ ] camelToSnake 메서드 포함
- [ ] null 안전성 확인
- [ ] 서비스/컨트롤러에서 사용 확인
- [ ] 테스트 케이스 작성
