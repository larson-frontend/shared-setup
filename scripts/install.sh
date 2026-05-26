#!/usr/bin/env zsh
#
# Magic Agent — Universal Install Script
#
# Clone a repository + auto-link shared-instructions in ONE command
#
# Usage:
#   ./scripts/install.sh --clone https://github.com/user/my-project
#   ./scripts/install.sh --clone https://github.com/user/my-project /path/to/install
#   ./scripts/install.sh --link /path/to/existing/project
#

set -e

# Get the actual path of THIS script file (works with both bash and zsh)
if [[ -n "${ZSH_VERSION}" ]]; then
  # zsh
  INSTALL_SCRIPT_PATH="$(readlink -f "${(%):-%N}")" 2>/dev/null || INSTALL_SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")"
else
  # bash and others
  INSTALL_SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")" 2>/dev/null || INSTALL_SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")"
fi
SHARED_INSTRUCTIONS_ROOT="$(dirname "$(dirname "$INSTALL_SCRIPT_PATH")")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo ""
  echo "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo "${BLUE}║  ✨ Magic Agent — Universal Installer                 ║${NC}"
  echo "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_success() {
  echo "${GREEN}✓${NC} $1"
}

print_error() {
  echo "${RED}✗${NC} $1"
}

print_warning() {
  echo "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo "${BLUE}ℹ${NC} $1"
}

run_install_verification() {
  local project_root="$1"
  local shared_root="$2"
  local verifier="$shared_root/scripts/verify-install.sh"

  if [[ ! -f "$verifier" ]]; then
    print_error "Verification script not found: $verifier"
    exit 1
  fi

  if [[ ! -x "$verifier" ]]; then
    chmod +x "$verifier" 2>/dev/null || true
  fi

  if "$verifier" --project-root "$project_root" --shared-root "$shared_root"; then
    print_success "Installation verified"
  else
    print_error "Installation verification failed"
    exit 1
  fi
}

setup_stats() {
  local PROJECT_DIR="$1"
  
  print_info "Setting up agent usage tracking..."
  
  # Create .agent-usage.md in project root
  cat > "$PROJECT_DIR/.agent-usage.md" << 'EOF'
# Agent Usage Statistics

This file tracks Magic Agent usage in your project.
Auto-generated and managed by shared-instructions.

## Log Format
[YYYY-MM-DD HH:MM] agent=AGENT_NAME task=TASK_TYPE model=MODEL_NAME status=STATUS lang=LANGUAGE desc=DESCRIPTION

EOF
  
  # Update .gitignore to exclude stats
  if [[ -f "$PROJECT_DIR/.gitignore" ]]; then
    if ! grep -q "\.agent-usage" "$PROJECT_DIR/.gitignore"; then
      echo "" >> "$PROJECT_DIR/.gitignore"
      echo "# Magic Agent Usage Tracking (local only)" >> "$PROJECT_DIR/.gitignore"
      echo ".agent-usage.md" >> "$PROJECT_DIR/.gitignore"
      print_success "Updated .gitignore for agent usage tracking"
    fi
  else
    cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Magic Agent Usage Tracking (local only)
.agent-usage.md
EOF
    print_success "Created .gitignore with agent usage tracking"
  fi
}

show_usage() {
  echo "${YELLOW}Usage:${NC}"
  echo ""
  echo "  Clone + Link:"
  echo "    ${BLUE}./scripts/install.sh --clone <REPO_URL> [TARGET_PATH]${NC}"
  echo ""
  echo "  Link Only:"
  echo "    ${BLUE}./scripts/install.sh --link <PROJECT_PATH>${NC}"
  echo ""
  echo "  Examples:"
  echo "    ${BLUE}./scripts/install.sh --clone https://github.com/user/my-project${NC}"
  echo "    ${BLUE}./scripts/install.sh --clone https://github.com/user/my-project ~/my-projects/my-app${NC}"
  echo "    ${BLUE}./scripts/install.sh --link /path/to/existing/project${NC}"
  echo ""
}

