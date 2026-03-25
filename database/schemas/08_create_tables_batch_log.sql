-- =====================================================
-- WMS 배치 처리 로그 테이블 생성 스크립트
-- Purpose: 배치 실행 이력 및 오류 상세 로그 테이블 생성
-- Scope: batch_job_log, batch_error_log
-- 실행 전: 07_create_tables_inventory.sql 실행 완료 확인
-- 실행 순서: 8단계
-- PRD 참조: wms_prd.md 섹션 5.1~5.3
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 배치 실행 이력 테이블
-- =====================================================

CREATE TABLE wms.batch_job_log (
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

COMMENT ON TABLE  wms.batch_job_log IS '배치 실행 이력 테이블';
COMMENT ON COLUMN wms.batch_job_log.batch_log_id    IS '배치 로그 ID';
COMMENT ON COLUMN wms.batch_job_log.wh_cd           IS '창고 코드';
COMMENT ON COLUMN wms.batch_job_log.batch_type      IS '배치 유형 (INB_CREATE, OUTB_CREATE, INB_RETRY, OUTB_RETRY)';
COMMENT ON COLUMN wms.batch_job_log.batch_name      IS '배치명';
COMMENT ON COLUMN wms.batch_job_log.start_datetime  IS '시작 일시';
COMMENT ON COLUMN wms.batch_job_log.end_datetime    IS '종료 일시';
COMMENT ON COLUMN wms.batch_job_log.status          IS '상태 (RUNNING, COMPLETED, FAILED, PARTIAL)';
COMMENT ON COLUMN wms.batch_job_log.total_count     IS '총 처리건수';
COMMENT ON COLUMN wms.batch_job_log.success_count   IS '성공건수';
COMMENT ON COLUMN wms.batch_job_log.error_count     IS '오류건수';
COMMENT ON COLUMN wms.batch_job_log.skip_count      IS '건너뜀건수 (중복 방지)';
COMMENT ON COLUMN wms.batch_job_log.error_message   IS '오류 메시지 요약';

CREATE INDEX ix_batch_job_wh     ON wms.batch_job_log (wh_cd);
CREATE INDEX ix_batch_job_type   ON wms.batch_job_log (batch_type);
CREATE INDEX ix_batch_job_status ON wms.batch_job_log (status);
CREATE INDEX ix_batch_job_start  ON wms.batch_job_log (start_datetime);

-- =====================================================
-- 2. 배치 오류 상세 로그 테이블
-- =====================================================

CREATE TABLE wms.batch_error_log (
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

COMMENT ON TABLE  wms.batch_error_log IS '배치 오류 상세 로그 테이블';
COMMENT ON COLUMN wms.batch_error_log.error_log_id  IS '오류 로그 ID';
COMMENT ON COLUMN wms.batch_error_log.batch_log_id  IS '배치 로그 ID';
COMMENT ON COLUMN wms.batch_error_log.ref_no        IS '참조번호 (입출고 원본)';
COMMENT ON COLUMN wms.batch_error_log.ref_detl_no   IS '참조 상세번호';
COMMENT ON COLUMN wms.batch_error_log.error_code    IS '오류 코드';
COMMENT ON COLUMN wms.batch_error_log.error_message IS '오류 메시지';
COMMENT ON COLUMN wms.batch_error_log.error_data    IS '오류 발생 데이터 (JSON)';
COMMENT ON COLUMN wms.batch_error_log.retry_count   IS '재시도 횟수';
COMMENT ON COLUMN wms.batch_error_log.retry_status  IS '재시도 상태 (PENDING, RETRIED, RESOLVED, SKIPPED)';

CREATE INDEX ix_batch_err_job    ON wms.batch_error_log (batch_log_id);
CREATE INDEX ix_batch_err_ref    ON wms.batch_error_log (ref_no);
CREATE INDEX ix_batch_err_retry  ON wms.batch_error_log (retry_status);

-- =====================================================
-- 다음 단계: 09_create_tables_status_history.sql 실행
-- =====================================================
