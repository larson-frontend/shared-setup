#!/usr/bin/env zsh
set -euo pipefail

# install-shared-instructions.sh
# Interactive installer to:
#  1) Pick a repo
#  2) Create `shared-instructions` symlink inside it
#  3) Choose IDE (VS Code / JetBrains / Eclipse)
#  4) Run the corresponding init script
#
# Messages follow the requested flow:
#  - "running.... script add sym link path for Repo: <repo_path>"
#  - IDE option menu (a/b/c)
#  - "installation progress ..... ready!" or an error message
#
# Usage:
#  ./shared-instructions/scripts/install-shared-instructions.sh
#
# Non-interactive options:
#  --workspace <path>      Root directory containing repos (default: parent of shared-instructions)
#  --shared-path <path>    Path to shared-instructions (default: this script's parent)
#  --target <repo-path>    Repo directory to install symlink into
#  --ide <vscode|jetbrains|eclipse>
#  --non-interactive       Use provided --target and --ide without prompts
#  --force                 Allow replacing an existing non-symlink target

SCRIPT_DIR=$(cd -- "$(dirname "$0")" && pwd)
DEFAULT_SHARED=$(realpath "$SCRIPT_DIR/..")
DEFAULT_WORKSPACE=$(realpath "$DEFAULT_SHARED/..")

WORKSPACE="$DEFAULT_WORKSPACE"
SHARED_PATH="$DEFAULT_SHARED"
TARGET_REPO=""
IDE_CHOICE=""
NON_INTERACTIVE=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workspace) WORKSPACE="$2"; shift 2;;
    --shared-path) SHARED_PATH="$2"; shift 2;;
    --target) TARGET_REPO="$2"; shift 2;;
    --ide) IDE_CHOICE="$2"; shift 2;;
    --non-interactive) NON_INTERACTIVE=true; shift;;
    --force) FORCE=true; shift;;
    -h|--help)
      cat <<'USAGE'
Interactive installer for shared-instructions.
Examples:
  ./shared-instructions/scripts/install-shared-instructions.sh
  ./shared-instructions/scripts/install-shared-instructions.sh --non-interactive --target ./fasting-frontend --ide vscode
  ./shared-instructions/scripts/install-shared-instructions.sh --target ./my-repo --ide vscode --non-interactive --force
USAGE
      exit 0;;
    *) echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

SHARED_ABS=$(realpath "$SHARED_PATH" 2>/dev/null || true)
WORKSPACE_ABS=$(realpath "$WORKSPACE" 2>/dev/null || true)
[[ -z "$SHARED_ABS" || ! -d "$SHARED_ABS" ]] && { echo "Error: shared-instructions not found: $SHARED_PATH" >&2; exit 1; }
[[ -z "$WORKSPACE_ABS" || ! -d "$WORKSPACE_ABS" ]] && { echo "Error: workspace path not found: $WORKSPACE" >&2; exit 1; }

echo "Using shared-instructions: $SHARED_ABS"

