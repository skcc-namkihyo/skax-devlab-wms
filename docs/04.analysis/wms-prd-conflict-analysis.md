# WMS PRD 충돌 분석 보고서

**작성일**: 2026-02-24  
**분석 대상**: `docs/01.analysis/01.rfp/wms_prd.md`  
**비교 대상**: 프로젝트 내 기존 파일 전체

---

## 1. 개요

본 문서는 `wms_prd.md`(WMS 기존 기능 개선 PRD)가 이 레포지토리의 기존 파일들과 내용 충돌이 없는지 분석한 결과를 기술한다.

### 1.1 분석 결론

> **⚠️ 심각한 충돌 존재**
>
> `wms_prd.md`와 기존 파일들은 **완전히 다른 두 개의 프로젝트**를 기술하고 있어, 다수의 항목에서 근본적인 충돌이 확인되었다.

| 항목 | `wms_prd.md` | 기존 파일들 |
|------|-------------|------------|
| 시스템명 | WMS (창고관리시스템) | 자동차 정비 예약 시스템 (Car Center) |
| 프로젝트 성격 | 기존 운영 시스템 개선 | 신규 시스템 개발 |
| 업무 도메인 | 물류센터 입·출고, 재고 관리 | 차량 정비 예약, 정비소, 사용자 관리 |

---

## 2. 충돌 상세 분석

### 2.1 기술 스택 충돌 (치명적)

`wms_prd.md` 섹션 11.1, 10.3, 6.1과 `.cursor/.rules/backend.dev.instructions.mdc`, `database/schemas/*.sql` 간의 충돌.

| 항목 | `wms_prd.md` | 기존 파일 (backend.dev.instructions.mdc) | 충돌 여부 |
|------|-------------|----------------------------------------|----------|
| **DBMS** | MSSQL (Korean_Wansung_CI_AS 정렬) | PostgreSQL 17.x | ✅ 충돌 |
| **프론트엔드** | Nexacro | Vue 3 | ✅ 충돌 |
| **인증 방식** | 세션(Session) 기반 인증 | JWT 기반 인증 | ✅ 충돌 |
| **API 구조** | REST API 미사용 | REST API 사용 | ✅ 충돌 |
| **데이터 처리** | 저장 프로시저(Stored Procedure) 중심 | MyBatis Mapper XML | ✅ 충돌 |
| **데이터 전달** | Map<String, Object> | Map<String, Object> | ✅ 일치 |

**근거 — `wms_prd.md` 섹션 10.3**:
> "REST API 구조는 사용하지 않는다."

**근거 — `backend.dev.instructions.mdc` 섹션 3.1**:
> "프레임워크: Spring Boot 3.5.4 / 데이터베이스: PostgreSQL 17.x"

---

### 2.2 패키지 구조 충돌

`wms_prd.md` 섹션 10.2와 `.cursor/.rules/backend.dev.instructions.mdc` 섹션 3.2 간의 충돌.

**`wms_prd.md`가 정의한 패키지 구조**:
```
com.execnt
├── adm/       # 전역 설정, 사용자 관리, 배치 스케쥴러 등
├── bms/       # 실적 관리
├── mdm/       # 마스터 관리
├── oms/       # 주문 관리
├── session/   # 세션 관리
├── vms/       # 시각화 관리
└── wms/       # 창고 관리 (입출고, 재고 관리)
```

**기존 파일이 정의한 패키지 구조** (`backend.dev.instructions.mdc` 섹션 3.2):
```
com.carfix
├── config/         # Spring 설정
├── common/         # 공통 모듈 (예외 처리, 유틸리티)
├── auth/           # 인증/인가 (JWT)
└── domain/
    ├── user/       # 사용자 관리
    ├── auth/       # 인증 API
    ├── vehicle/    # 차량 관리
    ├── reservation/ # 예약 관리
    └── servicecenter/ # 정비소 관리
```

**충돌 요약**: 루트 패키지명(`com.execnt` vs `com.carfix`), 구조 방식(기능 모듈형 vs 도메인 계층형) 모두 상이.

---

### 2.3 데이터베이스 스키마 충돌

`wms_prd.md` 섹션 11.2와 `database/schemas/*.sql` 간의 충돌.

