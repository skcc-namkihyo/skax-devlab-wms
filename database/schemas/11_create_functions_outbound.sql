-- =====================================================
-- WMS 출고 프로세스 함수 생성 스크립트
-- Purpose: 출고 할당, 피킹, 확정, 취소 프로세스 함수 생성
-- Scope: fn_outbound_allocate, fn_outbound_pick, fn_outbound_confirm, fn_outbound_cancel
-- 실행 전: 10_create_functions_inbound.sql 실행 완료 확인
-- 실행 순서: 11단계
-- PRD 참조: wms_prd.md 섹션 3.3, 7.1, 7.2
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 출고 할당/지시 함수
-- OUTB_SCD 변경, LALOC_QTY 반영, 가용수량(avlb_qty) 차감 -> 처리중수량(prcs_qty) 증가
-- PRD 섹션 3.3: 출고 할당(로케이션 지정)
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_outbound_allocate(
    p_wh_cd         varchar,
    p_outb_no       varchar,
    p_outb_detl_no  int DEFAULT NULL,
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
    v_detail        RECORD;
    v_avlb_qty      double precision;
    v_alloc_qty     double precision;
BEGIN
    SELECT outb_scd INTO v_current_scd
    FROM wms.twms_ob_outb_h
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '출고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '40' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 출고건은 할당할 수 없습니다.'::varchar;
        RETURN;
    END IF;

    FOR v_detail IN
        SELECT * FROM wms.twms_ob_outb_d
        WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N'
          AND (p_outb_detl_no IS NULL OR outb_detl_no = p_outb_detl_no)
          AND COALESCE(laloc_yn, 'N') = 'N'
    LOOP
        v_alloc_qty := COALESCE(v_detail.order_qty, 0);

        SELECT COALESCE(SUM(avlb_qty), 0) INTO v_avlb_qty
        FROM wms.twms_iv_invn_item
        WHERE wh_cd = p_wh_cd AND item_cd = v_detail.item_cd;

        IF v_avlb_qty < v_alloc_qty THEN
            RETURN QUERY SELECT 'ERR'::varchar,
                ('상품 ' || v_detail.item_cd || '의 가용재고(' || v_avlb_qty || ')가 부족합니다. 필요: ' || v_alloc_qty)::varchar;
            RETURN;
        END IF;

        UPDATE wms.twms_iv_invn_item
        SET avlb_qty      = avlb_qty - v_alloc_qty,
            prcs_qty      = prcs_qty + v_alloc_qty,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE wh_cd = p_wh_cd AND item_cd = v_detail.item_cd AND avlb_qty >= v_alloc_qty;

        UPDATE wms.twms_ob_outb_d
        SET laloc_qty      = v_alloc_qty,
            laloc_yn       = 'Y',
            laloc_scd      = '10',
            laloc_datetime = CURRENT_TIMESTAMP,
            outb_detl_scd  = '10',
            upd_person_id  = p_user_id,
            upd_datetime   = CURRENT_TIMESTAMP
        WHERE outb_no = p_outb_no AND outb_detl_no = v_detail.outb_detl_no AND wh_cd = p_wh_cd;
    END LOOP;

    UPDATE wms.twms_ob_outb_h
    SET outb_scd      = '10',
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ob_outb_h', 'OUTB_NO=' || p_outb_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, '10', 'ALLOCATE', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '출고 할당이 완료되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_outbound_allocate IS '출고 할당/지시 함수 - OUTB_SCD 변경, LALOC_QTY 반영, 가용재고 차감';

-- =====================================================
-- 2. 출고 피킹 처리 함수
-- 피킹 수량(PICK_QTY) 반영
-- PRD 섹션 3.3: 피킹 확인
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_outbound_pick(
    p_wh_cd         varchar,
    p_outb_no       varchar,
    p_outb_detl_no  int,
    p_pick_qty      double precision,
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
    v_laloc_qty     double precision;
BEGIN
    SELECT outb_scd INTO v_current_scd
    FROM wms.twms_ob_outb_h
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '출고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd < '10' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '할당이 완료되지 않은 출고건입니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '40' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 출고건입니다.'::varchar;
        RETURN;
    END IF;

    SELECT COALESCE(laloc_qty, 0) INTO v_laloc_qty
    FROM wms.twms_ob_outb_d
    WHERE outb_no = p_outb_no AND outb_detl_no = p_outb_detl_no AND wh_cd = p_wh_cd;

    IF p_pick_qty > v_laloc_qty THEN
        RETURN QUERY SELECT 'ERR'::varchar,
            ('피킹수량(' || p_pick_qty || ')이 할당수량(' || v_laloc_qty || ')을 초과합니다.')::varchar;
        RETURN;
    END IF;

    UPDATE wms.twms_ob_outb_d
    SET pick_qty       = COALESCE(pick_qty, 0) + p_pick_qty,
        outb_detl_scd  = '20',
        upd_person_id  = p_user_id,
        upd_datetime   = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND outb_detl_no = p_outb_detl_no AND wh_cd = p_wh_cd;

    UPDATE wms.twms_ob_outb_h
    SET outb_scd      = '20',
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND outb_scd < '20';

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ob_outb_d',
         'OUTB_NO=' || p_outb_no || ',DETL_NO=' || p_outb_detl_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, '20', 'PICK', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '피킹 처리가 완료되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_outbound_pick IS '출고 피킹 처리 함수 - PICK_QTY 반영';

-- =====================================================
-- 3. 출고 확정 함수
-- OUTB_SCD -> 40(완료), 재고 차감 (prcs_qty 감소, invn_qty 감소)
-- PRD 섹션 3.3: 출고 확정 -> 재고 차감
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_outbound_confirm(
    p_wh_cd     varchar,
    p_outb_no   varchar,
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
    v_deduct_qty    double precision;
BEGIN
    SELECT outb_scd INTO v_current_scd
    FROM wms.twms_ob_outb_h
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '출고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '40' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 출고건입니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd < '10' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '할당이 완료되지 않은 출고건입니다.'::varchar;
        RETURN;
    END IF;

    FOR v_detail IN
        SELECT * FROM wms.twms_ob_outb_d
        WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N'
    LOOP
        v_deduct_qty := COALESCE(v_detail.pick_qty, v_detail.laloc_qty, v_detail.order_qty, 0);

        UPDATE wms.twms_iv_invn_item
        SET invn_qty      = GREATEST(invn_qty - v_deduct_qty, 0),
            prcs_qty      = GREATEST(prcs_qty - v_deduct_qty, 0),
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE wh_cd = p_wh_cd AND item_cd = v_detail.item_cd;

        UPDATE wms.twms_ob_outb_d
        SET outb_cmpt_qty = v_deduct_qty,
            outb_detl_scd = '40',
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE outb_no = p_outb_no AND outb_detl_no = v_detail.outb_detl_no AND wh_cd = p_wh_cd;
    END LOOP;

    UPDATE wms.twms_ob_outb_h
    SET outb_scd      = '40',
        outb_date     = CURRENT_TIMESTAMP,
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ob_outb_h', 'OUTB_NO=' || p_outb_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, '40', 'CONFIRM', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '출고 확정이 완료되었습니다. 재고가 차감되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_outbound_confirm IS '출고 확정 함수 - OUTB_SCD->40, 재고 차감';

-- =====================================================
-- 4. 출고 취소 함수
-- DEL_YN -> Y, 할당된 재고 복원 (prcs_qty -> avlb_qty)
-- PRD 섹션 7.2: 확정(40) 이후 취소 불가
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_outbound_cancel(
    p_wh_cd     varchar,
    p_outb_no   varchar,
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
    v_current_scd   varchar(10);
    v_detail        RECORD;
    v_restore_qty   double precision;
BEGIN
    SELECT outb_scd INTO v_current_scd
    FROM wms.twms_ob_outb_h
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N';

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERR'::varchar, '출고번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF v_current_scd >= '40' THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이미 확정된 출고건은 취소할 수 없습니다.'::varchar;
        RETURN;
    END IF;

    FOR v_detail IN
        SELECT * FROM wms.twms_ob_outb_d
        WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd AND del_yn = 'N'
          AND COALESCE(laloc_yn, 'N') = 'Y'
    LOOP
        v_restore_qty := COALESCE(v_detail.laloc_qty, 0);

        IF v_restore_qty > 0 THEN
            UPDATE wms.twms_iv_invn_item
            SET avlb_qty      = avlb_qty + v_restore_qty,
                prcs_qty      = GREATEST(prcs_qty - v_restore_qty, 0),
                upd_person_id = p_user_id,
                upd_datetime  = CURRENT_TIMESTAMP
            WHERE wh_cd = p_wh_cd AND item_cd = v_detail.item_cd;
        END IF;
    END LOOP;

    UPDATE wms.twms_ob_outb_h
    SET del_yn         = 'Y',
        upd_person_id  = p_user_id,
        upd_datetime   = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd;

    UPDATE wms.twms_ob_outb_d
    SET del_yn         = 'Y',
        cancl_qty      = COALESCE(order_qty, 0),
        upd_person_id  = p_user_id,
        upd_datetime   = CURRENT_TIMESTAMP
    WHERE outb_no = p_outb_no AND wh_cd = p_wh_cd;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_reason, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_ob_outb_h', 'OUTB_NO=' || p_outb_no || ',WH_CD=' || p_wh_cd,
         v_current_scd, 'DEL', COALESCE(p_reason, '사용자 취소'), 'CANCEL', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar, '출고 취소가 완료되었습니다. 할당 재고가 복원되었습니다.'::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_outbound_cancel IS '출고 취소 함수 - DEL_YN 처리, 할당 재고 복원, 확정(40) 이후 취소 불가';

-- =====================================================
-- 다음 단계: 12_create_functions_inventory.sql 실행
-- =====================================================
