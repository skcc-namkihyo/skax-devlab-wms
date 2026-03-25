-- =====================================================
-- WMS 출고 관련 테이블 생성 스크립트
-- Purpose: 출고 주문 헤더/상세 테이블 생성
-- Scope: twms_ob_outb_h, twms_ob_outb_d
-- 실행 전: 05_create_tables_inbound.sql 실행 완료 확인
-- 실행 순서: 6단계
-- PRD 참조: wms_prd.md 섹션 11.2.3
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 출고 주문 헤더 테이블 (TWMS_OB_OUTB_H)
-- =====================================================

CREATE TABLE wms.twms_ob_outb_h (
    wh_cd           varchar(30)      NOT NULL,
    outb_no         varchar(20)      NOT NULL,
    ref_no          varchar(32),
    ref_dt          varchar(8),
    ref_org_cd      varchar(8),
    ref_rnp_typ_cd  varchar(8),
    strr_id         varchar(30),
    outb_tcd        varchar(20),
    outb_work_tcd   varchar(10),
    outb_ect_date   timestamp,
    outb_scd        varchar(10),
    del_yn          varchar(1),
    cust_id         varchar(20),
    shipto_id       varchar(51),
    outb_date       timestamp,
    route_cd        varchar(10),
    wave_no         varchar(20),
    ins_person_id   varchar(30),
    ins_datetime    timestamp,
    upd_person_id   varchar(30),
    upd_datetime    timestamp,
    itemwave_yn     varchar(1)       NOT NULL DEFAULT 'N',
    CONSTRAINT pk_twms_ob_outb_h PRIMARY KEY (outb_no, wh_cd)
);

COMMENT ON TABLE  wms.twms_ob_outb_h IS '출고 주문 헤더 테이블';
COMMENT ON COLUMN wms.twms_ob_outb_h.wh_cd         IS '창고 코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_no        IS '출고번호';
COMMENT ON COLUMN wms.twms_ob_outb_h.ref_no         IS '참조번호';
COMMENT ON COLUMN wms.twms_ob_outb_h.ref_dt         IS '참조일자';
COMMENT ON COLUMN wms.twms_ob_outb_h.ref_org_cd     IS '참조조직코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.ref_rnp_typ_cd IS '참조출고유형코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.strr_id        IS '화주 ID';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_tcd       IS '출고유형코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_work_tcd  IS '출고작업유형코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_ect_date  IS '출고예정일';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_scd       IS '출고상태코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.del_yn         IS '삭제여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ob_outb_h.cust_id        IS '고객 ID';
COMMENT ON COLUMN wms.twms_ob_outb_h.shipto_id      IS '배송지 ID';
COMMENT ON COLUMN wms.twms_ob_outb_h.outb_date      IS '출고일';
COMMENT ON COLUMN wms.twms_ob_outb_h.route_cd       IS '경로코드';
COMMENT ON COLUMN wms.twms_ob_outb_h.wave_no        IS '웨이브번호';
COMMENT ON COLUMN wms.twms_ob_outb_h.itemwave_yn    IS '아이템웨이브여부 (Y/N)';

CREATE INDEX ix_outb_h_wh_cd      ON wms.twms_ob_outb_h (wh_cd);
CREATE INDEX ix_outb_h_strr_id    ON wms.twms_ob_outb_h (strr_id);
CREATE INDEX ix_outb_h_outb_scd   ON wms.twms_ob_outb_h (outb_scd);
CREATE INDEX ix_outb_h_del_yn     ON wms.twms_ob_outb_h (del_yn);
CREATE INDEX ix_outb_h_outb_date  ON wms.twms_ob_outb_h (outb_date);
CREATE INDEX ix_outb_h_wave_no    ON wms.twms_ob_outb_h (wave_no);

-- =====================================================
-- 2. 출고 주문 상세 테이블 (TWMS_OB_OUTB_D)
-- =====================================================

