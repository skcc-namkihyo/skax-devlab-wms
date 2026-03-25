-- =====================================================
-- WMS DB 구축 전체 검증 스크립트 (01~15단계)
-- Purpose: 01~15번 스크립트가 모두 정상 적용되었는지 확인
-- 실행 환경: wmsdb 데이터베이스에 연결된 상태에서 실행
-- 생성일자: 2026-03-12
-- =====================================================

-- =====================================================
-- [검증 결과 요약 뷰]
-- 각 섹션별 결과를 확인 후 PASS/FAIL 여부를 판단하세요.
-- 기대값과 실제값이 다르면 해당 단계 스크립트를 재실행하세요.
-- =====================================================


-- =====================================================
-- [01단계] 역할(Role) 및 사용자(User) 생성 확인
-- 스크립트: 01_create_roles_and_users.sql
-- ※ 역할/사용자는 pg_catalog에서 확인 (wmsdb 외부 객체)
-- =====================================================

SELECT '=== [01단계] 역할(Role) 확인 ===' AS check_section;

SELECT
    rolname                AS role_name,
    rolcanlogin            AS can_login,
    CASE WHEN rolcanlogin THEN 'USER' ELSE 'ROLE' END AS type,
    CASE WHEN rolname IN ('wms_admin_role','wms_developer_role','wms_api_role','wms_readonly_role',
                          'wms_admin','wms_developer','wms_api','wms_readonly')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM pg_catalog.pg_roles
WHERE rolname IN (
    'wms_admin_role', 'wms_developer_role', 'wms_api_role', 'wms_readonly_role',
    'wms_admin', 'wms_developer', 'wms_api', 'wms_readonly'
)
ORDER BY rolcanlogin, rolname;

-- 기대: 8건 (4 역할 + 4 사용자)
SELECT '역할+사용자 총 건수 (기대: 8)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 8 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM pg_catalog.pg_roles
WHERE rolname IN (
    'wms_admin_role', 'wms_developer_role', 'wms_api_role', 'wms_readonly_role',
    'wms_admin', 'wms_developer', 'wms_api', 'wms_readonly'
);


-- =====================================================
-- [02단계] 스키마(Schema) 생성 확인
-- 스크립트: 02_create_schema.sql
-- =====================================================

SELECT '=== [02단계] 스키마 확인 ===' AS check_section;

SELECT
    schema_name                     AS schema_name,
    schema_owner                    AS owner,
    CASE WHEN schema_name = 'wms' THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.schemata
WHERE schema_name = 'wms';

-- 기대: wms 스키마 1건
SELECT '스키마 존재 여부 (기대: 1)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.schemata
WHERE schema_name = 'wms';


-- =====================================================
-- [03단계] 공통 마스터 테이블 생성 확인
-- 스크립트: 03_create_tables_common.sql
-- 테이블: common_code_group, common_code, warehouse, item_master, shipper
-- =====================================================

SELECT '=== [03단계] 공통 마스터 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('common_code_group','common_code','warehouse','item_master','shipper')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('common_code_group','common_code','warehouse','item_master','shipper')
ORDER BY table_name;

SELECT '공통 마스터 테이블 수 (기대: 5)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 5 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('common_code_group','common_code','warehouse','item_master','shipper');


-- =====================================================
-- [04단계] 사용자 관리 테이블 생성 확인
-- 스크립트: 04_create_tables_user.sql
-- 테이블: adm_userinfo, adm_user_session
-- =====================================================

SELECT '=== [04단계] 사용자 관리 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('adm_userinfo','adm_user_session')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('adm_userinfo','adm_user_session')
ORDER BY table_name;

SELECT '사용자 관리 테이블 수 (기대: 2)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 2 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('adm_userinfo','adm_user_session');


-- =====================================================
-- [05단계] 입고 테이블 생성 확인
-- 스크립트: 05_create_tables_inbound.sql
-- 테이블: twms_ib_inb_h, twms_ib_inb_d
-- =====================================================

SELECT '=== [05단계] 입고 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('twms_ib_inb_h','twms_ib_inb_d')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_ib_inb_h','twms_ib_inb_d')
ORDER BY table_name;

