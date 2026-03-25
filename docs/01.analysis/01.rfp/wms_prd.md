# WMS 기존 기능 개선 PRD

 

## 1. 문서 개요

 

### 1.1 문서 목적

본 문서는 현재 운영 중인 WMS 시스템의 안정적인 운영을 위한 기능 개선과 보완을 목적으로 한다.

 

주요 목적은 다음과 같다.

 

- 고객 요청에 따른 기존 기능 개선

- 운영 중 발생한 오류 및 예외 상황 보완

- 사용자의 오입력 및 오동작으로 인한 문제 최소화

- 상태 변경 및 처리 흐름에 대한 가시성 확보

- 향후 유사 요청에 대한 대응력 강화

 

본 변경은 기존 WMS 핵심 프로세스를 유지하는 범위 내에서 진행된다.

 

### 1.2 적용 범위

- 신규 화면 추가

- 기존 화면 일부 수정

- 입·출고 주문 생성 배치 로직 보완

- 내부 처리 로직 및 인터페이스 개선

- 테이블 구조 변경 가능 

  (단, 본 PRD를 기반으로 Cursor AI가 수행하는 개발 범위에는 테이블 변경은 포함하지 않으며, 테이블 변경은 운영자가 직접 수행한다)

 

### 1.3 용어 정의

- WMS: 창고관리시스템

- 입고 주문: 외부 시스템에서 전달된 입고 요청 데이터

- 출고 주문: 외부 시스템에서 전달된 출고 요청 데이터

  (일부 입,출고 주문은 사용자가 직접 생성)

- 상태값: 업무 단계 진행을 나타내는 공통 코드 값

 

---

 

## 2. 시스템 현황 및 운영 맥락

 

### 2.1 WMS 시스템 개요

본 시스템은 물류센터 단위로 운영되는 WMS로, 

입·출고 주문은 외부 시스템에서 전달되며, 내부에서는 배치 처리를 통해 주문이 생성된다.

 

### 2.2 현재 운영 프로세스 요약

WMS의 핵심 프로세스는 다음과 같다.

 

1. 입고 주문 생성

2. 검수

3. 입고 확정

4. 재고 이동

5. 출고 주문 생성

6. 피킹

7. 출고 확정

 

본 개선 작업은 위 프로세스 흐름 자체를 변경하지 않는다.

 

### 2.3 기존 시스템 제약 사항

- 레거시 구조 기반 시스템

- Nexacro 기반 화면 구성

- Map<String, Object> 중심 데이터 처리

- 저장 프로시저 중심의 데이터 및 상태 처리

 

### 2.4 개선 필요 배경

운영 중 다음과 같은 이슈가 반복적으로 발생하고 있다.

 

- 사용자의 잘못된 조작으로 인한 상태 오류

- 상태 전환 사유 파악의 어려움

- 고객 문의 발생 시 원인 분석에 소요되는 시간 증가

- 단순 오류임에도 운영 개입이 필요한 상황 발생

 

본 개선은 이러한 운영 부담을 완화하는 데 목적이 있다.

 

---

 

## 3. 업무 도메인 및 프로세스 설명

 

### 3.1 물류 도메인 구조

- 상품 단위 관리

- 물류센터 단위 운영

- 입·출고 주문은 외부 시스템 연계

 

### 3.2 입고 프로세스 흐름

- 외부 시스템에서 입고 주문 데이터 수신

- 정기 배치를 통해 WMS 입고 주문 생성

- 검수 → 입고 확정 단계 진행

 

### 3.3 출고 프로세스 흐름

- 외부 시스템에서 출고 주문 데이터 수신

- 정기 배치를 통해 WMS 출고 주문 생성

- 피킹 → 출고 확정 단계 진행

 

### 3.4 상태값 관리

- 상태값은 공통 코드 테이블을 통해 관리

- 상태값은 입출고 프로세스가 진행됨에 따라 각 단계별 변경

   (저장 프로시저 포함)

 

---

 

## 4. 개선 대상 기능 범위

 

### 4.1 화면 개선 대상

- 기존 화면 내 사용성 개선

- 오류 발생 가능성이 높은 입력 항목 보완

- 상태 변경 시 사용자 인지 강화

 

### 4.2 배치 처리 개선 대상

