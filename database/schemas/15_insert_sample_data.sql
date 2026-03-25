-- =====================================================
-- WMS 샘플 데이터 삽입 스크립트
-- Purpose: 개발/테스트용 샘플 데이터 삽입
-- Scope: 물류센터, 화주, 상품, 사용자, 입출고, 재고
-- 실행 전: 14_insert_common_codes.sql 실행 완료 확인
-- 실행 순서: 15단계
-- 주의: 개발/테스트 환경에서만 사용
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 물류센터 샘플
-- =====================================================

INSERT INTO wms.warehouse (wh_cd, wh_name, wh_type, address, tel, manager_id, ins_person_id) VALUES
    ('WH01', '서울 물류센터',   'MAIN',   '서울시 강서구 마곡동 123-45',       '02-1234-5678', 'admin',   'SYSTEM'),
    ('WH02', '경기 물류센터',   'MAIN',   '경기도 이천시 마장면 물류단지로 100',   '031-456-7890', 'manager1', 'SYSTEM'),
    ('WH03', '부산 물류센터',   'SUB',    '부산시 강서구 녹산동 567-89',        '051-987-6543', 'manager2', 'SYSTEM'),
    ('WH04', '반품센터',       'RETURN', '경기도 용인시 기흥구 반품로 50',       '031-111-2222', 'manager1', 'SYSTEM');

-- =====================================================
-- 2. 화주(거래처) 샘플
-- =====================================================

INSERT INTO wms.shipper (strr_id, strr_name, strr_type, business_no, ceo_name, address, tel, email, ins_person_id) VALUES
    ('STRR001', '삼성전자',     'SUPPLIER', '124-81-00001', '한종희', '경기도 수원시 영통구',         '031-200-1234', 'samsung@example.com',  'SYSTEM'),
    ('STRR002', 'LG전자',      'SUPPLIER', '107-86-00002', '조주완', '서울시 영등포구 여의도동',      '02-3777-1114',  'lg@example.com',       'SYSTEM'),
    ('STRR003', '쿠팡',        'CUSTOMER', '120-88-00003', '강한승', '서울시 송파구 송파대로',        '02-1577-7011',  'coupang@example.com',  'SYSTEM'),
    ('STRR004', '신세계',       'BOTH',     '201-81-00004', '강희석', '서울시 중구 충무로',           '02-1588-1234',  'ssg@example.com',      'SYSTEM');

-- =====================================================
-- 3. 상품(품목) 샘플
-- =====================================================

INSERT INTO wms.item_master (item_cd, item_name, item_type, item_spec, item_unit, barcode, weight, volume, ins_person_id) VALUES
    ('ITEM001', 'Galaxy S25 Ultra',     'GENERAL',   '256GB/Titanium',   'EA',  '8801643000001', 0.233, 0.5, 'SYSTEM'),
    ('ITEM002', 'Galaxy Tab S10',       'GENERAL',   '128GB/Gray',       'EA',  '8801643000002', 0.498, 1.2, 'SYSTEM'),
    ('ITEM003', 'Galaxy Buds3 Pro',     'GENERAL',   'Silver',           'EA',  '8801643000003', 0.005, 0.1, 'SYSTEM'),
    ('ITEM004', 'LG OLED TV 65"',       'FRAGILE',   'OLED65C4KNA',      'EA',  '8801643000004', 18.2,  45.0, 'SYSTEM'),
    ('ITEM005', 'LG 냉장고 양문형',       'GENERAL',   'S834S30',          'EA',  '8801643000005', 95.0,  120.0, 'SYSTEM'),
    ('ITEM006', '리튬 배터리 셀',         'DANGEROUS', '21700 Cell',       'BOX', '8801643000006', 5.0,   3.0, 'SYSTEM'),
    ('ITEM007', '냉동 식품 패키지',        'COLD',      '500g/Pack',        'BOX', '8801643000007', 12.0,  8.0, 'SYSTEM'),
    ('ITEM008', '보조배터리 20000mAh',    'GENERAL',   'PB-20K',           'EA',  '8801643000008', 0.35,  0.3, 'SYSTEM');

-- =====================================================
-- 4. 사용자 샘플
-- (password는 bytea 타입: E'\\x...' 형식의 더미 해시값)
-- =====================================================