echo "Scanning workspace for repos: $WORKSPACE_ABS"
local -a candidates
for d in "$WORKSPACE_ABS"/*; do
  [[ ! -d "$d" ]] && continue
  base=$(basename "$d")
  [[ "$base" == ".git" || "$base" == "shared-instructions" ]] && continue
  if [[ -d "$d/.git" || -f "$d/package.json" || -f "$d/pom.xml" || -d "$d/src" ]]; then
    candidates+="$d"
  fi
done

# Select repo
if [[ "$NON_INTERACTIVE" == true ]]; then
  [[ -z "$TARGET_REPO" ]] && { echo "Error: --non-interactive requires --target <repo-path>" >&2; exit 1; }
  TARGET_ABS=$(realpath "$TARGET_REPO" 2>/dev/null || true)
  [[ -z "$TARGET_ABS" || ! -d "$TARGET_ABS" ]] && { echo "Error: target repo not found: $TARGET_REPO" >&2; exit 1; }
else
  echo "Found repos:"
  i=1
  for c in $candidates; do
    echo "  [$i] $(basename "$c")  -> $c"
    (( i++ ))
  done
  echo "  [C] Custom path"
  printf "Select a repo number or 'C': "
  read -r choice
  if [[ "$choice" == "C" || "$choice" == "c" ]]; then
    printf "Enter absolute path to repo: "
    read -r custom
    TARGET_ABS=$(realpath "$custom" 2>/dev/null || true)
    [[ -z "$TARGET_ABS" || ! -d "$TARGET_ABS" ]] && { echo "Error: path not found: $custom" >&2; exit 1; }
  else
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then echo "Error: invalid selection" >&2; exit 1; fi
    idx=$choice
    count=${#candidates[@]}
    if (( idx < 1 || idx > count )); then echo "Error: selection out of range" >&2; exit 1; fi
    TARGET_ABS=${candidates[$idx]}
  fi
fi

REPO_NAME=$(basename "$TARGET_ABS")
LINK_TARGET="$TARGET_ABS/shared-instructions"

# Progress message (as requested)
echo "running.... script add sym link path for Repo: $TARGET_ABS"

# Create/refresh symlink
if [[ -L "$LINK_TARGET" ]]; then
  CUR=$(realpath "$LINK_TARGET")
  if [[ "$CUR" != "$SHARED_ABS" ]]; then
    rm -f "$LINK_TARGET" && ln -s "$SHARED_ABS" "$LINK_TARGET"
    echo "Symlink updated in $REPO_NAME -> $SHARED_ABS"
  else
    echo "Symlink already correct in $REPO_NAME"
  fi
elif [[ -e "$LINK_TARGET" ]]; then
  if [[ "$FORCE" != true ]]; then
    echo "Error: Destination exists and is not a symlink: $LINK_TARGET" >&2
    echo "Refusing to delete it automatically because this can remove real project files." >&2
    echo "If you want to replace it, rerun with --force:" >&2
    echo "  $0 --target '$TARGET_ABS' --ide '${IDE_CHOICE:-vscode|jetbrains|eclipse}' --non-interactive --force" >&2
    exit 1
  fi
  rm -rf "$LINK_TARGET" && ln -s "$SHARED_ABS" "$LINK_TARGET"
  echo "Replaced existing path with symlink in $REPO_NAME (--force)"
else
  ln -s "$SHARED_ABS" "$LINK_TARGET"
  echo "Created symlink in $REPO_NAME -> $SHARED_ABS"
fi

# IDE selection
if [[ "$NON_INTERACTIVE" == false ]]; then
  echo "IDE option choose"
  echo "  a. VScode"
  echo "  b. jetbrain"
  echo "  c.  eclipse"
  printf "Enter choice [a/b/c]: "
  read -r ans
  case "$ans" in
    a|A) IDE_CHOICE="vscode";;
    b|B) IDE_CHOICE="jetbrains";;
    c|C) IDE_CHOICE="eclipse";;
    *) echo "Error: invalid IDE choice" >&2; exit 1;;
  esac
fi

# Run selected init script
case "$IDE_CHOICE" in
  vscode)
    if [[ -x "$SHARED_ABS/scripts/init-shared-instructions-vscode.sh" ]]; then
      (cd "$TARGET_ABS" && "$SHARED_ABS/scripts/init-shared-instructions-vscode.sh" --shared-path "$SHARED_ABS" --non-interactive)
    else
      echo "Error: VS Code init script not found" >&2; exit 1
    fi
    ;;
  jetbrains)
    if [[ -x "$SHARED_ABS/scripts/init-shared-instructions-jetbrains.sh" ]]; then
      (cd "$TARGET_ABS" && "$SHARED_ABS/scripts/init-shared-instructions-jetbrains.sh" --shared-path "$SHARED_ABS" --non-interactive)
    else
      echo "Error: JetBrains init script not found" >&2; exit 1
    fi
    ;;
  eclipse)
    if [[ -x "$SHARED_ABS/scripts/init-shared-instructions-eclipse.sh" ]]; then
      (cd "$TARGET_ABS" && "$SHARED_ABS/scripts/init-shared-instructions-eclipse.sh" --shared-path "$SHARED_ABS" --non-interactive)
    else
      echo "Error: Eclipse init script not found" >&2; exit 1
    fi
    ;;
  *)
    echo "Error: specify --ide <vscode|jetbrains|eclipse> for --non-interactive" >&2
    exit 1
    ;;
esac

VERIFIER="$SHARED_ABS/scripts/verify-install.sh"
if [[ ! -f "$VERIFIER" ]]; then
  echo "Error: verification script not found: $VERIFIER" >&2
  exit 1
fi
if [[ ! -x "$VERIFIER" ]]; then
  chmod +x "$VERIFIER" 2>/dev/null || true
fi
"$VERIFIER" --project-root "$TARGET_ABS" --shared-root "$SHARED_ABS"

# Final progress message
echo "installation progress ..... ready!"
