# Specifications - Improvement Installer Onboarding Hardening (2026-05-25)

## Name

Installer Onboarding Hardening

## Ziel

Die Onboarding-Installer sollen robuster und sicherer laufen, insbesondere in nicht-interaktiven Umgebungen und bei vorhandenen Zielpfaden.

## Must-Have

- Hardening von `scripts/install-auto.sh` und `scripts/install-shared-instructions.sh`.
- Preflight-Checks vor Ausfuehrung (vorhandene Installer-Dateien und benoetigte Commands).
- Non-interactive Fail-Fast bei unklarer Auto-Detection.
- Sichere Argument-Weitergabe an delegierte Shell/PowerShell-Aufrufe.
- `--force` Guard beim Ersetzen eines bestehenden Nicht-Symlink-Ziels.
- Dokumentation fuer `--force` in `docs/INSTALLATION.md`.

## Nice-to-Have

- Explizite Rest-Risiken und kurze Verifikation im Eintrag dokumentieren.

## API-Endpunkte

Keine.

## Datenmodell

Keines.
