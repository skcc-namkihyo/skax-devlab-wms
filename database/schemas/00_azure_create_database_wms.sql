-- =====================================================
-- Azure PostgreSQL: 데이터베이스 wms 생성 및 앱 계정 권한
-- Purpose: JDBC URL의 dbname=wms 와 일치시키고 tms_developer 가 접속·객체 생성 가능하게 함
-- 연결 대상 DB: postgres (기본 DB)
-- 실행 계정: azure_pg_admin 또는 CREATEDB·GRANT 가능한 DBA
-- 주의: CREATE DATABASE 는 트랜잭션 블록 안에서 실행할 수 없음
-- 다음 단계: \c wms 또는 psql -d wms 로 전환 후 02b → 03 … 순서 실행
-- =====================================================

CREATE DATABASE wms;

GRANT CONNECT ON DATABASE wms TO tms_developer;
GRANT CREATE ON DATABASE wms TO tms_developer;
