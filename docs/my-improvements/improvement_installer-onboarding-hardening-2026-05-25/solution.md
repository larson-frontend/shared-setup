# Loesung - Installer Onboarding Hardening (2026-05-25)

## Umgesetzte Aenderungen

- `scripts/install-auto.sh` gehaertet:
  - Preflight-Checks fuer benoetigte Commands/Installer-Dateien.
  - Non-interactive Fail-Fast bei nicht aufloesbarer Auto-Detection.
  - Sichere Argument-Weitergabe mit stabiler Quoting-Strategie.
  - Konsolidierte Ausfuehrungspfade fuer Shell- und PowerShell-Delegation.
- `scripts/install-shared-instructions.sh` gehaertet:
  - `--force` als explizite Freigabe, bevor ein bestehendes Nicht-Symlink-Ziel
    ersetzt wird.
  - Klarere Fehlermeldung mit sichere(re)m Re-Run-Hinweis.
  - Robustere numerische Auswahlpruefung.
- `docs/INSTALLATION.md` erweitert:
  - Verhalten bei bestehendem realen `shared-instructions`-Pfad dokumentiert.
  - `--force`-Beispiel fuer den absichtlichen Replace-Fall hinzugefuegt.

## Verifikation

- Syntax-Check der Shell-Skripte mit `bash -n`.
- Hilfe-Ausgaben geprueft (`--help`) fuer `install-auto.sh` und
  `install-shared-instructions.sh`.

## Rest-Risiko

- In der aktuellen Umgebung ist `zsh` nicht verfuegbar. Entsprechende
  Preflight-Faelle wurden dadurch nur indirekt ueber Fail-Fast-Logik validiert,
  nicht mit einem vollstaendigen End-to-End `zsh`-Lauf.

## Betroffene Dateien

- `scripts/install-auto.sh`
- `scripts/install-shared-instructions.sh`
- `docs/INSTALLATION.md`