INSERT INTO wms.adm_userinfo (userid, company, usergroupcode, teamcode, username, email, tel, cellphone, ins_person_id) VALUES
    ('admin',    '본사', 'ADMIN',   'IT',   '시스템관리자', 'admin@wms.com',    '02-1234-0001', '010-0000-0001', 'SYSTEM'),
    ('manager1', '본사', 'MANAGER', 'WH01', '서울센터장',  'manager1@wms.com', '02-1234-0002', '010-0000-0002', 'SYSTEM'),
    ('manager2', '본사', 'MANAGER', 'WH03', '부산센터장',  'manager2@wms.com', '051-987-0001', '010-0000-0003', 'SYSTEM'),
    ('worker1',  '본사', 'WORKER',  'WH01', '입고작업자1', 'worker1@wms.com',  '02-1234-0003', '010-0000-0004', 'SYSTEM'),
    ('worker2',  '본사', 'WORKER',  'WH01', '출고작업자1', 'worker2@wms.com',  '02-1234-0004', '010-0000-0005', 'SYSTEM'),
    ('viewer1',  '본사', 'VIEWER',  'WH01', '조회자1',    'viewer1@wms.com',  '02-1234-0005', '010-0000-0006', 'SYSTEM');

-- =====================================================
-- 5. 입고 주문 샘플 (WH01 - 서울 물류센터)
-- =====================================================

-- 입고 1: 삼성 스마트폰 입고 (입고대기 상태)
INSERT INTO wms.twms_ib_inb_h (wh_cd, inb_no, ref_no, strr_id, inb_tcd, inb_ect_date, inb_scd, ins_person_id) VALUES
    ('WH01', 'INB20260224001', 'PO-2026-001', 'STRR001', '0', '2026-02-25', '00', 'worker1');

INSERT INTO wms.twms_ib_inb_d (wh_cd, inb_no, inb_detl_no, strr_id, item_cd, inb_ect_qty, inb_detl_scd, inspct_scd, to_wcell_no, ins_person_id) VALUES
    ('WH01', 'INB20260224001', 1, 'STRR001', 'ITEM001', 100, '00', '00', 'A-01-01', 'worker1'),
    ('WH01', 'INB20260224001', 2, 'STRR001', 'ITEM002',  50, '00', '00', 'A-01-02', 'worker1'),
    ('WH01', 'INB20260224001', 3, 'STRR001', 'ITEM003', 200, '00', '00', 'A-01-03', 'worker1');

-- 입고 2: LG 가전 입고 (검수중 상태)
INSERT INTO wms.twms_ib_inb_h (wh_cd, inb_no, ref_no, strr_id, inb_tcd, inb_ect_date, inb_scd, ins_person_id) VALUES
    ('WH01', 'INB20260224002', 'PO-2026-002', 'STRR002', '0', '2026-02-24', '10', 'worker1');

INSERT INTO wms.twms_ib_inb_d (wh_cd, inb_no, inb_detl_no, strr_id, item_cd, inb_ect_qty, inb_cmpt_qty, inb_detl_scd, inspct_scd, to_wcell_no, ins_person_id) VALUES
    ('WH01', 'INB20260224002', 1, 'STRR002', 'ITEM004', 20, 18, '10', '10', 'B-01-01', 'worker1'),
    ('WH01', 'INB20260224002', 2, 'STRR002', 'ITEM005', 10, 10, '10', '20', 'B-01-02', 'worker1');

-- 입고 3: 확정된 입고 (재고 반영용)
INSERT INTO wms.twms_ib_inb_h (wh_cd, inb_no, ref_no, strr_id, inb_tcd, inb_ect_date, inb_scd, inb_date, close_yn, ins_person_id) VALUES
    ('WH01', 'INB20260220001', 'PO-2026-000', 'STRR001', '0', '2026-02-20', '20', '2026-02-20', 'Y', 'worker1');

INSERT INTO wms.twms_ib_inb_d (wh_cd, inb_no, inb_detl_no, strr_id, item_cd, inb_ect_qty, inb_cmpt_qty, inb_detl_scd, inspct_scd, to_wcell_no, detl_inb_date, ins_person_id) VALUES
    ('WH01', 'INB20260220001', 1, 'STRR001', 'ITEM001', 200, 200, '20', '20', 'A-01-01', '2026-02-20', 'worker1'),
    ('WH01', 'INB20260220001', 2, 'STRR001', 'ITEM008', 500, 500, '20', '20', 'A-02-01', '2026-02-20', 'worker1');

-- =====================================================
-- 6. 출고 주문 샘플
-- =====================================================

-- 출고 1: 쿠팡 출고 (출고대기 상태)
INSERT INTO wms.twms_ob_outb_h (wh_cd, outb_no, ref_no, strr_id, outb_tcd, outb_ect_date, outb_scd, del_yn, ins_person_id, ins_datetime) VALUES
    ('WH01', 'OUTB20260224001', 'SO-2026-001', 'STRR003', '0', '2026-02-25', '00', 'N', 'worker2', CURRENT_TIMESTAMP);

INSERT INTO wms.twms_ob_outb_d (wh_cd, outb_no, outb_detl_no, item_cd, order_qty, outb_detl_scd, del_yn, invn_scd, strr_id, ins_person_id, ins_datetime) VALUES
    ('WH01', 'OUTB20260224001', 1, 'ITEM001', 30, '00', 'N', '1', 'STRR003', 'worker2', CURRENT_TIMESTAMP),
    ('WH01', 'OUTB20260224001', 2, 'ITEM008', 50, '00', 'N', '1', 'STRR003', 'worker2', CURRENT_TIMESTAMP);

