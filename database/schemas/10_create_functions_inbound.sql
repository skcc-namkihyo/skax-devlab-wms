-- =====================================================
-- WMS 입고 프로세스 함수 생성 스크립트
-- Purpose: 입고 검수, 확정, 취소 프로세스 함수 생성
-- Scope: fn_inbound_inspect, fn_inbound_confirm, fn_inbound_cancel
-- 실행 전: 09_create_tables_status_history.sql 실행 완료 확인
-- 실행 순서: 10단계
-- PRD 참조: wms_prd.md 섹션 3.2, 7.1, 7.2
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 입고 검수 처리 함수
-- INB_SCD: 00(대기) -> 10(검수중)
-- INSPCT_SCD: 00(미검수) -> 10(검수중) or 20(검수완료)
-- PRD 섹션 3.2: 입고 검수 프로세스, 섹션 7.1: 상태 변경은 저장 프로시저 내에서 처리
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_inbound_inspect(
    p_wh_cd         varchar,
    p_inb_no        varchar,
    p_inb_detl_no   int DEFAULT NULL,
    p_inspct_scd    varchar DEFAULT '10',
    p_infr_qty      double precision DEFAULT 0,
    p_inb_cmpt_qty  double precision DEFAULT NULL,
    p_user_id       varchar DEFAULT 'SYSTEM'
)
RETURNS TABLE (
    result_code    varchar,
    result_message varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_scd   varchar(10);
    v_header_scd    varchar(10);
BEGIN
    SELECT inb_scd INTO v_header_scd
    FROM wms.twms_ib_inb_h
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '입고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    -- 상태 역행 방지 (PRD 섹션 7.2): 확정(20) 이후에는 검수 불가
    IF v_header_scd >= '20' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 입고건은 검수할 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF p_inb_detl_no IS NOT NULL THEN
        UPDATE wms.twms_ib_inb_d
        SET inspct_scd    = p_inspct_scd,
            infr_qty      = COALESCE(p_infr_qty, infr_qty),
            inb_cmpt_qty  = COALESCE(p_inb_cmpt_qty, inb_cmpt_qty),
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE inb_no = p_inb_no AND inb_detl_no = p_inb_detl_no AND wh_cd = p_wh_cd;
    ELSE
        UPDATE wms.twms_ib_inb_d
        SET inspct_scd    = p_inspct_scd,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd AND del_yn = 'N';
    END IF;

    IF v_header_scd = '00' THEN
        UPDATE wms.twms_ib_inb_h
        SET inb_scd       = '10',
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd;

        INSERT INTO wms.status_change_history
            (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by)
        VALUES
            (p_wh_cd, 'twms_ib_inb_h', 'INB_NO=' || p_inb_no || ',WH_CD=' || p_wh_cd,
             '00', '10', 'INSPECT', p_user_id);
    END IF;

    RETURN QUERY SELECT 'OK'::varchar, '검수 처리가 완료되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_inbound_inspect IS '입고 검수 처리 함수 - INB_SCD 00->10, INSPCT_SCD 변경';

-- =====================================================
-- 2. 입고 확정 함수
-- INB_SCD: 10(검수) -> 20(확정)
-- 확정 시 재고 테이블(twms_iv_*)에 반영
-- PRD 섹션 3.2: 입고확정 후 재고 반영, 섹션 7.1
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_inbound_confirm(
    p_wh_cd     varchar,
    p_inb_no    varchar,
    p_user_id   varchar DEFAULT 'SYSTEM'
)
RETURNS TABLE (
    result_code    varchar,
    result_message varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_scd   varchar(10);
    v_detail        RECORD;
    v_lot_no        varchar(30);
    v_lot_exists    boolean;
BEGIN
    SELECT inb_scd INTO v_current_scd
    FROM wms.twms_ib_inb_h
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '입고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '20' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 입고건입니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd < '10' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '검수가 완료되지 않은 입고건입니다. 먼저 검수를 진행하세요.'::varchar;
        RETURN;
    END IF;

    FOR v_detail IN
        SELECT * FROM wms.twms_ib_inb_d
        WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd AND del_yn = 'N'
    LOOP
        v_lot_no := p_wh_cd || '-' || p_inb_no || '-' || v_detail.inb_detl_no;

        SELECT EXISTS(
            SELECT 1 FROM wms.twms_iv_lot WHERE wh_cd = p_wh_cd AND lot_no = v_lot_no
        ) INTO v_lot_exists;

        IF NOT v_lot_exists THEN
            INSERT INTO wms.twms_iv_lot (wh_cd, lot_no, strr_id, item_cd, prdt_lot_no,
                                         inb_date, prdt_date, invn_scd, src_no, ins_person_id)
            VALUES (p_wh_cd, v_lot_no, v_detail.strr_id, v_detail.item_cd, v_detail.prdt_lot_no,
                    CURRENT_TIMESTAMP, v_detail.prdt_date, COALESCE(v_detail.invn_scd, '1'),
                    p_inb_no, p_user_id);
        END IF;

        INSERT INTO wms.twms_iv_invn_item (wh_cd, lot_no, item_cd, strr_id, invn_qty, avlb_qty,
                                           ins_person_id, ins_datetime)
        VALUES (p_wh_cd, v_lot_no, v_detail.item_cd, COALESCE(v_detail.strr_id, '0'),
                COALESCE(v_detail.inb_cmpt_qty, v_detail.inb_ect_qty),
                COALESCE(v_detail.inb_cmpt_qty, v_detail.inb_ect_qty),
                p_user_id, CURRENT_TIMESTAMP)
        ON CONFLICT (wh_cd, lot_no) DO UPDATE
        SET invn_qty      = wms.twms_iv_invn_item.invn_qty + EXCLUDED.invn_qty,
            avlb_qty      = wms.twms_iv_invn_item.avlb_qty + EXCLUDED.avlb_qty,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP;

        IF v_detail.to_wcell_no IS NOT NULL THEN
            INSERT INTO wms.twms_iv_invn (wh_cd, wcell_no, lot_no, invn_qty, ins_person_id, ins_datetime)
            VALUES (p_wh_cd, v_detail.to_wcell_no, v_lot_no,
                    COALESCE(v_detail.inb_cmpt_qty, v_detail.inb_ect_qty),
                    p_user_id, CURRENT_TIMESTAMP)
            ON CONFLICT (wh_cd, wcell_no, lot_no) DO UPDATE
            SET invn_qty      = wms.twms_iv_invn.invn_qty + EXCLUDED.invn_qty,
                upd_person_id = p_user_id,
                upd_datetime  = CURRENT_TIMESTAMP;

            INSERT INTO wms.twms_iv_invn_lot_cell (wh_cd, lot_no, wcell_no, item_cd, strr_id,
                                                   invn_qty, avlb_qty, ins_person_id)
            VALUES (p_wh_cd, v_lot_no, v_detail.to_wcell_no, v_detail.item_cd,
                    v_detail.strr_id,
                    COALESCE(v_detail.inb_cmpt_qty, v_detail.inb_ect_qty),
                    COALESCE(v_detail.inb_cmpt_qty, v_detail.inb_ect_qty),
                    p_user_id)
            ON CONFLICT (wh_cd, lot_no, wcell_no) DO UPDATE
            SET invn_qty      = wms.twms_iv_invn_lot_cell.invn_qty + EXCLUDED.invn_qty,
                avlb_qty      = wms.twms_iv_invn_lot_cell.avlb_qty + EXCLUDED.avlb_qty,
                upd_person_id = p_user_id,
                upd_datetime  = CURRENT_TIMESTAMP;
        END IF;

        UPDATE wms.twms_ib_inb_d
        SET inb_detl_scd  = '20',
            inspct_scd    = '20',
            detl_inb_date = CURRENT_TIMESTAMP,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE inb_no = p_inb_no AND inb_detl_no = v_detail.inb_detl_no AND wh_cd = p_wh_cd;
    END LOOP;

    UPDATE wms.twms_ib_inb_h
    SET inb_scd       = '20',
        inb_date      = CURRENT_TIMESTAMP,
        close_yn      = 'Y',
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ib_inb_h', 'INB_NO=' || p_inb_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, '20', 'CONFIRM', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '입고 확정이 완료되었습니다. 재고에 반영되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_inbound_confirm IS '입고 확정 함수 - INB_SCD 10->20, 재고 반영 (LOT/셀/품목)';

-- =====================================================
-- 3. 입고 취소 함수
-- DEL_YN: N -> Y (논리 삭제)
-- PRD 섹션 7.2: 상태 역행 방지 - 확정 후에는 취소 불가
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_inbound_cancel(
    p_wh_cd     varchar,
    p_inb_no    varchar,
    p_reason    varchar DEFAULT NULL,
    p_user_id   varchar DEFAULT 'SYSTEM'
)
RETURNS TABLE (
    result_code    varchar,
    result_message varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_scd varchar(10);
BEGIN
    SELECT inb_scd INTO v_current_scd
    FROM wms.twms_ib_inb_h
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '입고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '20' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 입고건은 취소할 수 없습니다.'::varchar;
        RETURN;
    END IF;

    UPDATE wms.twms_ib_inb_h
    SET del_yn         = 'Y',
        upd_person_id  = p_user_id,
        upd_datetime   = CURRENT_TIMESTAMP
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd;

    UPDATE wms.twms_ib_inb_d
    SET del_yn         = 'Y',
        upd_person_id  = p_user_id,
        upd_datetime   = CURRENT_TIMESTAMP
    WHERE inb_no = p_inb_no AND wh_cd = p_wh_cd;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_reason, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ib_inb_h', 'INB_NO=' || p_inb_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, 'DEL', COALESCE(p_reason, '사용자 취소'), 'CANCEL', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '입고 취소가 완료되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_inbound_cancel IS '입고 취소 함수 - DEL_YN 처리, 확정(20) 이후 취소 불가';

-- =====================================================
-- 다음 단계: 11_create_functions_outbound.sql 실행
-- =====================================================
