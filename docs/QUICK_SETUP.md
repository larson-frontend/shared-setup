# Shared Instructions — Quick Setup

Nutze shared-instructions in neuen Projekten in **3 Schritten** (~2 Minuten).

---

## � Ein-Befehl-Installation (Empfohlen)

**Klont shared-instructions und konfiguriert alles automatisch:**

```zsh
# Lokal (von einem Projekt mit shared-instructions)
zsh path/to/shared-instructions/scripts/bootstrap.sh

# Oder mit Username-Personalisierung
zsh path/to/shared-instructions/scripts/bootstrap.sh --username mario
```

**Windows (PowerShell):**
```powershell
# Lokal
powershell -ExecutionPolicy Bypass -File path\to\shared-instructions\scripts\bootstrap.ps1

# Mit Username
powershell -ExecutionPolicy Bypass -File path\to\bootstrap.ps1 -Username mario
```

**Remote-Installation (direkt aus GitHub):**

```zsh
# Linux/macOS
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/shared-instructions/main/scripts/bootstrap.sh | zsh

# Mit Parametern
curl -fsSL URL | zsh -s -- --username mario --branch main
```

```powershell
# Windows (PowerShell als Admin)
irm https://raw.githubusercontent.com/YOUR_ORG/shared-instructions/main/scripts/bootstrap.ps1 | iex
```

**Das Script:**
- ✅ Klont shared-instructions ins Parent-Directory
- ✅ Erstellt Symlink im aktuellen Projekt
- ✅ Konfiguriert VS Code automatisch
- ✅ Logged die Installation

---

## �📋 Voraussetzungen

- VS Code installiert
- `zsh` Shell (Linux/macOS) oder PowerShell (Windows)
- Git-Repository initialisiert

---

## ⚡ Setup (3 Schritte)

### 1️⃣ Symlink erstellen

```zsh
# Im Projekt-Root (z.B. my-new-project/)
ln -s ../shared-instructions shared-instructions
```

**Windows:**
```powershell
New-Item -ItemType SymbolicLink -Path "shared-instructions" -Target "..\shared-instructions"
```

### 2️⃣ VS Code konfigurieren

```zsh
./shared-instructions/scripts/init-shared-instructions-vscode.sh --non-interactive
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/init-shared-instructions-vscode.ps1 -NonInteractive
```

### 3️⃣ VS Code neu laden

- `Ctrl+Shift+P` → "Reload Window"
- Fertig! Der Agent nutzt jetzt `shared-instructions/instructions/copilot.instructions.md`

---

## 🎯 Interaktive Installation

Auto-Detect-Script findet dein IDE und konfiguriert alles:

```zsh
./shared-instructions/scripts/install-auto.sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File shared-instructions/scripts/install-auto.ps1
```

---

## 📦 Mehrere Projekte

```
workspace/
├── shared-instructions/         ← Zentrale Quelle
├── project-1/
│   └── shared-instructions/     ← Symlink zu ../shared-instructions
├── project-2/
│   └── shared-instructions/     ← Symlink zu ../shared-instructions
└── project-3/
    └── shared-instructions/     ← Symlink zu ../shared-instructions
```

**Vorteil:** Einmal aktualisieren → alle Projekte profitieren.

---

## 🔧 Optionale Konfiguration

### Custom Path (falls nicht `../shared-instructions`)

```zsh
./shared-instructions/scripts/init-shared-instructions-vscode.sh \
  --shared-path /absoluter/pfad/zu/shared-instructions \
  --non-interactive
```

### JetBrains IDEs (IntelliJ, WebStorm, etc.)

```zsh
./shared-instructions/scripts/init-shared-instructions-jetbrains.sh --non-interactive
```

### Eclipse

```zsh
./shared-instructions/scripts/init-shared-instructions-eclipse.sh --non-interactive
```

### Username-Personalisierung (Team-Tracking)

```zsh
./shared-instructions/scripts/init-shared-instructions-vscode.sh \
  --username "mario" \
  --non-interactive
# Setzt Agent-Name auf: mario-magic_agent
```

---

## ✅ Verifizieren

```zsh
./shared-instructions/scripts/verify-install.sh --project-root .
```

---

## 📚 Weiterführende Docs

- **Vollständige Anleitung:** `shared-instructions/docs/INSTALLATION.md`
- **Team-Workflows:** `shared-instructions/docs/TEAM_SETUP_GUIDE.md`
- **Getting Started:** `shared-instructions/docs/GETTING_STARTED.md`
- **Agent Usage Logging:** `shared-instructions/docs/agent-usage.md`

---

## 🆘 Troubleshooting

**Symlink funktioniert nicht (Windows):**
- Entwicklermodus aktivieren oder Admin-Rechte nutzen
- Alternativ: Ordner kopieren statt Symlink

**VS Code lädt Instruktionen nicht:**
```zsh
# Settings manuell prüfen
code .vscode/settings.json
# Sollte enthalten:
# "github.copilot.chat.codeGeneration.instructions": [
#   { "file": "shared-instructions/instructions/copilot.instructions.md" }
# ]
```

**Script nicht ausführbar:**
```zsh
chmod +x shared-instructions/scripts/*.sh
```
