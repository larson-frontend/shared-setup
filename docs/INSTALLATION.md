# Installation (Quick Start)

Minimal steps to start using shared-instructions in your project. No Docker or extra tooling required.

<p><strong><span style="color:red">Run this first (auto-detect installer):</span></strong></p>
Quick interactive setup (auto-detect):
```zsh
./shared-instructions/scripts/install-auto.sh
```

<p><strong><span style="color:red">Windows: run this (auto-detect installer):</span></strong></p>
Windows (auto-detect, PowerShell):
```powershell
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/install-auto.ps1
```

## Prerequisites
- VS Code installed
- `zsh` shell (Linux/macOS)

## Steps (copy/paste)

1) Link shared-instructions into your project root
```zsh
# From your project root
ln -s ../shared-instructions shared-instructions
```

<p><strong><span style="color:red">Init VS Code settings (required):</span></strong></p>
2) Initialize VS Code settings (reads Copilot instructions from shared-instructions)
```zsh
shared-instructions/scripts/init-shared-instructions-vscode.sh --non-interactive
```

3) Run canonical post-install verification
```zsh
shared-instructions/scripts/verify-install.sh --project-root .
```

<p><strong><span style="color:red">Windows VS Code init (required):</span></strong></p>
Windows (PowerShell):
```powershell
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/init-shared-instructions-vscode.ps1 -NonInteractive
```

4) Reload VS Code
- `Ctrl+Shift+P` → "Reload Window"

5) Start using the agent
- Open any file → press `Ctrl+I`
- The agent uses `shared-instructions/instructions/copilot.instructions.md`

## Optional

- Custom shared path (if not `../shared-instructions`):
```zsh
shared-instructions/scripts/init-shared-instructions-vscode.sh \
  --shared-path /absolute/path/to/shared-instructions \
  --non-interactive
```

- Log this setup (keeps team-wide usage history):
```zsh
./shared-instructions/scripts/log-agent-usage.sh \
  --agent "Magic Agent" \
  --task setup \
  --model claude-sonnet-4.5 \
  --status primary \
  --desc "Initialized shared-instructions for project"
```

- JetBrains / Eclipse (optional):
```zsh
shared-instructions/scripts/init-shared-instructions-jetbrains.sh --non-interactive
shared-instructions/scripts/init-shared-instructions-eclipse.sh --non-interactive
```

- If a repo already has a real folder/file at `shared-instructions`, the installer will now refuse to delete it.
  Use `--force` only when you intentionally want to replace that non-symlink target:
```zsh
./shared-instructions/scripts/install-shared-instructions.sh \
  --non-interactive \
  --target /absolute/path/to/repo \
  --ide vscode \
  --force
```