| 항목 | `wms_prd.md` | `database/schemas/*.sql` | 충돌 여부 |
|------|-------------|--------------------------|----------|
| **DBMS** | MSSQL | PostgreSQL | ✅ 충돌 |
| **스키마명** | `TLSDB.dbo` | `carfix` | ✅ 충돌 |
| **테이블명 형식** | 대문자 (`TWMS_IB_INB_H`) | 소문자 (`user`, `vehicle`) | ✅ 충돌 |
| **PK 방식** | IDENTITY 컬럼 | SERIAL / SEQUENCE | ✅ 충돌 |
| **문자열 타입** | `nvarchar` | `varchar` / `text` | ✅ 충돌 |
| **날짜 타입** | `datetime` | `timestamp` | ✅ 충돌 |

**`wms_prd.md`가 정의한 주요 테이블** (MSSQL 기반):
- `ADM_USERINFO` — 사용자 정보
- `TWMS_IB_INB_H` / `TWMS_IB_INB_D` — 입고 헤더/상세
- `TWMS_OB_OUTB_H` / `TWMS_OB_OUTB_D` — 출고 헤더/상세
- `TWMS_IV_LOT` / `TWMS_IV_INVN` — 재고 LOT/수량

**기존 `database/schemas/*.sql`이 정의한 주요 테이블** (PostgreSQL 기반):
- `user`, `refresh_token` — 사용자/인증
- `vehicle` — 차량
- `reservation` — 예약
- `service_center` — 정비소

---

### 2.4 인증 방식 충돌

| 항목 | `wms_prd.md` (섹션 12.1) | 기존 Task 정의서 / Cursor Rules | 충돌 여부 |
|------|-------------------------|-------------------------------|----------|
| **인증 방식** | 세션(Session) 기반 인증 | JWT 기반 인증 | ✅ 충돌 |
| **인증 유지** | 서버 세션 | Access Token + Refresh Token | ✅ 충돌 |
| **사용자 유형** | 물류센터 사용자, 화주 사용자, 센터 관리자, IT 관리자 | CUSTOMER, BUSINESS | ✅ 충돌 |

---

### 2.5 API 응답 형식 충돌

기존 파일들 사이에도 `success` 필드 포함 여부에 관한 내부 불일치가 존재한다.

| 파일 | 정의한 응답 형식 | 충돌 여부 |
|------|----------------|----------|
| `wms_prd.md` | REST API 미사용 — 응답 형식 정의 없음 | ✅ 충돌 |
| `car-center-001.사용자관리.task.md` (섹션 3.3) | `{success, result_code, result_message, data}` | ⚠️ 내부 불일치 |
| `README.md` (주의사항 섹션) | `{result_code, result_message, data}` (`success` 필드 없음) | ⚠️ 내부 불일치 |
| `backend.dev.instructions.mdc` (섹션 3.7.6) | `{result_code, result_message, data}` (`success` 필드 없음) | ✅ README와 일치 |

> **추가 발견**: `car-center-001.사용자관리.task.md`는 `success` 필드를 포함하고 있으나, `README.md`와 `backend.dev.instructions.mdc`는 `success` 필드를 명시적으로 제외하고 있다. Task 정의서와 Cursor Rules 간에도 불일치가 존재한다.

---

### 2.6 업무 도메인 충돌

`wms_prd.md`의 WMS 업무 도메인과 기존 Task 정의서들의 Car Center 도메인은 완전히 상이하다.

| 기존 Task 정의서 | 도메인 | `wms_prd.md` 관련성 |
|----------------|--------|---------------------|
| `car-center-001.사용자관리.task.md` | 회원가입, 로그인, 프로필 관리 | ❌ 무관 |
| `car-center-002.차량정보관리.task.md` | 차량 정보 CRUD | ❌ 무관 |
| `car-center-003.정비소관리.task.md` | 정비소 등록 및 관리 | ❌ 무관 |
| `car-center-004.예약시스템.task.md` | 정비 예약 생성/조회/취소 | ❌ 무관 |
| `car-center-005.관리자시스템.task.md` | 관리자 대시보드 | ❌ 무관 |

`wms_prd.md`가 다루는 업무:
- 입고 주문 생성, 검수, 입고 확정
- 출고 주문 생성, 피킹, 출고 확정
- 재고 이동 및 배치 처리

---

## 3. 충돌 요약 매트릭스

