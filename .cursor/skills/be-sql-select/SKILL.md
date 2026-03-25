---
description: "SELECT 6종 패턴 | 6 SELECT query patterns for MyBatis"
---

# be-sql-select

## 개요

SELECT 쿼리의 6가지 표준 패턴을 제공합니다. 단순 조회, 동적 WHERE, IN 절, 페이징, COUNT, JOIN을 포함합니다. 모든 MyBatis Mapper XML에 적용 가능합니다.

**사용 시점**: 데이터 조회 쿼리가 필요할 때

## 템플릿 / 패턴

### 패턴 1: 단순 SELECT

```xml
<!-- 개요: PK 기반 단일 행 조회 -->
<select id="selectUserById" parameterType="map" resultType="map">
    SELECT
        user_id,
        user_name,
        user_email,
        is_active,
        created_at,
        updated_at
    FROM wms.twms_user
    WHERE user_id = #{userId}
</select>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userId", 1L);
Map<String, Object> user = userMapper.selectUserById(params);
```

### 패턴 2: 동적 WHERE (검색/필터링)

```xml
<!-- 개요: 동적 조건으로 목록 조회 -->
<select id="selectUsers" parameterType="map" resultType="map">
    SELECT * FROM wms.twms_user
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
    ORDER BY created_at DESC
</select>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userName", "김");
params.put("isActive", true);
List<Map<String, Object>> users = userMapper.selectUsers(params);
```

### 패턴 3: IN 절 (다중 ID 조회)

```xml
<!-- 개요: 여러 ID로 조회 -->
<select id="selectUsersByIds" parameterType="map" resultType="map">
    SELECT * FROM wms.twms_user
    WHERE user_id IN
    <foreach collection="userIds" item="userId" open="(" separator="," close=")">
        #{userId}
    </foreach>
    ORDER BY user_id
</select>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
List<Long> userIds = Arrays.asList(1L, 2L, 3L);
params.put("userIds", userIds);
List<Map<String, Object>> users = userMapper.selectUsersByIds(params);
```

### 패턴 4: 페이징

```xml
<!-- 개요: LIMIT/OFFSET 기반 페이징 -->
<select id="selectUsersWithPaging" parameterType="map" resultType="map">
    SELECT * FROM wms.twms_user
    <where>
        <if test="searchKeyword != null and searchKeyword != ''">
            AND user_name LIKE CONCAT('%', #{searchKeyword}, '%')
        </if>
    </where>
    ORDER BY created_at DESC
    LIMIT #{limit} OFFSET #{offset}
</select>
```

**Java 사용**:
```java
// 페이지 번호와 페이지 크기로 offset 계산
int pageNumber = 2;  // 2번째 페이지
int pageSize = 10;   // 페이지 크기
int offset = (pageNumber - 1) * pageSize;  // offset = 10

Map<String, Object> params = new HashMap<>();
params.put("limit", pageSize);
params.put("offset", offset);
List<Map<String, Object>> users = userMapper.selectUsersWithPaging(params);
```

### 패턴 5: COUNT 조회

```xml
<!-- 개요: 조건에 맞는 전체 개수 조회 -->
<select id="countUsers" parameterType="map" resultType="int">
    SELECT COUNT(*) FROM wms.twms_user
    <where>
        <if test="userName != null and userName != ''">
            AND user_name LIKE CONCAT('%', #{userName}, '%')
        </if>
        <if test="isActive != null">
            AND is_active = #{isActive, jdbcType=BOOLEAN}
        </if>
    </where>
</select>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("isActive", true);
int total = userMapper.countUsers(params);
System.out.println("활성 사용자: " + total);
```

### 패턴 6: JOIN 조회

```xml
<!-- 개요: 여러 테이블 JOIN으로 상세 정보 조회 -->
<select id="selectOrdersWithUser" parameterType="map" resultType="map">
    SELECT
        o.order_id,
        o.user_id,
        u.user_name,
        u.user_email,
        o.order_date,
        o.total_amount
    FROM wms.twms_order o
    LEFT JOIN wms.twms_user u ON o.user_id = u.user_id
    <where>
        <if test="startDate != null">
            <![CDATA[
            AND o.order_date >= #{startDate}
            ]]>
        </if>
        <if test="endDate != null">
            <![CDATA[
            AND o.order_date < #{endDate}
            ]]>
        </if>
    </where>
    ORDER BY o.order_date DESC
</select>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("startDate", "2025-01-01T00:00:00");
params.put("endDate", "2025-12-31T23:59:59");
List<Map<String, Object>> orders = orderMapper.selectOrdersWithUser(params);
```

## 사용 가이드

1. **단순 조회**: ID 기반 단일 행 → 패턴 1
2. **검색/필터링**: 동적 조건 다수 → 패턴 2
3. **다중 ID 조회**: IN 절 필요 → 패턴 3
4. **대용량 목록**: 페이징 필수 → 패턴 4
5. **통계 조회**: 개수/합계 → 패턴 5
6. **관계 데이터**: 다중 테이블 → 패턴 6

## 체크리스트

- [ ] SELECT 쿼리에 필요한 컬럼만 명시 (SELECT *)
- [ ] WHERE 절에 동적 조건 사용 (<where>, <if>)
- [ ] 페이징 쿼리에 LIMIT/OFFSET 포함
- [ ] IN 절에 <foreach> 사용
- [ ] 날짜 비교는 CDATA로 감싸기 (<![CDATA[ ]]>)
- [ ] resultType="map" 또는 resultType="int" 확인
- [ ] parameterType="map" 확인
- [ ] JOIN은 LEFT/INNER 명확히
- [ ] ORDER BY 기본값 설정