SELECT '입고 테이블 수 (기대: 2)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 2 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_ib_inb_h','twms_ib_inb_d');


-- =====================================================
-- [06단계] 출고 테이블 생성 확인
-- 스크립트: 06_create_tables_outbound.sql
-- 테이블: twms_ob_outb_h, twms_ob_outb_d
-- =====================================================

SELECT '=== [06단계] 출고 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('twms_ob_outb_h','twms_ob_outb_d')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_ob_outb_h','twms_ob_outb_d')
ORDER BY table_name;

SELECT '출고 테이블 수 (기대: 2)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 2 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_ob_outb_h','twms_ob_outb_d');


-- =====================================================
-- [07단계] 재고 테이블 생성 확인
-- 스크립트: 07_create_tables_inventory.sql
-- 테이블: twms_iv_lot, twms_iv_invn, twms_iv_invn_item, twms_iv_invn_lot_cell
-- =====================================================

SELECT '=== [07단계] 재고 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell')
ORDER BY table_name;

SELECT '재고 테이블 수 (기대: 4)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 4 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell');


-- =====================================================
-- [08단계] 배치 로그 테이블 생성 확인
-- 스크립트: 08_create_tables_batch_log.sql
-- 테이블: batch_job_log, batch_error_log
-- =====================================================

SELECT '=== [08단계] 배치 로그 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('batch_job_log','batch_error_log')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('batch_job_log','batch_error_log')
ORDER BY table_name;

SELECT '배치 로그 테이블 수 (기대: 2)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 2 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('batch_job_log','batch_error_log');


-- =====================================================
-- [09단계] 이력 테이블 생성 확인
-- 스크립트: 09_create_tables_status_history.sql
-- 테이블: status_change_history, screen_access_log
-- =====================================================

SELECT '=== [09단계] 이력 테이블 확인 ===' AS check_section;

SELECT
    table_name,
    CASE WHEN table_name IN ('status_change_history','screen_access_log')
         THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('status_change_history','screen_access_log')
ORDER BY table_name;

SELECT '이력 테이블 수 (기대: 2)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 2 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_name IN ('status_change_history','screen_access_log');


-- =====================================================
-- [03~09단계] 전체 테이블 목록 한번에 확인
-- =====================================================

SELECT '=== [03~09단계] wms 스키마 전체 테이블 목록 ===' AS check_section;

SELECT
    table_name                                       AS table_name,
    CASE
        WHEN table_name IN (
            'common_code_group','common_code','warehouse','item_master','shipper',
            'adm_userinfo','adm_user_session',
            'twms_ib_inb_h','twms_ib_inb_d',
            'twms_ob_outb_h','twms_ob_outb_d',
            'twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell',
            'batch_job_log','batch_error_log',
            'status_change_history','screen_access_log'
        ) THEN 'PASS ✓'
        ELSE 'UNEXPECTED'
    END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT '전체 테이블 수 (기대: 19)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 19 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.tables
WHERE table_schema = 'wms'
  AND table_type = 'BASE TABLE';


-- =====================================================
-- [10~12단계] 함수(Function) 생성 확인
-- 스크립트: 10_create_functions_inbound.sql
--           11_create_functions_outbound.sql
--           12_create_functions_inventory.sql
-- 함수: fn_inbound_inspect, fn_inbound_confirm, fn_inbound_cancel
--       fn_outbound_allocate, fn_outbound_pick, fn_outbound_confirm, fn_outbound_cancel
--       fn_inventory_move, fn_inventory_adjust
-- =====================================================

SELECT '=== [10~12단계] 함수(Function) 확인 ===' AS check_section;

SELECT
    routine_name                                    AS function_name,
    CASE
        WHEN routine_name IN (
            '10단계 (입고)',  'fn_inbound_inspect', 'fn_inbound_confirm', 'fn_inbound_cancel',
            '11단계 (출고)',  'fn_outbound_allocate', 'fn_outbound_pick', 'fn_outbound_confirm', 'fn_outbound_cancel',
            '12단계 (재고)',  'fn_inventory_move', 'fn_inventory_adjust'
        ) THEN 'PASS ✓'
        ELSE 'UNEXPECTED'
    END AS result
