#!/bin/bash
# Check Java code style standards
# Exit codes: 0 (pass), 1 (fail style check)

FILE="$1"

if [ ! -f "$FILE" ]; then
  exit 0
fi

ERRORS=0

# Check 1: Package naming (lowercase)
if grep -q '^package [A-Z]' "$FILE"; then
  echo "🔴 ERROR: Package name must be lowercase: $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: @Service/@RestController annotations required
if grep -q '^public class.*Service' "$FILE"; then
  if ! grep -q '@Service' "$FILE"; then
    echo "🔴 ERROR: Service class missing @Service annotation: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

if grep -q '^public class.*Controller' "$FILE"; then
  if ! grep -q '@RestController' "$FILE"; then
    echo "🔴 ERROR: Controller missing @RestController annotation: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check 3: Map usage in Mapper classes
if grep -q 'Mapper' "$FILE"; then
  if grep -q 'Map<' "$FILE"; then
    echo "🟡 WARNING: Map usage in Mapper - prefer typed objects: $FILE"
  fi
fi

# Check 4: No hardcoded SQL in Java (should be in XML)
if grep -q 'SELECT\|INSERT\|UPDATE\|DELETE' "$FILE" | grep -i 'string'; then
  echo "🔴 ERROR: SQL should be in Mapper XML, not Java: $FILE"
  ERRORS=$((ERRORS + 1))
fi

# Check 5: Method naming convention (camelCase)
if grep -oP 'public\s+\w+\s+[A-Z]\w+\(' "$FILE" | grep -qv '_'; then
  # Method names should start with lowercase letter
  if grep -q 'public.*[A-Z][A-Z_]*(' "$FILE"; then
    echo "🟡 WARNING: Method names should use camelCase: $FILE"
  fi
fi

if [ $ERRORS -gt 0 ]; then
  exit 1
fi

exit 0
