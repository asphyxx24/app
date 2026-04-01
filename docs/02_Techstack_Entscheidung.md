# Techstack-Entscheidung

## Gewaehlter Stack: Flutter + Dart + SQLite (drift)

## Warum Flutter?

### Evaluierte Alternativen

| Ansatz | Vorteile | Nachteile | Verdict |
|---|---|---|---|
| **PWA** | Schnellster Start, kein Build noetig | WebView-Performance, begrenzte Offline-Speicherung (iOS 50 MB Limit, 7-Tage-Eviction), keine echten nativen APIs | Nicht geeignet fuer wachsende Komplexitaet |
| **Capacitor** | 100% Web-Code-Reuse, Web + App aus einem Codebase | Immer noch WebView unter der Haube, Performance-Limit bei komplexen UIs, braucht trotzdem Android Studio zum Builden | Guter Kompromiss, aber WebView bleibt Flaschenhals |
| **React Native / Expo** | Native Rendering, grosses Oekosystem, kein Xcode/Android Studio noetig (EAS Build) | UI muss in RN-Primitives neu geschrieben werden, Bridge-Overhead, TypeScript-Kenntnisse waeren Vorteil | Solide Option, aber kein Vorteil gegenueber Flutter wenn Dart kein Problem ist |
| **Flutter** | Native GPU-Rendering (Skia/Impeller), Material Design eingebaut, Hot Reload, ein Toolset, Dart ist sauber typisiert | Muss Dart lernen, groessere APK (~15-20 MB vs ~7-10 MB RN) | **Gewaehlt** |

### Entscheidungsgruende fuer Flutter

1. **Performance**: Flutter rendert direkt auf der GPU via Impeller (Android) / Skia. Kein WebView, keine JavaScript-Bridge. 60/120 fps auch bei komplexen UIs.

2. **Material Design ist nativ**: Da die App nur fuer Android ist, passt Material Design perfekt. Flutter hat die beste Material-3-Implementation aller Frameworks — direkt von Google.

3. **Dart ist kein Hindernis**: Die Entwicklung passiert mit Claude Code. Dart ist eine saubere, stark typisierte Sprache die gut lesbar und debuggbar ist.

4. **Alles aus einem Guss**: Kein Plugin-Kompatibilitaetsproblem zwischen Web und Native. Kein Bridge-Overhead. Ein Toolset, eine Sprache, ein Build-System.

5. **Hot Reload**: Aenderungen sind in Millisekunden auf dem Geraet sichtbar — kein Neustart, kein Rebuild.

6. **Widget-System**: Flutters kompositionelles Widget-System ist ideal fuer komplexe UIs (Kalender, Karteikarten-Animationen, verschachtelte Listen).

## Kein Backend (vorerst)

### Warum kein Server?
- Die App ist nur fuer einen Nutzer auf Android-Geraeten
- Kalender, Notizen, Karteikarten sind primaer lokale Daten
- Kein Server = keine Kosten, keine Latenz, keine Abhaengigkeit

### Lokale Datenbank: drift (SQLite)
- **drift** (frueher: moor) ist die fuehrende typsichere SQLite-Bibliothek fuer Flutter/Dart
- Volle SQL-Power (Joins, Indizes, Migrationen)
- Compile-Time-Checks fuer Queries
- Generierte Dart-Klassen aus dem Schema
- Daten bleiben bis zur App-Deinstallation erhalten — kein Browser-Limit

### Spaeter bei Bedarf: Supabase
Wenn Multi-Device-Sync gewuenscht ist:
- Supabase (PostgreSQL) als Backend nachrüsten
- Lokale drift-DB bleibt Primary → Supabase als Sync-Target
- Offline-First: App funktioniert immer, sync wenn online

## Zusaetzliche Packages fuer neue Features

### Zeichenfunktion in Notizen
| Package | Zweck |
|---|---|
| **perfect_freehand** | Natuerlich aussehende Freihand-Striche mit variabler Strichstaerke |
| **flutter_colorpicker** | Farbauswahl fuer Stifte/Marker |

Die Zeichnungen werden als Liste von Stroke-Objekten (Punkte + Farbe + Breite) serialisiert und in der drift-DB gespeichert.

### Anki-Kompatibilitaet
| Package | Zweck |
|---|---|
| **archive** | ZIP-Handling fuer .apkg Dateien (Anki-Export-Format) |
| **sqlite3** | Direktes Lesen der Anki-Datenbank innerhalb der .apkg |

**.apkg Format**: Eine .apkg Datei ist ein ZIP-Archiv mit einer SQLite-Datenbank (`collection.anki2` / `collection.anki21`). Enthaelt Decks, Karten (Vorderseite/Rueckseite als HTML), Medien und Lernfortschritt.

**FSRS-Algorithmus**: Free Spaced Repetition Scheduler — der moderne Algorithmus den Anki seit v23.10 nutzt. Besser als SM-2, da er auf maschinellem Lernen basiert und sich an das individuelle Lernverhalten anpasst. Wird in Dart implementiert.

### Claude-Integration
| Package | Zweck |
|---|---|
| **http** / **dio** | HTTP-Client fuer Anthropic API Calls |
| **flutter_markdown** | Markdown-Rendering fuer Claude-Antworten |
| **flutter_secure_storage** | Sicheres Speichern des API-Keys |

Der API-Key wird in den App-Einstellungen eingegeben und sicher auf dem Geraet gespeichert. Claude bekommt Kontext ueber die App-Daten (Notizen, Karteikarten, Termine) und kann als Lernassistent, Support-Bot oder Brainstorming-Partner fungieren.

## Tooling

| Tool | Zweck |
|---|---|
| **Flutter SDK** | Framework + CLI (`flutter create`, `flutter run`, `flutter build`) |
| **Android Studio** | Android SDK + Emulator (muss installiert sein, kann aber im Hintergrund bleiben) |
| **VS Code + Flutter Extension** | Leichterer Editor zum Entwickeln |
| **drift** | Typsichere SQLite-Datenbank |
| **flutter_local_notifications** | Lokale Erinnerungen/Benachrichtigungen |
| **table_calendar** | Kalender-Widget (spart Wochen Entwicklungszeit) |
| **flutter_riverpod** | State Management |
| **perfect_freehand** | Freihand-Zeichnen |
| **archive** | .apkg Import/Export (Anki) |
| **http** | Anthropic API fuer Claude-Integration |
| **flutter_secure_storage** | Sichere Speicherung des API-Keys |

## APK-Distribution
Kein Play Store noetig. Workflow:
```bash
flutter build apk --release
# APK liegt unter: build/app/outputs/flutter-apk/app-release.apk
# Per USB, AirDroid, oder Cloud-Storage aufs Handy kopieren
# Auf dem Handy: "Aus unbekannten Quellen installieren" erlauben
```
