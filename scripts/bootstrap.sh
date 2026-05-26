#!/usr/bin/env zsh
#
# Bootstrap Script — Install shared-instructions in any project (one command)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shared-instructions/main/scripts/bootstrap.sh | zsh
#
# Or locally:
#   zsh <(curl -fsSL URL) [--repo REPO_URL] [--branch BRANCH] [--username USER]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
REPO_URL="${SHARED_INSTRUCTIONS_REPO:-https://github.com/YOUR_ORG/shared-instructions.git}"
BRANCH="${SHARED_INSTRUCTIONS_BRANCH:-main}"
USERNAME=""
TARGET_DIR=""

print_header() {
  echo ""
  echo "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo "${BLUE}║     🚀 Shared Instructions Bootstrap Installer            ║${NC}"
  echo "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_success() {
  echo "${GREEN}✓${NC} $1"
}

print_error() {
  echo "${RED}✗${NC} $1"
}

print_info() {
  echo "${BLUE}ℹ${NC} $1"
}

print_warning() {
  echo "${YELLOW}⚠${NC} $1"
}

usage() {
  cat <<EOF
Bootstrap shared-instructions into any project

Usage:
  $0 [OPTIONS]

Options:
  --repo URL        Git repository URL for shared-instructions
                    (default: ${REPO_URL})
  --branch BRANCH   Branch to clone (default: ${BRANCH})
  --username NAME   Your username for agent personalization (optional)
  --target DIR      Install to specific directory (default: auto-detect)
  --help            Show this help

Examples:
  # Quick install (auto-detect project)
  $0

  # With custom repo and username
  $0 --repo https://github.com/myorg/shared-instructions.git --username mario

  # Remote install via curl
  curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shared-instructions/main/scripts/bootstrap.sh | zsh

  # Remote with parameters
  curl -fsSL URL | zsh -s -- --username mario

EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --repo)
        REPO_URL="$2"
        shift 2
        ;;
      --branch)
        BRANCH="$2"
        shift 2
        ;;
      --username)
        USERNAME="$2"
        shift 2
        ;;
      --target)
        TARGET_DIR="$2"
        shift 2
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

detect_project_root() {
  # Try to find project root (git root or directories with common project files)
  if [[ -n "$TARGET_DIR" ]]; then
    echo "$TARGET_DIR"
    return
  fi

  # Check if we're in a git repo
  if git rev-parse --show-toplevel &>/dev/null; then
    git rev-parse --show-toplevel
    return
  fi

  # Look for common project indicators
  local current="$PWD"
  while [[ "$current" != "/" ]]; do
    if [[ -f "$current/package.json" ]] || \
       [[ -f "$current/pom.xml" ]] || \
       [[ -f "$current/go.mod" ]] || \
       [[ -f "$current/Cargo.toml" ]] || \
       [[ -d "$current/.git" ]]; then
      echo "$current"
      return
    fi
    current=$(dirname "$current")
  done

  # Default to current directory
  echo "$PWD"
}

check_prerequisites() {
  print_info "Checking prerequisites..."
  
  local missing=()
  
  if ! command -v git &>/dev/null; then
    missing+=("git")
  fi
  
  if ! command -v zsh &>/dev/null; then
    print_warning "zsh not found, using current shell"
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    print_error "Missing required tools: ${missing[*]}"
    echo "Please install them and try again."
    exit 1
  fi
  
  print_success "All prerequisites met"
}

clone_shared_instructions() {
  local project_root="$1"
  local shared_parent="$(dirname "$project_root")"
  local shared_path="$shared_parent/shared-instructions"

  print_info "Cloning shared-instructions..."
  
  # Check if already exists
  if [[ -d "$shared_path" ]]; then
    print_warning "shared-instructions already exists at: $shared_path"
    
    # Try to update it
    print_info "Attempting to update existing installation..."
    if cd "$shared_path" && git pull origin "$BRANCH" &>/dev/null; then
      print_success "Updated existing shared-instructions"
      cd - &>/dev/null
    else
      print_warning "Could not update. Using existing version."
    fi
  else
    # Clone fresh
    if git clone --branch "$BRANCH" "$REPO_URL" "$shared_path" &>/dev/null; then
      print_success "Cloned shared-instructions to: $shared_path"
    else
      print_error "Failed to clone shared-instructions from: $REPO_URL"
      exit 1
    fi
  fi

  echo "$shared_path"
}

