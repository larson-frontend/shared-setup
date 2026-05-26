#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SHARED_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

CI_MODE=0
JSON_MODE=0

PASSED=()
WARNINGS=()
FAILURES=()

usage() {
  cat <<'USAGE'
Local setup diagnostics for shared-setup readiness.

Usage:
  scripts/doctor.sh [--ci] [--json] [--help]

Options:
  --ci    Non-interactive concise output.
  --json  Print a simple JSON summary.
  --help  Show this help message.
USAGE
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/ }"
  printf '%s' "$s"
}

emit_line() {
  local level="$1"
  local message="$2"
  if [[ "$JSON_MODE" -eq 0 ]]; then
    printf '%s: %s\n' "$level" "$message"
  fi
}

add_pass() {
  local message="$1"
  PASSED+=("$message")
  emit_line "PASS" "$message"
}

add_warn() {
  local message="$1"
  WARNINGS+=("$message")
  emit_line "WARN" "$message"
}

add_fail() {
  local message="$1"
  FAILURES+=("$message")
  emit_line "FAIL" "$message"
}

join_json_array() {
  local first=1
  local item
  printf '['
  for item in "$@"; do
    if [[ "$first" -eq 0 ]]; then
      printf ','
    fi
    first=0
    printf '"%s"' "$(json_escape "$item")"
  done
  printf ']'
}

print_json_summary() {
  local status="pass"
  if [[ "${#FAILURES[@]}" -gt 0 ]]; then
    status="fail"
  elif [[ "${#WARNINGS[@]}" -gt 0 ]]; then
    status="warn"
  fi

  printf '{'
  printf '"status":"%s",' "$status"
  printf '"sharedRoot":"%s",' "$(json_escape "$SHARED_ROOT")"
  printf '"cwd":"%s",' "$(json_escape "$(pwd -P)")"
  printf '"counts":{"pass":%d,"warn":%d,"fail":%d},' "${#PASSED[@]}" "${#WARNINGS[@]}" "${#FAILURES[@]}"
  printf '"passes":'
  join_json_array "${PASSED[@]}"
  printf ',"warnings":'
  join_json_array "${WARNINGS[@]}"
  printf ',"failures":'
  join_json_array "${FAILURES[@]}"
  printf '}\n'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci)
      CI_MODE=1
      shift
      ;;
    --json)
      JSON_MODE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      add_fail "Unknown argument: $1"
      break
      ;;
  esac
done

if [[ "$JSON_MODE" -eq 0 && "$CI_MODE" -eq 0 ]]; then
  printf 'Running shared-setup doctor diagnostics...\n'
fi

required_commands=(git bash node npm)
optional_commands=(zsh powershell pwsh java mvn gradle)

for cmd in "${required_commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    add_pass "Required command available: $cmd"
  else
    add_fail "Required command missing: $cmd"
  fi
done

for cmd in "${optional_commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    add_pass "Optional tool available: $cmd"
  else
    add_warn "Optional tool missing: $cmd"
  fi
done

key_files=(
  ".vscode/settings.json"
  "scripts/install-auto.sh"
  "scripts/verify-install.sh"
  "instructions/copilot.instructions.md"
)

for rel in "${key_files[@]}"; do
  if [[ -f "$SHARED_ROOT/$rel" ]]; then
    add_pass "Key file present: $rel"
  else
    add_fail "Key file missing: $rel"
  fi
done

CURRENT_DIR="$(pwd -P)"
TARGET_LINK="$CURRENT_DIR/shared-instructions"
VERIFY_SCRIPT="$SHARED_ROOT/scripts/verify-install.sh"

if [[ "$CURRENT_DIR" == "$SHARED_ROOT" ]]; then
  add_warn "Target project symlink check skipped (running in shared-setup root)"
elif [[ -L "$TARGET_LINK" || -e "$TARGET_LINK" ]]; then
  if [[ -x "$VERIFY_SCRIPT" || -f "$VERIFY_SCRIPT" ]]; then
    if bash "$VERIFY_SCRIPT" --project-root "$CURRENT_DIR" >/dev/null 2>&1; then
      add_pass "Target project verification succeeded via verify-install.sh"
    else
      add_fail "Target project verification failed via verify-install.sh"
    fi
  else
    add_warn "verify-install.sh unavailable; target project check skipped"
  fi
else
  add_warn "No shared-instructions link in current directory; target project check skipped"
fi

if [[ "$JSON_MODE" -eq 0 ]]; then
  printf 'SUMMARY: PASS=%d WARN=%d FAIL=%d\n' "${#PASSED[@]}" "${#WARNINGS[@]}" "${#FAILURES[@]}"
fi

if [[ "$JSON_MODE" -eq 1 ]]; then
  print_json_summary
fi

if [[ "${#FAILURES[@]}" -gt 0 ]]; then
  exit 1
fi

exit 0
