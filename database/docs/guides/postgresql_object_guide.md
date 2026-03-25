# PostgreSQL 오브젝트 생성 가이드 (WMS 창고관리시스템)

## 스키마
- 스키마명: `wms`
- 테이블 소유자: `admin_role`
- 사용자 역할: `developer_role`

## 테이블 공통 규칙
- 반드시 코멘트를 포함해야 함
- 반드시 기본키(PK)를 가져야 함
- 반드시 생성자, 생성일시, 수정자, 수정일시 필드를 포함해야 함
- 테이블명은 두 단어 이상의 단수 소문자로 작성
- WMS 창고관리 관련 테이블은 도메인별로 그룹화하여 명명

## 속성 공통 규칙
- 반드시 코멘트를 포함해야 함
- 공통코드 속성의 경우, 코멘트에 코드그룹과 예시를 포함
- 기본키는 SERIAL 타입을 사용하고 `[테이블명]_id`로 작성하며 세단어 이내로 작성함
- 속성명은 두단어 이상 세단어 이하의 소문자로 생성하고 언더바(_)로 연결함
- 속성명은 최대한 중복되지 않고 명확하게 작성하되 의미를 해치지 않는 선에서 간결하게 작성함
- 날짜 필드는 timestamp 타입 사용
- 500자 이상의 문자열은 TEXT 타입 사용
- 문자열은 VARCHAR 타입 사용 (CHAR 타입 사용하지 않음)
- 숫자는 NUMERIC 타입 사용, 정수는 INT 타입 사용
- bool 타입은 적극사용 하며, 필요시 _YN 으로 사용
- 문자열 속성은 반드시 최대 길이 지정
- 숫자 속성은 반드시 최대 길이 지정
- 자동차 관련 정보는 표준화된 코드값 사용 (브랜드, 모델, 연식 등)

## 인덱스 규칙
- 인덱스 명명: `[테이블명]_[ix1]`, `[테이블명]_[ix2]`
- 유니크 인덱스 명명: `[테이블명]_[ux1]`, `[테이블명]_[ux2]`
- 외래키

## 외래키 제약조건
- 테이블 생성 시 외래키 제약조건 추가
- 외래키 제약조건명은 PostgreSQL 표준을 따름
- 모든 FK 컬럼에는 인덱스를 자동 생성
- 모든 FK 컬럼명은 참조하는 부모 테이블의 PK 컬럼명과 데이터타입을 정확히 동일하게 작성

> - 예) 부모 테이블의 PK가 service_center_id라면, 이를 참조하는 모든 자식/상세/매핑 테이블의 FK 컬럼도 반드시 service_center_id로 명명한다.
> - 의미상 부모와 동일한 속성(예: service_center_id, user_id, vehicle_id 등)은 컬럼명, 타입, 코멘트까지 완전히 일치시킨다.

## 트리거
- 기본적으로 사용하지 않음 (필요시에만 사용)
- 트리거 명명: `[테이블명]_[trg1]`, `[테이블명]_[trg2]`

## 프로시저
- 기본적으로 사용하지 않음 (필요시에만 사용)
- 프로시저 명명: `[테이블명]_[prc1]`, `[테이블명]_[prc2]`

## 뷰
- 기본적으로 사용하지 않음 (필요시에만 사용)
- 뷰 명명: `[테이블명]_[vw1]`, `[테이블명]_[vw2]`

## 타입
- 타입은 사용하지 않음
- 필요한 경우, 공통코드 테이블의 코드그룹에 속하도록 하고 등록하여 사용

## 시퀀스
- 시퀀스는 사용하지 않음
- 필요한 경우 수동으로 생성하며, 시퀀스 명명: `[테이블명]_[seq1]`, `[테이블명]_[seq2]`

---

> 본 가이드는 WMS 창고관리시스템의 PostgreSQL 데이터베이스 오브젝트 설계 및 생성 시 일관성과 품질을 보장하기 위한 표준 규칙을 제공합니다.

## 예시
```sql
-- 테이블 생성 예시 (가이드 규칙 반영)
CREATE TABLE wms.service_center (
    service_center_id SERIAL PRIMARY KEY, -- 기본키
    business_number VARCHAR(20) NOT NULL, -- 사업자등록번호
    center_name VARCHAR(100) NOT NULL, -- 정비소명
    center_code VARCHAR(50) NOT NULL, -- 정비소 코드
    center_status_code VARCHAR(50) NOT NULL, -- 정비소 상태 코드 (코드그룹: CENTER_STATUS, 예시: ACTIVE, INACTIVE, SUSPENDED, CLOSED)
    address TEXT NOT NULL, -- 주소
    phone_number VARCHAR(20) NOT NULL, -- 전화번호
    email VARCHAR(100), -- 이메일
    operating_hours TEXT, -- 운영시간
    description TEXT, -- 설명
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 생성일시
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 수정일시
    created_by VARCHAR(50) NOT NULL, -- 생성자
    updated_by VARCHAR(50) NOT NULL, -- 수정자
    CONSTRAINT service_center_ux1 UNIQUE (business_number),
    CONSTRAINT service_center_ux2 UNIQUE (center_code)
);

-- 테이블 코멘트
COMMENT ON TABLE wms.service_center IS '정비소 정보 테이블';

-- 컬럼 코멘트
COMMENT ON COLUMN wms.service_center.service_center_id IS '정비소 ID';
COMMENT ON COLUMN wms.service_center.business_number IS '사업자등록번호';
COMMENT ON COLUMN wms.service_center.center_name IS '정비소명';
COMMENT ON COLUMN wms.service_center.center_code IS '정비소 코드';
COMMENT ON COLUMN wms.service_center.center_status_code IS '정비소 상태 코드 (코드그룹: CENTER_STATUS, 예시: ACTIVE, INACTIVE, SUSPENDED, CLOSED)';
COMMENT ON COLUMN wms.service_center.address IS '주소';
COMMENT ON COLUMN wms.service_center.phone_number IS '전화번호';
COMMENT ON COLUMN wms.service_center.email IS '이메일';
COMMENT ON COLUMN wms.service_center.operating_hours IS '운영시간';
COMMENT ON COLUMN wms.service_center.description IS '설명';
COMMENT ON COLUMN wms.service_center.created_at IS '생성일시';
COMMENT ON COLUMN wms.service_center.updated_at IS '수정일시';
COMMENT ON COLUMN wms.service_center.created_by IS '생성자';
COMMENT ON COLUMN wms.service_center.updated_by IS '수정자';

-- 인덱스 생성 예시
CREATE INDEX service_center_ix1 ON wms.service_center (center_status_code);
CREATE INDEX service_center_ix2 ON wms.service_center (center_name);
```
