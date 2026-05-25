# Code Review - Installer Onboarding Hardening (2026-05-25)

## Findings

- Kritisch: Keine offenen Findings.
- Minor: Keine offenen Findings.
- Nits: Keine offenen Findings.

## Entscheidungen

- Safety vor Convenience: bestehende Nicht-Symlink-Ziele werden nur mit
  `--force` ersetzt.
- Non-interactive Ausfuehrung wird bei unklarer Auto-Detection hart beendet,
  statt in interaktive Rueckfragen zu fallen.
- Argumente werden unveraendert und gequotet an delegierte Installer
  weitergereicht.

## Follow-ups

- Optional: dedizierter E2E-Lauf in einer Umgebung mit verfuegbarem `zsh`.