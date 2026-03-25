-- =====================================================
-- WMS 공통코드 초기 데이터 삽입 스크립트
-- Purpose: 시스템 운영에 필요한 공통코드 초기 데이터 삽입
-- Scope: 입고상태, 출고상태, 재고상태, 검수상태, 입출고유형, 사용자그룹 등
-- 실행 전: 13_grant_permissions.sql 실행 완료 확인
-- 실행 순서: 14단계
-- PRD 참조: wms_prd.md 섹션 3.1~3.4, 7.1
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 코드그룹 등록
-- =====================================================

INSERT INTO wms.common_code_group (code_group_id, code_group_name, description, ins_person_id) VALUES
    ('INB_SCD',       '입고상태코드',     '입고 헤더 상태 코드',           'SYSTEM'),
    ('INB_TCD',       '입고유형코드',     '입고 유형 (정상, 반품 등)',       'SYSTEM'),
    ('INB_DETL_SCD',  '입고상세상태코드',  '입고 상세 라인 상태 코드',        'SYSTEM'),
    ('INSPCT_SCD',    '검수상태코드',     '입고 검수 상태 코드',           'SYSTEM'),
    ('OUTB_SCD',      '출고상태코드',     '출고 헤더 상태 코드',           'SYSTEM'),
    ('OUTB_TCD',      '출고유형코드',     '출고 유형 (정상, 반품 등)',       'SYSTEM'),
    ('OUTB_DETL_SCD', '출고상세상태코드',  '출고 상세 라인 상태 코드',        'SYSTEM'),
    ('LALOC_SCD',     '할당상태코드',     '출고 할당 상태 코드',           'SYSTEM'),
    ('INVN_SCD',      '재고상태코드',     '재고 상태 코드 (양품, 불량 등)',    'SYSTEM'),
    ('ITEM_SCD',      '상품상태코드',     '상품 상태 코드',              'SYSTEM'),
    ('ITEM_TYPE',     '상품유형',        '상품 유형 분류',              'SYSTEM'),
    ('ITEM_UNIT',     '상품단위',        '상품 단위 (EA, BOX 등)',       'SYSTEM'),
    ('WH_TYPE',       '창고유형',        '창고 유형 분류',              'SYSTEM'),
    ('STRR_TYPE',     '거래처유형',       '화주/거래처 유형 분류',          'SYSTEM'),
    ('USER_GROUP',    '사용자그룹',       '사용자 그룹 코드',             'SYSTEM'),
    ('BATCH_TYPE',    '배치유형',        '배치 작업 유형',              'SYSTEM'),
    ('BATCH_STATUS',  '배치상태',        '배치 실행 상태',              'SYSTEM'),
    ('ACCESS_TYPE',   '접근유형',        '화면 접근 유형',              'SYSTEM'),
    ('INB_WORK_TCD',  '입고작업유형코드',  '입고 작업 유형',              'SYSTEM'),
    ('OUTB_WORK_TCD', '출고작업유형코드',  '출고 작업 유형',              'SYSTEM');

-- =====================================================
-- 2. 입고 관련 코드
-- =====================================================

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INB_SCD', '00', '입고대기',   1, '입고 등록 후 검수 전 상태',         'SYSTEM'),
    ('INB_SCD', '10', '검수중',    2, '입고 검수 진행 중',              'SYSTEM'),
    ('INB_SCD', '20', '입고확정',   3, '입고 확정 완료, 재고 반영됨',       'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INB_TCD', '0', '정상입고',    1, '정상 입고',                     'SYSTEM'),
    ('INB_TCD', '1', '반품입고',    2, '반품에 의한 입고',               'SYSTEM'),
    ('INB_TCD', '2', '이관입고',    3, '센터 간 이관 입고',              'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INB_DETL_SCD', '00', '대기',      1, '입고 상세 대기',            'SYSTEM'),
    ('INB_DETL_SCD', '10', '검수중',    2, '검수 진행 중',              'SYSTEM'),
    ('INB_DETL_SCD', '20', '입고확정',   3, '입고 확정 완료',            'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INSPCT_SCD', '00', '미검수',     1, '검수 전',                    'SYSTEM'),
    ('INSPCT_SCD', '10', '검수중',     2, '검수 진행 중',               'SYSTEM'),
    ('INSPCT_SCD', '20', '검수완료',    3, '검수 완료',                  'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INB_WORK_TCD', '0', '일반입고',   1, '일반 입고 작업',              'SYSTEM'),
    ('INB_WORK_TCD', '1', '크로스도킹', 2, '크로스도킹 입고',             'SYSTEM');

