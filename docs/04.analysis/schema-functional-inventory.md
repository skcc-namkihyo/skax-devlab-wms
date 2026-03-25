# DB 스키마 기능 목록 및 WMS 전환 분석

**작성일**: 2026-02-24  
**목적**: 현재 `database/schemas/*.sql`의 기능 목록 정리 + `wms_prd.md` 기반 WMS 전환 시 재작성 필요 항목 분석

---

## 1. 현재 스키마 실행 순서 및 파일 목록

| 순서 | 파일명 | 목적 |
|------|--------|------|
| 1 | `create_roles_and_users.sql` | DB 역할/사용자/데이터베이스 생성 |
| 2 | `create_schema.sql` | `carfix` 스키마 생성 및 권한 설정 |
| 3 | `create_tables_phase1_2.sql` | 사용자·차량·정비소 테이블 |
| 4 | `create_tables_phase3_reservation.sql` | 예약 테이블 |
| 5 | `create_tables_phase4_quote.sql` | 견적 테이블 |
| 6 | `create_tables_phase5_maintenance_process.sql` | 정비 프로세스 테이블 |
| 7 | `create_tables_phase6_notification.sql` | 알림·메시지 테이블 |
| 8 | `create_tables_phase7_payment.sql` | 결제 테이블 |
| 9 | `create_tables_phase8_review.sql` | 리뷰·평점 테이블 |
| 10 | `create_tables_phase9_admin.sql` | 관리자·공지사항 테이블 |
| 11 | `grant_api_schema_permissions.sql` | API 역할 권한 부여 |
| 기타 | `insert_sample_data.sql` | 샘플 데이터 삽입 |
| 기타 | `verify_sample_data.sql` | 샘플 데이터 검증 |
| 기타 | `truncate_all_tables.sql` | 전체 테이블 초기화 |
| 기타 | `update_user_passwords.sql` | 사용자 비밀번호 업데이트 |

---

## 2. 현재 스키마 기능 목록 (Car Center — PostgreSQL)

### 2.1 인프라 레이어 (`create_roles_and_users.sql`, `create_schema.sql`)

| 기능 | 객체명 | 내용 |
|------|--------|------|
| 역할 생성 | `carfix_admin_role` | DDL 전체 권한 |
| 역할 생성 | `carfix_developer_role` | SELECT/INSERT/UPDATE/DELETE |
| 역할 생성 | `carfix_api_role` | SELECT/INSERT/UPDATE/DELETE (API 전용) |
| 역할 생성 | `carfix_readonly_role` | SELECT 전용 (리포팅/분석) |
| 사용자 생성 | `carfix_admin` / `carfix_developer` / `carfix_api` / `carfix_readonly` | 각 역할별 DB 사용자 |
| 데이터베이스 | `carfixdb` | PostgreSQL 데이터베이스 |
| 스키마 | `carfix` | 전체 테이블 수용 스키마 |

---

### 2.2 Phase 1-2: 사용자·차량·정비소 (`create_tables_phase1_2.sql`)

#### 사용자 관련 (2개 테이블)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.user` | user_id, email(UQ), password, user_type_code, name, phone_number, address, preferred_service_center_ids(JSON), notification_settings(JSON), is_active | 사용자 기본 정보 및 설정 |
| `carfix.refresh_token` | refresh_token_id, user_id(FK), token, expires_at | JWT Refresh Token 관리 |

**인덱스**: email, user_type_code, is_active, token, expires_at

#### 차량 관련 (4개 테이블)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.vehicle` | vehicle_id, user_id(FK), license_number(UQ per user), manufacturer, model, year, engine_type_code, mileage | 차량 기본 정보 |
| `carfix.maintenance_history` | maintenance_history_id, vehicle_id(FK), reservation_id, service_type_code, description, mileage_at_service, service_date | 차량별 정비 이력 |
| `carfix.parts_replacement` | parts_replacement_id, maintenance_history_id(FK), part_name, part_number, quantity, unit_price, replaced_date | 부품 교체 이력 |
| `carfix.maintenance_alert` | maintenance_alert_id, vehicle_id(FK), alert_type_code, mileage_threshold, days_threshold, is_active | 정기점검 알림 설정 |

