-- =====================================================
-- WMS 전체 데이터 초기화 스크립트
-- Purpose: 모든 WMS 테이블 데이터 삭제 (스키마/구조 유지)
-- 주의: 이 스크립트를 실행하면 모든 데이터가 삭제됩니다!
-- 사용 환경: 개발/테스트 환경에서만 사용
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 실행 전 경고
-- =====================================================
-- !! 운영 환경에서 절대 실행하지 마세요 !!
-- !! 이 스크립트는 모든 데이터를 삭제합니다 !!

DO $$
BEGIN
    RAISE NOTICE '=== WMS 전체 데이터 초기화를 시작합니다 ===';
    RAISE NOTICE '경고: 이 작업은 되돌릴 수 없습니다!';
END;
$$;

-- =====================================================
-- FK 의존성 순서를 고려한 삭제 (자식 -> 부모 순)
-- =====================================================

-- 이력/로그 테이블 (의존성 없음)
TRUNCATE TABLE wms.screen_access_log RESTART IDENTITY CASCADE;
TRUNCATE TABLE wms.status_change_history RESTART IDENTITY CASCADE;

-- 배치 로그 (batch_error_log -> batch_job_log)
TRUNCATE TABLE wms.batch_error_log RESTART IDENTITY CASCADE;
TRUNCATE TABLE wms.batch_job_log RESTART IDENTITY CASCADE;

-- 재고 테이블
TRUNCATE TABLE wms.twms_iv_invn_lot_cell CASCADE;
TRUNCATE TABLE wms.twms_iv_invn_item CASCADE;
TRUNCATE TABLE wms.twms_iv_invn CASCADE;
TRUNCATE TABLE wms.twms_iv_lot CASCADE;

-- 출고 테이블 (상세 -> 헤더)
TRUNCATE TABLE wms.twms_ob_outb_d CASCADE;
TRUNCATE TABLE wms.twms_ob_outb_h CASCADE;

-- 입고 테이블 (상세 -> 헤더)
TRUNCATE TABLE wms.twms_ib_inb_d CASCADE;
TRUNCATE TABLE wms.twms_ib_inb_h CASCADE;

-- 사용자 테이블 (세션 -> 사용자)
TRUNCATE TABLE wms.adm_user_session CASCADE;
TRUNCATE TABLE wms.adm_userinfo CASCADE;

-- 공통 마스터
TRUNCATE TABLE wms.common_code CASCADE;
TRUNCATE TABLE wms.common_code_group CASCADE;
TRUNCATE TABLE wms.shipper CASCADE;
TRUNCATE TABLE wms.item_master CASCADE;
TRUNCATE TABLE wms.warehouse CASCADE;

DO $$
BEGIN
    RAISE NOTICE '=== WMS 전체 데이터 초기화가 완료되었습니다 ===';
END;
$$;

-- =====================================================
-- 초기화 후 공통코드를 다시 넣으려면:
-- \i 14_insert_common_codes.sql
-- \i 15_insert_sample_data.sql
-- =====================================================
