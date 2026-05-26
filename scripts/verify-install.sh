#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'USAGE'
Verify shared-instructions post-install state.

Usage:
  scripts/verify-install.sh [--project-root <path>] [--workspace-root <path>] [--shared-root <path>]

Options:
  --project-root <path>    Target project root to verify (default: $WORKSPACE_ROOT or current directory)
  --workspace-root <path>  Alias for --project-root
  --shared-root <path>     Expected shared-instructions root (default: optional via $SHARED_INSTRUCTIONS_ROOT)
  -h, --help               Show this help

Environment:
  WORKSPACE_ROOT           Default for --project-root
  SHARED_INSTRUCTIONS_ROOT Optional expected shared-instructions root
USAGE
}

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

PROJECT_ROOT="${WORKSPACE_ROOT:-$PWD}"
EXPECTED_SHARED_ROOT="${SHARED_INSTRUCTIONS_ROOT:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root|--workspace-root)
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --shared-root)
      EXPECTED_SHARED_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1. Run with --help for usage."
      ;;
  esac
done

PROJECT_ABS="$(realpath "$PROJECT_ROOT" 2>/dev/null || true)"
[[ -n "$PROJECT_ABS" && -d "$PROJECT_ABS" ]] || fail "Project root not found: $PROJECT_ROOT"
pass "Project root exists: $PROJECT_ABS"

LINK_PATH="$PROJECT_ABS/shared-instructions"
[[ -L "$LINK_PATH" ]] || fail "Missing symlink: $LINK_PATH. Create it with install/bootstrap scripts."
pass "Symlink exists: $LINK_PATH"

RESOLVED_SHARED="$(realpath "$LINK_PATH" 2>/dev/null || true)"
[[ -n "$RESOLVED_SHARED" && -d "$RESOLVED_SHARED" ]] || fail "Symlink target is invalid: $LINK_PATH"
pass "Symlink resolves to directory: $RESOLVED_SHARED"

if [[ -n "$EXPECTED_SHARED_ROOT" ]]; then
  EXPECTED_ABS="$(realpath "$EXPECTED_SHARED_ROOT" 2>/dev/null || true)"
  [[ -n "$EXPECTED_ABS" && -d "$EXPECTED_ABS" ]] || fail "Expected shared root not found: $EXPECTED_SHARED_ROOT"
  [[ "$RESOLVED_SHARED" == "$EXPECTED_ABS" ]] || fail "Symlink points to $RESOLVED_SHARED but expected $EXPECTED_ABS"
  pass "Symlink target matches expected shared root"
fi

INSTRUCTIONS_FILE="$RESOLVED_SHARED/instructions/copilot.instructions.md"
[[ -r "$INSTRUCTIONS_FILE" ]] || fail "Missing readable instructions file: $INSTRUCTIONS_FILE"
pass "Instructions file is readable"

SETTINGS_FILE="$PROJECT_ABS/.vscode/settings.json"
[[ -f "$SETTINGS_FILE" ]] || fail "Missing VS Code settings file: $SETTINGS_FILE. Run init-shared-instructions-vscode.sh first."
pass "VS Code settings file exists"

if grep -Fq 'shared-instructions/instructions/copilot.instructions.md' "$SETTINGS_FILE" || \
   grep -Fq 'shared-instructions\\instructions\\copilot.instructions.md' "$SETTINGS_FILE"; then
  pass "VS Code settings reference shared instructions path"
else
  fail "Settings file does not reference shared-instructions/instructions/copilot.instructions.md"
fi

printf 'PASS: Verification complete\n'
