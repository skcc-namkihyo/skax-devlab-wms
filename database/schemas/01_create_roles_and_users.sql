-- =====================================================
-- WMS 역할 및 사용자 생성 스크립트
-- Purpose: 창고관리시스템(WMS)의 DB 역할 및 사용자 생성
-- Scope: 역할(Role), 사용자(User), 데이터베이스 생성
-- 실행 전: postgres 데이터베이스에 연결되어 있는지 확인
-- 실행 순서: 1단계 (가장 먼저 실행)
-- PRD 참조: wms_prd.md 섹션 12 (보안 및 권한 관리)
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 역할(Role) 생성
-- =====================================================

CREATE ROLE wms_admin_role;
CREATE ROLE wms_developer_role;
CREATE ROLE wms_api_role;
CREATE ROLE wms_readonly_role;

-- =====================================================
-- 2. 사용자(User) 생성
-- =====================================================

CREATE USER wms_admin WITH PASSWORD 'Admin@123!@#$%' IN ROLE wms_admin_role;
CREATE USER wms_developer WITH PASSWORD 'Dev@123!@#$%' IN ROLE wms_developer_role;
CREATE USER wms_api WITH PASSWORD 'Api@123!@#$%' IN ROLE wms_api_role;
CREATE USER wms_readonly WITH PASSWORD 'Read@123!@#$%' IN ROLE wms_readonly_role;

-- =====================================================
-- 3. 데이터베이스 생성
-- =====================================================

CREATE DATABASE wmsdb OWNER wms_admin;

-- =====================================================
-- 중요: 이 스크립트 실행 후
-- 1. wmsdb 데이터베이스로 연결을 전환하세요
-- 2. 다음 단계: 02_create_schema.sql 실행
-- =====================================================

-- Note: Please change the password in production environment
-- Note: The actual passwords should be stored securely and not in version control
