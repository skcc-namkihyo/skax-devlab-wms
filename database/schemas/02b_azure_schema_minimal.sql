-- =====================================================
-- Azure PostgreSQL: wms 스키마만 생성 (역할 스크립트 01 생략 시)
-- Purpose: 02_create_schema.sql 이 wms_admin_role 등에 의존하므로, Azure 단일 계정(tms_developer) 경로용 최소 스키마
-- 연결 대상 DB: wms
-- 실행 순서: 00_azure_create_database_wms.sql 적용 후, 본 스크립트 → 03_create_tables_common.sql 부터
-- =====================================================

CREATE SCHEMA IF NOT EXISTS wms;

COMMENT ON SCHEMA wms IS 'WMS 업무 스키마 (Azure 최소 부트스트랩)';
