-- =====================================================
-- WMS 입고 관련 테이블 생성 스크립트
-- Purpose: 입고 주문 헤더/상세 테이블 생성
-- Scope: twms_ib_inb_h, twms_ib_inb_d
-- 실행 전: 04_create_tables_user.sql 실행 완료 확인
-- 실행 순서: 5단계
-- PRD 참조: wms_prd.md 섹션 11.2.2
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 입고 주문 헤더 테이블 (TWMS_IB_INB_H)
-- =====================================================

CREATE TABLE wms.twms_ib_inb_h (
    wh_cd               varchar(30)      NOT NULL,
    inb_no              varchar(20)      NOT NULL,
    ref_no              varchar(32),
    strr_id             varchar(30),
    inb_tcd             varchar(20)      DEFAULT '0',
    inb_ect_date        timestamp        DEFAULT CURRENT_TIMESTAMP,
    inb_scd             varchar(10)      DEFAULT '00',
    del_yn              varchar(1)       DEFAULT 'N',
    outb_no             varchar(20),
    cust_id             varchar(20),
    shipto_id           varchar(51),
    suppr_id            varchar(20),
    inb_date            timestamp,
    close_yn            varchar(1)       DEFAULT 'N',
    inb_work_tcd        varchar(10)      DEFAULT '0',
    user_col_1          varchar(50),
    user_col_2          varchar(50),
    user_col_3          varchar(50),
    user_col_4          varchar(50),
    user_col_5          varchar(50),
    ins_person_id       varchar(30),
    upd_datetime        timestamp        DEFAULT CURRENT_TIMESTAMP,
    upd_person_id       varchar(30),
    ins_datetime        timestamp        DEFAULT CURRENT_TIMESTAMP,
    shipper_addr_1      varchar(128),
    inb_cntr_datetime   timestamp,
    ref_dt              varchar(8),
    ref_org_cd          varchar(8),
    ref_rnp_typ_cd      varchar(8),
    ref_detl_no         double precision,
    route_cd            varchar(20),
    inb_so_no           varchar(20),
    org_cd              varchar(20),
    data_occr_tp        varchar(1),
    zclose              varchar(1),
    part_inb            varchar(1)       DEFAULT 'N',
    CONSTRAINT pk_twms_ib_inb_h PRIMARY KEY (inb_no, wh_cd)
);

COMMENT ON TABLE  wms.twms_ib_inb_h IS '입고 주문 헤더 테이블';
COMMENT ON COLUMN wms.twms_ib_inb_h.wh_cd           IS '창고 코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_no           IS '입고번호';
COMMENT ON COLUMN wms.twms_ib_inb_h.ref_no           IS '참조번호';
COMMENT ON COLUMN wms.twms_ib_inb_h.strr_id          IS '화주 ID';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_tcd          IS '입고유형코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_ect_date     IS '입고예정일';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_scd          IS '입고상태코드 (00:대기, 10:검수, 20:확정)';
COMMENT ON COLUMN wms.twms_ib_inb_h.del_yn           IS '삭제여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ib_inb_h.outb_no          IS '출고번호 (반품 연계)';
COMMENT ON COLUMN wms.twms_ib_inb_h.cust_id          IS '고객 ID';
COMMENT ON COLUMN wms.twms_ib_inb_h.shipto_id        IS '배송지 ID';
COMMENT ON COLUMN wms.twms_ib_inb_h.suppr_id         IS '공급업체 ID';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_date         IS '입고일';
COMMENT ON COLUMN wms.twms_ib_inb_h.close_yn         IS '마감여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_work_tcd     IS '입고작업유형코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.shipper_addr_1   IS '화주 주소';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_cntr_datetime IS '입고계약일시';
COMMENT ON COLUMN wms.twms_ib_inb_h.ref_dt           IS '참조일자';
COMMENT ON COLUMN wms.twms_ib_inb_h.ref_org_cd       IS '참조조직코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.ref_rnp_typ_cd   IS '참조입고유형코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.route_cd         IS '경로코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.inb_so_no        IS '입고SO번호';
COMMENT ON COLUMN wms.twms_ib_inb_h.org_cd           IS '조직코드';
COMMENT ON COLUMN wms.twms_ib_inb_h.data_occr_tp     IS '데이터 발생유형';
COMMENT ON COLUMN wms.twms_ib_inb_h.zclose           IS 'Z마감여부';
COMMENT ON COLUMN wms.twms_ib_inb_h.part_inb         IS '부분입고여부 (Y/N)';

CREATE INDEX ix_inb_h_wh_cd     ON wms.twms_ib_inb_h (wh_cd);
CREATE INDEX ix_inb_h_strr_id   ON wms.twms_ib_inb_h (strr_id);
CREATE INDEX ix_inb_h_inb_scd   ON wms.twms_ib_inb_h (inb_scd);
CREATE INDEX ix_inb_h_del_yn    ON wms.twms_ib_inb_h (del_yn);
CREATE INDEX ix_inb_h_inb_date  ON wms.twms_ib_inb_h (inb_date);
CREATE INDEX ix_inb_h_ref_no    ON wms.twms_ib_inb_h (ref_no);

