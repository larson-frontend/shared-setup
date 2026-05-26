# Installation — Ultra Quick

Minimal steps only. Pick your OS and run.

- Prerequisite: VS Code installed

## Linux/macOS
```zsh
./shared-instructions/scripts/install-auto.sh
shared-instructions/scripts/init-shared-instructions-vscode.sh --non-interactive
shared-instructions/scripts/verify-install.sh --project-root .
```

## Windows
```powershell
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/install-auto.ps1
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/init-shared-instructions-vscode.ps1 -NonInteractive
bash shared-instructions/scripts/verify-install.sh --project-root .
```

## Finish
- Reload VS Code: Ctrl+Shift+P → "Reload Window"
- Start using: Open any file → press Ctrl+I
