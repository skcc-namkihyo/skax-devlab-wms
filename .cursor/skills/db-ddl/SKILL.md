---
description: "DDL 생성 (테이블, 인덱스) | Create tables and indexes with PostgreSQL DDL"
---

# db-ddl

## 개요

PostgreSQL DDL을 사용하여 테이블과 인덱스를 생성합니다. WMS 네이밍 규칙(twms_ prefix), 공통 컬럼(created_at, updated_at), 제약조건을 포함합니다.

⚠️ **이 Skill은 수동 발동 전용입니다 (disable-model-invocation)**

**사용 시점**: 새로운 엔티티 테이블이 필요할 때

## 템플릿 / 패턴

### 스키마 생성

```sql
-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS wms;

-- 검색 경로 설정
SET search_path TO wms, public;
```

### 기본 테이블

```sql
-- 사용자 테이블
CREATE TABLE IF NOT EXISTS wms.twms_user (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM',
    CONSTRAINT uk_twms_user_email UNIQUE (user_email)
);

-- 기본 인덱스
CREATE INDEX idx_twms_user_email ON wms.twms_user(user_email);
CREATE INDEX idx_twms_user_created_at ON wms.twms_user(created_at DESC);
```

### 관계 테이블 (FK)

```sql
-- 주문 테이블
CREATE TABLE IF NOT EXISTS wms.twms_order (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(15, 2),
    order_status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM',
    CONSTRAINT pk_twms_order PRIMARY KEY (order_id),
    CONSTRAINT fk_twms_order_user_id FOREIGN KEY (user_id)
        REFERENCES wms.twms_user(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 복합 인덱스 (사용자별 주문 조회)
CREATE INDEX idx_twms_order_user_id ON wms.twms_order(user_id);
CREATE INDEX idx_twms_order_date ON wms.twms_order(order_date DESC);
CREATE INDEX idx_twms_order_user_date ON wms.twms_order(user_id, order_date DESC);

-- 상태별 조회 인덱스
CREATE INDEX idx_twms_order_status ON wms.twms_order(order_status) WHERE order_status != 'COMPLETED';
```

### 상세 테이블 (다대일 관계)

```sql
-- 주문 상세 테이블
CREATE TABLE IF NOT EXISTS wms.twms_order_detail (
    order_detail_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_quantity INTEGER NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    total_price NUMERIC(15, 2) GENERATED ALWAYS AS (order_quantity * unit_price) STORED,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM',
    CONSTRAINT fk_twms_order_detail_order_id FOREIGN KEY (order_id)
        REFERENCES wms.twms_order(order_id)
        ON DELETE CASCADE
);

-- 인덱스
CREATE INDEX idx_twms_order_detail_order_id ON wms.twms_order_detail(order_id);
CREATE INDEX idx_twms_order_detail_product_id ON wms.twms_order_detail(product_id);
```

### 재고 테이블

```sql
-- 재고 테이블
CREATE TABLE IF NOT EXISTS wms.twms_stock (
    stock_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL,
    warehouse_location VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0,
    available_quantity GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM',
    CONSTRAINT fk_twms_stock_product_id FOREIGN KEY (product_id)
        REFERENCES wms.twms_product(product_id)
        ON DELETE CASCADE
);

-- 재고 조회 인덱스
CREATE INDEX idx_twms_stock_product_id ON wms.twms_stock(product_id);
CREATE INDEX idx_twms_stock_location ON wms.twms_stock(warehouse_location);
CREATE INDEX idx_twms_stock_available ON wms.twms_stock(available_quantity) WHERE available_quantity > 0;
```

### 입출고 테이블