-- =====================================================
-- 2. 입고 주문 상세 테이블 (TWMS_IB_INB_D)
-- =====================================================

CREATE TABLE wms.twms_ib_inb_d (
    wh_cd           varchar(30)      NOT NULL,
    inb_no          varchar(20)      NOT NULL,
    inb_detl_no     int              DEFAULT 0 NOT NULL,
    strr_id         varchar(30),
    item_cd         varchar(45),
    prdt_lot_no     varchar(20),
    inb_ect_qty     double precision DEFAULT 0,
    inb_cmpt_qty    double precision DEFAULT 0,
    inb_cancl_qty   double precision DEFAULT 0,
    inb_detl_scd    varchar(10)      DEFAULT '00',
    del_yn          varchar(1)       DEFAULT 'N',
    outb_no         varchar(20),
    invn_scd        varchar(20)      DEFAULT '1',
    rmk             varchar(2000),
    ref_no          varchar(32),
    ref_detl_no     varchar(20),
    item_scd        varchar(30),
    infr_qty        double precision DEFAULT 0,
    item_strg_cd    varchar(20)      DEFAULT 'EA',
    close_yn        varchar(1)       DEFAULT 'N',
    prdt_date       timestamp,
    lot_attr_1      varchar(20),
    lot_attr_2      varchar(20),
    lot_attr_3      varchar(400),
    lot_attr_4      varchar(20),
    lot_attr_5      varchar(20),
    lot_attr_6      varchar(20),
    ins_person_id   varchar(30),
    ins_datetime    timestamp        DEFAULT CURRENT_TIMESTAMP,
    upd_person_id   varchar(30),
    upd_datetime    timestamp        DEFAULT CURRENT_TIMESTAMP,
    ref_dt          varchar(8),
    ref_org_cd      varchar(10),
    ref_rnp_typ_cd  varchar(10),
    ser_grp_no      numeric(28,0),
    inspct_scd      varchar(20)      DEFAULT '00',
    to_wcell_no     varchar(20),
    detl_inb_date   timestamp,
    part_inb        varchar(1)       DEFAULT 'N',
    CONSTRAINT pk_twms_ib_inb_d PRIMARY KEY (inb_no, inb_detl_no, wh_cd)
);

COMMENT ON TABLE  wms.twms_ib_inb_d IS '입고 주문 상세 테이블';
COMMENT ON COLUMN wms.twms_ib_inb_d.wh_cd         IS '창고 코드';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_no         IS '입고번호';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_detl_no    IS '입고 상세번호';
COMMENT ON COLUMN wms.twms_ib_inb_d.strr_id        IS '화주 ID';
COMMENT ON COLUMN wms.twms_ib_inb_d.item_cd        IS '상품코드';
COMMENT ON COLUMN wms.twms_ib_inb_d.prdt_lot_no    IS '제품 LOT번호';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_ect_qty    IS '입고예정수량';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_cmpt_qty   IS '입고완료수량';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_cancl_qty  IS '입고취소수량';
COMMENT ON COLUMN wms.twms_ib_inb_d.inb_detl_scd   IS '입고상세상태코드';
COMMENT ON COLUMN wms.twms_ib_inb_d.del_yn         IS '삭제여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ib_inb_d.invn_scd       IS '재고상태코드';
COMMENT ON COLUMN wms.twms_ib_inb_d.rmk            IS '비고';
COMMENT ON COLUMN wms.twms_ib_inb_d.item_scd       IS '상품상태코드';
COMMENT ON COLUMN wms.twms_ib_inb_d.infr_qty       IS '불량수량';
COMMENT ON COLUMN wms.twms_ib_inb_d.item_strg_cd   IS '상품보관코드 (단위)';
COMMENT ON COLUMN wms.twms_ib_inb_d.close_yn       IS '마감여부 (Y/N)';
COMMENT ON COLUMN wms.twms_ib_inb_d.prdt_date      IS '제조일';
COMMENT ON COLUMN wms.twms_ib_inb_d.inspct_scd     IS '검수상태코드 (00:미검수, 10:검수중, 20:검수완료)';
COMMENT ON COLUMN wms.twms_ib_inb_d.to_wcell_no    IS '입고 셀번호';
COMMENT ON COLUMN wms.twms_ib_inb_d.detl_inb_date  IS '상세 입고일';
COMMENT ON COLUMN wms.twms_ib_inb_d.part_inb       IS '부분입고여부 (Y/N)';

CREATE INDEX ix_inb_d_wh_cd    ON wms.twms_ib_inb_d (wh_cd);
CREATE INDEX ix_inb_d_item_cd  ON wms.twms_ib_inb_d (item_cd);
CREATE INDEX ix_inb_d_strr_id  ON wms.twms_ib_inb_d (strr_id);
CREATE INDEX ix_inb_d_scd      ON wms.twms_ib_inb_d (inb_detl_scd);

-- =====================================================
-- 다음 단계: 06_create_tables_outbound.sql 실행
-- =====================================================
