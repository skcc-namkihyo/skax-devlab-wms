#!/usr/bin/env bash
# WMS 배치·이력 테이블 생성 + (선택) 데모 데이터
# 사용: DATABASE_URL 환경변수에 WMS용 Postgres 연결 문자열 설정
# 예: export DATABASE_URL="postgresql://user:pass@host/neondb?sslmode=require"
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLY_SQL="$SCRIPT_DIR/apply_wms_log_tables.sql"
SEED_SQL="$SCRIPT_DIR/seed_wms_log_demo.sql"

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "오류: DATABASE_URL 이 설정되지 않았습니다." >&2
  echo "  export DATABASE_URL='postgresql://...'" >&2
  exit 1
fi

echo ">>> DDL 적용: $APPLY_SQL"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$APPLY_SQL"

if [[ "${1:-}" == "--with-seed" ]]; then
  echo ">>> 데모 데이터: $SEED_SQL"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$SEED_SQL"
else
  echo "데모 데이터를 넣으려면: $0 --with-seed"
fi

echo ">>> wms 스키마 테이블 확인"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
  "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema = 'wms' ORDER BY table_name;"
