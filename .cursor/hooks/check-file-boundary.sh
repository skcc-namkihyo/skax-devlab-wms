#!/bin/bash
# Enforce project boundary - prevent modifications outside project root
# Exit codes: 0 (within project), 1 (outside project)

FILE_PATH="$1"

# Get project root (where .cursor exists)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

# Normalize file path (resolve symlinks)
if [ -f "$FILE_PATH" ]; then
  NORMALIZED_PATH="$(cd "$(dirname "$FILE_PATH")" && pwd)/$(basename "$FILE_PATH")"
else
  NORMALIZED_PATH="$(cd "$(dirname "$FILE_PATH")" 2>/dev/null && pwd)/$(basename "$FILE_PATH")" || NORMALIZED_PATH="$FILE_PATH"
fi

# Check if file is within project root
if [[ ! "$NORMALIZED_PATH" =~ ^${PROJECT_ROOT} ]]; then
  echo "🔴 ERROR: File modification outside project boundary blocked"
  echo "  Project Root: $PROJECT_ROOT"
  echo "  Target File: $NORMALIZED_PATH"
  exit 1
fi

# Whitelist checks (allow specific external paths for legitimate reasons)
# Example: .git, .vscode, node_modules (in case)
DANGEROUS_PATHS=(
  "/etc/"
  "/usr/"
  "/bin/"
  "/sbin/"
  "/var/"
  "/sys/"
  "/proc/"
  "/dev/"
  "/lib/"
  "/opt/"
  "$HOME/.ssh"
  "$HOME/.bashrc"
  "$HOME/.zshrc"
)

for DANGEROUS_PATH in "${DANGEROUS_PATHS[@]}"; do
  if [[ "$NORMALIZED_PATH" =~ ^${DANGEROUS_PATH} ]]; then
    echo "🔴 ERROR: Cannot modify system/config files: $NORMALIZED_PATH"
    exit 1
  fi
done

# Allow hidden project files (.git, .cursor, .vscode)
if [[ "$NORMALIZED_PATH" =~ \/.git/ ]] || \
   [[ "$NORMALIZED_PATH" =~ \/.cursor/ ]] || \
   [[ "$NORMALIZED_PATH" =~ \/.vscode/ ]]; then
  exit 0
fi

# Allow project files
if [[ "$NORMALIZED_PATH" =~ ^${PROJECT_ROOT}/(backend|frontend|database|infra|config|docker)/ ]] || \
   [[ "$NORMALIZED_PATH" =~ ^${PROJECT_ROOT}/[^/]+\.(md|json|yml|yaml|properties|xml|sql)$ ]]; then
  exit 0
fi

echo "✅ File within project boundary: $(basename "$NORMALIZED_PATH")"
exit 0
