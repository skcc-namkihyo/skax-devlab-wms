-- =====================================================
-- WMS 이력 관리 테이블 생성 스크립트
-- Purpose: 상태 변경 추적 및 화면 조회/다운로드 이력 테이블 생성
-- Scope: status_change_history, screen_access_log
-- 실행 전: 08_create_tables_batch_log.sql 실행 완료 확인
-- 실행 순서: 9단계
-- PRD 참조: wms_prd.md 섹션 8.2, 8.3
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 상태 변경 이력 테이블 (PRD 섹션 8.3 운영 대응 목적)
-- =====================================================

CREATE TABLE wms.status_change_history (
    history_id      SERIAL       NOT NULL,
    wh_cd           varchar(30)  NOT NULL,
    table_name      varchar(50)  NOT NULL,
    record_key      varchar(100) NOT NULL,
    old_status      varchar(10),
    new_status      varchar(10)  NOT NULL,
    change_reason   varchar(500),
    change_type     varchar(20)  NOT NULL,
    changed_by      varchar(30)  NOT NULL,
    changed_at      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_status_change_history PRIMARY KEY (history_id)
);

COMMENT ON TABLE  wms.status_change_history IS '상태 변경 이력 테이블';
COMMENT ON COLUMN wms.status_change_history.history_id    IS '이력 ID';
COMMENT ON COLUMN wms.status_change_history.wh_cd         IS '창고 코드';
COMMENT ON COLUMN wms.status_change_history.table_name    IS '대상 테이블명 (twms_ib_inb_h, twms_ob_outb_h 등)';
COMMENT ON COLUMN wms.status_change_history.record_key    IS '대상 레코드 키 (예: INB_NO=INB001,WH_CD=WH01)';
COMMENT ON COLUMN wms.status_change_history.old_status    IS '변경 전 상태';
COMMENT ON COLUMN wms.status_change_history.new_status    IS '변경 후 상태';
COMMENT ON COLUMN wms.status_change_history.change_reason IS '변경 사유';
COMMENT ON COLUMN wms.status_change_history.change_type   IS '변경 유형 (INSPECT, CONFIRM, CANCEL, ALLOCATE, PICK, DELETE 등)';
COMMENT ON COLUMN wms.status_change_history.changed_by    IS '변경자 ID';
COMMENT ON COLUMN wms.status_change_history.changed_at    IS '변경 일시';

CREATE INDEX ix_sch_wh_cd      ON wms.status_change_history (wh_cd);
CREATE INDEX ix_sch_table       ON wms.status_change_history (table_name);
CREATE INDEX ix_sch_record_key  ON wms.status_change_history (record_key);
CREATE INDEX ix_sch_changed_at  ON wms.status_change_history (changed_at);
CREATE INDEX ix_sch_changed_by  ON wms.status_change_history (changed_by);

-- =====================================================
-- 2. 화면 조회/다운로드 이력 테이블 (PRD 섹션 8.2 개인정보 화면)
-- =====================================================

CREATE TABLE wms.screen_access_log (
    access_log_id   SERIAL       NOT NULL,
    userid          varchar(20)  NOT NULL,
    screen_id       varchar(50)  NOT NULL,
    screen_name     varchar(100),
    access_type     varchar(20)  NOT NULL,
    search_params   text,
    result_count    int,
    ip_address      varchar(100),
    accessed_at     timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_screen_access_log PRIMARY KEY (access_log_id)
);

COMMENT ON TABLE  wms.screen_access_log IS '화면 조회/다운로드 이력 테이블';
COMMENT ON COLUMN wms.screen_access_log.access_log_id IS '접근 로그 ID';
COMMENT ON COLUMN wms.screen_access_log.userid        IS '사용자 ID';
COMMENT ON COLUMN wms.screen_access_log.screen_id     IS '화면 ID';
COMMENT ON COLUMN wms.screen_access_log.screen_name   IS '화면명';
COMMENT ON COLUMN wms.screen_access_log.access_type   IS '접근유형 (SEARCH, DOWNLOAD, EXPORT)';
COMMENT ON COLUMN wms.screen_access_log.search_params IS '조회 조건 (JSON)';
COMMENT ON COLUMN wms.screen_access_log.result_count  IS '조회 결과건수';
COMMENT ON COLUMN wms.screen_access_log.ip_address    IS '접속 IP';
COMMENT ON COLUMN wms.screen_access_log.accessed_at   IS '접근 일시';

CREATE INDEX ix_sal_userid      ON wms.screen_access_log (userid);
CREATE INDEX ix_sal_screen_id   ON wms.screen_access_log (screen_id);
CREATE INDEX ix_sal_access_type ON wms.screen_access_log (access_type);
CREATE INDEX ix_sal_accessed_at ON wms.screen_access_log (accessed_at);

-- =====================================================
-- 다음 단계: 10_create_functions_inbound.sql 실행
-- =====================================================
