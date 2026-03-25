---
description: "Service + Mapper 쌍 생성 | Create Service and MyBatis Mapper pair"
---

# be-service-mapper

## 개요

Service 클래스와 MyBatis Mapper 쌍을 생성합니다. Service는 비즈니스 로직을 처리하고, Mapper는 데이터 접근을 담당합니다. XML 매퍼 파일도 함께 생성합니다.

**사용 시점**: 새로운 도메인 엔티티의 데이터 접근 계층이 필요할 때

## 템플릿 / 패턴

### Service 클래스

```java
package com.execnt.wms.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.execnt.wms.mapper.UserMapper;
import com.execnt.common.exception.BizException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 사용자 관리 서비스
 * @author Team
 * @date 2025-03-18
 */
@Service
public class UserService {

    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    /**
     * 사용자 목록 조회.
     * @param params 조회 파라미터
     * @return 사용자 목록 및 총 개수
     * @throws Exception 시스템 예외
     */
    public Map<String, Object> getUserList(Map<String, Object> params) throws Exception {
        // 동적 조건 처리
        if (params.get("userName") != null && "".equals(params.get("userName"))) {
            params.put("userName", null);
        }

        // 페이징 계산
        Integer limit = (Integer) params.getOrDefault("limit", 10);
        Integer offset = (Integer) params.getOrDefault("offset", 0);
        params.put("limit", limit);
        params.put("offset", offset);

        List<Map<String, Object>> list = userMapper.selectUsers(params);
        int total = userMapper.countUsers(params);

        Map<String, Object> result = new HashMap<>();
        result.put("data", list);
        result.put("total", total);

        return result;
    }

    /**
     * 사용자 상세 조회.
     * @param userId 사용자 ID
     * @return 사용자 정보
     * @throws Exception 시스템 예외
     */
    public Map<String, Object> getUserById(Long userId) throws Exception {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        return userMapper.selectUserById(params);
    }

    /**
     * 사용자 생성.
     * @param params 사용자 정보 (userName, userEmail, password, isActive)
     * @return 생성된 사용자 ID
     * @throws BizException 비즈니스 예외 (이미 등록된 이메일)
     * @throws Exception 시스템 예외
     */
    @Transactional
    public Map<String, Object> createUser(Map<String, Object> params) throws Exception {
        // 이메일 중복 확인
        Map<String, Object> checkParams = new HashMap<>();
        checkParams.put("userEmail", params.get("userEmail"));
        int count = userMapper.countByEmail(checkParams);
        if (count > 0) {
            throw new BizException("E1001");  // 이미 등록된 이메일
        }

        params.put("isActive", params.getOrDefault("isActive", true));
        params.put("createdBy", "SYSTEM");

        userMapper.insertUser(params);

        // 생성된 ID 반환
        Map<String, Object> result = new HashMap<>();
        result.put("userId", params.get("userId"));
        return result;
    }

    /**
     * 사용자 수정.
     * @param params 수정할 사용자 정보 (userId 포함)
     * @return 수정된 사용자 정보
     * @throws Exception 시스템 예외
     */
    @Transactional
    public Map<String, Object> updateUser(Map<String, Object> params) throws Exception {
        params.put("updatedBy", "SYSTEM");
        userMapper.updateUserSelective(params);
        return getUserById((Long) params.get("userId"));
    }

    /**
     * 사용자 삭제.
     * @param params 삭제할 사용자 정보 (userId)
     * @throws Exception 시스템 예외
     */
    @Transactional
    public void deleteUser(Map<String, Object> params) throws Exception {
        userMapper.deleteUser(params);
    }

    /**
     * 사용자 일괄 삭제.
     * @param params 삭제할 사용자 ID 목록 (userIds)
     * @throws Exception 시스템 예외
     */
    @Transactional
    public void deleteUsersBatch(Map<String, Object> params) throws Exception {
        userMapper.deleteUsersByIds(params);
    }
}
```

### Mapper Interface

```java
package com.execnt.wms.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;

/**
 * 사용자 Mapper 인터페이스
 */
@Mapper
public interface UserMapper {

    /**
     * 사용자 목록 조회 (동적 WHERE 포함).
     */
    List<Map<String, Object>> selectUsers(Map<String, Object> params);

    /**
     * 사용자 상세 조회.
     */
    Map<String, Object> selectUserById(Map<String, Object> params);

    /**
     * 사용자 수 조회.
     */
    int countUsers(Map<String, Object> params);

    /**
     * 이메일로 사용자 수 조회.
     */
    int countByEmail(Map<String, Object> params);

    /**
     * 사용자 생성.
     */
    int insertUser(Map<String, Object> params);

    /**
     * 사용자 수정 (선택적 컬럼).
     */
    int updateUserSelective(Map<String, Object> params);

    /**
     * 사용자 삭제.
     */
    int deleteUser(Map<String, Object> params);

    /**
     * 사용자 일괄 삭제.
     */
    int deleteUsersByIds(Map<String, Object> params);
}
```

### MyBatis Mapper XML