```sql
-- 입고 헤더
CREATE TABLE IF NOT EXISTS wms.twms_inbound_header (
    inbound_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inbound_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    supplier_id BIGINT,
    inbound_status VARCHAR(50) DEFAULT 'PENDING',
    total_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM'
);

-- 입고 상세
CREATE TABLE IF NOT EXISTS wms.twms_inbound_detail (
    inbound_detail_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    received_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_twms_inbound_detail_inbound_id FOREIGN KEY (inbound_id)
        REFERENCES wms.twms_inbound_header(inbound_id)
        ON DELETE CASCADE
);

-- 인덱스
CREATE INDEX idx_twms_inbound_header_date ON wms.twms_inbound_header(inbound_date DESC);
CREATE INDEX idx_twms_inbound_header_status ON wms.twms_inbound_header(inbound_status);
CREATE INDEX idx_twms_inbound_detail_inbound_id ON wms.twms_inbound_detail(inbound_id);
```

### 출고 테이블

```sql
-- 출고 헤더
CREATE TABLE IF NOT EXISTS wms.twms_outbound_header (
    outbound_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outbound_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_id BIGINT,
    outbound_status VARCHAR(50) DEFAULT 'PENDING',
    total_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) DEFAULT 'SYSTEM',
    updated_by VARCHAR(50) DEFAULT 'SYSTEM'
);

-- 출고 상세
CREATE TABLE IF NOT EXISTS wms.twms_outbound_detail (
    outbound_detail_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outbound_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    shipped_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_twms_outbound_detail_outbound_id FOREIGN KEY (outbound_id)
        REFERENCES wms.twms_outbound_header(outbound_id)
        ON DELETE CASCADE
);

-- 인덱스
CREATE INDEX idx_twms_outbound_header_date ON wms.twms_outbound_header(outbound_date DESC);
CREATE INDEX idx_twms_outbound_header_status ON wms.twms_outbound_header(outbound_status);
CREATE INDEX idx_twms_outbound_detail_outbound_id ON wms.twms_outbound_detail(outbound_id);
```

## 네이밍 규칙

| 항목 | 규칙 | 예시 |
|------|------|------|
| 테이블 | twms_ + domain | twms_user, twms_order |
| PK | {테이블}_id | user_id, order_id |
| FK | {참조테이블}_id | user_id, product_id |
| Boolean | is_ prefix | is_active, is_deleted |
| 날짜 | _at suffix | created_at, updated_at |
| 인덱스 | idx_{테이블}_{컬럼} | idx_twms_user_email |
| Unique | uk_{테이블}_{컬럼} | uk_twms_user_email |

## 공통 컬럼 (필수)

모든 테이블에 포함되어야 할 컬럼:

```sql
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
created_by VARCHAR(50) DEFAULT 'SYSTEM',
updated_by VARCHAR(50) DEFAULT 'SYSTEM'
```

## 데이터 타입

| 용도 | 타입 | 예시 |
|------|------|------|
| ID/FK | BIGINT | user_id BIGINT |
| 텍스트 (짧음) | VARCHAR(N) | VARCHAR(100) |
| 텍스트 (길음) | TEXT | 설명, 비고 |
| 날짜시간 | TIMESTAMP | created_at TIMESTAMP |
| Boolean | BOOLEAN | is_active BOOLEAN |
| 금액 | NUMERIC(15, 2) | NUMERIC(15, 2) |
| 수량 | INTEGER | INTEGER |

## 사용 가이드

1. **스키마 생성**: 최초 1회만 실행
2. **테이블 생성**: 엔티티별로 생성
3. **인덱스 생성**: 조회 성능 필요시 추가
4. **제약조건**: FK, UNIQUE 포함
5. **공통 컬럼**: 모든 테이블에 포함

## 체크리스트

- [ ] 스키마 생성 (wms)
- [ ] twms_ 프리픽스 확인
- [ ] PK (GENERATED ALWAYS AS IDENTITY) 확인
- [ ] FK와 ON DELETE/UPDATE 규칙 확인
- [ ] 공통 컬럼 (created_at, updated_at, created_by, updated_by) 포함
- [ ] 기본 인덱스 생성 (PK, FK, 주요 조회 컬럼)
- [ ] UNIQUE 제약조건 확인
- [ ] 데이터 타입 확인
- [ ] GENERATED ALWAYS AS STORED 컬럼 (재고 등)
- [ ] 테스트 데이터 삽입 후 조회 확인