clone_and_link() {
  local repo_url="$1"
  local target_path="$2"
  
  if [[ -z "$repo_url" ]]; then
    print_error "Repository URL required"
    show_usage
    exit 1
  fi
  
  # Use global SHARED_INSTRUCTIONS_ROOT
  if [[ ! -d "$SHARED_INSTRUCTIONS_ROOT/instructions" ]]; then
    print_error "Could not locate shared-instructions at: $SHARED_INSTRUCTIONS_ROOT"
    exit 1
  fi
  
  print_success "Using shared-instructions: $SHARED_INSTRUCTIONS_ROOT"
  echo ""
  
  # Parse repo name if target not provided
  if [[ -z "$target_path" ]]; then
    target_path="${repo_url##*/}"
    target_path="${target_path%.git}"
  fi
  
  # Expand ~
  target_path="${target_path/#\~/$HOME}"
  
  echo "${YELLOW}🔄 Cloning...${NC}"
  echo "  Repository: $repo_url"
  echo "  Location: $target_path"
  echo ""
  
  # Clone
  if git clone "$repo_url" "$target_path"; then
    print_success "Repository cloned"
  else
    print_error "Failed to clone repository"
    exit 1
  fi
  
  cd "$target_path"
  
  # Setup statistics
  setup_stats "$(pwd)"
  
  echo ""
  echo "${YELLOW}🔗 Linking...${NC}"
  
  # Create symlink
  if [[ -L shared-instructions ]]; then
    rm shared-instructions
    print_warning "Removed existing symlink"
  fi
  
  if ln -s "$SHARED_INSTRUCTIONS_ROOT" shared-instructions; then
    print_success "Symlink created: shared-instructions"
  else
    print_error "Failed to create symlink"
    exit 1
  fi
  
  run_install_verification "$(pwd)" "$SHARED_INSTRUCTIONS_ROOT"

  echo ""
  echo "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo "${GREEN}║  ✓ Installation Complete!                             ║${NC}"
  echo "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "📁 Project: $(basename "$target_path")"
  echo "📂 Location: $(pwd)"
  echo "🔗 Symlink: shared-instructions → $SHARED_INSTRUCTIONS_ROOT"
  echo ""
  echo "${YELLOW}🔧 Next Steps:${NC}"
  echo ""
  echo "  1. Open in VS Code:"
  echo "     ${BLUE}code .${NC}"
  echo ""
  echo "  2. Reload VS Code:"
  echo "     ${BLUE}Ctrl+Shift+P → 'Reload Window'${NC}"
  echo ""
  echo "  3. Start using Magic Agent:"
  echo "     ${BLUE}Press Ctrl+I in any file${NC}"
  echo ""
  echo "${GREEN}Happy coding! 🚀${NC}"
  echo ""
}

link_only() {
  local project_path="$1"
  
  if [[ -z "$project_path" ]]; then
    print_error "Project path required"
    show_usage
    exit 1
  fi
  
  # Use global SHARED_INSTRUCTIONS_ROOT
  if [[ ! -d "$SHARED_INSTRUCTIONS_ROOT/instructions" ]]; then
    print_error "Could not locate shared-instructions at: $SHARED_INSTRUCTIONS_ROOT"
    exit 1
  fi
  
  print_success "Using shared-instructions: $SHARED_INSTRUCTIONS_ROOT"
  
  # Expand ~
  project_path="${project_path/#\~/$HOME}"
  
  if [[ ! -d "$project_path" ]]; then
    print_error "Project directory not found: $project_path"
    exit 1
  fi
  
  cd "$project_path"
  
  # Setup statistics
  setup_stats "$(pwd)"
  
  echo ""
  echo "${YELLOW}🔗 Linking...${NC}"
  
  # Create symlink
  if [[ -L shared-instructions ]]; then
    rm shared-instructions
    print_warning "Removed existing symlink"
  fi
  
  if ln -s "$SHARED_INSTRUCTIONS_ROOT" shared-instructions; then
    print_success "Symlink created: shared-instructions"
  else
    print_error "Failed to create symlink"
    exit 1
  fi
  
  run_install_verification "$(pwd)" "$SHARED_INSTRUCTIONS_ROOT"

  echo ""
  echo "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo "${GREEN}║  ✓ Project Linked!                                    ║${NC}"
  echo "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "📁 Project: $(basename "$(pwd)")"
  echo "📂 Location: $(pwd)"
  echo "🔗 Symlink: shared-instructions → $SHARED_INSTRUCTIONS_ROOT"
  echo ""
  echo "${YELLOW}🔧 Next Steps:${NC}"
  echo ""
  echo "  1. Open in VS Code:"
  echo "     ${BLUE}code .${NC}"
  echo ""
  echo "  2. Reload VS Code:"
  echo "     ${BLUE}Ctrl+Shift+P → 'Reload Window'${NC}"
  echo ""
  echo "  3. Start using Magic Agent:"
  echo "     ${BLUE}Press Ctrl+I in any file${NC}"
  echo ""
  echo "${GREEN}Happy coding! 🚀${NC}"
  echo ""
}

# Main
main() {
  print_header
  
  MODE="$1"
  
  case "$MODE" in
    --clone)
      clone_and_link "$2" "$3"
      ;;
    --link)
      link_only "$2"
      ;;
    --help|-h)
      show_usage
      ;;
    *)
      print_error "Invalid command: $MODE"
      show_usage
      exit 1
      ;;
  esac
}

main "$@"