> WMS 레포: XML 파일은 `src/main/resources/mapper/` 아래에 둡니다 (`application.yml`의 `classpath:mapper/**/*.xml`).

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.execnt.wms.mapper.UserMapper">

    <!-- 동적 조건 WHERE 절 -->
    <sql id="whereClauses">
        <where>
            <if test="userName != null and userName != ''">
                AND user_name LIKE CONCAT('%', #{userName}, '%')
            </if>
            <if test="userEmail != null and userEmail != ''">
                AND user_email = #{userEmail}
            </if>
            <if test="isActive != null">
                AND is_active = #{isActive, jdbcType=BOOLEAN}
            </if>
        </where>
    </sql>

    <!-- 사용자 목록 조회 -->
    <select id="selectUsers" parameterType="map" resultType="map">
        SELECT * FROM wms.twms_user
        <include refid="whereClauses"/>
        ORDER BY created_at DESC
        LIMIT #{limit} OFFSET #{offset}
    </select>

    <!-- 사용자 상세 조회 -->
    <select id="selectUserById" parameterType="map" resultType="map">
        SELECT * FROM wms.twms_user WHERE user_id = #{userId}
    </select>

    <!-- 사용자 수 조회 -->
    <select id="countUsers" parameterType="map" resultType="int">
        SELECT COUNT(*) FROM wms.twms_user
        <include refid="whereClauses"/>
    </select>

    <!-- 이메일로 사용자 수 조회 -->
    <select id="countByEmail" parameterType="map" resultType="int">
        SELECT COUNT(*) FROM wms.twms_user WHERE user_email = #{userEmail}
    </select>

    <!-- 사용자 생성 -->
    <insert id="insertUser" parameterType="map">
        INSERT INTO wms.twms_user (
            user_name,
            user_email,
            password_hash,
            is_active,
            created_at,
            created_by
        ) VALUES (
            #{userName},
            #{userEmail},
            #{passwordHash},
            #{isActive, jdbcType=BOOLEAN},
            CURRENT_TIMESTAMP,
            #{createdBy}
        )
    </insert>

    <!-- 사용자 수정 (선택적) -->
    <update id="updateUserSelective" parameterType="map">
        UPDATE wms.twms_user
        <set>
            <if test="userName != null">user_name = #{userName},</if>
            <if test="userEmail != null">user_email = #{userEmail},</if>
            <if test="isActive != null">is_active = #{isActive, jdbcType=BOOLEAN},</if>
            updated_at = CURRENT_TIMESTAMP,
            updated_by = #{updatedBy}
        </set>
        WHERE user_id = #{userId}
    </update>

    <!-- 사용자 삭제 -->
    <delete id="deleteUser" parameterType="map">
        DELETE FROM wms.twms_user WHERE user_id = #{userId}
    </delete>

    <!-- 사용자 일괄 삭제 -->
    <delete id="deleteUsersByIds" parameterType="map">
        DELETE FROM wms.twms_user
        WHERE user_id IN
        <foreach collection="userIds" item="userId" open="(" separator="," close=")">
            #{userId}
        </foreach>
    </delete>

</mapper>
```

### 로그인용 `AdmUserinfoMapper` (WMS 현행)

- 인터페이스: `com.execnt.wms.mapper.AdmUserinfoMapper`
- XML: `src/main/resources/mapper/AdmUserinfoMapper.xml` (`classpath:mapper/**/*.xml` 와 일치)
- 메서드 예: `selectUserForLogin(Map)` → `wms.adm_userinfo`에서 `userid`로 1건, BCrypt 검증은 `AuthService`에서 `PasswordEncoder`로 처리.

```java
package com.execnt.wms.mapper;

import org.apache.ibatis.annotations.Mapper;
import java.util.Map;

@Mapper
public interface AdmUserinfoMapper {
    Map<String, Object> selectUserForLogin(Map<String, Object> params);
}
```

```xml
<mapper namespace="com.execnt.wms.mapper.AdmUserinfoMapper">
    <select id="selectUserForLogin" parameterType="map" resultType="map">
        SELECT userid, username, usergroupcode, password, use_yn, lock_yn
        FROM wms.adm_userinfo
        WHERE userid = #{userid}
    </select>
</mapper>
```

`AuthService`는 위 Mapper로 행을 읽은 뒤 `use_yn`/`lock_yn`/비밀번호를 검증하고 `JwtUtil`로 토큰을 발급합니다.

## 사용 가이드

1. **Service 클래스 생성**: `wms/service/[Domain]Service.java`
2. **Mapper Interface 생성**: `wms/mapper/[Domain]Mapper.java` (@Mapper 필수)
3. **XML 매퍼 생성**: WMS 표준은 `src/main/resources/mapper/[Domain]Mapper.xml` (복수형 `mappers/` 디렉터리가 아님)
4. **경로 일치 확인**: namespace = com.execnt.wms.mapper.[Domain]Mapper
5. **트랜잭션 처리**: CUD 메서드에 @Transactional 추가
6. **예외 처리**: BizException 사용 (비즈니스 규칙 위반)
7. **Map 파라미터**: 모든 메서드에서 Map<String, Object> 사용

## 체크리스트

- [ ] Service 클래스 생성
- [ ] Mapper Interface 생성 (@Mapper 필수)
- [ ] XML 매퍼 파일 생성 (WMS: `resources/mapper/`)
- [ ] namespace 일치 확인
- [ ] CRUD 메서드 구현
- [ ] 동적 SQL <where>, <set> 사용
- [ ] CUD 메서드에 @Transactional 추가
- [ ] SELECT 쿼리에 resultType="map" 확인
- [ ] INSERT 쿼리에 parameterType="map" 확인
- [ ] WHERE 절에 특수문자는 CDATA 사용
- [ ] 테스트 케이스 작성