FROM information_schema.routines
WHERE routine_schema = 'wms'
  AND routine_type   = 'FUNCTION'
  AND routine_name IN (
      'fn_inbound_inspect', 'fn_inbound_confirm', 'fn_inbound_cancel',
      'fn_outbound_allocate', 'fn_outbound_pick', 'fn_outbound_confirm', 'fn_outbound_cancel',
      'fn_inventory_move', 'fn_inventory_adjust'
  )
ORDER BY routine_name;

SELECT '함수 수 (기대: 9)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 9 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.routines
WHERE routine_schema = 'wms'
  AND routine_type   = 'FUNCTION'
  AND routine_name IN (
      'fn_inbound_inspect', 'fn_inbound_confirm', 'fn_inbound_cancel',
      'fn_outbound_allocate', 'fn_outbound_pick', 'fn_outbound_confirm', 'fn_outbound_cancel',
      'fn_inventory_move', 'fn_inventory_adjust'
  );


-- =====================================================
-- [13단계] 권한(Grant) 부여 확인
-- 스크립트: 13_grant_permissions.sql
-- wms_api_role의 테이블 권한 확인
-- =====================================================

SELECT '=== [13단계] 권한(Grant) 확인 - wms_api_role ===' AS check_section;

SELECT
    grantee,
    table_name,
    string_agg(privilege_type, ', ' ORDER BY privilege_type) AS privileges,
    CASE WHEN COUNT(*) >= 4 THEN 'PASS ✓' ELSE 'PARTIAL △' END AS result
FROM information_schema.role_table_grants
WHERE table_schema = 'wms'
  AND grantee = 'wms_api_role'
  AND table_name IN (
      'common_code_group','common_code','warehouse','item_master','shipper',
      'adm_userinfo','adm_user_session',
      'twms_ib_inb_h','twms_ib_inb_d',
      'twms_ob_outb_h','twms_ob_outb_d',
      'twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell'
  )
GROUP BY grantee, table_name
ORDER BY table_name;

SELECT '권한 부여된 핵심 테이블 수 (기대: 15)' AS check_item, COUNT(DISTINCT table_name) AS actual_count,
       CASE WHEN COUNT(DISTINCT table_name) = 15 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM information_schema.role_table_grants
WHERE table_schema = 'wms'
  AND grantee = 'wms_api_role'
  AND table_name IN (
      'common_code_group','common_code','warehouse','item_master','shipper',
      'adm_userinfo','adm_user_session',
      'twms_ib_inb_h','twms_ib_inb_d',
      'twms_ob_outb_h','twms_ob_outb_d',
      'twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell'
  );


-- =====================================================
-- [14단계] 공통코드 초기 데이터 삽입 확인
-- 스크립트: 14_insert_common_codes.sql
-- =====================================================

SELECT '=== [14단계] 공통코드 데이터 확인 ===' AS check_section;

-- 코드그룹 확인
SELECT
    code_group_id,
    code_group_name,
    use_yn,
    CASE WHEN use_yn = 'Y' THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM wms.common_code_group
ORDER BY code_group_id;

SELECT '공통코드 그룹 수 (기대: 20)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) = 20 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM wms.common_code_group;

-- 코드 상세 건수 확인
SELECT '공통코드 상세 건수 (기대: 1건 이상)' AS check_item, COUNT(*) AS actual_count,
       CASE WHEN COUNT(*) > 0 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM wms.common_code;

-- 핵심 코드그룹별 코드 수
SELECT
    code_group_id,
    COUNT(*) AS code_count
FROM wms.common_code
GROUP BY code_group_id
ORDER BY code_group_id;


-- =====================================================
-- [15단계] 샘플 데이터 삽입 확인
-- 스크립트: 15_insert_sample_data.sql
-- =====================================================

SELECT '=== [15단계] 샘플 데이터 확인 ===' AS check_section;

SELECT '물류센터(warehouse)'    AS table_name, COUNT(*) AS row_count,
       CASE WHEN COUNT(*) >= 4 THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM wms.warehouse
