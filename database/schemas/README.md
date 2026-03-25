# WMS Database Schema

WMS(창고관리시스템) PostgreSQL 데이터베이스 스키마 및 초기 데이터 스크립트입니다.

## 실행 순서

아래 순서대로 스크립트를 실행해야 합니다. FK 참조 및 권한 의존성을 고려한 순서입니다.

### 1단계: 역할/사용자/DB 생성 (postgres DB에서 실행)

```bash
psql -U postgres -f 01_create_roles_and_users.sql
```

### 2단계: 스키마 생성 (wmsdb에서 실행)

```bash
psql -U wms_admin -d wmsdb -f 02_create_schema.sql
```

### 3~9단계: 테이블 생성 (wmsdb에서 실행)

```bash
psql -U wms_admin -d wmsdb -f 03_create_tables_common.sql
psql -U wms_admin -d wmsdb -f 04_create_tables_user.sql
psql -U wms_admin -d wmsdb -f 05_create_tables_inbound.sql
psql -U wms_admin -d wmsdb -f 06_create_tables_outbound.sql
psql -U wms_admin -d wmsdb -f 07_create_tables_inventory.sql
psql -U wms_admin -d wmsdb -f 08_create_tables_batch_log.sql
psql -U wms_admin -d wmsdb -f 09_create_tables_status_history.sql
```

### 10~12단계: Function 생성

```bash
psql -U wms_admin -d wmsdb -f 10_create_functions_inbound.sql
psql -U wms_admin -d wmsdb -f 11_create_functions_outbound.sql
psql -U wms_admin -d wmsdb -f 12_create_functions_inventory.sql
```

### 13단계: 권한 부여

```bash
psql -U wms_admin -d wmsdb -f 13_grant_permissions.sql
```

### 14~15단계: 초기 데이터 삽입

```bash
psql -U wms_admin -d wmsdb -f 14_insert_common_codes.sql
psql -U wms_admin -d wmsdb -f 15_insert_sample_data.sql
```

### 전체 한 번에 실행

```bash
# 1단계: postgres DB에서 역할/사용자/DB 생성
psql -U postgres -f 01_create_roles_and_users.sql

# 2~15단계: wmsdb에서 나머지 실행
psql -U wms_admin -d wmsdb -f 02_create_schema.sql \
  -f 03_create_tables_common.sql \
  -f 04_create_tables_user.sql \
  -f 05_create_tables_inbound.sql \
  -f 06_create_tables_outbound.sql \
  -f 07_create_tables_inventory.sql \
  -f 08_create_tables_batch_log.sql \
  -f 09_create_tables_status_history.sql \
  -f 10_create_functions_inbound.sql \
  -f 11_create_functions_outbound.sql \
  -f 12_create_functions_inventory.sql \
  -f 13_grant_permissions.sql \
  -f 14_insert_common_codes.sql \
  -f 15_insert_sample_data.sql
```

## 파일 목록

| 파일명 | 유형 | 설명 |
|--------|------|------|
| `01_create_roles_and_users.sql` | DCL | 역할 4개, 사용자 4개, DB 생성 |
| `02_create_schema.sql` | DCL | wms 스키마 + 기본 권한 설정 |
| `03_create_tables_common.sql` | DDL | 공통코드, 물류센터, 상품, 화주 마스터 (5 테이블) |
| `04_create_tables_user.sql` | DDL | 사용자 정보 + 세션 관리 (2 테이블) |
| `05_create_tables_inbound.sql` | DDL | 입고 헤더/상세 (2 테이블) |
| `06_create_tables_outbound.sql` | DDL | 출고 헤더/상세 (2 테이블) |
| `07_create_tables_inventory.sql` | DDL | 재고 LOT/셀/품목/LOT×셀 (4 테이블) |
| `08_create_tables_batch_log.sql` | DDL | 배치 실행 이력/오류 로그 (2 테이블) |
| `09_create_tables_status_history.sql` | DDL | 상태 변경/화면 접근 이력 (2 테이블) |
| `10_create_functions_inbound.sql` | DDL | 입고 검수/확정/취소 함수 (3 함수) |
| `11_create_functions_outbound.sql` | DDL | 출고 할당/피킹/확정/취소 함수 (4 함수) |
| `12_create_functions_inventory.sql` | DDL | 재고 이동/조정 함수 (2 함수) |
| `13_grant_permissions.sql` | DCL | 역할별 세부 권한 부여 |
| `14_insert_common_codes.sql` | DML | 공통코드 초기 데이터 (20 그룹, 80+ 코드) |
| `15_insert_sample_data.sql` | DML | 개발/테스트용 샘플 데이터 |
| `truncate_all_tables.sql` | Util | 전체 데이터 초기화 (개발 전용) |

