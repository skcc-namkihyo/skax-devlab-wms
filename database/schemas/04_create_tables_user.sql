-- =====================================================
-- WMS 사용자 관리 테이블 생성 스크립트
-- Purpose: 사용자 정보 및 세션 관리 테이블 생성
-- Scope: adm_userinfo, adm_user_session
-- 실행 전: 03_create_tables_common.sql 실행 완료 확인
-- 실행 순서: 4단계
-- PRD 참조: wms_prd.md 섹션 11.2.1, 12.1
-- 생성일자: 2026-02-24
-- =====================================================

-- =====================================================
-- 1. 사용자 정보 테이블 (PRD 섹션 11.2.1 ADM_USERINFO 전환)
-- =====================================================

CREATE TABLE wms.adm_userinfo (
    userid                  varchar(20)  NOT NULL,
    company                 varchar(20),
    usergroupcode           varchar(20),
    teamcode                varchar(20),
    username                varchar(50),
    password                varchar(255),
    email                   varchar(60),
    tel                     varchar(40),
    cellphone               varchar(20),
    use_yn                  varchar(1)   DEFAULT 'Y',
    ins_datetime            timestamp    DEFAULT CURRENT_TIMESTAMP,
    ins_person_id           varchar(30),
    upd_datetime            timestamp    DEFAULT CURRENT_TIMESTAMP,
    upd_person_id           varchar(30),
    pw_err_cnt              int          DEFAULT 0,
    validsdate              varchar(14),
    validedate              varchar(14),
    password_upd_datetime   varchar(14),
    assign_grp              varchar(10),
    ip                      varchar(100),
    oldpassword             varchar(30),
    oldpassword2            varchar(32),
    login_date              timestamp,
    lock_yn                 varchar(1)   DEFAULT 'N',
    personal_info_handler_yn varchar(1)  DEFAULT 'N',
    job_user_yn             varchar(1)   DEFAULT 'N',
    CONSTRAINT pk_adm_userinfo PRIMARY KEY (userid)
);

COMMENT ON TABLE  wms.adm_userinfo IS '사용자 정보 테이블';
COMMENT ON COLUMN wms.adm_userinfo.userid                   IS '사용자 ID';
COMMENT ON COLUMN wms.adm_userinfo.company                  IS '회사코드';
COMMENT ON COLUMN wms.adm_userinfo.usergroupcode            IS '사용자 그룹 코드';
COMMENT ON COLUMN wms.adm_userinfo.teamcode                 IS '팀 코드';
COMMENT ON COLUMN wms.adm_userinfo.username                 IS '사용자명';
COMMENT ON COLUMN wms.adm_userinfo.password                 IS '암호화된 비밀번호';
COMMENT ON COLUMN wms.adm_userinfo.email                    IS '이메일';
COMMENT ON COLUMN wms.adm_userinfo.tel                      IS '전화번호';
COMMENT ON COLUMN wms.adm_userinfo.cellphone                IS '휴대전화';
COMMENT ON COLUMN wms.adm_userinfo.use_yn                   IS '사용여부 (Y/N)';
COMMENT ON COLUMN wms.adm_userinfo.pw_err_cnt               IS '비밀번호 오류 횟수';
COMMENT ON COLUMN wms.adm_userinfo.validsdate               IS '유효 시작일';
COMMENT ON COLUMN wms.adm_userinfo.validedate               IS '유효 종료일';
COMMENT ON COLUMN wms.adm_userinfo.password_upd_datetime    IS '비밀번호 변경일시';
COMMENT ON COLUMN wms.adm_userinfo.assign_grp               IS '할당 그룹';
COMMENT ON COLUMN wms.adm_userinfo.ip                       IS '접속 IP';
COMMENT ON COLUMN wms.adm_userinfo.oldpassword              IS '이전 비밀번호';
COMMENT ON COLUMN wms.adm_userinfo.oldpassword2             IS '이전 비밀번호2';
COMMENT ON COLUMN wms.adm_userinfo.login_date               IS '최종 로그인 일시';
COMMENT ON COLUMN wms.adm_userinfo.lock_yn                  IS '계정 잠금 여부 (Y/N)';
COMMENT ON COLUMN wms.adm_userinfo.personal_info_handler_yn IS '개인정보취급자 여부 (Y/N)';
COMMENT ON COLUMN wms.adm_userinfo.job_user_yn              IS '업무담당자 여부 (Y/N)';

CREATE INDEX ix_adm_userinfo_group  ON wms.adm_userinfo (usergroupcode);
CREATE INDEX ix_adm_userinfo_use    ON wms.adm_userinfo (use_yn);
CREATE INDEX ix_adm_userinfo_lock   ON wms.adm_userinfo (lock_yn);

-- =====================================================
-- 2. 사용자 세션 테이블 (PRD 섹션 12.1 세션 기반 인증)
-- =====================================================

CREATE TABLE wms.adm_user_session (
    session_id      varchar(128) NOT NULL,
    userid          varchar(20)  NOT NULL,
    ip_address      varchar(100),
    user_agent      varchar(500),
    login_datetime  timestamp    DEFAULT CURRENT_TIMESTAMP,
    last_access     timestamp    DEFAULT CURRENT_TIMESTAMP,
    expire_datetime timestamp    NOT NULL,
    is_valid        varchar(1)   DEFAULT 'Y',
    CONSTRAINT pk_adm_user_session PRIMARY KEY (session_id),
    CONSTRAINT fk_session_userid FOREIGN KEY (userid)
        REFERENCES wms.adm_userinfo(userid)
);

COMMENT ON TABLE  wms.adm_user_session IS '사용자 세션 테이블';
COMMENT ON COLUMN wms.adm_user_session.session_id      IS '세션 ID';
COMMENT ON COLUMN wms.adm_user_session.userid          IS '사용자 ID';
COMMENT ON COLUMN wms.adm_user_session.ip_address      IS '접속 IP';
COMMENT ON COLUMN wms.adm_user_session.user_agent      IS '브라우저 정보';
COMMENT ON COLUMN wms.adm_user_session.login_datetime  IS '로그인 일시';
COMMENT ON COLUMN wms.adm_user_session.last_access     IS '마지막 접근 일시';
COMMENT ON COLUMN wms.adm_user_session.expire_datetime IS '만료 일시';
COMMENT ON COLUMN wms.adm_user_session.is_valid        IS '유효여부 (Y/N)';

CREATE INDEX ix_session_userid  ON wms.adm_user_session (userid);
CREATE INDEX ix_session_expire  ON wms.adm_user_session (expire_datetime);
CREATE INDEX ix_session_valid   ON wms.adm_user_session (is_valid);

-- =====================================================
-- 다음 단계: 05_create_tables_inbound.sql 실행
-- =====================================================
