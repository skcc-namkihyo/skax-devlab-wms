---
description: "INSERT/UPDATE/DELETE 및 동적SQL | CUD patterns with dynamic SQL"
---

# be-sql-write

## 개요

INSERT, UPDATE, DELETE 쿼리의 표준 패턴입니다. 동적 SQL (<if>, <set>, <foreach>), CDATA, 트랜잭션 처리를 포함합니다. 모든 데이터 변경 작업에 적용됩니다.

**사용 시점**: 데이터 생성/수정/삭제 쿼리가 필요할 때

## 템플릿 / 패턴

### 패턴 1: 단순 INSERT

```xml
<!-- 개요: 모든 필드를 지정한 정상적인 INSERT -->
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
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userName", "김철수");
params.put("userEmail", "kim@example.com");
params.put("passwordHash", "hashed_password");
params.put("isActive", true);
params.put("createdBy", "admin");
userMapper.insertUser(params);
```

### 패턴 2: 배치 INSERT (다중 행 삽입)

```xml
<!-- 개요: 여러 행을 한 번에 삽입 -->
<insert id="insertUsersBatch" parameterType="map">
    INSERT INTO wms.twms_user (
        user_name,
        user_email,
        password_hash,
        is_active,
        created_at,
        created_by
    ) VALUES
    <foreach collection="users" item="user" separator=",">
        (
            #{user.userName},
            #{user.userEmail},
            #{user.passwordHash},
            #{user.isActive, jdbcType=BOOLEAN},
            CURRENT_TIMESTAMP,
            #{user.createdBy}
        )
    </foreach>
</insert>
```

**Java 사용**:
```java
List<Map<String, Object>> users = new ArrayList<>();
for (int i = 0; i < 5; i++) {
    Map<String, Object> user = new HashMap<>();
    user.put("userName", "User" + i);
    user.put("userEmail", "user" + i + "@example.com");
    user.put("passwordHash", "hash");
    user.put("isActive", true);
    user.put("createdBy", "SYSTEM");
    users.add(user);
}

Map<String, Object> params = new HashMap<>();
params.put("users", users);
userMapper.insertUsersBatch(params);
```

### 패턴 3: 단순 UPDATE

```xml
<!-- 개요: 모든 필드를 명시적으로 수정 -->
<update id="updateUser" parameterType="map">
    UPDATE wms.twms_user
    SET
        user_name = #{userName},
        user_email = #{userEmail},
        is_active = #{isActive, jdbcType=BOOLEAN},
        updated_at = CURRENT_TIMESTAMP,
        updated_by = #{updatedBy}
    WHERE user_id = #{userId}
</update>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userId", 1L);
params.put("userName", "김철수");
params.put("userEmail", "newkim@example.com");
params.put("isActive", true);
params.put("updatedBy", "admin");
userMapper.updateUser(params);
```

### 패턴 4: 동적 UPDATE (선택적 컬럼)

```xml
<!-- 개요: null이 아닌 필드만 수정 -->
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
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userId", 1L);
params.put("userName", "새이름");    // 이 필드만 수정
// userEmail, isActive는 null (수정 안 함)
params.put("updatedBy", "admin");
userMapper.updateUserSelective(params);
```

### 패턴 5: 조건부 UPDATE

```xml
<!-- 개요: 특정 상태일 때만 수정 (낙관적 잠금) -->
<update id="updateOrderStatus" parameterType="map">
    UPDATE wms.twms_order
    SET
        order_status = #{newStatus},
        updated_at = CURRENT_TIMESTAMP,
        updated_by = #{updatedBy}
    WHERE order_id = #{orderId}
      AND order_status = #{currentStatus}
</update>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("orderId", 1L);
params.put("currentStatus", "PENDING");  // 현재 상태 확인
params.put("newStatus", "CONFIRMED");    // 새 상태
params.put("updatedBy", "system");
int rowsAffected = orderMapper.updateOrderStatus(params);
if (rowsAffected == 0) {
    throw new BizException("E1002");  // 상태 변경 실패
}
```

### 패턴 6: 단순 DELETE

```xml
<!-- 개요: 단일 행 삭제 -->
<delete id="deleteUser" parameterType="map">
    DELETE FROM wms.twms_user WHERE user_id = #{userId}
</delete>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userId", 1L);
userMapper.deleteUser(params);
```

