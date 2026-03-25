-- =====================================================
-- Azure PostgreSQL: tms_developer 에 wms 스키마 권한 부여
-- Purpose: DBA가 03~12, 14~16 DDL/데이터를 적용한 뒤, 앱 계정이 CRUD·함수 실행 가능하도록 설정 (13단계 대체)
-- 연결 대상 DB: wms
-- 실행 계정: DDL을 수행한 DBA(azure_pg_admin 등, 스키마 내 객체 소유자)
-- =====================================================

GRANT USAGE ON SCHEMA wms TO tms_developer;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA wms TO tms_developer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA wms TO tms_developer;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA wms TO tms_developer;

ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO tms_developer;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT USAGE, SELECT ON SEQUENCES TO tms_developer;
ALTER DEFAULT PRIVILEGES IN SCHEMA wms GRANT EXECUTE ON FUNCTIONS TO tms_developer;