UNION ALL
SELECT '화주(shipper)',          COUNT(*), CASE WHEN COUNT(*) >= 4 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.shipper
UNION ALL
SELECT '상품(item_master)',      COUNT(*), CASE WHEN COUNT(*) >= 5 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.item_master
UNION ALL
SELECT '사용자(adm_userinfo)',   COUNT(*), CASE WHEN COUNT(*) >= 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.adm_userinfo
UNION ALL
SELECT '입고헤더(twms_ib_inb_h)', COUNT(*), CASE WHEN COUNT(*) >= 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.twms_ib_inb_h
UNION ALL
SELECT '입고상세(twms_ib_inb_d)', COUNT(*), CASE WHEN COUNT(*) >= 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.twms_ib_inb_d
UNION ALL
SELECT '출고헤더(twms_ob_outb_h)', COUNT(*), CASE WHEN COUNT(*) >= 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.twms_ob_outb_h
UNION ALL
SELECT '출고상세(twms_ob_outb_d)', COUNT(*), CASE WHEN COUNT(*) >= 1 THEN 'PASS ✓' ELSE 'FAIL ✗' END
FROM wms.twms_ob_outb_d
ORDER BY table_name;


-- =====================================================
-- [최종 요약] 단계별 전체 현황 한눈에 보기
-- =====================================================

SELECT '=== [최종 요약] 단계별 검증 결과 ===' AS check_section;

SELECT step, description, expected, actual,
       CASE WHEN actual = expected THEN 'PASS ✓' ELSE 'FAIL ✗' END AS result
FROM (
    -- 01: 역할+사용자
    SELECT '01' AS step, '역할+사용자 수' AS description, 8 AS expected,
           (SELECT COUNT(*)::int FROM pg_catalog.pg_roles
            WHERE rolname IN ('wms_admin_role','wms_developer_role','wms_api_role','wms_readonly_role',
                              'wms_admin','wms_developer','wms_api','wms_readonly')) AS actual
    UNION ALL
    -- 02: 스키마
    SELECT '02', 'wms 스키마 존재', 1,
           (SELECT COUNT(*)::int FROM information_schema.schemata WHERE schema_name = 'wms')
    UNION ALL
    -- 03~09: 전체 테이블
    SELECT '03~09', '전체 테이블 수', 19,
           (SELECT COUNT(*)::int FROM information_schema.tables
            WHERE table_schema = 'wms' AND table_type = 'BASE TABLE')
    UNION ALL
    -- 10~12: 함수
    SELECT '10~12', '함수(Function) 수', 9,
           (SELECT COUNT(*)::int FROM information_schema.routines
            WHERE routine_schema = 'wms' AND routine_type = 'FUNCTION'
              AND routine_name IN (
                  'fn_inbound_inspect','fn_inbound_confirm','fn_inbound_cancel',
                  'fn_outbound_allocate','fn_outbound_pick','fn_outbound_confirm','fn_outbound_cancel',
                  'fn_inventory_move','fn_inventory_adjust'))
    UNION ALL
    -- 13: 권한
    SELECT '13', 'wms_api_role 권한 테이블 수', 15,
           (SELECT COUNT(DISTINCT table_name)::int FROM information_schema.role_table_grants
            WHERE table_schema = 'wms' AND grantee = 'wms_api_role'
              AND table_name IN (
                  'common_code_group','common_code','warehouse','item_master','shipper',
                  'adm_userinfo','adm_user_session',
                  'twms_ib_inb_h','twms_ib_inb_d',
                  'twms_ob_outb_h','twms_ob_outb_d',
                  'twms_iv_lot','twms_iv_invn','twms_iv_invn_item','twms_iv_invn_lot_cell'))
    UNION ALL
    -- 14: 공통코드 그룹
    SELECT '14', '공통코드 그룹 수', 20,
           (SELECT COUNT(*)::int FROM wms.common_code_group)
    UNION ALL
    -- 15: 샘플 물류센터
    SELECT '15', '샘플 물류센터 수 (최소)', 4,
           LEAST((SELECT COUNT(*)::int FROM wms.warehouse), 4)
) summary
ORDER BY step;
