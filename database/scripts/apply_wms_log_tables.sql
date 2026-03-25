-- =====================================================
-- WMS 배치·이력 로그 테이블 일괄 생성 (idempotent)
-- =====================================================
-- MCP(postgres_tms) 조회 요약 (2026-03-25):
--   current_database=postgres, current_user=tms_developer
--   기존 테이블: cron.*, tms.* 만 존재 — wms 스키마 없음
-- 본 스크립트는 Neon/로컬 등 단일 DB 사용자 환경에서
--   backend 로그 API에 필요한 wms.batch_job_log, batch_error_log,
--   status_change_history, screen_access_log 만 생성합니다.
-- 원본: database/schemas/08_create_tables_batch_log.sql,
--       database/schemas/09_create_tables_status_history.sql
-- =====================================================

CREATE SCHEMA IF NOT EXISTS wms;

-- 배치 실행 이력
CREATE TABLE IF NOT EXISTS wms.batch_job_log (
    batch_log_id    SERIAL       NOT NULL,
    wh_cd           varchar(30)  NOT NULL,
    batch_type      varchar(30)  NOT NULL,
    batch_name      varchar(100) NOT NULL,
    start_datetime  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_datetime    timestamp,
    status          varchar(20)  NOT NULL DEFAULT 'RUNNING',
    total_count     int          DEFAULT 0,
    success_count   int          DEFAULT 0,
    error_count     int          DEFAULT 0,
    skip_count      int          DEFAULT 0,
    error_message   text,
    ins_person_id   varchar(30),
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_batch_job_log PRIMARY KEY (batch_log_id)
);

CREATE INDEX IF NOT EXISTS ix_batch_job_wh     ON wms.batch_job_log (wh_cd);
CREATE INDEX IF NOT EXISTS ix_batch_job_type   ON wms.batch_job_log (batch_type);
CREATE INDEX IF NOT EXISTS ix_batch_job_status ON wms.batch_job_log (status);
CREATE INDEX IF NOT EXISTS ix_batch_job_start  ON wms.batch_job_log (start_datetime);

-- 배치 오류 상세
CREATE TABLE IF NOT EXISTS wms.batch_error_log (
    error_log_id    SERIAL       NOT NULL,
    batch_log_id    int          NOT NULL,
    ref_no          varchar(32),
    ref_detl_no     varchar(20),
    error_code      varchar(20),
    error_message   text         NOT NULL,
    error_data      text,
    retry_count     int          DEFAULT 0,
    retry_status    varchar(20)  DEFAULT 'PENDING',
    ins_datetime    timestamp    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_batch_error_log PRIMARY KEY (error_log_id),
    CONSTRAINT fk_batch_error_job FOREIGN KEY (batch_log_id)
        REFERENCES wms.batch_job_log(batch_log_id)
);

CREATE INDEX IF NOT EXISTS ix_batch_err_job    ON wms.batch_error_log (batch_log_id);
CREATE INDEX IF NOT EXISTS ix_batch_err_ref    ON wms.batch_error_log (ref_no);
CREATE INDEX IF NOT EXISTS ix_batch_err_retry  ON wms.batch_error_log (retry_status);

-- 상태 변경 이력
CREATE TABLE IF NOT EXISTS wms.status_change_history (
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

CREATE INDEX IF NOT EXISTS ix_sch_wh_cd      ON wms.status_change_history (wh_cd);
CREATE INDEX IF NOT EXISTS ix_sch_table       ON wms.status_change_history (table_name);
CREATE INDEX IF NOT EXISTS ix_sch_record_key  ON wms.status_change_history (record_key);
CREATE INDEX IF NOT EXISTS ix_sch_changed_at  ON wms.status_change_history (changed_at);
CREATE INDEX IF NOT EXISTS ix_sch_changed_by  ON wms.status_change_history (changed_by);

-- 화면 접근 이력
CREATE TABLE IF NOT EXISTS wms.screen_access_log (
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

CREATE INDEX IF NOT EXISTS ix_sal_userid      ON wms.screen_access_log (userid);
CREATE INDEX IF NOT EXISTS ix_sal_screen_id   ON wms.screen_access_log (screen_id);
CREATE INDEX IF NOT EXISTS ix_sal_access_type ON wms.screen_access_log (access_type);
CREATE INDEX IF NOT EXISTS ix_sal_accessed_at ON wms.screen_access_log (accessed_at);