- 입·출고 주문 생성 배치 안정성 강화

- 예외 데이터 발생 시 오류 식별 개선

 

### 4.3 내부 로직 개선 대상

- 저장 프로시저 처리 흐름 정리

- 상태 변경 로직 명확화

 

### 4.4 제외 범위

- 신규 업무 프로세스 추가

- 대규모 시스템 구조 변경

 

---

 

## 5. 입·출고 주문 배치 처리

 

### 5.1 배치 처리 방식

- 입·출고 주문 생성은 정기 배치 방식으로 수행된다.

- 수동 배치 실행 기능은 제공하지 않는다. (로컬 환경 테스트,디버깅 용도에 한해 가능)

 

### 5.2 재처리 기능

- 배치 재처리 기능은 기존에 존재한다.

- 본 개선에서는 재처리 기능의 흐름은 유지한다.

 

### 5.3 예외 상황 대응

- 배치 처리 중 오류 발생 시 오류 원인 식별이 가능하도록 개선한다.

- 재처리 시 중복 처리 가능성을 최소화한다.

 

---

 

## 6. 화면 및 사용자 인터랙션

 

### 6.1 Nexacro 화면 구조

- 화면 → 컨트롤러 → 서비스 → 맵퍼 구조

- 화면 단에서 Map<String, Object> 형태로 데이터 전달

 

### 6.2 사용자 오입력 대응

- 상태 변경과 연관된 버튼 및 기능에 대해 사용자 인지 강화

  (*상태 변경이라 함은 입고 검수,취소,삭제,출고 지시,취소,삭제 등 WMS관련 모든 변경을 뜻함)

- 잘못된 조작 시 즉시 확인 가능한 피드백 제공

 

### 6.3 상태 변경 인지

- 상태 변경이 발생하는 경우 사용자에게 명확히 인지 가능하도록 한다.

 

---

 

## 7. 상태 변경 및 데이터 처리

 

### 7.1 상태 변경 처리 방식

- 상태 변경은 저장 프로시저 내에서 데이터 저장과 함께 처리된다.

- 상태 변경만 단독으로 수행하는 구조는 사용하지 않는다.

 

### 7.2 상태 전환 조건

- 각 상태 전환은 기존 업무 규칙을 따른다.

- 불필요한 상태 역행은 허용하지 않는다.

 

### 7.3 오류 발생 시 처리

- 상태 변경 중 오류 발생 시 데이터 불일치가 발생하지 않도록 한다.

 

---

 

## 8. 이력 및 로그 관리

 

### 8.1 이력 관리 기준

- 모든 상태 변경에 대해 이력을 기록하지 않는다.

- 일부 주요 단계에 대해서만 이력 테이블을 사용한다.

 

### 8.2 화면 이력

- 개인정보 포함 화면에 대해서는 조회 및 다운로드 이력을 관리한다.

 

### 8.3 운영 대응 목적 로그

- 고객 문의 대응을 위해 상태 변경 흐름 추적이 가능하도록 고려한다.

 

---

 

## 9. 프론트엔드 처리 구조

 

### 9.1 Nexacro 화면 구조

- Nexacro 기반 화면

- 화면 → 컨트롤러 → 서비스 → 맵퍼 구조

- 화면 단에서 Map<String, Object> 형태로 데이터 전달

 

### 9.2 공통 처리 방식

- 공통 조회 로직은 사용하지 않는다.

- 저장 및 상태 변경은 저장 프로시저 호출을 통해 수행한다.

- 사내 공통 프레임워크를 함께 사용한다.

 

---

 

## 10. 백엔드 패키지 구조

 

### 10.1 패키지 구조 개요

본 시스템은 Java 및 Spring 기반의 레거시 구조를 사용하며, 

기존 패키지 구조를 유지하는 것을 원칙으로 한다.

 

### 10.2 패키지 구성

 

com.execnt

├── adm/

│   ├── ctr/         # 전역 설정 (Security, Swagger 등)

│   │   ├── common/         # 공통코드, 조회조건 등

│   │   ├── scheduler/         # 배치 스케쥴러

│   │   ├── security/         # 로그, 사용자 그룹 등

│   │   ├── user/         # 사용자 관리

├─ └─ └── dao/      # DAO

├── bms/              # 실적 관리

