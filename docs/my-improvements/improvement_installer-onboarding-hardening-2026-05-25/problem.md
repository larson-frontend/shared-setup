# Problem - Installer Onboarding Hardening (2026-05-25)

## Ausgangslage

Der Einstieg lief ueber `scripts/install-auto.sh` und den Shell-Installer
`scripts/install-shared-instructions.sh`. In mehreren Faellen war das Verhalten
nicht robust genug fuer automatisierte oder sicherheitskritische Nutzung.

## Konkrete Probleme

1. Fehlende oder unvollstaendige Preflight-Pruefungen konnten erst spaet zu
   Fehlern fuehren.
2. In non-interactive Kontexten war eine uneindeutige Auto-Detection nicht
   klar fail-fast abgesichert.
3. Die Argument-Weitergabe an delegierte Aufrufe war nicht durchgaengig sicher
   gequotet.
4. Ein vorhandenes Ziel unter `shared-instructions` konnte ohne explizite
   Bestaetigung ersetzt werden.
5. Das neue `--force`-Verhalten war in der Installationsdoku noch nicht
   sauber beschrieben.

## Warum die Verbesserung noetig war

Onboarding-Skripte sind Entry-Points. Fehler oder unsichere Defaults an dieser
Stelle erzeugen schnell Folgeschaeden (z. B. versehentliches Ueberschreiben von
Projektinhalten) und erschweren CI-/Automations-Flows.
