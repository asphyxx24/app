# Setup-Anleitung

## Voraussetzungen

### 1. Flutter SDK installieren

```bash
# Homebrew (empfohlen auf macOS)
brew install --cask flutter

# Oder manuell: https://docs.flutter.dev/get-started/install/macos/mobile-android

# Pruefen ob alles funktioniert:
flutter doctor
```

### 2. Android Studio installieren

Flutter braucht Android Studio **nicht als Editor**, aber fuer:
- Android SDK (Compiler, Build Tools)
- Android Emulator (zum Testen ohne physisches Geraet)

```bash
brew install --cask android-studio
```

Nach der Installation:
1. Android Studio oeffnen
2. SDK Manager → Android SDK installieren (API Level 34+)
3. AVD Manager → Emulator erstellen (z.B. Pixel 8, API 34)
4. Android Studio kann danach geschlossen werden

### 3. VS Code Extensions

- **Flutter** (von Dart Code) — bringt Dart Extension automatisch mit
- **Flutter Widget Snippets** — Shortcuts fuer haeufige Widgets

### 4. Physisches Geraet einrichten (optional, aber empfohlen)

1. Auf dem Android-Handy: Einstellungen → Ueber das Telefon → 7x auf "Build-Nummer" tippen → Entwickleroptionen aktiviert
2. Entwickleroptionen → USB-Debugging aktivieren
3. Handy per USB anschliessen
4. `flutter devices` sollte das Geraet anzeigen

## Projekt erstellen

```bash
cd /Users/praktika/Documents/mein-organizer
flutter create --org com.meinorganizer --project-name mein_organizer app
cd app
```

### Abhaengigkeiten installieren

In `app/pubspec.yaml` folgende Dependencies hinzufuegen:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Datenbank
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # State Management
  flutter_riverpod: ^2.6.0
  riverpod_annotation: ^2.6.0

  # UI
  google_fonts: ^6.2.0
  flutter_markdown: ^0.7.0

  # Zeichenfunktion
  perfect_freehand: ^3.0.0
  flutter_colorpicker: ^1.1.0

  # Kalender
  table_calendar: ^3.1.0
  flutter_local_notifications: ^18.0.0

  # Anki-Kompatibilitaet
  archive: ^4.0.0

  # Claude-Integration
  http: ^1.2.0
  flutter_secure_storage: ^9.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # drift Code-Generierung
  drift_dev: ^2.22.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.6.0
```

```bash
cd app
flutter pub get
```

### App starten

```bash
# Im Emulator
flutter run

# Auf physischem Geraet (per USB verbunden)
flutter run -d <device-id>

# Device-ID herausfinden
flutter devices
```

### APK bauen

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Projektstruktur (Ziel)

```
app/
├── lib/
│   ├── main.dart                  # App-Einstiegspunkt
│   ├── app.dart                   # MaterialApp + Theme + Navigation
│   ├── database/
│   │   ├── database.dart          # drift Database-Klasse
│   │   └── tables/
│   │       ├── notes.dart         # Notes-Tabelle
│   │       ├── note_drawings.dart # Zeichnungs-Daten
│   │       ├── decks.dart         # Karteikarten-Decks
│   │       ├── cards.dart         # Karteikarten
│   │       ├── card_progress.dart # FSRS-Lernfortschritt
│   │       ├── events.dart        # Kalender-Termine
│   │       └── chat_messages.dart # Claude Chat-Verlauf
│   ├── features/
│   │   ├── home/
│   │   │   └── home_screen.dart   # Dashboard mit Feature-Kacheln
│   │   ├── notes/
│   │   │   ├── notes_screen.dart
│   │   │   ├── note_editor_screen.dart
│   │   │   ├── drawing_canvas.dart    # Zeichen-Widget
│   │   │   └── notes_provider.dart
│   │   ├── flashcards/
│   │   │   ├── decks_screen.dart
│   │   │   ├── cards_screen.dart
│   │   │   ├── study_screen.dart
│   │   │   ├── anki_import.dart       # .apkg Import
│   │   │   ├── anki_export.dart       # .apkg Export
│   │   │   ├── fsrs.dart              # FSRS-Algorithmus
│   │   │   └── flashcards_provider.dart
│   │   ├── calendar/
│   │   │   ├── calendar_screen.dart
│   │   │   ├── event_editor_screen.dart
│   │   │   └── calendar_provider.dart
│   │   ├── assistant/
│   │   │   ├── chat_screen.dart       # Claude Chat-Interface
│   │   │   ├── claude_api.dart        # Anthropic API Client
│   │   │   └── assistant_provider.dart
│   │   └── settings/
│   │       └── settings_screen.dart   # inkl. API-Key Eingabe
│   └── shared/
│       ├── theme.dart             # Material 3 Theme
│       └── widgets/               # Wiederverwendbare Widgets
├── pubspec.yaml
└── android/                       # Android-spezifische Konfig (autogeneriert)
```

## Nuetzliche Befehle

```bash
# App starten mit Hot Reload
flutter run

# Code generieren (drift, riverpod)
dart run build_runner build

# Tests ausfuehren
flutter test

# APK bauen
flutter build apk --release

# Flutter + Abhaengigkeiten pruefen
flutter doctor
flutter pub outdated
```
