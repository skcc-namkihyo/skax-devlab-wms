#!/bin/bash
# Prevent dangerous SQL operations (DROP, TRUNCATE without confirmation)
# Exit codes: 0 (safe), 1 (dangerous)

FILE="$1"
CONTENT="${2}"

if [ ! -f "$FILE" ]; then
  exit 0
fi

# Skip non-SQL files
if [[ ! "$FILE" =~ \.sql$ ]]; then
  exit 0
fi

ERRORS=0

# Check 1: DROP TABLE without double confirmation
if grep -qi 'DROP\s\+TABLE' "$FILE"; then
  echo "🔴 BLOCKED: DROP TABLE detected - requires manual review"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: TRUNCATE without WHERE (data loss)
if grep -qi 'TRUNCATE' "$FILE"; then
  echo "🔴 BLOCKED: TRUNCATE detected - potential data loss"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: DELETE without WHERE clause
if grep -E 'DELETE\s+FROM' "$FILE" | grep -vq 'WHERE'; then
  echo "🔴 BLOCKED: DELETE without WHERE clause - would delete all rows"
  ERRORS=$((ERRORS + 1))
fi

# Check 4: UPDATE without WHERE clause
if grep -E 'UPDATE\s+.*\s+SET' "$FILE" | grep -vq 'WHERE'; then
  echo "🔴 BLOCKED: UPDATE without WHERE clause - would update all rows"
  ERRORS=$((ERRORS + 1))
fi

# Check 5: DROP DATABASE
if grep -qi 'DROP\s\+DATABASE' "$FILE"; then
  echo "🔴 BLOCKED: DROP DATABASE - destructive operation"
  ERRORS=$((ERRORS + 1))
fi

# Check 6: Warn about ALTER TABLE
if grep -qi 'ALTER\s\+TABLE' "$FILE"; then
  echo "🟡 WARNING: ALTER TABLE detected - ensure migration script versioned: $FILE"
fi

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "⛔ Dangerous SQL operation blocked. Contact DBA or use git commit --no-verify to override."
  exit 1
fi

exit 0