### 패턴 7: 배치 DELETE (다중 행 삭제)

```xml
<!-- 개요: 여러 행을 한 번에 삭제 -->
<delete id="deleteUsersByIds" parameterType="map">
    DELETE FROM wms.twms_user
    WHERE user_id IN
    <foreach collection="userIds" item="userId" open="(" separator="," close=")">
        #{userId}
    </foreach>
</delete>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("userIds", Arrays.asList(1L, 2L, 3L));
userMapper.deleteUsersByIds(params);
```

### 패턴 8: 조건부 DELETE

```xml
<!-- 개요: 특정 조건에 맞는 행 삭제 -->
<delete id="deleteInactiveUsers" parameterType="map">
    DELETE FROM wms.twms_user
    WHERE is_active = false
      AND updated_at < #{beforeDate}
</delete>
```

**Java 사용**:
```java
Map<String, Object> params = new HashMap<>();
params.put("beforeDate", "2024-01-01T00:00:00");
userMapper.deleteInactiveUsers(params);
```

## 동적 SQL 패턴

### IF 조건

```xml
<if test="parameter != null and parameter != ''">
    AND column = #{parameter}
</if>

<!-- Boolean 체크 -->
<if test="isActive != null">
    AND is_active = #{isActive, jdbcType=BOOLEAN}
</if>

<!-- 숫자 범위 -->
<if test="minAmount != null and maxAmount != null">
    AND amount BETWEEN #{minAmount} AND #{maxAmount}
</if>
```

### SET 절 (자동 쉼표 처리)

```xml
<set>
    <if test="column1 != null">column1 = #{column1},</if>
    <if test="column2 != null">column2 = #{column2},</if>
    updated_at = CURRENT_TIMESTAMP
</set>
<!-- 마지막 쉼표 자동 제거 -->
```

### FOREACH (배치 처리)

```xml
<!-- IN 절 -->
<foreach collection="ids" item="id" open="(" separator="," close=")">
    #{id}
</foreach>

<!-- VALUES 절 (배치 INSERT) -->
<foreach collection="items" item="item" separator=",">
    (#{item.id}, #{item.name})
</foreach>
```

### CDATA (특수문자 처리)

```xml
<select id="selectByDate" parameterType="map" resultType="map">
    <![CDATA[
        SELECT * FROM wms.twms_order
        WHERE created_at >= #{startDate} AND created_at < #{endDate}
    ]]>
</select>
```

## 트랜잭션 패턴 (Java Service)

```java
@Transactional
public void createOrderWithDetails(Map<String, Object> orderData) throws Exception {
    // 1. 주문 헤더 삽입
    orderMapper.insertOrder(orderData);

    // 2. 주문 명세 삽입
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> details = (List) orderData.get("details");
    orderMapper.insertOrderDetailsBatch(details);

    // 3. 재고 차감
    stockMapper.decreaseStock(orderData);

    // 예외 발생 시 모두 ROLLBACK
    // 정상 완료 시 모두 COMMIT
}
```

## 사용 가이드

1. **INSERT**: 모든 필드 지정 또는 배치 처리
2. **UPDATE**: 선택적 수정 시 <set> 사용, 모든 필드 수정 시 직접 작성
3. **DELETE**: 단일 또는 배치 삭제 선택
4. **동적 SQL**: <if>, <set>, <foreach> 활용
5. **특수문자**: CDATA로 감싸기 (<![CDATA[ ]]>)
6. **Boolean**: jdbcType=BOOLEAN 명시
7. **트랜잭션**: CUD 메서드에 @Transactional 추가

## 체크리스트

- [ ] INSERT/UPDATE/DELETE 쿼리 작성
- [ ] parameterType="map" 확인
- [ ] <set> 태그로 동적 컬럼 처리
- [ ] <foreach>로 배치 처리
- [ ] CDATA로 특수문자 처리
- [ ] Boolean 필드에 jdbcType=BOOLEAN
- [ ] 모든 CUD 메서드에 @Transactional
- [ ] 시간 추적 필드 (created_at, updated_at) 포함
- [ ] 사용자 추적 필드 (created_by, updated_by) 포함
- [ ] 테스트 케이스 작성
