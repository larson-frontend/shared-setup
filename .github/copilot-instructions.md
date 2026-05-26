# Team Copilot Instructions

## Ziel

Arbeite so, dass Änderungen klein, reviewbar und konsistent zum Projektstil bleiben.

## Architektur

Dieses Repository dient als zentraler Standard für VS Code Settings, AI Instructions und Custom Agents.
Es wird per Symlink oder Kopie in Projekte eingebunden.

## Coding Rules

- Verwende vorhandene Patterns vor neuen Abstraktionen.
- Halte Änderungen minimal und fokussiert.
- Ändere keine öffentlichen APIs ohne klaren Grund.
- Nach UI-Änderungen müssen E2E-Tests geprüft werden.
- TypeScript `strict` Mode ist Pflicht.
- Zod für Runtime-Validierung an Systemgrenzen.

## Commit-Konventionen

Commit-Messages folgen dem Conventional Commits Format:

- `feat: ...` — neues Feature
- `fix: ...` — Bugfix
- `docs: ...` — Dokumentation
- `chore: ...` — Maintenance
- `refactor: ...` — Code-Umbau ohne Verhaltensänderung

## Git Workflow

1. Niemals direkt auf `develop` oder `main` pushen.
2. Feature-Arbeit auf Feature-Branch aus `develop`.
3. PR von Feature-Branch → `develop`, dann `develop` → `main`.
4. Jeder PR braucht Code Review.
5. Nach Merge auf `main`: semantic-release übernimmt alles automatisch.

## Review Rules

- Findings zuerst, Zusammenfassung danach.
- Verweise bei Erklärungen immer auf konkrete Dateien.
- Risiken und fehlende Tests explizit benennen.

## Two-Gate Architect Review (Pflicht)

Policy-Name: **Two-Gate Architect Review**.

- Start gate (kickoff) vor Implementierung: `review_phase: kickoff` + `architect_kickoff` setzen.
- End gate (signoff) vor finaler Antwort: `review_phase: final` + `architect_signoff` setzen.
- Während Umsetzung: `review_phase: execution`.
- Hard Rule: `decision: done` nur wenn `architect_kickoff=approved` **und** `architect_signoff=approved`.
- Fehlt ein Gate oder ist ein Gate nicht `approved`, dann `decision` auf `adjust` oder `blocked` setzen.

Pflicht-Headerfelder (zusätzlich zu bestehenden):
- `review_phase: kickoff | execution | final`
- `architect_kickoff: approved | adjust | blocked`
- `architect_signoff: approved | adjust | blocked`

## Testing Rules

- Nach jeder Code-Änderung: Bestehende Tests prüfen, ggf. neue schreiben.
- E2E-Tests für User-Flows (Cypress, Playwright).
- MSW-Mock-Handler für neue API-Calls ergänzen.
- Vor dem Commit: Tests müssen grün sein.

## Documentation Rules

- Neue Features dokumentieren, wenn sie für andere relevant sind.
- Änderungen an `.vscode/` oder `.github/` im PR begründen.
- Zentrales Erfahrungswissen in `docs/my-experience/` pflegen.

### Zentrales Experience Ledger (Pflicht)

- Jede abgeschlossene Aufgabe aktualisiert sowohl den Kategorie-Ordner (`docs/my-features/`, `docs/my-improvements/`, `docs/my-defects/`, `docs/my-dep-upgrades/`) als auch den zentralen Index unter `docs/my-experience/`.
- Vor jedem major Bugfix zuerst `docs/my-experience/severe-bug-history.md` konsultieren.
- Schwere Bugs muessen nach Abschluss in `docs/my-experience/severe-bug-history.md` und `docs/my-experience/history.json` eingetragen werden.

### Feature- / Improvement- / Defect-Dokumentation

Am Ende jeder abgeschlossenen Aufgabe den User fragen:
> **„Soll ich das als Feature, Improvement oder Defect dokumentieren?"**

Jede Aufgabe gehört in **genau eine** der drei Kategorien:

| Kategorie | Ordner | Wann verwenden? |
|-----------|--------|-----------------|
| **Feature** | `docs/my-features/feature_<name>/` | Neues fachliches Feature, neue UI/Endpunkt |
| **Improvement** | `docs/my-improvements/improvement_<name>/` | Refactoring, Performance, Dependency-Hygiene, Tooling, Security-Hardening ohne Feature-Wert |
| **Defect** | `docs/my-defects/defect_<name>/` | Bug, Regression, fehlerhaftes Verhalten |

> Hinweis: `docs/my-bugs/` ist ein **Legacy-Alias** für `docs/my-defects/` und
> wird nur noch für historische Einträge benutzt. Neue Defekte gehen nach
> `my-defects/`.

Jeder Ordner enthält **5 Pflicht-Dateien**:

| Datei | Inhalt |
|-------|--------|
| `specifications.md` | Name, Ziel, Must-Have / Nice-to-Have, API-Endpunkte, Datenmodell (bei Defects: erwartetes vs. beobachtetes Verhalten) |
| `problem.md` | Ausgangslage, konkrete Probleme, warum die Änderung nötig ist |
| `solution.md` | Architektur, FE/BFF/DB-Änderungen, betroffene Dateien, technische Details |
| `progress.md` | Status, erledigte [x] + offene [ ] Schritte, Branch-Namen |
| `history.json` | JSON-Array: `{ step, date, action, details, commit, repo }` pro Schritt |

Mindestens `problem.md` und `solution.md` müssen vor dem Merge vorhanden
sein. Die übrigen drei sind dringend empfohlen, dürfen aber bei reinen
Improvements (z. B. Dependency-Updates) auch nachgereicht werden.

## Lokale Entwicklung

- Frontend mit Mocks: `npm run dev:mock` (MSW)
- Frontend mit BFF: `VITE_API_BASE_URL=http://localhost:3001 npm run dev`
- BFF mit Mock Mode: `ENABLE_MOCK_MODE=true npm run dev`
- BFF mit DB: `npm run dev`
