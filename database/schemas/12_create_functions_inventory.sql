-- =====================================================
-- WMS 재고 관리 함수 생성 스크립트
-- Purpose: 셀 간 재고 이동 및 재고 조정 함수 생성
-- Scope: fn_inventory_move, fn_inventory_adjust
-- 실행 전: 11_create_functions_outbound.sql 실행 완료 확인
-- 실행 순서: 12단계
-- PRD 참조: wms_prd.md 섹션 3.1
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 셀 간 재고 이동 함수
-- 출발 셀에서 도착 셀로 지정 수량만큼 LOT 단위 재고 이동
-- PRD 섹션 3.1: 재고 관리 프로세스
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_inventory_move(
    p_wh_cd         varchar,
    p_lot_no        varchar,
    p_from_cell     varchar,
    p_to_cell       varchar,
    p_move_qty      double precision,
    p_user_id       varchar DEFAULT 'SYSTEM'
)
RETURNS TABLE (
    result_code    varchar,
    result_message varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_qty   double precision;
    v_item_cd       varchar(45);
    v_strr_id       varchar(30);
BEGIN
    IF p_from_cell = p_to_cell THEN
        RETURN QUERY SELECT 'ERR'::varchar, '출발 셀과 도착 셀이 동일합니다.'::varchar;
        RETURN;
    END IF;

    IF p_move_qty <= 0 THEN
        RETURN QUERY SELECT 'ERR'::varchar, '이동수량은 0보다 커야 합니다.'::varchar;
        RETURN;
    END IF;

    SELECT invn_qty INTO v_current_qty
    FROM wms.twms_iv_invn
    WHERE wh_cd = p_wh_cd AND wcell_no = p_from_cell AND lot_no = p_lot_no;

    IF NOT FOUND OR v_current_qty < p_move_qty THEN
        RETURN QUERY SELECT 'ERR'::varchar,
            ('출발 셀(' || p_from_cell || ')의 재고가 부족합니다. 현재: ' || COALESCE(v_current_qty, 0) || ', 필요: ' || p_move_qty)::varchar;
        RETURN;
    END IF;

    SELECT item_cd, strr_id INTO v_item_cd, v_strr_id
    FROM wms.twms_iv_lot
    WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;

    UPDATE wms.twms_iv_invn
    SET invn_qty      = invn_qty - p_move_qty,
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE wh_cd = p_wh_cd AND wcell_no = p_from_cell AND lot_no = p_lot_no;

    -- 출발 셀 재고가 0이 되면 삭제
    DELETE FROM wms.twms_iv_invn
    WHERE wh_cd = p_wh_cd AND wcell_no = p_from_cell AND lot_no = p_lot_no AND invn_qty <= 0;

    INSERT INTO wms.twms_iv_invn (wh_cd, wcell_no, lot_no, invn_qty, ins_person_id, ins_datetime)
    VALUES (p_wh_cd, p_to_cell, p_lot_no, p_move_qty, p_user_id, CURRENT_TIMESTAMP)
    ON CONFLICT (wh_cd, wcell_no, lot_no) DO UPDATE
    SET invn_qty      = wms.twms_iv_invn.invn_qty + EXCLUDED.invn_qty,
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP;

    UPDATE wms.twms_iv_invn_lot_cell
    SET invn_qty      = GREATEST(invn_qty - p_move_qty, 0),
        avlb_qty      = GREATEST(avlb_qty - p_move_qty, 0),
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP
    WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no AND wcell_no = p_from_cell;

    DELETE FROM wms.twms_iv_invn_lot_cell
    WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no AND wcell_no = p_from_cell AND invn_qty <= 0;

    INSERT INTO wms.twms_iv_invn_lot_cell (wh_cd, lot_no, wcell_no, item_cd, strr_id,
                                           invn_qty, avlb_qty, ins_person_id)
    VALUES (p_wh_cd, p_lot_no, p_to_cell, v_item_cd, v_strr_id,
            p_move_qty, p_move_qty, p_user_id)
    ON CONFLICT (wh_cd, lot_no, wcell_no) DO UPDATE
    SET invn_qty      = wms.twms_iv_invn_lot_cell.invn_qty + EXCLUDED.invn_qty,
        avlb_qty      = wms.twms_iv_invn_lot_cell.avlb_qty + EXCLUDED.avlb_qty,
        upd_person_id = p_user_id,
        upd_datetime  = CURRENT_TIMESTAMP;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_reason, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_iv_invn',
         'LOT_NO=' || p_lot_no || ',FROM=' || p_from_cell || ',TO=' || p_to_cell,
         p_from_cell, p_to_cell,
         '재고이동: ' || p_move_qty || '개', 'MOVE', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar,
        ('재고 이동 완료: ' || p_from_cell || ' -> ' || p_to_cell || ' (' || p_move_qty || '개)')::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_inventory_move IS '셀 간 재고 이동 함수 - 출발/도착 셀 간 LOT 단위 이동';

-- =====================================================
-- 2. 재고 조정 함수
-- 가용수량(avlb_qty) / 처리중수량(prcs_qty) / 재고수량(invn_qty) 조정
-- PRD 섹션 3.1: 재고 실사/조정
-- =====================================================

CREATE OR REPLACE FUNCTION wms.fn_inventory_adjust(
    p_wh_cd         varchar,
    p_lot_no        varchar,
    p_adjust_qty    double precision,
    p_adjust_type   varchar DEFAULT 'INVN',
    p_reason        varchar DEFAULT NULL,
    p_user_id       varchar DEFAULT 'SYSTEM'
)
RETURNS TABLE (
    result_code    varchar,
    result_message varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_qty       double precision;
    v_new_qty       double precision;
BEGIN
    IF p_adjust_type NOT IN ('INVN', 'AVLB', 'PRCS') THEN
        RETURN QUERY SELECT 'ERR'::varchar, '조정유형은 INVN, AVLB, PRCS 중 하나여야 합니다.'::varchar;
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM wms.twms_iv_invn_item WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no) THEN
        RETURN QUERY SELECT 'ERR'::varchar, 'LOT 번호를 찾을 수 없습니다.'::varchar;
        RETURN;
    END IF;

    IF p_adjust_type = 'INVN' THEN
        SELECT invn_qty INTO v_old_qty FROM wms.twms_iv_invn_item WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;
        v_new_qty := GREATEST(v_old_qty + p_adjust_qty, 0);

        UPDATE wms.twms_iv_invn_item
        SET invn_qty      = v_new_qty,
            avlb_qty      = GREATEST(avlb_qty + p_adjust_qty, 0),
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;

    ELSIF p_adjust_type = 'AVLB' THEN
        SELECT avlb_qty INTO v_old_qty FROM wms.twms_iv_invn_item WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;
        v_new_qty := GREATEST(v_old_qty + p_adjust_qty, 0);

        UPDATE wms.twms_iv_invn_item
        SET avlb_qty      = v_new_qty,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;

    ELSIF p_adjust_type = 'PRCS' THEN
        SELECT prcs_qty INTO v_old_qty FROM wms.twms_iv_invn_item WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;
        v_new_qty := GREATEST(v_old_qty + p_adjust_qty, 0);

        UPDATE wms.twms_iv_invn_item
        SET prcs_qty      = v_new_qty,
            upd_person_id = p_user_id,
            upd_datetime  = CURRENT_TIMESTAMP
        WHERE wh_cd = p_wh_cd AND lot_no = p_lot_no;
    END IF;

    INSERT INTO wms.status_change_history
        (wh_cd, table_name, record_key, old_status, new_status, change_reason, change_type, changed_by)
    VALUES
        (p_wh_cd, 'twms_iv_invn_item',
         'LOT_NO=' || p_lot_no || ',TYPE=' || p_adjust_type,
         v_old_qty::varchar, v_new_qty::varchar,
         COALESCE(p_reason, '재고 조정: ' || p_adjust_qty), 'ADJUST', p_user_id);

    RETURN QUERY SELECT 'OK'::varchar,
        ('재고 조정 완료: ' || p_adjust_type || ' ' || v_old_qty || ' -> ' || v_new_qty)::varchar;
END;
$$;

COMMENT ON FUNCTION wms.fn_inventory_adjust IS '재고 조정 함수 - 가용/처리중/재고수량 조정';

-- =====================================================
-- 다음 단계: 13_grant_permissions.sql 실행
-- =====================================================