#### 정비소 관련 (5개 테이블)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.service_center` | service_center_id, user_id(FK), business_name, business_number(UQ), address, phone_number, latitude, longitude, is_active | 정비소 기본 정보 |
| `carfix.operating_hour` | operating_hour_id, service_center_id(FK), day_type_code(UQ per center), open_time, close_time, is_closed | 정비소 운영시간 |
| `carfix.service_item` | service_item_id, service_center_id(FK), item_code(UQ per center), item_name, standard_price, estimated_duration, is_available | 정비소 제공 서비스 항목 |
| `carfix.equipment` | equipment_id, service_center_id(FK), equipment_name, equipment_type_code, certification_number, certification_date, expiry_date | 정비소 보유 장비 |
| `carfix.mechanic` | mechanic_id, service_center_id(FK), name, phone_number, license_number, license_type, experience_years, is_active | 정비사 정보 |
| `carfix.mechanic_specialty` | mechanic_specialty_id, mechanic_id(FK), service_item_code(UQ per mechanic), proficiency_level(1-5 CHECK) | 정비사 전문 분야 |
| `carfix.mechanic_schedule` | mechanic_schedule_id, mechanic_id(FK), day_of_week_code(UQ per mechanic+date), start_time, end_time, is_available, effective_date, expiry_date | 정비사 근무 스케줄 |

---

### 2.3 Phase 3: 예약 (`create_tables_phase3_reservation.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.reservation` | reservation_id, user_id(FK), service_center_id(FK), vehicle_id(FK), reservation_number(UQ), reservation_date, reservation_time, status_code(PENDING→CONFIRMED→IN_PROGRESS→COMPLETED→CANCELLED), current_mileage, symptom_description, urgency_level | 예약 헤더 정보 |
| `carfix.reservation_detail` | reservation_detail_id, reservation_id(FK), service_item_code, service_item_name, estimated_price, estimated_duration | 예약별 정비 항목 상세 |
| `carfix.reservation_status_history` | status_history_id, reservation_id(FK), status_code, status_note, changed_at, changed_by | 예약 상태 변경 이력 |

**상태 흐름**: `PENDING → CONFIRMED → IN_PROGRESS → COMPLETED / CANCELLED`

---

### 2.4 Phase 4: 견적 (`create_tables_phase4_quote.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.quote` | quote_id, reservation_id(FK), service_center_id(FK), quote_number(UQ), status_code(DRAFT→PENDING→APPROVED→REJECTED→EXPIRED), total_amount, parts_amount, labor_amount, tax_amount, valid_until | 견적 헤더 |
| `carfix.quote_item` | quote_item_id, quote_id(FK), service_item_code, service_item_name, item_type_code(PARTS/LABOR), unit_price, quantity, subtotal, is_approved | 견적 항목 |
| `carfix.quote_status_history` | status_history_id, quote_id(FK), status_code, status_note, changed_at, changed_by | 견적 상태 변경 이력 |

---

### 2.5 Phase 5: 정비 프로세스 (`create_tables_phase5_maintenance_process.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.maintenance_process` | process_id, reservation_id(FK·UQ), status_code(RECEIVED→DIAGNOSING→QUOTE_PENDING→IN_PROGRESS→QUALITY_CHECK→COMPLETED), progress_percentage(0-100), current_step_description, expected_completion_time, actual_completion_time, vehicle_condition | 실시간 정비 진행 상태 |
| `carfix.maintenance_process_history` | history_id, process_id(FK), status_code, status_note, mechanic_comment, changed_at, changed_by | 정비 단계별 이력 |

---

### 2.6 Phase 6: 알림·메시지 (`create_tables_phase6_notification.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.notification` | notification_id, user_id(FK), reservation_id(FK·NULL가능), notification_type_code(RESERVATION/MAINTENANCE/QUOTE/MESSAGE), title, content, is_read, sent_at | 사용자 알림 |
| `carfix.message` | message_id, reservation_id(FK), sender_id(FK→user), receiver_id(FK→user), content, is_read, sent_at | 고객-정비소 간 메시지 |

---

### 2.7 Phase 7: 결제 (`create_tables_phase7_payment.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.payment` | payment_id, reservation_id(FK), quote_id(FK), payment_number(UQ), payment_method_code(CARD/ACCOUNT/PHONE/BANK_TRANSFER), payment_timing_code(PREPAID/PARTIAL/POSTPAID), status_code(PENDING→COMPLETED→FAILED→REFUNDED), total_amount, paid_amount, refund_amount, paid_at, refunded_at | 결제 정보 |
| `carfix.payment_history` | history_id, payment_id(FK), status_code, status_note, amount, changed_at, changed_by | 결제 상태 이력 |

---

