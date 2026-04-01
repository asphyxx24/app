# Mein Organizer

Persoenliche Android-App, die Produktivitaets-Tools an einem Ort vereint.

## Features (geplant)

- **Home-Dashboard** — Uebersicht aller Features beim App-Start
- **Notizen** — Text + Freihand-Zeichnen
- **Karteikarten** — Anki-kompatibler Lernmodus mit FSRS-Algorithmus (.apkg Import/Export)
- **Kalender** — Termine mit lokalen Erinnerungen
- **Claude-Assistent** — KI-Helfer fuer Fragen, Lernen und Support

## Tech-Stack

| Technologie | Zweck |
|---|---|
| Flutter + Dart | Framework |
| drift (SQLite) | Lokale Datenbank |
| Riverpod | State Management |
| perfect_freehand | Zeichenfunktion |
| Anthropic API | Claude-Integration |

## Entwicklung

```bash
# Emulator starten (ohne Android Studio)
flutter emulators                        # verfuegbare Emulatoren anzeigen
flutter emulators --launch <name>        # Emulator starten

# Oder physisches Geraet per USB
flutter devices                          # verbundene Geraete anzeigen

# App starten
flutter run

# Code-Generierung (drift, riverpod)
dart run build_runner build

# APK bauen
flutter build apk --release
```

## Projektdokumentation

Details zu Architektur, Techstack-Entscheidungen und Feature-Roadmap unter [`docs/`](docs/).

## Lizenz

Privates Projekt — nur fuer persoenliche Nutzung.
