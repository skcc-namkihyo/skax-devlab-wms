#!/bin/bash
# Check Vue CDN globals (no import/require allowed)
# Exit codes: 0 (pass), 1 (fail CDN check)

FILE="$1"

if [ ! -f "$FILE" ]; then
  exit 0
fi

ERRORS=0

# Check 1: No import statements
if grep -q "^[[:space:]]*import\s" "$FILE"; then
  echo "🔴 ERROR: import statement found - CDN environment (use window.Vue): $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: No require statements
if grep -q "require(" "$FILE"; then
  echo "🔴 ERROR: require() found - CDN environment (use window.Vue): $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: Verify window.Vue usage
if ! grep -q 'window\.Vue' "$FILE" && grep -q 'const\|let\|var' "$FILE"; then
  if grep -q 'ref\|reactive\|computed\|watch' "$FILE"; then
    echo "🔴 ERROR: Vue methods used without window.Vue import: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 4: Verify Element Plus CDN
if grep -q 'ElMessage\|ElNotification\|ElInput' "$FILE"; then
  if ! grep -q 'window\.ElementPlus' "$FILE"; then
    echo "🔴 ERROR: Element Plus components used without window.ElementPlus: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 5: No npm packages
if grep -q 'from\s.*node_modules\|import.*from\s.*[@a-zA-Z]' "$FILE"; then
  echo "🔴 ERROR: npm package import detected (CDN only): $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 6: Warn about <script> type
if [ "${FILE##*.}" = "html" ] || [ "${FILE##*.}" = "htm" ]; then
  if ! grep -q '<script.*type="module"' "$FILE" && grep -q '<script>'; then
    echo "🟢 INFO: Verify <script> tags don't use module syntax: $FILE"
  fi
fi

if [ $ERRORS -gt 0 ]; then
  exit 1
fi

exit 0