### 2.8 Phase 8: 리뷰·평점 (`create_tables_phase8_review.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.review` | review_id, reservation_id(FK·UQ), service_center_id(FK), user_id(FK), rating(1-5 CHECK), content | 정비 완료 후 리뷰 |
| `carfix.review_reply` | reply_id, review_id(FK·UQ), service_center_id(FK), content | 정비소의 리뷰 답변 |

---

### 2.9 Phase 9: 관리자 (`create_tables_phase9_admin.sql`)

| 테이블명 | 주요 컬럼 | 기능 |
|----------|----------|------|
| `carfix.notice` | notice_id, title, content, is_important, is_active | 관리자 공지사항 |

---

### 2.10 전체 테이블 수 요약

| Phase | 도메인 | 테이블 수 |
|-------|--------|-----------|
| 1-2 | 사용자·차량·정비소 | 13개 |
| 3 | 예약 | 3개 |
| 4 | 견적 | 3개 |
| 5 | 정비 프로세스 | 2개 |
| 6 | 알림·메시지 | 2개 |
| 7 | 결제 | 2개 |
| 8 | 리뷰·평점 | 2개 |
| 9 | 관리자 | 1개 |
| **합계** | | **28개** |

---

## 3. WMS PRD 기반 재작성 필요 항목 분석

`wms_prd.md` 섹션 11.2에 명시된 실제 WMS 테이블과 현재 스키마를 비교한다.

### 3.1 WMS에서 필요한 테이블 vs 현재 스키마 대응 여부

#### 인프라 레이어

| WMS 필요 항목 | `wms_prd.md` 근거 | 현재 스키마 | 재작성 필요 |
|--------------|------------------|------------|------------|
| DB 역할/사용자 | 섹션 12.1 (자체 로그인) | carfix_* 역할 (PostgreSQL) | ✅ MSSQL 계정 구조로 재작성 |
| 스키마/데이터베이스 | 섹션 11.1 (MSSQL, TLSDB) | carfix 스키마 (PostgreSQL) | ✅ MSSQL DB로 전면 교체 |

#### 사용자 관리

| WMS 필요 테이블 | 현재 테이블 | 대응 여부 | 비고 |
|----------------|------------|----------|------|
| `ADM_USERINFO` | `carfix.user` | ❌ 불일치 | 컬럼 구조 전면 상이 (USERID, USERGROUPCODE, TEAMCODE, PW_ERR_CNT, LOCK_YN, JOB_USER_YN 등) |
| (세션 관리) | `carfix.refresh_token` | ❌ 불일치 | WMS는 JWT 미사용, 세션 기반 → refresh_token 테이블 불필요 |

#### 입고 관련

| WMS 필요 테이블 | 현재 테이블 | 대응 여부 | 비고 |
|----------------|------------|----------|------|
| `TWMS_IB_INB_H` (입고 헤더) | 없음 | ❌ 신규 | INB_NO, WH_CD, INB_SCD, INB_TCD, REF_NO, DATA_OCCR_TP 등 |
| `TWMS_IB_INB_D` (입고 상세) | 없음 | ❌ 신규 | INB_DETL_NO, ITEM_CD, INB_ECT_QTY, INB_CMPT_QTY, INSPCT_SCD 등 |

#### 출고 관련

| WMS 필요 테이블 | 현재 테이블 | 대응 여부 | 비고 |
|----------------|------------|----------|------|
| `TWMS_OB_OUTB_H` (출고 헤더) | 없음 | ❌ 신규 | OUTB_NO, WH_CD, OUTB_SCD, OUTB_TCD, WAVE_NO 등 |
| `TWMS_OB_OUTB_D` (출고 상세) | 없음 | ❌ 신규 | OUTB_DETL_NO, PICK_QTY, LALOC_QTY, LALOC_SCD 등 |

#### 재고 관련

| WMS 필요 테이블 | 현재 테이블 | 대응 여부 | 비고 |
|----------------|------------|----------|------|
| `TWMS_IV_LOT` (LOT 마스터) | 없음 | ❌ 신규 | LOT_NO, WH_CD, ITEM_CD, PRDT_LOT_NO, INVN_SCD 등 |
| `TWMS_IV_INVN` (재고 셀 단위) | 없음 | ❌ 신규 | WH_CD, WCELL_NO, LOT_NO, INVN_QTY |
| `TWMS_IV_INVN_ITEM` (품목 단위 재고) | 없음 | ❌ 신규 | ITEM_CD, AVLB_QTY, PRCS_QTY |
| `TWMS_IV_INVN_LOT_CELL` (LOT×셀 재고) | 없음 | ❌ 신규 | LOT_NO, WCELL_NO, AVLB_QTY, PRCS_QTY |

