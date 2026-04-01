# Feature Roadmap

## Phase 1: Fundament + Notizen mit Zeichnen
> Ziel: Lauffaehige App mit Dashboard, Navigation, Datenbank und Notizen inkl. Zeichenfunktion

### Setup
- [ ] Flutter SDK installieren
- [ ] Android Studio installieren (fuer SDK + Emulator)
- [ ] VS Code + Flutter/Dart Extensions einrichten
- [ ] Projekt erstellen: `flutter create mein_organizer`
- [ ] drift (SQLite) einbinden und konfigurieren
- [ ] Grundlegende App-Struktur mit Material 3 Theme

### Home-Dashboard
- [ ] Dashboard als Startseite der App
- [ ] Feature-Kacheln: Notizen, Karteikarten, Kalender, Claude-Assistent
- [ ] Jede Kachel zeigt Kurzinfo (Anzahl Notizen, faellige Karten, heutige Termine)
- [ ] Antippen navigiert zum jeweiligen Feature

### Navigation
- [ ] Bottom Navigation Bar mit Seitenstruktur
- [ ] Seiten: Home, Notizen, Karteikarten (Platzhalter), Kalender (Platzhalter), Einstellungen

### Notizen-Feature
- [ ] Datenbank-Tabelle: `notes` (id, title, content, created_at, updated_at)
- [ ] Datenbank-Tabelle: `note_drawings` (id, note_id, strokes_json, created_at)
- [ ] Notizen-Liste mit Suche
- [ ] Notiz erstellen / bearbeiten (Fullscreen-Editor)
- [ ] Notiz loeschen (mit Bestaetigung)
- [ ] Sortierung: nach Datum oder alphabetisch

### Zeichenfunktion
- [ ] Zeichen-Canvas innerhalb einer Notiz (umschaltbar: Text / Zeichnen)
- [ ] Freihand-Zeichnen mit perfect_freehand (natuerliche Strichstaerke)
- [ ] Stiftfarbe und -breite waehlbar
- [ ] Radierer-Tool
- [ ] Undo/Redo fuer Striche
- [ ] Zeichnung wird als Stroke-Daten in der DB gespeichert

---

## Phase 2: Karteikartensystem (Anki-kompatibel)
> Ziel: Lernmodus mit FSRS-Algorithmus und Anki Import/Export

### Datenmodell
- [ ] Tabelle `decks` (id, name, description, color, created_at)
- [ ] Tabelle `cards` (id, deck_id, front, back, media_refs, created_at)
- [ ] Tabelle `card_progress` (card_id, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review, next_review)

### Anki-Kompatibilitaet
- [ ] .apkg Import: ZIP entpacken, SQLite-DB lesen, Decks + Karten extrahieren
- [ ] .apkg Export: Karten + Decks in Anki-kompatibles Format verpacken
- [ ] Medien-Handling: Bilder aus .apkg extrahieren und lokal speichern
- [ ] HTML-Rendering fuer Karteninhalte (Anki speichert Vorder-/Rueckseite als HTML)

### FSRS-Algorithmus
- [ ] FSRS-Implementierung in Dart (basierend auf Open-Source-Referenz)
- [ ] Bewertung: "Nochmal", "Schwer", "Gut", "Leicht"
- [ ] Naechstes Review-Datum wird automatisch berechnet
- [ ] Algorithmus passt sich an individuelles Lernverhalten an

### Features
- [ ] Deck-Uebersicht (Grid oder Liste)
- [ ] Deck erstellen / bearbeiten / loeschen
- [ ] Karten innerhalb eines Decks verwalten (CRUD)
- [ ] Lernmodus: Karte anzeigen → umdrehen → Bewertung
- [ ] Karten die "faellig" sind werden priorisiert
- [ ] Statistiken: Karten gelernt heute, Streak, Fortschritt pro Deck

---

## Phase 3: Kalender
> Ziel: Termine verwalten mit lokalen Erinnerungen

### Datenmodell
- [ ] Tabelle `events` (id, title, description, start_time, end_time, color, reminder_minutes, created_at)

### Features
- [ ] Monatsansicht (table_calendar Widget)
- [ ] Tagesansicht mit Zeitstrahl
- [ ] Wochenansicht (optional, nach Bedarf)
- [ ] Termin erstellen mit Date/Time Picker
- [ ] Termin bearbeiten / loeschen
- [ ] Lokale Notifications als Erinnerung (flutter_local_notifications)
- [ ] Farbkodierung nach Kategorie

---

## Phase 4: Claude-Assistent
> Ziel: Claude als integrierter Helfer in der App

### Setup
- [ ] Einstellungen-Screen: API-Key Eingabe (Anthropic API)
- [ ] API-Key sicher speichern (flutter_secure_storage)
- [ ] HTTP-Client fuer Anthropic Messages API

### Chat-Interface
- [ ] Chat-Screen mit Nachrichtenverlauf
- [ ] Markdown-Rendering fuer Claude-Antworten (flutter_markdown)
- [ ] Streaming-Antworten (Antwort wird Stueck fuer Stueck angezeigt)
- [ ] Chat-Verlauf lokal speichern

### App-Kontext fuer Claude
- [ ] Claude kann auf Notizen zugreifen ("Fasse meine Notiz zu X zusammen")
- [ ] Claude kann Karteikarten vorschlagen ("Erstelle Karten zu diesem Thema")
- [ ] Claude kann Termine anzeigen ("Was steht diese Woche an?")
- [ ] System-Prompt mit App-Kontext: aktuelle Notizen, faellige Karten, heutige Termine

### Lernhilfe
- [ ] Claude erklaert schwierige Karteikarten-Themen
- [ ] Claude generiert neue Karteikarten aus Text/Notizen
- [ ] Claude beantwortet Fragen zum Lernstoff

---

## Phase 5+: Erweiterungen (nach Bedarf)

### Todo-Listen
- [ ] Aufgaben mit Faelligkeitsdatum und Prioritaet
- [ ] Checklisten innerhalb einer Aufgabe
- [ ] Integration mit Kalender (Faellige Aufgaben im Kalender anzeigen)

### Gewohnheitstracker
- [ ] Taegliche Gewohnheiten definieren
- [ ] Tagescheck: erledigt / nicht erledigt
- [ ] Streak-Anzeige und Statistiken

### Multi-Device Sync
- [ ] Supabase-Backend einrichten
- [ ] Offline-First Sync-Logik: lokal schreiben → bei Verbindung synchronisieren
- [ ] Konfliktloesung bei gleichzeitigen Aenderungen

### Android Widgets
- [ ] Home Screen Widget: Heutige Termine
- [ ] Home Screen Widget: Faellige Karteikarten-Anzahl

### Daten-Management
- [ ] Export: Notizen als Markdown, Termine als ICS
- [ ] Import: Markdown-Dateien als Notizen
- [ ] Automatisches lokales Backup

---

## Technische Schulden / Nice-to-have
- [ ] Dark Mode / Theme-Wechsel
- [ ] Schriftgroesse anpassbar
- [ ] Biometric Lock (Fingerabdruck zum Entsperren)
- [ ] In-App-Suche ueber alle Bereiche (Notizen + Karten + Termine)