| 충돌 항목 | 심각도 | 비고 |
|----------|--------|------|
| 프로젝트 도메인 (WMS vs Car Center) | 🔴 치명적 | 두 시스템은 별개의 프로젝트 |
| DBMS (MSSQL vs PostgreSQL) | 🔴 치명적 | 쿼리, 타입, 스키마 모두 상이 |
| 프론트엔드 프레임워크 (Nexacro vs Vue 3) | 🔴 치명적 | 개발 방식 전혀 다름 |
| 인증 방식 (세션 vs JWT) | 🔴 치명적 | 보안 아키텍처 전면 충돌 |
| API 구조 (미사용 vs REST API) | 🔴 치명적 | wms는 REST API 사용 안 함 |
| 패키지 구조 (`com.execnt` vs `com.carfix`) | 🔴 치명적 | 루트 패키지부터 상이 |
| 데이터 처리 (저장 프로시저 vs MyBatis) | 🔴 치명적 | 데이터 접근 방식 전면 충돌 |
| Task 정의서 도메인 불일치 | 🔴 치명적 | WMS 관련 Task 없음 |
| API 응답 형식 (`success` 필드 여부) | 🟡 경고 | 기존 파일 간 내부 불일치도 존재 |

---

## 4. 권장 조치

### 4.1 시나리오별 권장 방향

#### 시나리오 A: WMS를 별도 프로젝트로 분리 (권장)

`wms_prd.md`의 기술 스택(MSSQL, Nexacro, 세션 인증, 저장 프로시저)이 이 레포의 Car Center 기술 스택과 전면 충돌하므로, **별도 레포지토리 생성**을 강력 권장한다.

- 이 레포의 `.cursor/.rules/` 파일들은 전부 Car Center 기준이므로, WMS 개발 시 AI가 잘못된 지침을 참조할 위험이 있다.
- `database/schemas/*.sql`도 PostgreSQL 기반이므로 WMS 개발에 사용 불가하다.

#### 시나리오 B: WMS를 이 레포에서 개발

- `.cursor/.rules/backend.dev.instructions.mdc`를 WMS 기술 스택(MSSQL, 세션 인증, 저장 프로시저)에 맞게 별도 작성 필요
- `database/schemas/*.sql` 디렉토리를 WMS용으로 교체 또는 분리 필요
- 기존 Car Center Task 정의서와 WMS Task를 명확히 분리 관리 필요
- AI 혼선 방지를 위해 Cursor Rules에 프로젝트 구분 명시 필요

#### 시나리오 C: 단순 참고 문서로 보관

- 현재 위치(`docs/01.analysis/01.rfp/`)를 유지해도 되나, AI가 컨텍스트로 읽을 경우 혼선 가능성 존재
- 파일 상단에 이 문서가 별도 시스템의 PRD임을 명시하는 주석 추가 권장

---

### 4.2 추가 권장 — 기존 파일 내부 불일치 해소

`car-center-001.사용자관리.task.md`의 API 응답 형식에서 `success` 필드를 제거하여 `README.md` 및 `backend.dev.instructions.mdc`와 일치시킬 것을 권장한다.

**수정 전** (`car-center-001.task.md` 섹션 3.3):
```json
{
  "success": true,
  "result_code": "I0001",
  "result_message": "...",
  "data": { ... }
}
```

**수정 후** (README.md / backend.dev.instructions.mdc 기준):
```json
{
  "result_code": "I0001",
  "result_message": "...",
  "data": { ... }
}
```

---

## 5. 분석 대상 파일 목록

| 파일 경로 | 역할 |
|----------|------|
| `docs/01.analysis/01.rfp/wms_prd.md` | WMS 기능 개선 PRD (분석 대상) |
| `README.md` | 프로젝트 워크플로우 가이드 |
| `.cursor/.rules/backend.dev.instructions.mdc` | 백엔드 개발 Cursor Rules |
| `.cursor/.rules/postgresql-standard-rule.mdc` | PostgreSQL 표준 Cursor Rules |
| `database/schemas/*.sql` | PostgreSQL 기반 DB 스키마 |
| `docs/02.design/01.tasks/car-center-001.사용자관리.task.md` | Car Center Task 정의서 |
| `docs/02.design/01.tasks/car-center-002.차량정보관리.task.md` | Car Center Task 정의서 |
| `docs/02.design/01.tasks/car-center-003.정비소관리.task.md` | Car Center Task 정의서 |
| `docs/02.design/01.tasks/car-center-004.예약시스템.task.md` | Car Center Task 정의서 |
| `docs/02.design/01.tasks/car-center-005.관리자시스템.task.md` | Car Center Task 정의서 |
