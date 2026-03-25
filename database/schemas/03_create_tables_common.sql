-- =====================================================
-- WMS 공통 마스터 테이블 생성 스크립트
-- Purpose: 공통코드, 물류센터, 상품, 화주 마스터 테이블 생성
-- Scope: common_code_group, common_code, warehouse, item_master, shipper
-- 실행 전: 02_create_schema.sql 실행 완료 확인
-- 실행 순서: 3단계
-- PRD 참조: wms_prd.md 섹션 3.1, 3.4
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 공통코드 그룹 테이블
-- =====================================================

CREATE TABLE wms.common_code_group (
    code_group_id   varchar(30)  NOT NULL,
    code_group_name varchar(100) NOT NULL,
    description     varchar(500),
    use_yn          varchar(1)   NOT NULL DEFAULT 'Y',
    ins_person_id   varchar(30),
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_common_code_group PRIMARY KEY (code_group_id)
);

COMMENT ON TABLE  wms.common_code_group IS '공통코드 그룹 테이블';
COMMENT ON COLUMN wms.common_code_group.code_group_id   IS '코드그룹 ID';
COMMENT ON COLUMN wms.common_code_group.code_group_name IS '코드그룹명';
COMMENT ON COLUMN wms.common_code_group.description     IS '설명';
COMMENT ON COLUMN wms.common_code_group.use_yn          IS '사용여부 (Y/N)';

-- =====================================================
-- 2. 공통코드 테이블
-- =====================================================

CREATE TABLE wms.common_code (
    code_group_id varchar(30)  NOT NULL,
    code_id       varchar(30)  NOT NULL,
    code_name     varchar(100) NOT NULL,
    sort_order    int          DEFAULT 0,
    description   varchar(500),
    use_yn        varchar(1)   NOT NULL DEFAULT 'Y',
    attr_1        varchar(100),
    attr_2        varchar(100),
    attr_3        varchar(100),
    ins_person_id varchar(30),
    ins_datetime  timestamp    DEFAULT CURRENT_TIMESTAMP,
    upd_person_id varchar(30),
    upd_datetime  timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_common_code PRIMARY KEY (code_group_id, code_id),
    CONSTRAINT fk_common_code_group FOREIGN KEY (code_group_id)
        REFERENCES wms.common_code_group(code_group_id)
);

COMMENT ON TABLE  wms.common_code IS '공통코드 테이블';
COMMENT ON COLUMN wms.common_code.code_group_id IS '코드그룹 ID';
COMMENT ON COLUMN wms.common_code.code_id       IS '코드 ID';
COMMENT ON COLUMN wms.common_code.code_name     IS '코드명';
COMMENT ON COLUMN wms.common_code.sort_order    IS '정렬순서';
COMMENT ON COLUMN wms.common_code.use_yn        IS '사용여부 (Y/N)';
COMMENT ON COLUMN wms.common_code.attr_1        IS '속성값 1';
COMMENT ON COLUMN wms.common_code.attr_2        IS '속성값 2';
COMMENT ON COLUMN wms.common_code.attr_3        IS '속성값 3';

CREATE INDEX ix_common_code_use ON wms.common_code (use_yn);

-- =====================================================
-- 3. 물류센터(창고) 마스터 테이블
-- =====================================================

CREATE TABLE wms.warehouse (
    wh_cd           varchar(30)  NOT NULL,
    wh_name         varchar(100) NOT NULL,
    wh_type         varchar(20),
    address         varchar(500),
    tel             varchar(40),
    manager_id      varchar(20),
    use_yn          varchar(1)   NOT NULL DEFAULT 'Y',
    ins_person_id   varchar(30),
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_warehouse PRIMARY KEY (wh_cd)
);

COMMENT ON TABLE  wms.warehouse IS '물류센터(창고) 마스터 테이블';
COMMENT ON COLUMN wms.warehouse.wh_cd       IS '창고 코드';
COMMENT ON COLUMN wms.warehouse.wh_name     IS '창고명';
COMMENT ON COLUMN wms.warehouse.wh_type     IS '창고 유형';
COMMENT ON COLUMN wms.warehouse.address     IS '주소';
COMMENT ON COLUMN wms.warehouse.tel         IS '연락처';
COMMENT ON COLUMN wms.warehouse.manager_id  IS '관리자 ID';
COMMENT ON COLUMN wms.warehouse.use_yn      IS '사용여부 (Y/N)';

-- =====================================================
-- 4. 상품(품목) 마스터 테이블
-- =====================================================

CREATE TABLE wms.item_master (
    item_cd         varchar(45)    NOT NULL,
    item_name       varchar(200)   NOT NULL,
    item_type       varchar(20),
    item_spec       varchar(200),
    item_unit       varchar(20)    DEFAULT 'EA',
    barcode         varchar(50),
    weight          double precision,
    volume          double precision,
    use_yn          varchar(1)     NOT NULL DEFAULT 'Y',
    ins_person_id   varchar(30),
    ins_datetime    timestamp      DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp      DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_item_master PRIMARY KEY (item_cd)
);

COMMENT ON TABLE  wms.item_master IS '상품(품목) 마스터 테이블';
COMMENT ON COLUMN wms.item_master.item_cd     IS '상품 코드';
COMMENT ON COLUMN wms.item_master.item_name   IS '상품명';
COMMENT ON COLUMN wms.item_master.item_type   IS '상품 유형';
COMMENT ON COLUMN wms.item_master.item_spec   IS '상품 규격';
COMMENT ON COLUMN wms.item_master.item_unit   IS '단위 (EA, BOX 등)';
COMMENT ON COLUMN wms.item_master.barcode     IS '바코드';
COMMENT ON COLUMN wms.item_master.weight      IS '무게';
COMMENT ON COLUMN wms.item_master.volume      IS '부피';
COMMENT ON COLUMN wms.item_master.use_yn      IS '사용여부 (Y/N)';

CREATE INDEX ix_item_master_barcode ON wms.item_master (barcode);
CREATE INDEX ix_item_master_type    ON wms.item_master (item_type);

-- =====================================================
-- 5. 화주(거래처) 마스터 테이블
-- =====================================================

CREATE TABLE wms.shipper (
    strr_id         varchar(30)  NOT NULL,
    strr_name       varchar(100) NOT NULL,
    strr_type       varchar(20),
    business_no     varchar(20),
    ceo_name        varchar(50),
    address         varchar(500),
    tel             varchar(40),
    email           varchar(60),
    use_yn          varchar(1)   NOT NULL DEFAULT 'Y',
    ins_person_id   varchar(30),
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_shipper PRIMARY KEY (strr_id)
);

COMMENT ON TABLE  wms.shipper IS '화주(거래처) 마스터 테이블';
COMMENT ON COLUMN wms.shipper.strr_id     IS '화주 ID';
COMMENT ON COLUMN wms.shipper.strr_name   IS '화주명';
COMMENT ON COLUMN wms.shipper.strr_type   IS '거래처 유형';
COMMENT ON COLUMN wms.shipper.business_no IS '사업자번호';
COMMENT ON COLUMN wms.shipper.ceo_name    IS '대표자명';
COMMENT ON COLUMN wms.shipper.address     IS '주소';
COMMENT ON COLUMN wms.shipper.tel         IS '연락처';
COMMENT ON COLUMN wms.shipper.email       IS '이메일';
COMMENT ON COLUMN wms.shipper.use_yn      IS '사용여부 (Y/N)';

CREATE INDEX ix_shipper_type ON wms.shipper (strr_type);

-- =====================================================
-- 다음 단계: 04_create_tables_user.sql 실행
-- =====================================================