-- =====================================================
-- 3. 출고 관련 코드
-- =====================================================

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('OUTB_SCD', '00', '출고대기',   1, '출고 등록 후 할당 전',           'SYSTEM'),
    ('OUTB_SCD', '10', '할당완료',   2, '로케이션 할당 완료',             'SYSTEM'),
    ('OUTB_SCD', '20', '피킹중',    3, '피킹 작업 진행 중',             'SYSTEM'),
    ('OUTB_SCD', '30', '피킹완료',   4, '피킹 작업 완료',               'SYSTEM'),
    ('OUTB_SCD', '40', '출고확정',   5, '출고 확정 완료, 재고 차감됨',      'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('OUTB_TCD', '0', '정상출고',    1, '정상 출고',                     'SYSTEM'),
    ('OUTB_TCD', '1', '반품출고',    2, '반품에 의한 출고',               'SYSTEM'),
    ('OUTB_TCD', '2', '이관출고',    3, '센터 간 이관 출고',              'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('OUTB_DETL_SCD', '00', '대기',      1, '출고 상세 대기',            'SYSTEM'),
    ('OUTB_DETL_SCD', '10', '할당완료',   2, '할당 완료',                'SYSTEM'),
    ('OUTB_DETL_SCD', '20', '피킹완료',   3, '피킹 완료',                'SYSTEM'),
    ('OUTB_DETL_SCD', '40', '출고확정',   4, '출고 확정 완료',            'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('LALOC_SCD', '00', '미할당',     1, '할당 전',                     'SYSTEM'),
    ('LALOC_SCD', '10', '할당완료',   2, '할당 완료',                   'SYSTEM'),
    ('LALOC_SCD', '20', '할당해제',   3, '할당 해제됨',                  'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('OUTB_WORK_TCD', '0', '일반출고',   1, '일반 출고 작업',              'SYSTEM'),
    ('OUTB_WORK_TCD', '1', '긴급출고',   2, '긴급 출고 작업',              'SYSTEM');

-- =====================================================
-- 4. 재고/상품 관련 코드
-- =====================================================

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('INVN_SCD', '1', '양품',     1, '정상 양품',                       'SYSTEM'),
    ('INVN_SCD', '2', '불량',     2, '불량품',                          'SYSTEM'),
    ('INVN_SCD', '3', '보류',     3, '보류 (판정 대기)',                  'SYSTEM'),
    ('INVN_SCD', '4', '폐기대기', 4, '폐기 대기',                        'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('ITEM_SCD', '00', '정상',     1, '정상 상태',                       'SYSTEM'),
    ('ITEM_SCD', '10', '단종',     2, '단종 상품',                       'SYSTEM'),
    ('ITEM_SCD', '20', '보류',     3, '보류 상태',                       'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('ITEM_TYPE', 'GENERAL',   '일반상품',   1, '일반 상품',               'SYSTEM'),
    ('ITEM_TYPE', 'DANGEROUS', '위험물',    2, '위험물',                   'SYSTEM'),
    ('ITEM_TYPE', 'COLD',      '냉장/냉동', 3, '냉장/냉동 상품',            'SYSTEM'),
    ('ITEM_TYPE', 'FRAGILE',   '파손주의',   4, '파손 주의 상품',            'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('ITEM_UNIT', 'EA',   '개',    1, '낱개',                           'SYSTEM'),
    ('ITEM_UNIT', 'BOX',  '박스',  2, '박스',                           'SYSTEM'),
    ('ITEM_UNIT', 'PLT',  '파렛트', 3, '파렛트',                         'SYSTEM'),
    ('ITEM_UNIT', 'SET',  '세트',  4, '세트',                           'SYSTEM'),
    ('ITEM_UNIT', 'KG',   'kg',   5, '킬로그램',                        'SYSTEM');

-- =====================================================
-- 5. 마스터 관련 코드
-- =====================================================

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('WH_TYPE', 'MAIN',     '메인창고',   1, '메인 물류센터',               'SYSTEM'),
    ('WH_TYPE', 'SUB',      '서브창고',   2, '서브 물류센터',               'SYSTEM'),
    ('WH_TYPE', 'RETURN',   '반품창고',   3, '반품 전용 창고',              'SYSTEM'),
    ('WH_TYPE', 'TEMP',     '임시창고',   4, '임시 보관 창고',              'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('STRR_TYPE', 'SUPPLIER',  '공급업체',   1, '공급업체 (입고)',             'SYSTEM'),
    ('STRR_TYPE', 'CUSTOMER',  '고객',      2, '고객 (출고)',               'SYSTEM'),
    ('STRR_TYPE', 'BOTH',      '공급/고객',  3, '공급 및 고객 겸용',           'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('USER_GROUP', 'ADMIN',      '시스템관리자', 1, '시스템 관리자 그룹',          'SYSTEM'),
    ('USER_GROUP', 'MANAGER',    '센터관리자',  2, '물류센터 관리자 그룹',         'SYSTEM'),
    ('USER_GROUP', 'WORKER',     '작업자',     3, '현장 작업자 그룹',            'SYSTEM'),
    ('USER_GROUP', 'VIEWER',     '조회자',     4, '조회 전용 그룹',              'SYSTEM');

-- =====================================================
-- 6. 배치/이력 관련 코드
-- =====================================================

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('BATCH_TYPE', 'INB_CREATE',  '입고생성',     1, '입고 배치 생성',             'SYSTEM'),
    ('BATCH_TYPE', 'OUTB_CREATE', '출고생성',     2, '출고 배치 생성',             'SYSTEM'),
    ('BATCH_TYPE', 'INB_RETRY',   '입고재처리',    3, '입고 오류 재처리',           'SYSTEM'),
    ('BATCH_TYPE', 'OUTB_RETRY',  '출고재처리',    4, '출고 오류 재처리',           'SYSTEM'),
    ('BATCH_TYPE', 'INVN_SYNC',   '재고동기화',    5, '재고 동기화 배치',           'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('BATCH_STATUS', 'RUNNING',   '실행중',     1, '배치 실행 중',               'SYSTEM'),
    ('BATCH_STATUS', 'COMPLETED', '완료',       2, '배치 정상 완료',              'SYSTEM'),
    ('BATCH_STATUS', 'FAILED',    '실패',       3, '배치 실패',                  'SYSTEM'),
    ('BATCH_STATUS', 'PARTIAL',   '부분완료',    4, '배치 부분 완료 (일부 오류)',     'SYSTEM');

INSERT INTO wms.common_code (code_group_id, code_id, code_name, sort_order, description, ins_person_id) VALUES
    ('ACCESS_TYPE', 'SEARCH',    '조회',       1, '화면 조회',                    'SYSTEM'),
    ('ACCESS_TYPE', 'DOWNLOAD',  '다운로드',    2, '데이터 다운로드',               'SYSTEM'),
    ('ACCESS_TYPE', 'EXPORT',    '내보내기',    3, '엑셀 등 내보내기',              'SYSTEM');

-- =====================================================
-- 다음 단계: 15_insert_sample_data.sql 실행
-- =====================================================
