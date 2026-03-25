---
description: "고급 SQL (윈도우함수, CTE, 마이그레이션) | Advanced SQL patterns and optimization"
---

# db-advanced-sql

## 개요

고급 SQL 패턴을 제공합니다. 윈도우 함수, CTE(Common Table Expression), 마이그레이션, 성능 모니터링을 포함합니다. 복잡한 분석, 보고서 쿼리에 사용됩니다.

**사용 시점**: 복잡한 데이터 분석, 성능 최적화가 필요할 때

## 템플릿 / 패턴

### 윈도우 함수

#### ROW_NUMBER (순위)

```sql
-- 사용자별 주문 순위
SELECT
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn,
    order_id,
    user_id,
    total_amount,
    created_at
FROM wms.twms_order
WHERE rn <= 5;  -- 사용자별 최근 5개 주문
```

#### RANK (동순위 처리)

```sql
-- 주문액 기준 순위 (동순위 포함)
SELECT
    RANK() OVER (ORDER BY total_amount DESC) AS rank,
    order_id,
    total_amount,
    user_id
FROM wms.twms_order
ORDER BY rank;
```

#### LAG/LEAD (이전/다음 행)

```sql
-- 전일 대비 매출 변화
SELECT
    order_date,
    daily_sales,
    LAG(daily_sales) OVER (ORDER BY order_date) AS prev_sales,
    daily_sales - LAG(daily_sales) OVER (ORDER BY order_date) AS sales_change,
    ROUND(
        ((daily_sales - LAG(daily_sales) OVER (ORDER BY order_date)) /
         LAG(daily_sales) OVER (ORDER BY order_date) * 100)::NUMERIC, 2
    ) AS change_percent
FROM (
    SELECT
        DATE(created_at) AS order_date,
        SUM(total_amount) AS daily_sales
    FROM wms.twms_order
    GROUP BY DATE(created_at)
) daily_stats
ORDER BY order_date;
```

#### NTILE (분위수)

```sql
-- 사용자를 4개 분위수로 분류
SELECT
    user_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS quartile
FROM (
    SELECT
        user_id,
        SUM(total_amount) AS total_spent
    FROM wms.twms_order
    GROUP BY user_id
) user_spending;
```

### CTE (Common Table Expression)

#### 단순 CTE

```sql
-- 활성 사용자 목록
WITH active_users AS (
    SELECT user_id, user_name, user_email
    FROM wms.twms_user
    WHERE is_active = true
)
SELECT * FROM active_users;
```

#### 다중 CTE (주문 분석)

```sql
-- 사용자별 주문 통계
WITH user_orders AS (
    SELECT
        user_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent,
        AVG(total_amount) AS avg_order_value
    FROM wms.twms_order
    GROUP BY user_id
),
high_value_users AS (
    SELECT *
    FROM user_orders
    WHERE total_spent > 10000
)
SELECT
    u.user_id,
    u.user_name,
    u.user_email,
    hv.order_count,
    hv.total_spent,
    hv.avg_order_value
FROM wms.twms_user u
JOIN high_value_users hv ON u.user_id = hv.user_id
ORDER BY hv.total_spent DESC;
```

#### 재귀 CTE (계층 구조)

```sql
-- 카테고리 계층 구조
WITH RECURSIVE category_tree AS (
    -- 기본 항
    SELECT
        category_id,
        parent_category_id,
        category_name,
        1 AS level
    FROM wms.twms_category
    WHERE parent_category_id IS NULL

    UNION ALL

    -- 재귀 항
    SELECT
        c.category_id,
        c.parent_category_id,
        REPEAT('  ', ct.level) || c.category_name AS category_name,
        ct.level + 1
    FROM wms.twms_category c
    JOIN category_tree ct ON c.parent_category_id = ct.category_id
)
SELECT * FROM category_tree
ORDER BY category_name;
```

### 쿼리 최적화

#### 집계 함수 (Aggregation)

```sql
-- 일별 매출 분석
SELECT
    DATE(created_at) AS order_date,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS daily_revenue,
    AVG(total_amount) AS avg_order_value,
    MAX(total_amount) AS max_order,
    MIN(total_amount) AS min_order,
    COUNT(DISTINCT user_id) AS unique_customers
FROM wms.twms_order
GROUP BY DATE(created_at)
ORDER BY order_date DESC;
```

#### HAVING 절 (집계 필터)

```sql
-- 100개 이상 주문한 사용자
SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM wms.twms_order
GROUP BY user_id
HAVING COUNT(*) >= 100
ORDER BY order_count DESC;
```

