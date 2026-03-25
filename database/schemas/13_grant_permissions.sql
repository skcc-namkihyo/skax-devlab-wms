-- =====================================================
-- WMS 권한 부여 스크립트
-- Purpose: 전체 테이블/시퀀스/함수에 대한 역할별 권한 부여
-- Scope: wms_admin_role, wms_developer_role, wms_api_role, wms_readonly_role
-- 실행 전: 12_create_functions_inventory.sql 실행 완료 확인
-- 실행 순서: 13단계
-- PRD 참조: wms_prd.md 섹션 12
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. wms_admin_role (전체 관리 권한)
-- =====================================================

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wms TO wms_admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA wms TO wms_admin_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA wms TO wms_admin_role;

-- =====================================================
-- 2. wms_developer_role (개발용: CRUD + Function 실행)
-- =====================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA wms TO wms_developer_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA wms TO wms_developer_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA wms TO wms_developer_role;

-- =====================================================
-- 3. wms_api_role (API 서버용: CRUD + Function 실행)
-- =====================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA wms TO wms_api_role;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA wms TO wms_api_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA wms TO wms_api_role;

-- =====================================================
-- 4. wms_readonly_role (읽기 전용)
-- =====================================================

GRANT SELECT ON ALL TABLES IN SCHEMA wms TO wms_readonly_role;

-- =====================================================
-- 5. 개별 테이블 권한 명시 (문서화 목적)
-- =====================================================

-- 공통 마스터
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.common_code_group TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.common_code TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.warehouse TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.item_master TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.shipper TO wms_api_role;

-- 사용자 관리
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.adm_userinfo TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.adm_user_session TO wms_api_role;

-- 입고
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_ib_inb_h TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_ib_inb_d TO wms_api_role;

-- 출고
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_ob_outb_h TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_ob_outb_d TO wms_api_role;

-- 재고
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_iv_lot TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_iv_invn TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_iv_invn_item TO wms_api_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wms.twms_iv_invn_lot_cell TO wms_api_role;

-- 배치 로그
GRANT SELECT, INSERT, UPDATE ON wms.batch_job_log TO wms_api_role;
GRANT SELECT, INSERT ON wms.batch_error_log TO wms_api_role;

-- 이력
GRANT SELECT, INSERT ON wms.status_change_history TO wms_api_role;
GRANT SELECT, INSERT ON wms.screen_access_log TO wms_api_role;

-- 시퀀스
GRANT USAGE ON SEQUENCE wms.batch_job_log_batch_log_id_seq TO wms_api_role;
GRANT USAGE ON SEQUENCE wms.batch_error_log_error_log_id_seq TO wms_api_role;
GRANT USAGE ON SEQUENCE wms.status_change_history_history_id_seq TO wms_api_role;
GRANT USAGE ON SEQUENCE wms.screen_access_log_access_log_id_seq TO wms_api_role;

-- Function 실행 권한
GRANT EXECUTE ON FUNCTION wms.fn_inbound_inspect TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_inbound_confirm TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_inbound_cancel TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_outbound_allocate TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_outbound_pick TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_outbound_confirm TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_outbound_cancel TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_inventory_move TO wms_api_role;
GRANT EXECUTE ON FUNCTION wms.fn_inventory_adjust TO wms_api_role;

-- =====================================================
-- 다음 단계: 14_insert_common_codes.sql 실행
-- =====================================================