create_symlink() {
  local project_root="$1"
  local shared_path="$2"
  local symlink_path="$project_root/shared-instructions"

  print_info "Creating symlink..."

  # Check if symlink already exists
  if [[ -L "$symlink_path" ]]; then
    local target=$(readlink "$symlink_path")
    if [[ "$target" == "$shared_path" ]] || [[ "$target" == "../shared-instructions" ]]; then
      print_success "Symlink already exists and is correct"
      return 0
    else
      print_warning "Symlink exists but points elsewhere: $target"
      rm "$symlink_path"
    fi
  elif [[ -e "$symlink_path" ]]; then
    print_error "Path exists but is not a symlink: $symlink_path"
    print_info "Please remove it manually and try again"
    exit 1
  fi

  # Create symlink (relative path)
  if ln -s "../shared-instructions" "$symlink_path"; then
    print_success "Created symlink: $symlink_path"
  else
    print_error "Failed to create symlink"
    exit 1
  fi
}

initialize_vscode() {
  local project_root="$1"
  local username="$2"

  print_info "Initializing VS Code settings..."

  local init_script="$project_root/shared-instructions/scripts/init-shared-instructions-vscode.sh"
  
  if [[ ! -x "$init_script" ]]; then
    chmod +x "$init_script" 2>/dev/null || true
  fi

  if [[ -x "$init_script" ]]; then
    local args=("--non-interactive")
    if [[ -n "$username" ]]; then
      args+=("--username" "$username")
    fi
    
    if "$init_script" "${args[@]}"; then
      print_success "VS Code settings initialized"
    else
      print_warning "VS Code initialization had issues (may be okay)"
    fi
  else
    print_warning "VS Code init script not found or not executable"
  fi
}

verify_installation() {
  local project_root="$1"
  local shared_path="$2"
  local verifier="$shared_path/scripts/verify-install.sh"

  print_info "Verifying installation..."

  if [[ ! -f "$verifier" ]]; then
    print_error "Verification script not found: $verifier"
    exit 1
  fi

  if [[ ! -x "$verifier" ]]; then
    chmod +x "$verifier" 2>/dev/null || true
  fi

  "$verifier" --project-root "$project_root" --shared-root "$shared_path"
  print_success "Installation verification passed"
}

log_installation() {
  local project_root="$1"
  local username="${2:-Magic Agent}"

  local log_script="$project_root/shared-instructions/scripts/log-agent-usage.sh"
  
  if [[ -x "$log_script" ]]; then
    "$log_script" \
      --agent "$username" \
      --task setup \
      --model claude-opus-4.5 \
      --status primary \
      --desc "Bootstrapped shared-instructions into project" \
      &>/dev/null || true
  fi
}

print_next_steps() {
  local project_root="$1"
  
  echo ""
  echo "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo "${GREEN}║  ✓ Installation Complete!                                 ║${NC}"
  echo "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "${BLUE}📁 Project root:${NC} $project_root"
  echo ""
  echo "${YELLOW}🔧 Next Steps:${NC}"
  echo ""
  echo "  1. Reload your IDE:"
  echo "     ${BLUE}VS Code:${NC} Ctrl+Shift+P → 'Reload Window'"
  echo ""
  echo "  2. Start using the agent:"
  echo "     ${BLUE}VS Code:${NC} Press Ctrl+I in any file"
  echo ""
  echo "  3. Read the docs:"
  echo "     ${BLUE}cat${NC} shared-instructions/docs/QUICK_SETUP.md"
  echo ""
  echo "${GREEN}Happy coding! 🚀${NC}"
  echo ""
}

main() {
  print_header

  parse_args "$@"
  check_prerequisites

  local project_root=$(detect_project_root)
  print_info "Project root: $project_root"

  # Clone shared-instructions to parent directory
  local shared_path=$(clone_shared_instructions "$project_root")

  # Create symlink in project
  create_symlink "$project_root" "$shared_path"

  # Initialize VS Code
  initialize_vscode "$project_root" "$USERNAME"

  # Verify install state before final summary/logging
  verify_installation "$project_root" "$shared_path"

  # Log the installation
  log_installation "$project_root" "$USERNAME"

  # Done
  print_next_steps "$project_root"
}

main "$@"
