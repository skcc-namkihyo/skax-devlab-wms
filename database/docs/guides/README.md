# Database Guides

## 개요
이 폴더는 WMS(창고관리시스템)의 PostgreSQL 데이터베이스 설계, 구축, 관리를 위한 가이드 문서들을 포함합니다.

## 가이드 목록

### 1. 요구사항 기반 DB 설계 체크리스트
- **[requirements_based_design_guide.md](./requirements_based_design_guide.md)** - 요구사항(기획서, PRD 등)만으로 DB 구조를 설계할 때 반드시 확인해야 할 핵심 정보와 체크리스트

### 2. 모델링 워크플로우 가이드
- **[modeling_workflow.md](./modeling_workflow.md)** - 데이터베이스 설계 및 변경 시 따라야 할 단계별 프로세스와 산출물 흐름 안내

### 3. PostgreSQL 오브젝트 설계 가이드
- **[postgresql_object_guide.md](./postgresql_object_guide.md)** - PostgreSQL 오브젝트(테이블, 인덱스 등) 설계 및 생성 표준 가이드

### 4. 테이블 정의서 템플릿
- **[table_definition_template.md](./table_definition_template.md)** - 테이블 정의서 표준 템플릿 및 작성 가이드

### 5. 테이블 변경 관리 가이드
- **[table_change_management.md](./table_change_management.md)** - 테이블 변경 및 이력 관리 표준 가이드

### 6. DB 역할 및 사용자 관리 가이드
- **[db_roles_and_users.md](./db_roles_and_users.md)** - DB 사용자/역할/권한 관리 가이드

### 7. 역할 및 사용자 생성 SQL
- **[create_roles_and_users.sql](./create_roles_and_users.sql)** - 역할 및 사용자 생성 SQL 스크립트

### 8. 데이터 모델 품질 점검 가이드
- **[data_quality_schema_checklist_guide.md](./data_quality_schema_checklist_guide.md)** - 데이터 모델(ERD/DDL/정의서) 품질 점검용 체크리스트 및 가이드

### 9. 실데이터 품질 점검 가이드
- **[data_quality_data_checklist_guide.md](./data_quality_data_checklist_guide.md)** - 운영/테스트 DB 등 실데이터 품질 점검용 체크리스트 및 가이드

## 사용 방법

### 새 테이블 생성 시
1. `postgresql_object_guide.md`의 명명 규칙과 설계 원칙을 따라 테이블 설계
2. `table_definition_template.md` 템플릿을 사용하여 테이블 정의서 작성
3. 해당 스키마 폴더에 정의서 저장

### 데이터베이스 초기 설정 시
1. `create_roles_and_users.sql` 스크립트 실행하여 역할 및 사용자 생성
2. `db_roles_and_users.md`를 참조하여 추가 권한 설정

### 개발 환경 구축 시
1. PostgreSQL 설치 후 `postgresql_object_guide.md`의 설정 가이드 참조
2. 스키마별 DDL 스크립트 실행
3. 역할 및 사용자 설정

## 스키마별 정보

### wms (Warehouse Management System)
- **목적**: WMS 창고관리시스템의 핵심 비즈니스 로직 관리
- **주요 도메인**:
  - **공통 관리**: common_code_group, common_code
  - **사용자 관리**: adm_userinfo, adm_user_session
  - **마스터 관리**: warehouse, item_master, shipper
  - **입고 관리**: twms_ib_inb_h (입고 헤더), twms_ib_inb_d (입고 상세)
  - **출고 관리**: twms_ob_outb_h (출고 헤더), twms_ob_outb_d (출고 상세)
  - **재고 관리**: twms_iv_lot, twms_iv_invn, twms_iv_invn_item, twms_iv_invn_lot_cell
  - **배치/로그**: batch_job_log, batch_error_log, status_change_history, screen_access_log

## 참고 자료
- [테이블 정의서 목록](../table_definitions/README.md)
- [DDL 스크립트](../../schemas/)
- [ERD 다이어그램](../../schemas/)

## 문서 관리
- 모든 가이드 문서는 Markdown 형식으로 작성
- 변경 시 관련 문서들의 일관성 유지 필요
- 예시 코드는 실제 동작하는 코드로 작성

---

> 이 가이드들은 WMS(창고관리시스템)의 데이터베이스 설계 및 관리 표준을 정의합니다. 새로운 개발이나 변경 시 반드시 이 가이드들을 참조하여 일관성을 유지해주세요.