-- 출고 2: 신세계 출고 (할당 완료 상태)
INSERT INTO wms.twms_ob_outb_h (wh_cd, outb_no, ref_no, strr_id, outb_tcd, outb_ect_date, outb_scd, del_yn, ins_person_id, ins_datetime) VALUES
    ('WH01', 'OUTB20260224002', 'SO-2026-002', 'STRR004', '0', '2026-02-25', '10', 'N', 'worker2', CURRENT_TIMESTAMP);

INSERT INTO wms.twms_ob_outb_d (wh_cd, outb_no, outb_detl_no, item_cd, order_qty, laloc_qty, laloc_yn, laloc_scd, outb_detl_scd, del_yn, invn_scd, strr_id, laloc_datetime, ins_person_id, ins_datetime) VALUES
    ('WH01', 'OUTB20260224002', 1, 'ITEM001', 10, 10, 'Y', '10', '10', 'N', '1', 'STRR004', CURRENT_TIMESTAMP, 'worker2', CURRENT_TIMESTAMP);

-- =====================================================
-- 7. 재고 샘플 (확정된 입고에 대한 재고)
-- =====================================================

-- LOT 마스터
INSERT INTO wms.twms_iv_lot (wh_cd, lot_no, strr_id, item_cd, prdt_lot_no, inb_date, invn_scd, src_no, ins_person_id) VALUES
    ('WH01', 'WH01-INB20260220001-1', 'STRR001', 'ITEM001', 'LOT-S25-001',  '2026-02-20', '1', 'INB20260220001', 'SYSTEM'),
    ('WH01', 'WH01-INB20260220001-2', 'STRR001', 'ITEM008', 'LOT-PB20K-001', '2026-02-20', '1', 'INB20260220001', 'SYSTEM');

-- 셀별 재고
INSERT INTO wms.twms_iv_invn (wh_cd, wcell_no, lot_no, invn_qty, ins_person_id, ins_datetime) VALUES
    ('WH01', 'A-01-01', 'WH01-INB20260220001-1', 200, 'SYSTEM', CURRENT_TIMESTAMP),
    ('WH01', 'A-02-01', 'WH01-INB20260220001-2', 500, 'SYSTEM', CURRENT_TIMESTAMP);

-- 품목별 재고 집계
INSERT INTO wms.twms_iv_invn_item (wh_cd, lot_no, item_cd, strr_id, invn_qty, avlb_qty, prcs_qty, ins_person_id, ins_datetime) VALUES
    ('WH01', 'WH01-INB20260220001-1', 'ITEM001', 'STRR001', 200, 190, 10, 'SYSTEM', CURRENT_TIMESTAMP),
    ('WH01', 'WH01-INB20260220001-2', 'ITEM008', 'STRR001', 500, 500, 0,  'SYSTEM', CURRENT_TIMESTAMP);

-- LOT×셀 재고
INSERT INTO wms.twms_iv_invn_lot_cell (wh_cd, lot_no, wcell_no, item_cd, strr_id, invn_qty, avlb_qty, prcs_qty, ins_person_id) VALUES
    ('WH01', 'WH01-INB20260220001-1', 'A-01-01', 'ITEM001', 'STRR001', 200, 190, 10, 'SYSTEM'),
    ('WH01', 'WH01-INB20260220001-2', 'A-02-01', 'ITEM008', 'STRR001', 500, 500, 0,  'SYSTEM');

-- =====================================================
-- 8. 상태 변경 이력 샘플
-- =====================================================

INSERT INTO wms.status_change_history (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by) VALUES
    ('WH01', 'twms_ib_inb_h', 'INB_NO=INB20260220001,WH_CD=WH01', '00', '10', 'INSPECT', 'worker1'),
    ('WH01', 'twms_ib_inb_h', 'INB_NO=INB20260220001,WH_CD=WH01', '10', '20', 'CONFIRM', 'worker1'),
    ('WH01', 'twms_ib_inb_h', 'INB_NO=INB20260224002,WH_CD=WH01', '00', '10', 'INSPECT', 'worker1'),
    ('WH01', 'twms_ob_outb_h', 'OUTB_NO=OUTB20260224002,WH_CD=WH01', '00', '10', 'ALLOCATE', 'worker2');

-- =====================================================
-- 샘플 데이터 삽입 완료
-- 물류센터: 4건, 화주: 4건, 상품: 8건, 사용자: 6건
-- 입고: 3건(헤더) + 7건(상세), 출고: 2건(헤더) + 3건(상세)
-- 재고 LOT: 2건, 셀재고: 2건, 품목재고: 2건, LOT×셀: 2건
-- 상태이력: 4건
-- =====================================================
