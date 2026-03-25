-- =====================================================
-- adm_userinfo 비밀번호 BCrypt 보정 (기존 DB에 password 미설정 시)
-- 평문 'admin'과 동일한 BCrypt 해시 (cost 10)
-- 실행 전: 15_insert_sample_data.sql 이 구버전이었을 때만 필요할 수 있음
-- =====================================================

UPDATE wms.adm_userinfo
SET password = '$2y$10$kYA71dhwyv0YtRcHxFXlK.pwwyJUwlO6WEFCkmTlLnSh0aaJulk.W'
WHERE password IS NULL
   OR trim(password) = '';