CREATE TABLE wms.twms_ob_outb_d (
    wh_cd               varchar(30)      NOT NULL,
    outb_no             varchar(20)      NOT NULL,
    outb_detl_no        int              NOT NULL,
    item_cd             varchar(45),
    prdt_lot_no         varchar(20),
    order_qty           double precision,
    outb_cmpt_qty       double precision,
    cancl_qty           double precision,
    laloc_qty           double precision,
    pick_qty            double precision,
    shipto_id           varchar(51),
    laloc_scd           varchar(10),
    outb_detl_scd       varchar(10),
    del_yn              varchar(1),
    invn_scd            varchar(20),
    outb_scan_yn        varchar(1),
    rmk                 varchar(2000),
    ref_no              varchar(32),
    laloc_yn            varchar(1),
    laloc_datetime      timestamp,
    inb_date            timestamp,
    inb_no              varchar(20),
    lot_attr_1          varchar(20),
    lot_attr_2          varchar(20),
    lot_attr_3          varchar(400),
    lot_attr_4          varchar(20),
    lot_attr_5          varchar(20),
    lot_attr_6          varchar(20),
    item_strg_cd        varchar(20),
    strr_id             varchar(30),
    ins_person_id       varchar(30),
    ins_datetime        timestamp,
    upd_person_id       varchar(30),
    upd_datetime        timestamp,
    ref_dt              varchar(8),
    ref_org_cd          varchar(8),
    ref_rnp_typ_cd      varchar(8),
    outb_so_no          varchar(20),
    outb_so_detl_no     int,
    scan_qty            double precision,
    tims_send_scd       varchar(10),
    polca_send_scd      varchar(10),
    tims_send_datetime  timestamp,
    polca_send_datetime timestamp,
    sms_box_send_yn     varchar(1),
    sms_unit_send_yn    varchar(1),
    pick_box_qty        double precision,
    pick_unit_qty       double precision,
    wave_no             varchar(20),
    prnt_job_no         varchar(14),
    CONSTRAINT pk_twms_ob_outb_d PRIMARY KEY (outb_no, outb_detl_no, wh_cd)
);

COMMENT ON TABLE  wms.twms_ob_outb_d IS '출고 주문 상세 테이블';
COMMENT ON COLUMN wms.twms_ob_outb_d.wh_cd            IS '창고 코드';
COMMENT ON COLUMN wms.twms_ob_outb_d.outb_no           IS '출고번호';
COMMENT ON COLUMN wms.twms_ob_outb_d.outb_detl_no      IS '출고 상세번호';
COMMENT ON COLUMN wms.twms_ob_outb_d.item_cd           IS '상품코드';
COMMENT ON COLUMN wms.twms_ob_outb_d.prdt_lot_no       IS '제품 LOT번호';
COMMENT ON COLUMN wms.twms_ob_outb_d.order_qty         IS '주문수량';
COMMENT ON COLUMN wms.twms_ob_outb_d.outb_cmpt_qty     IS '출고완료수량';
COMMENT ON COLUMN wms.twms_ob_outb_d.cancl_qty         IS '취소수량';
COMMENT ON COLUMN wms.twms_ob_outb_d.laloc_qty         IS '할당수량';
COMMENT ON COLUMN wms.twms_ob_outb_d.pick_qty          IS '피킹수량';
COMMENT ON COLUMN wms.twms_ob_outb_d.shipto_id         IS '배송지 ID';
COMMENT ON COLUMN wms.twms_ob_outb_d.laloc_scd         IS '할당상태코드';
COMMENT ON COLUMN wms.twms_ob_outb_d.outb_detl_scd     IS '출고상세상태코드';
COMMENT ON COLUMN wms.twms_ob_outb_d.del_yn            IS '삭제여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ob_outb_d.invn_scd          IS '재고상태코드';
COMMENT ON COLUMN wms.twms_ob_outb_d.outb_scan_yn      IS '스캔여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ob_outb_d.rmk               IS '비고';
COMMENT ON COLUMN wms.twms_ob_outb_d.laloc_yn          IS '할당여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ob_outb_d.laloc_datetime    IS '할당일시';
COMMENT ON COLUMN wms.twms_ob_outb_d.wave_no           IS '웨이브번호';
COMMENT ON COLUMN wms.twms_ob_outb_d.scan_qty          IS '스캔수량';

CREATE INDEX ix_outb_d_wh_cd      ON wms.twms_ob_outb_d (wh_cd);
CREATE INDEX ix_outb_d_item_cd    ON wms.twms_ob_outb_d (item_cd);
CREATE INDEX ix_outb_d_strr_id    ON wms.twms_ob_outb_d (strr_id);
CREATE INDEX ix_outb_d_scd        ON wms.twms_ob_outb_d (outb_detl_scd);
CREATE INDEX ix_outb_d_wave_no    ON wms.twms_ob_outb_d (wave_no);

-- =====================================================
-- 다음 단계: 07_create_tables_inventory.sql 실행
-- =====================================================