#### CASE 식 (조건부 처리)

```sql
-- 주문액 범위별 고객 분류
SELECT
    user_id,
    user_name,
    SUM(total_amount) AS total_spent,
    CASE
        WHEN SUM(total_amount) >= 100000 THEN 'VIP'
        WHEN SUM(total_amount) >= 50000 THEN 'Gold'
        WHEN SUM(total_amount) >= 10000 THEN 'Silver'
        ELSE 'Regular'
    END AS customer_grade
FROM wms.twms_user u
LEFT JOIN wms.twms_order o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name
ORDER BY total_spent DESC;
```

### 마이그레이션 패턴

#### 테이블 수정

```sql
-- 새 컬럼 추가
ALTER TABLE wms.twms_user ADD COLUMN phone VARCHAR(20);

-- 컬럼 삭제
ALTER TABLE wms.twms_user DROP COLUMN legacy_field;

-- 컬럼 타입 변경
ALTER TABLE wms.twms_user ALTER COLUMN phone TYPE VARCHAR(20);

-- 기본값 설정
ALTER TABLE wms.twms_user ALTER COLUMN is_active SET DEFAULT false;

-- NULL 제약 추가
ALTER TABLE wms.twms_user ALTER COLUMN phone SET NOT NULL;
```

#### 데이터 마이그레이션

```sql
-- 데이터 복사 및 변환
INSERT INTO wms.twms_user_new (user_id, user_name, user_email, is_active, created_at)
SELECT user_id, user_name, LOWER(email), is_active, created_at
FROM wms.twms_user_old;

-- 테이블 이름 변경
ALTER TABLE wms.twms_user RENAME TO twms_user_old;
ALTER TABLE wms.twms_user_new RENAME TO twms_user;

-- 제약조건 추가
ALTER TABLE wms.twms_user
ADD CONSTRAINT pk_twms_user PRIMARY KEY (user_id);

ALTER TABLE wms.twms_user
ADD CONSTRAINT uk_twms_user_email UNIQUE (user_email);
```

#### 인덱스 마이그레이션

```sql
-- 인덱스 생성 (동시성 유지)
CREATE INDEX CONCURRENTLY idx_twms_order_new ON wms.twms_order(user_id, created_at DESC);

-- 기존 인덱스 삭제
DROP INDEX IF EXISTS idx_twms_order_old;

-- 인덱스 재명명
ALTER INDEX idx_twms_order_new RENAME TO idx_twms_order;
```

### 성능 모니터링

#### 슬로우 쿼리 확인

```sql
-- 평균 실행 시간이 1초 이상인 쿼리
SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time,
    ROUND((total_exec_time::NUMERIC / calls)::NUMERIC, 2) AS avg_ms
FROM pg_stat_statements
WHERE mean_exec_time > 1000
ORDER BY mean_exec_time DESC
LIMIT 10;
```

#### 테이블 크기

```sql
-- 테이블 크기 확인
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'wms'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

#### 인덱스 효율성

```sql
-- 사용하지 않는 인덱스
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'wms'
AND idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

#### 쿼리 실행 계획

```sql
-- EXPLAIN ANALYZE로 쿼리 성능 분석
EXPLAIN ANALYZE
SELECT o.order_id, u.user_name, o.total_amount
FROM wms.twms_order o
JOIN wms.twms_user u ON o.user_id = u.user_id
WHERE o.created_at >= '2025-01-01'
ORDER BY o.created_at DESC;
```

## 사용 가이드

1. **윈도우 함수**: 순위, 순번, 이전/다음 행 필요시
2. **CTE**: 복잡한 쿼리를 단계별로 작성할 때
3. **집계 함수**: 통계, 요약 데이터 필요시
4. **마이그레이션**: 스키마 변경 시 안전하게 처리
5. **성능 모니터링**: 느린 쿼리 식별 및 최적화

## 체크리스트

- [ ] 윈도우 함수 (ROW_NUMBER, RANK, LAG/LEAD, NTILE)
- [ ] CTE (단순, 다중, 재귀)
- [ ] 집계 함수 (COUNT, SUM, AVG, MAX, MIN)
- [ ] CASE 식 (조건부 처리)
- [ ] 마이그레이션 패턴 (ALTER, INSERT, DROP)
- [ ] EXPLAIN ANALYZE (성능 분석)
- [ ] 인덱스 재구성
- [ ] 테이블 통계 업데이트
- [ ] 성능 기준 설정
- [ ] 모니터링 및 최적화
