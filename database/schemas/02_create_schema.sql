-- =====================================================
-- WMS 스키마 생성 및 기본 권한 부여 스크립트
-- Purpose: wms 스키마 생성 및 기본 권한 설정
-- Scope: 스키마 레벨 권한 및 향후 생성될 객체에 대한 기본 권한 설정
-- 실행 전: wmsdb 데이터베이스에 연결되어 있는지 확인
-- 실행 순서: 2단계 (01_create_roles_and_users.sql 실행 후)
-- PRD 참조: wms_prd.md 섹션 12
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 스키마 생성
-- =====================================================

CREATE SCHEMA IF NOT EXISTS wms;

ALTER SCHEMA wms OWNER TO wms_admin;

-- =====================================================
-- 2. 스키마 레벨 권한 부여
-- =====================================================

GRANT ALL PRIVILEGES ON SCHEMA wms TO wms_admin_role;
GRANT USAGE ON SCHEMA wms TO wms_developer_role;
GRANT USAGE ON SCHEMA wms TO wms_api_role;
GRANT USAGE ON SCHEMA wms TO wms_readonly_role;

-- =====================================================
-- 3. 향후 생성될 객체에 대한 기본 권한 설정
-- =====================================================

ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT ALL PRIVILEGES ON TABLES TO wms_admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT ALL PRIVILEGES ON SEQUENCES TO wms_admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT ALL PRIVILEGES ON FUNCTIONS TO wms_admin_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO wms_developer_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT USAGE ON SEQUENCES TO wms_developer_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT EXECUTE ON FUNCTIONS TO wms_developer_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO wms_api_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT USAGE ON SEQUENCES TO wms_api_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT EXECUTE ON FUNCTIONS TO wms_api_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT SELECT ON TABLES TO wms_readonly_role;

-- =====================================================
-- 스키마 생성 완료
-- 다음 단계: 03_create_tables_common.sql 실행
-- =====================================================