---

### 3.2 WMS 추가 필요 추정 테이블 (PRD 섹션 3~5 기반)

`wms_prd.md`에 명시되지 않았으나 업무 흐름상 필요한 테이블:

| 추정 테이블 | 목적 | 근거 섹션 |
|------------|------|----------|
| 배치 처리 로그 테이블 | 배치 오류 식별, 재처리 이력 | 섹션 5.3 |
| 상태 변경 이력 테이블 | 고객 문의 대응용 상태 추적 | 섹션 8.3 |
| 공통 코드 테이블 | 상태값(INB_SCD, OUTB_SCD 등) 코드 관리 | 섹션 3.4 |
| 화면 조회/다운로드 이력 | 개인정보 포함 화면 이력 관리 | 섹션 8.2 |

---

### 3.3 현재 스키마 중 WMS에서 재사용 불가 항목

아래 테이블들은 Car Center 전용이므로 WMS SQL 재작성 시 포함하지 않아야 한다.

| 현재 테이블 | 이유 |
|------------|------|
| `carfix.vehicle` | 차량 도메인 — WMS 무관 |
| `carfix.maintenance_*` | 정비 이력/프로세스 — WMS 무관 |
| `carfix.service_center` / `carfix.service_item` | 정비소 도메인 — WMS 무관 |
| `carfix.reservation` | 예약 시스템 — WMS 무관 |
| `carfix.quote` / `carfix.payment` | 견적·결제 — WMS 무관 |
| `carfix.review` | 리뷰 — WMS 무관 |
| `carfix.notification` / `carfix.message` | Car Center 알림 — WMS 무관 |
| `carfix.refresh_token` | JWT 기반 — WMS는 세션 기반 인증 |
| `carfix.mechanic` | 정비사 — WMS 무관 |
| `carfix.notice` | Car Center 공지 — WMS 전용으로 재작성 필요 |

---

## 4. WMS SQL 재작성 시 권장 파일 구조

`wms_prd.md` 기반으로 WMS용 SQL을 별도로 작성할 경우 아래 구조를 권장한다.

```
database/wms-schemas/
├── 01_create_database.sql          # MSSQL DB 및 로그인 계정 생성
├── 02_create_users_table.sql       # ADM_USERINFO (사용자 관리)
├── 03_create_common_code_table.sql # 공통 코드 테이블 (상태값 등)
├── 04_create_inbound_tables.sql    # TWMS_IB_INB_H / TWMS_IB_INB_D (입고)
├── 05_create_outbound_tables.sql   # TWMS_OB_OUTB_H / TWMS_OB_OUTB_D (출고)
├── 06_create_inventory_tables.sql  # TWMS_IV_LOT / TWMS_IV_INVN 계열 (재고)
├── 07_create_batch_log_tables.sql  # 배치 처리 로그 / 오류 이력
├── 08_create_status_history.sql    # 상태 변경 이력 (운영 대응용)
├── 09_create_screen_log.sql        # 화면 조회/다운로드 이력 (개인정보)
└── 10_insert_sample_data.sql       # 초기 공통 코드 및 테스트 데이터
```

---

## 5. MSSQL vs PostgreSQL 문법 변환 참고

WMS SQL을 MSSQL로 재작성 시 주요 문법 차이:

| 항목 | 현재 (PostgreSQL) | WMS 재작성 (MSSQL) |
|------|------------------|-------------------|
| 자동증가 PK | `SERIAL PRIMARY KEY` | `INT IDENTITY(1,1) PRIMARY KEY` |
| 문자열 타입 | `VARCHAR(n)` | `nvarchar(n)` |
| 불리언 타입 | `BOOLEAN` | `nvarchar(1)` (`'Y'`/`'N'`) |
| 날짜/시각 타입 | `TIMESTAMP` | `datetime` |
| 현재 시각 기본값 | `DEFAULT CURRENT_TIMESTAMP` | `DEFAULT getdate()` |
| IF NOT EXISTS | `CREATE TABLE IF NOT EXISTS` | `IF NOT EXISTS (SELECT...) CREATE TABLE` |
| 스키마명 | `carfix.테이블명` | `TLSDB.dbo.테이블명` |
| 병합 구문 | 미사용 | `MERGE` 문 사용 (`wms_prd.md` 섹션 11.1) |
| 정렬 | 기본 정렬 | `COLLATE Korean_Wansung_CI_AS` |
| 문자 인코딩 | UTF-8 | `nvarchar` (유니코드 내장) |
