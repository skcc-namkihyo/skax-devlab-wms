-- =====================================================
-- WMS 로그·이력 데모 데이터 (테이블이 비어 있을 때만 삽입)
-- 프론트 Mock(batch-job-logs.json 등)과 유사한 형태
-- =====================================================

DO $$
DECLARE
    id_partial int;
BEGIN
    IF EXISTS (SELECT 1 FROM wms.batch_job_log LIMIT 1) THEN
        RAISE NOTICE 'batch_job_log 에 이미 데이터가 있어 데모 삽입을 건너뜁니다.';
        RETURN;
    END IF;

    INSERT INTO wms.batch_job_log (
        wh_cd, batch_type, batch_name, start_datetime, end_datetime, status,
        total_count, success_count, error_count, skip_count, error_message
    ) VALUES
    (
        'WH01', 'INBOUND_ORDER', '입고주문생성',
        '2026-03-25 01:00:00', '2026-03-25 01:12:33', 'PARTIAL',
        1200, 1180, 15, 5, '일부 참조번호 유효성 오류'
    ),
    (
        'WH01', 'OUTBOUND_ORDER', '출고주문생성',
        '2026-03-24 22:00:00', '2026-03-24 22:05:10', 'COMPLETED',
        800, 800, 0, 0, NULL
    ),
    (
        'WH02', 'INBOUND_ORDER', '입고주문생성',
        '2026-03-24 18:00:00', '2026-03-24 18:00:45', 'FAILED',
        500, 0, 500, 0, 'DB 연결 타임아웃'
    );

    SELECT batch_log_id INTO id_partial
    FROM wms.batch_job_log
    WHERE status = 'PARTIAL' AND wh_cd = 'WH01'
    ORDER BY batch_log_id ASC
    LIMIT 1;

    INSERT INTO wms.batch_error_log (
        batch_log_id, ref_no, ref_detl_no, error_code, error_message, retry_count, retry_status, ins_datetime
    ) VALUES
    (id_partial, 'IN-20260325-0001', '1', 'E1001', '상품 마스터 미존재', 0, 'PENDING', '2026-03-25 01:05:12'),
    (id_partial, 'IN-20260325-0002', '1', 'E3001', '입력값 형식 오류(수량)', 1, 'RETRIED', '2026-03-25 01:06:01');

    INSERT INTO wms.status_change_history (
        wh_cd, table_name, record_key, old_status, new_status, change_type, change_reason, changed_by, changed_at
    ) VALUES
    (
        'WH01', 'twms_ib_inb_h', 'WH01|INB-20260325-0001',
        'RECV', 'INSPECT', 'INSPECT', NULL, 'user02', '2026-03-25 09:00:00'
    ),
    (
        'WH01', 'twms_ib_inb_h', 'WH01|INB-20260325-0001',
        'INSPECT', 'CONFIRMED', 'CONFIRM', '검수 완료', 'user01', '2026-03-25 10:15:00'
    );

    INSERT INTO wms.screen_access_log (
        userid, screen_id, screen_name, access_type, result_count, ip_address, accessed_at
    ) VALUES
    (
        'auditor01', 'SCR-PII-CUSTOMER', '고객(개인정보) 상세',
        'SEARCH', 1, '10.0.0.12', '2026-03-25 11:00:00'
    ),
    (
        'auditor01', 'SCR-PII-CUSTOMER', '고객(개인정보) 상세',
        'DOWNLOAD', 1, '10.0.0.12', '2026-03-25 11:05:00'
    );

    RAISE NOTICE '데모 데이터 삽입 완료 (오류 상세 연결 batch_log_id=%)', id_partial;
END $$;
