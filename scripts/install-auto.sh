#!/usr/bin/env zsh
set -euo pipefail

# install-auto.sh
# Auto-detect OS/shell and run the appropriate installer.
# Falls back to asking the user which terminal to use.
#
# Forwards common flags to the underlying installer:
#   --workspace <path>
#   --shared-path <path>
#   --target <repo-path>
#   --ide <vscode|jetbrains|eclipse>
#   --non-interactive

SCRIPT_DIR=$(cd -- "$(dirname "$0")" && pwd)
PS_SCRIPT="$SCRIPT_DIR/install-shared-instructions.ps1"
SH_SCRIPT="$SCRIPT_DIR/install-shared-instructions.sh"

# Collect and forward args
ARGS=("$@")

exists() { command -v "$1" >/dev/null 2>&1; }
is_interactive() { [[ -t 0 && -t 1 ]]; }

fail_preflight() {
  echo "Error: $1" >&2
  exit 1
}

require_cmd() {
  cmd="$1"
  hint="$2"
  if ! exists "$cmd"; then
    fail_preflight "Required command '$cmd' not found. $hint"
  fi
}

preflight_for() {
  mode="$1"
  case "$mode" in
    windows-powershell)
      [[ -f "$PS_SCRIPT" ]] || fail_preflight "PowerShell installer missing: $PS_SCRIPT"
      require_cmd powershell.exe "Install PowerShell or run from a shell where powershell.exe is available."
      ;;
    unix-shell)
      [[ -f "$SH_SCRIPT" ]] || fail_preflight "Shell installer missing: $SH_SCRIPT"
      require_cmd zsh "Install zsh (for example: apt install zsh) to run $SH_SCRIPT."
      ;;
    unix-powershell)
      [[ -f "$PS_SCRIPT" ]] || fail_preflight "PowerShell installer missing: $PS_SCRIPT"
      if ! exists pwsh && ! exists powershell; then
        fail_preflight "PowerShell not found. Install 'pwsh' or 'powershell'."
      fi
      ;;
    *)
      fail_preflight "Unknown preflight mode: $mode"
      ;;
  esac
}

fail_noninteractive_autodetect() {
  echo "Error: Auto-detection could not choose an installer in non-interactive mode." >&2
  echo "Run one of these explicitly:" >&2
  echo "  $SH_SCRIPT [args]" >&2
  echo "  powershell -ExecutionPolicy Bypass -File $PS_SCRIPT [args]" >&2
  exit 1
}

run_shell_installer() {
  preflight_for unix-shell
  "$SH_SCRIPT" "${ARGS[@]}"
}

run_posix_powershell_installer() {
  preflight_for unix-powershell
  if exists pwsh; then
    psbin=pwsh
  else
    psbin=powershell
  fi
  "$psbin" -ExecutionPolicy Bypass -File "$PS_SCRIPT" "${ARGS[@]}"
}

require_cmd uname "Install coreutils (or equivalent) so platform detection can run."
os_name=$(uname -s 2>/dev/null || echo "unknown")

# Windows-like environments (Git Bash/MINGW/MSYS/Cygwin)
if [[ "$os_name" == MINGW* || "$os_name" == MSYS* || "$os_name" == CYGWIN* ]]; then
  if exists powershell.exe && [[ -f "$PS_SCRIPT" ]]; then
    preflight_for windows-powershell
    echo "Detected Windows environment; using PowerShell installer."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT" "${ARGS[@]}"
    exit 0
  fi
  echo "Windows environment detected but PowerShell not found."
  if ! is_interactive; then
    fail_noninteractive_autodetect
  fi
  echo "Which terminal are you using?"
  echo "  1) bash/zsh (Git Bash/MSYS)"
  echo "  2) PowerShell (provide path)"
  printf "Enter choice [1/2]: "
  read -r choice
  case "$choice" in
    1)
      run_shell_installer
      ;;
    2)
      printf "Enter full path to powershell.exe: "
      read -r pspath
      [[ -x "$pspath" ]] || { echo "Error: powershell.exe not executable: $pspath" >&2; exit 1; }
      [[ -f "$PS_SCRIPT" ]] || fail_preflight "PowerShell installer missing: $PS_SCRIPT"
      "$pspath" -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT" "${ARGS[@]}"
      ;;
    *)
      echo "Invalid choice" >&2; exit 1;;
  esac
  exit 0
fi

# Non-Windows (Linux/macOS)
if [[ -f "$SH_SCRIPT" ]]; then
  run_shell_installer
  exit 0
fi

# Fallback prompt
echo "Could not auto-detect environment."
if ! is_interactive; then
  fail_noninteractive_autodetect
fi
echo "Which terminal are you using?"
echo "  1) bash/zsh (Linux/macOS)"
echo "  2) PowerShell (Windows)"
printf "Enter choice [1/2]: "
read -r choice
case "$choice" in
  1)
    run_shell_installer
    ;;
  2)
    run_posix_powershell_installer
    ;;
  *)
    echo "Invalid choice" >&2; exit 1;;
esac
