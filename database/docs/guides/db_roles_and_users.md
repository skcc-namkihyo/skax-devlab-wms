<!--
Purpose: WMS 창고관리시스템의 DB 사용자/역할/권한 관리 가이드
Scope: WMS 창고관리시스템의 DB 사용자 및 권한 관리 시 적용
-->

# DB 역할 및 사용자 관리 가이드

이 문서는 WMS 창고관리시스템의 데이터베이스(DB) 역할, 사용자, 권한 관리 원칙과 실제 적용 예시를 안내합니다. 실제 SQL 스크립트는 [`create_roles_and_users.sql`](./create_roles_and_users.sql)을 참고하세요.

## 1. 목적
- 데이터베이스 보안 및 운영 효율성을 위해 역할(Role) 기반 권한 관리 체계를 적용합니다.
- 개발, 운영, 외부 연동(API), 분석 등 목적별로 최소 권한 원칙을 준수합니다.

## 2. 역할 및 사용자 설계 원칙
- **Admin Role**: 스키마/테이블/시퀀스 생성, 변경, 삭제 등 모든 DDL 권한 보유
- **Developer Role**: 데이터 조회/입력/수정/삭제(DML) 권한만 보유
- **API Role**: 외부 연동용 핵심 비즈니스 테이블에 한정된 CRUD 권한 부여
- **Read-Only Role**: 보고서 및 분석을 위한 읽기 전용 권한 부여
- 각 역할별로 별도의 사용자 계정 생성 및 역할(Role) 할당
- 실제 비밀번호는 운영 환경에서 별도 관리(버전 관리 금지)

## 3. 권한 부여 예시
- 실제 SQL 예시는 [`create_roles_and_users.sql`](./create_roles_and_users.sql) 파일을 참고하세요.
- 주요 예시:
  - wms 스키마에 대한 역할 생성 및 권한 부여
  - 기본 객체(테이블/시퀀스) 및 향후 생성 객체에 대한 권한 자동 부여
  - 역할별 사용자 계정 생성 및 역할 할당
  - 외부 연동(API) 전용 테이블에 한정된 권한 부여
  - 분석 및 보고서용 읽기 전용 권한 부여

```sql
-- Admin Role 생성 및 권한 부여 예시
CREATE ROLE wms_admin_role;
GRANT ALL PRIVILEGES ON SCHEMA wms TO wms_admin_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wms TO wms_admin_role;

-- Developer Role 생성 및 권한 부여 예시
CREATE ROLE wms_developer_role;
GRANT USAGE ON SCHEMA wms TO wms_developer_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA wms TO wms_developer_role;

-- API Role 생성 및 권한 부여 예시
CREATE ROLE wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE wms.reservation TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE wms.quote TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE wms.payment TO wms_api_role;

-- Read-Only Role 생성 및 권한 부여 예시
CREATE ROLE wms_readonly_role;
GRANT USAGE ON SCHEMA wms TO wms_readonly_role;
GRANT SELECT ON ALL TABLES IN SCHEMA wms TO wms_readonly_role;

-- 사용자 계정 생성 및 역할 할당 예시
CREATE USER wms_admin WITH PASSWORD 'Admin****' IN ROLE wms_admin_role;
CREATE USER wms_developer WITH PASSWORD 'Dev****' IN ROLE wms_developer_role;
CREATE USER wms_api WITH PASSWORD 'Api****' IN ROLE wms_api_role;
CREATE USER wms_readonly WITH PASSWORD 'Read****' IN ROLE wms_readonly_role;
```

> **전체 SQL 스크립트 및 상세 예시는 [`create_roles_and_users.sql`](./create_roles_and_users.sql) 파일을 반드시 참고하세요.**

## 4. 역할별 상세 권한

### 4.1 Admin Role (`wms_admin_role`)
- **권한**: 모든 DDL 권한 (CREATE, ALTER, DROP, TRUNCATE)
- **용도**: 데이터베이스 스키마 및 테이블 구조 관리
- **접근 가능**: wms 스키마의 모든 객체

### 4.2 Developer Role (`wms_developer_role`)
- **권한**: DML 권한 (SELECT, INSERT, UPDATE, DELETE)
- **용도**: 개발 및 테스트 환경에서의 데이터 조작
- **접근 가능**: wms 스키마의 모든 테이블

### 4.3 API Role (`wms_api_role`)
- **권한**: 핵심 비즈니스 테이블에 대한 CRUD 권한
- **용도**: 외부 API 시스템과의 연동
- **접근 가능 테이블**:
  - 예약 시스템: `reservation`, `reservation_detail`, `reservation_status_history`
  - 견적 시스템: `quote`, `quote_item`, `quote_status_history`
  - 결제 시스템: `payment`, `payment_method`, `payment_status_history`
  - 사용자/차량/정비소: `user`, `vehicle`, `service_center`

### 4.4 Read-Only Role (`wms_readonly_role`)
- **권한**: SELECT 권한만
- **용도**: 보고서 생성, 데이터 분석, 비즈니스 인텔리전스
- **접근 가능**: wms 스키마의 모든 테이블 (읽기 전용)

## 5. 보안 및 운영 주의사항
- 운영 환경에서는 반드시 강력한 비밀번호 정책을 적용하고, 비밀번호는 별도 안전한 경로로 관리합니다.
- 불필요한 권한 부여를 금지하며, 최소 권한 원칙(Principle of Least Privilege)을 준수합니다.
- 권한 변경/추가/삭제 시 반드시 변경 이력을 남기고, 관련자 승인 후 적용합니다.
- API Role은 필요한 테이블에만 접근할 수 있도록 제한적으로 권한을 부여합니다.
- Read-Only Role은 데이터 무결성을 위해 수정 권한을 절대 부여하지 않습니다.

## 6. 변경 이력
| 버전 | 일자 | 작성자 | 변경 내용 | 비고 |
|-------|------------|----------|-----------------------------|------|
| 1.0   | 2024-06-16 | 관리자   | 최초 작성 및 SQL 예시 추가 |      |
| 1.1   | 2024-06-16 | 관리자   | create_roles_and_users.sql 연동, 보안 주의사항 보강 |      |
| 2.0   | 2024-12-19 | 관리자   | WMS 창고관리시스템에 맞게 전체 내용 수정 | wms 시스템 적용 | 