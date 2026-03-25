-- =====================================================
-- WMS 재고 관련 테이블 생성 스크립트
-- Purpose: 재고 LOT, 셀별 재고, 품목별 재고, LOT×셀 재고 테이블 생성
-- Scope: twms_iv_lot, twms_iv_invn, twms_iv_invn_item, twms_iv_invn_lot_cell
-- 실행 전: 06_create_tables_outbound.sql 실행 완료 확인
-- 실행 순서: 7단계
-- PRD 참조: wms_prd.md 섹션 11.2.4
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 재고 LOT 마스터 테이블 (TWMS_IV_LOT)
-- =====================================================

CREATE TABLE wms.twms_iv_lot (
    wh_cd           varchar(30)  NOT NULL,
    lot_no          varchar(30)  NOT NULL,
    strr_id         varchar(30),
    item_cd         varchar(45),
    prdt_lot_no     varchar(20),
    valid_datetime  timestamp,
    inb_date        timestamp,
    prdt_date       timestamp,
    invn_scd        varchar(20),
    src_no          varchar(20),
    lot_attr_1      varchar(20)  DEFAULT 'NULL',
    lot_attr_2      varchar(20)  DEFAULT 'NULL',
    lot_attr_3      varchar(400) DEFAULT 'NULL',
    lot_attr_4      varchar(20)  DEFAULT 'NULL',
    lot_attr_5      varchar(20)  DEFAULT 'NULL',
    lot_attr_6      varchar(20)  DEFAULT 'NULL',
    ins_person_id   varchar(30),
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_twms_iv_lot PRIMARY KEY (wh_cd, lot_no)
);

COMMENT ON TABLE  wms.twms_iv_lot IS '재고 LOT 마스터 테이블';
COMMENT ON COLUMN wms.twms_iv_lot.wh_cd          IS '창고 코드';
COMMENT ON COLUMN wms.twms_iv_lot.lot_no          IS 'LOT 번호';
COMMENT ON COLUMN wms.twms_iv_lot.strr_id         IS '화주 ID';
COMMENT ON COLUMN wms.twms_iv_lot.item_cd         IS '상품 코드';
COMMENT ON COLUMN wms.twms_iv_lot.prdt_lot_no     IS '제품 LOT번호';
COMMENT ON COLUMN wms.twms_iv_lot.valid_datetime  IS '유효기한';
COMMENT ON COLUMN wms.twms_iv_lot.inb_date        IS '입고일';
COMMENT ON COLUMN wms.twms_iv_lot.prdt_date       IS '제조일';
COMMENT ON COLUMN wms.twms_iv_lot.invn_scd        IS '재고상태코드';
COMMENT ON COLUMN wms.twms_iv_lot.src_no          IS '원본번호';

CREATE INDEX ix_iv_lot_item_cd  ON wms.twms_iv_lot (item_cd);
CREATE INDEX ix_iv_lot_strr_id  ON wms.twms_iv_lot (strr_id);
CREATE INDEX ix_iv_lot_inb_date ON wms.twms_iv_lot (inb_date);

-- =====================================================
-- 2. 셀별 재고 테이블 (TWMS_IV_INVN)
-- =====================================================

CREATE TABLE wms.twms_iv_invn (
    wh_cd           varchar(30)      NOT NULL,
    wcell_no        varchar(20)      NOT NULL,
    lot_no          varchar(30)      NOT NULL,
    invn_qty        double precision DEFAULT 0,
    ins_datetime    timestamp,
    ins_person_id   varchar(30),
    upd_datetime    timestamp,
    upd_person_id   varchar(30),
    CONSTRAINT pk_twms_iv_invn PRIMARY KEY (wh_cd, wcell_no, lot_no)
);

COMMENT ON TABLE  wms.twms_iv_invn IS '셀별 재고 테이블';
COMMENT ON COLUMN wms.twms_iv_invn.wh_cd     IS '창고 코드';
COMMENT ON COLUMN wms.twms_iv_invn.wcell_no  IS '셀 번호';
COMMENT ON COLUMN wms.twms_iv_invn.lot_no    IS 'LOT 번호';
COMMENT ON COLUMN wms.twms_iv_invn.invn_qty  IS '재고수량';