## 테이블 구조 (총 19개)

| 영역 | 테이블 | 수 |
|------|--------|-----|
| 공통 | common_code_group, common_code, warehouse, item_master, shipper | 5 |
| 사용자 | adm_userinfo, adm_user_session | 2 |
| 입고 | twms_ib_inb_h, twms_ib_inb_d | 2 |
| 출고 | twms_ob_outb_h, twms_ob_outb_d | 2 |
| 재고 | twms_iv_lot, twms_iv_invn, twms_iv_invn_item, twms_iv_invn_lot_cell | 4 |
| 배치 | batch_job_log, batch_error_log | 2 |
| 이력 | status_change_history, screen_access_log | 2 |

## Function 목록 (총 9개)

| 함수 | 목적 |
|------|------|
| `fn_inbound_inspect` | 입고 검수 처리 (INB_SCD 00→10) |
| `fn_inbound_confirm` | 입고 확정 + 재고 반영 (INB_SCD 10→20) |
| `fn_inbound_cancel` | 입고 취소 (DEL_YN 처리) |
| `fn_outbound_allocate` | 출고 할당/지시 (가용재고 → 처리중) |
| `fn_outbound_pick` | 피킹 처리 (PICK_QTY 반영) |
| `fn_outbound_confirm` | 출고 확정 + 재고 차감 (OUTB_SCD→40) |
| `fn_outbound_cancel` | 출고 취소 + 재고 복원 |
| `fn_inventory_move` | 셀 간 재고 이동 |
| `fn_inventory_adjust` | 재고 수량 조정 (가용/처리중/재고) |

## 역할 및 사용자

| 역할 | 사용자 | 권한 |
|------|--------|------|
| `wms_admin_role` | `wms_admin` | 전체 관리 |
| `wms_developer_role` | `wms_developer` | CRUD + Function 실행 |
| `wms_api_role` | `wms_api` | CRUD + Function 실행 |
| `wms_readonly_role` | `wms_readonly` | 읽기 전용 |

## DBeaver 사용법

1. 새 데이터베이스 연결 생성
2. Host: `localhost`, Port: `5432`, Database: `wmsdb`
3. Username: `wms_admin`, Password: `Admin@123`
4. 연결 후 SQL 편집기에서 스크립트 실행

## 데이터 초기화

개발/테스트 환경에서 데이터를 초기화하려면:

```bash
psql -U wms_admin -d wmsdb -f truncate_all_tables.sql
```

초기화 후 공통코드와 샘플 데이터를 다시 넣으려면:

```bash
psql -U wms_admin -d wmsdb -f 14_insert_common_codes.sql
psql -U wms_admin -d wmsdb -f 15_insert_sample_data.sql
```

## PRD 참조

이 스키마는 `docs/01.analysis/01.rfp/wms_prd.md`를 기반으로 설계되었습니다.
MSSQL 기반의 원본 테이블 정의를 PostgreSQL로 변환하였으며, 주요 변환 규칙은 다음과 같습니다:

- `nvarchar(n)` → `varchar(n)`
- `datetime` → `timestamp`
- `float` → `double precision`
- `varbinary(32)` → `bytea`
- MSSQL 저장 프로시저 → PostgreSQL Function
- 복합 PK 구조 유지 (SERIAL 미사용)
