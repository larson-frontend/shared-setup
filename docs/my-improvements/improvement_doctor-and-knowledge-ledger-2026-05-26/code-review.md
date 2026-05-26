# Code Review

## Kritisch

- Keine offenen kritischen Findings.

## Minor

- JSON-Ausgabe in `doctor.sh` ist bewusst einfach gehalten und auf lokale Diagnose ausgelegt.

## Entscheidungen

- Shellcheck als eigener Ubuntu-Job, um CI-Laufzeiten in der Matrix nicht unnoetig zu erhoehen.