CREATE INDEX ix_iv_invn_lot_no   ON wms.twms_iv_invn (lot_no);
CREATE INDEX ix_iv_invn_wcell_no ON wms.twms_iv_invn (wcell_no);

-- =====================================================
-- 3. 품목별 재고 집계 테이블 (TWMS_IV_INVN_ITEM)
-- =====================================================

CREATE TABLE wms.twms_iv_invn_item (
    wh_cd           varchar(30)      NOT NULL,
    lot_no          varchar(30)      NOT NULL,
    item_cd         varchar(45),
    strr_id         varchar(30)      DEFAULT '0',
    invn_qty        double precision DEFAULT 0,
    avlb_qty        double precision DEFAULT 0,
    prcs_qty        double precision DEFAULT 0,
    ins_person_id   varchar(30),
    ins_datetime    timestamp,
    upd_person_id   varchar(30),
    upd_datetime    timestamp,
    CONSTRAINT pk_twms_iv_invn_item PRIMARY KEY (wh_cd, lot_no)
);

COMMENT ON TABLE  wms.twms_iv_invn_item IS '품목별 재고 집계 테이블';
COMMENT ON COLUMN wms.twms_iv_invn_item.wh_cd    IS '창고 코드';
COMMENT ON COLUMN wms.twms_iv_invn_item.lot_no   IS 'LOT 번호';
COMMENT ON COLUMN wms.twms_iv_invn_item.item_cd  IS '상품 코드';
COMMENT ON COLUMN wms.twms_iv_invn_item.strr_id  IS '화주 ID';
COMMENT ON COLUMN wms.twms_iv_invn_item.invn_qty IS '재고수량';
COMMENT ON COLUMN wms.twms_iv_invn_item.avlb_qty IS '가용수량';
COMMENT ON COLUMN wms.twms_iv_invn_item.prcs_qty IS '처리중수량 (할당/피킹 진행)';

CREATE INDEX ix_iv_invn_item_item ON wms.twms_iv_invn_item (item_cd);
CREATE INDEX ix_iv_invn_item_strr ON wms.twms_iv_invn_item (strr_id);

-- =====================================================
-- 4. LOT×셀 재고 테이블 (TWMS_IV_INVN_LOT_CELL)
-- =====================================================

CREATE TABLE wms.twms_iv_invn_lot_cell (
    wh_cd           varchar(30)      NOT NULL,
    lot_no          varchar(30)      NOT NULL,
    wcell_no        varchar(20)      NOT NULL,
    item_cd         varchar(45),
    strr_id         varchar(30),
    invn_qty        double precision DEFAULT 0,
    avlb_qty        double precision DEFAULT 0,
    prcs_qty        double precision DEFAULT 0,
    ins_person_id   varchar(30),
    ins_datetime    timestamp        DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp        DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_twms_iv_invn_lot_cell PRIMARY KEY (wh_cd, lot_no, wcell_no)
);

COMMENT ON TABLE  wms.twms_iv_invn_lot_cell IS 'LOT×셀 재고 테이블';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.wh_cd    IS '창고 코드';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.lot_no   IS 'LOT 번호';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.wcell_no IS '셀 번호';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.item_cd  IS '상품 코드';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.strr_id  IS '화주 ID';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.invn_qty IS '재고수량';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.avlb_qty IS '가용수량';
COMMENT ON COLUMN wms.twms_iv_invn_lot_cell.prcs_qty IS '처리중수량';

CREATE INDEX ix_iv_lot_cell_item ON wms.twms_iv_invn_lot_cell (item_cd);
CREATE INDEX ix_iv_lot_cell_cell ON wms.twms_iv_invn_lot_cell (wcell_no);

-- =====================================================
-- 다음 단계: 08_create_tables_batch_log.sql 실행
-- =====================================================