├── mdm/              # 마스터 관리

├── oms/           # 주문 관리

├── session/              # 세션 관리

├── vms/           # 시각화 관리

└── wms/       # 창고 관리(입출고,재고 관리)

 

### 10.3 개발 유의사항

- 신규 패키지 생성은 최소화한다.

- 기존 패키지 내 기능 확장을 우선 고려한다.

- REST API 구조는 사용하지 않는다.

 

---

 

## 11. DB 및 데이터베이스 처리

 

### 11.1 DBMS 특성

- MSSQL 사용

- IDENTITY 컬럼 사용

- MERGE 구문 사용

- 트리거 미사용

- 저장 프로시저 기반 처리

 

### 11.2 테이블 구조 개요

 

#### 11.2.1 사용자 테이블

CREATE TABLE ADM_USERINFO (

USERID nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

COMPANY nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

USERGROUPCODE nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

TEAMCODE nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

USERNAME nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

PASSWORD varbinary(32) NULL,

EMAIL nvarchar(60) COLLATE Korean_Wansung_CI_AS NULL,

TEL nvarchar(40) COLLATE Korean_Wansung_CI_AS NULL,

CELLPHONE nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

USE_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime DEFAULT getdate() NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime DEFAULT getdate() NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

PW_ERR_CNT int DEFAULT 0 NULL,

VALIDSDATE nvarchar(14) COLLATE Korean_Wansung_CI_AS NULL,

VALIDEDATE nvarchar(14) COLLATE Korean_Wansung_CI_AS NULL,

PASSWORD_UPD_DATETIME nvarchar(14) COLLATE Korean_Wansung_CI_AS NULL,

ASSIGN_GRP nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

IP nvarchar(100) COLLATE Korean_Wansung_CI_AS NULL,

OLDPASSWORD nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

OLDPASSWORD2 nvarchar(32) COLLATE Korean_Wansung_CI_AS NULL,

LOGIN_DATE datetime NULL,

LOCK_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

PERSONAL_INFO_HANDLER_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

JOB_USER_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

CONSTRAINT ADM_USERINFO_PK PRIMARY KEY (USERID)

 

 

#### 11.2.2 입고 관련 테이블

CREATE TABLE TLSDB.dbo.TWMS_IB_INB_H (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

INB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

REF_NO nvarchar(32) COLLATE Korean_Wansung_CI_AS NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INB_TCD nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT '0' NULL,

INB_ECT_DATE datetime DEFAULT getdate() NULL,

INB_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS DEFAULT '00' NULL,

DEL_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

OUTB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

CUST_ID nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

SHIPTO_ID nvarchar(51) COLLATE Korean_Wansung_CI_AS NULL,

SUPPR_ID nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INB_DATE datetime NULL,

CLOSE_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

INB_WORK_TCD nvarchar(10) COLLATE Korean_Wansung_CI_AS DEFAULT '0' NULL,

USER_COL_1 nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

USER_COL_2 nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

USER_COL_3 nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

USER_COL_4 nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

USER_COL_5 nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime DEFAULT getdate() NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime DEFAULT getdate() NULL,

SHIPPER_ADDR_1 nvarchar(128) COLLATE Korean_Wansung_CI_AS NULL,

INB_CNTR_DATETIME datetime NULL,

REF_DT nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_ORG_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_RNP_TYP_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_DETL_NO float NULL,

ROUTE_CD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INB_SO_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

ORG_CD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

DATA_OCCR_TP nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

ZCLOSE nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

PART_INB nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

CONSTRAINT IDX_TWMS_IB_INB_H_PK PRIMARY KEY (INB_NO,WH_CD)

);

 

CREATE TABLE TLSDB.dbo.TWMS_IB_INB_D (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

INB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

INB_DETL_NO int DEFAULT 0 NOT NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

ITEM_CD nvarchar(45) COLLATE Korean_Wansung_CI_AS NULL,

PRDT_LOT_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INB_ECT_QTY float DEFAULT 0 NULL,

INB_CMPT_QTY float DEFAULT 0 NULL,

INB_CANCL_QTY float DEFAULT 0 NULL,

INB_DETL_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS DEFAULT '00' NULL,

DEL_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

OUTB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INVN_SCD nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT '1' NULL,

RMK nvarchar(2000) COLLATE Korean_Wansung_CI_AS NULL,

REF_NO nvarchar(32) COLLATE Korean_Wansung_CI_AS NULL,

REF_DETL_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

ITEM_SCD nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INFR_QTY float DEFAULT 0 NULL,

ITEM_STRG_CD nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT N'EA' NULL,

CLOSE_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL,

PRDT_DATE datetime NULL,

LOT_ATTR_1 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_2 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_3 nvarchar(400) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_4 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_5 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_6 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime DEFAULT getdate() NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime DEFAULT getdate() NULL,

REF_DT nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_ORG_CD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

REF_RNP_TYP_CD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

SER_GRP_NO numeric(28,0) NULL,

INSPCT_SCD nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT '00' NULL,

TO_WCELL_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

DETL_INB_DATE datetime NULL,

PART_INB nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NULL

CONSTRAINT IDX_TWMS_IB_INB_D_PK PRIMARY KEY (INB_NO,INB_DETL_NO,WH_CD)

);

 

 

 

#### 11.2.3 출고 관련 테이블

CREATE TABLE TWMS_OB_OUTB_H (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

OUTB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

REF_NO nvarchar(32) COLLATE Korean_Wansung_CI_AS NULL,

REF_DT nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_ORG_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_RNP_TYP_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_TCD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_WORK_TCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_ECT_DATE datetime NULL,

OUTB_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

DEL_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

CUST_ID nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

SHIPTO_ID nvarchar(51) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_DATE datetime NULL,

ROUTE_CD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

WAVE_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime NULL

ITEMWAVE_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS DEFAULT 'N' NOT NULL,

CONSTRAINT IDX_TWMS_OB_OUTB_H_PK PRIMARY KEY (OUTB_NO,WH_CD)

);

 

CREATE TABLE TLSDB.dbo.TWMS_OB_OUTB_D (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

OUTB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

OUTB_DETL_NO int NOT NULL,

ITEM_CD nvarchar(45) COLLATE Korean_Wansung_CI_AS NULL,

PRDT_LOT_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

ORDER_QTY float NULL,

OUTB_CMPT_QTY float NULL,

CANCL_QTY float NULL,

LALOC_QTY float NULL,

PICK_QTY float NULL,

SHIPTO_ID nvarchar(51) COLLATE Korean_Wansung_CI_AS NULL,

LALOC_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_DETL_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

DEL_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

INVN_SCD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_SCAN_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

RMK nvarchar(2000) COLLATE Korean_Wansung_CI_AS NULL,

REF_NO nvarchar(32) COLLATE Korean_Wansung_CI_AS NULL,

LALOC_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

LALOC_DATETIME datetime NULL,

INB_DATE datetime NULL,

INB_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_1 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_2 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_3 nvarchar(400) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_4 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_5 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_6 nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

ITEM_STRG_CD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime NULL,

REF_DT nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_ORG_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

REF_RNP_TYP_CD nvarchar(8) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_SO_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

OUTB_SO_DETL_NO int NULL,

SCAN_QTY float NULL,

TIMS_SEND_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

POLCA_SEND_SCD nvarchar(10) COLLATE Korean_Wansung_CI_AS NULL,

TIMS_SEND_DATETIME datetime NULL,

POLCA_SEND_DATETIME datetime NULL,

SMS_BOX_SEND_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

SMS_UNIT_SEND_YN nvarchar(1) COLLATE Korean_Wansung_CI_AS NULL,

PICK_BOX_QTY float NULL,

PICK_UNIT_QTY float NULL,

WAVE_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

PRNT_JOB_NO nvarchar(14) COLLATE Korean_Wansung_CI_AS NULL,

CONSTRAINT IDX_TWMS_OB_OUTB_D_PK PRIMARY KEY (OUTB_NO,OUTB_DETL_NO,WH_CD)

);

 

 

 

#### 11.2.4 재고 테이블

CREATE TABLE TLSDB.dbo.TWMS_IV_LOT (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

LOT_NO nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

ITEM_CD nvarchar(45) COLLATE Korean_Wansung_CI_AS NULL,

PRDT_LOT_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

VALID_DATETIME datetime NULL,

INB_DATE datetime NULL,

PRDT_DATE datetime NULL,

INVN_SCD nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

SRC_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NULL,

LOT_ATTR_1 nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

LOT_ATTR_2 nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

LOT_ATTR_3 nvarchar(400) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

LOT_ATTR_4 nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

LOT_ATTR_5 nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

LOT_ATTR_6 nvarchar(20) COLLATE Korean_Wansung_CI_AS DEFAULT 'NULL' NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime DEFAULT getdate() NULL,

CONSTRAINT IDX_TWMS_IV_LOT_PK PRIMARY KEY (WH_CD,LOT_NO)

)

 

CREATE TABLE TLSDB.dbo.TWMS_IV_INVN (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

WCELL_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

LOT_NO nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

INVN_QTY float DEFAULT 0 NULL,

INS_DATETIME datetime NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

CONSTRAINT IDX_TWMS_IV_INVN_PK PRIMARY KEY (WH_CD,WCELL_NO,LOT_NO)

);

 

CREATE TABLE TLSDB.dbo.TWMS_IV_INVN_ITEM (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

LOT_NO nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

ITEM_CD nvarchar(45) COLLATE Korean_Wansung_CI_AS NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS DEFAULT '0' NULL,

INVN_QTY float DEFAULT 0 NULL,

AVLB_QTY float DEFAULT 0 NULL,

PRCS_QTY float DEFAULT 0 NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime NULL,

CONSTRAINT IDX_TWMS_IV_INVN_ITEM_PK PRIMARY KEY (WH_CD,LOT_NO)

);

 

CREATE TABLE TLSDB.dbo.TWMS_IV_INVN_LOT_CELL (

WH_CD nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

LOT_NO nvarchar(30) COLLATE Korean_Wansung_CI_AS NOT NULL,

WCELL_NO nvarchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,

ITEM_CD nvarchar(45) COLLATE Korean_Wansung_CI_AS NULL,

STRR_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INVN_QTY float DEFAULT 0 NULL,

AVLB_QTY float DEFAULT 0 NULL,

PRCS_QTY float DEFAULT 0 NULL,

INS_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

INS_DATETIME datetime DEFAULT getdate() NULL,

UPD_PERSON_ID nvarchar(30) COLLATE Korean_Wansung_CI_AS NULL,

UPD_DATETIME datetime DEFAULT getdate() NULL,

CONSTRAINT IDX_TWMS_IV_INVN_LOT_CELL_PK PRIMARY KEY (WH_CD,LOT_NO,WCELL_NO)

);

 

※ 실제 테이블 명 및 컬럼 구성은 기존 시스템 정의를 따른다.

 

### 11.3 테이블 변경 원칙

- 테이블 변경은 운영자가 직접 수행한다.

- Cursor AI는 테이블 변경을 수행하지 않는다.

- 컬럼 추가 시 기존 로직 영향도를 사전에 검토한다.

 

---

 

## 12. 보안 및 권한 관리

 

### 12.1 인증 방식

- 자체 로그인 방식

- 세션 기반 인증

 

### 12.2 권한 유형

- 물류센터 사용자

- 화주 사용자

- 센터 관리자

- IT 관리자

 

기존 권한 정책은 유지한다.

 

---

 

## 13. 운영 및 유지보수 고려사항

 

### 13.1 고객 요청 유형

- 잘못된 조작에 대한 복구 요청

- 상태 변경 사유 문의

- 처리 결과에 대한 확인 요청

 

---

 

## 14. 변경 영향도 분석

 

### 14.1 화면 영향도

- 기존 화면 수정 및 일부 신규 화면 추가

 

### 14.2 배치 영향도

- 기존 배치 구조 유지

- 내부 처리 로직 보완

 

### 14.3 데이터 영향도

- 데이터 정합성 유지 필수

- 이력 데이터 관리 기준 유지

 

---

 

## 15. 개발 및 적용 유의사항

 

### 15.1 Cursor AI 개발 범위

- Nexacro 화면

- 컨트롤러, 서비스, 맵퍼

- 저장 프로시저 호출 로직

 

### 15.2 운영자 작업 범위

- 테이블 구조 변경

- 데이터 보정 및 마이그레이션

 

### 15.3 적용 시 유의사항

- 운영 중단 최소화

- 기존 기능 영향도 사전 검토