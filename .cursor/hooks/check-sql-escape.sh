#!/bin/bash
# Check SQL XML for proper escaping and safety
# Exit codes: 0 (pass), 1 (fail escape check)

FILE="$1"

if [ ! -f "$FILE" ]; then
  exit 0
fi

ERRORS=0

# Check 1: Unescaped < > & in XML (should be in CDATA)
if grep -E '[^<]<[^!/]' "$FILE" | grep -v '<!\\[CDATA\\[' | grep -qv '<delete\|<insert\|<select\|<update'; then
  echo "🔴 ERROR: Unescaped '<' found in SQL - use CDATA: $FILE"
  ERRORS=$((ERRORS + 1))
fi

if grep '>' "$FILE" | grep -v ']]>' | grep -v ' > \| >= \|CDATA' | grep -q 'SELECT\|WHERE'; then
  echo "🔴 ERROR: Unescaped '>' found in comparisons - use CDATA: $FILE"
  ERRORS=$((ERRORS + 1))
fi

if grep '&' "$FILE" | grep -v '&lt;\|&gt;\|&amp;\|&quot;' | grep -q 'SELECT\|WHERE'; then
  echo "🔴 ERROR: Unescaped '&' found in SQL - use CDATA: $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: WHERE clause in UPDATE/DELETE (safety)
if grep -q '<update' "$FILE"; then
  UPDATE_BLOCK=$(sed -n '/<update/,/<\/update>/p' "$FILE")
  if echo "$UPDATE_BLOCK" | grep -q '<update' && ! echo "$UPDATE_BLOCK" | grep -q '<where>'; then
    echo "🔴 ERROR: UPDATE without WHERE clause detected: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

if grep -q '<delete' "$FILE"; then
  DELETE_BLOCK=$(sed -n '/<delete/,/<\/delete>/p' "$FILE")
  if echo "$DELETE_BLOCK" | grep -q '<delete' && ! echo "$DELETE_BLOCK" | grep -q '<where>'; then
    echo "🔴 ERROR: DELETE without WHERE clause detected: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 3: Parameter placeholders (#{} for MyBatis)
if grep '${' "$FILE" | grep -q 'SELECT\|INSERT\|UPDATE\|DELETE'; then
  echo "🔴 ERROR: Use #{} instead of ${} for parameters (SQL injection risk): $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 4: CDATA formatting for comparisons
if grep -E 'WHERE.*[<>]' "$FILE" | grep -v '<\\!\\[CDATA\\[' | grep -qv '&lt;\|&gt;'; then
  echo "🟡 WARNING: Comparison operators should use CDATA or &lt;/&gt;: $FILE"
fi

if [ $ERRORS -gt 0 ]; then
  exit 1
fi

exit 0
