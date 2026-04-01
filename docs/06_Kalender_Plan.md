# Kalender-Feature: Implementierungsplan

## Datenmodell

### Tabelle `CalendarEvents`

| Feld | Typ | Beschreibung |
|---|---|---|
| `id` | autoIncrement | Primary Key |
| `title` | text | Titel des Termins (Pflicht) |
| `description` | text (default: '') | Optionale Beschreibung |
| `location` | text (default: '') | Optionaler Ort |
| `startTime` | dateTime | Startzeitpunkt |
| `endTime` | dateTime | Endzeitpunkt |
| `isAllDay` | boolean (default: false) | Ganztaegiges Event |
| `colorIndex` | integer (default: 0) | Index in Farbpalette (0-7) |
| `reminderMinutes` | integer (nullable) | Minuten vor Start fuer Erinnerung |
| `recurrenceRule` | text (nullable) | RRULE fuer spaeter (nicht in Phase 1) |
| `createdAt` | dateTime | Erstellungszeitpunkt |
| `updatedAt` | dateTime | Letzte Aenderung |

### Farbpalette (8 Farben)
Blau, Rot, Gruen, Orange, Violett, Cyan, Pink, Gelb — analog zu Google Calendar.

### Erinnerungs-Optionen
Keine | Zum Zeitpunkt | 5 Min | 15 Min | 30 Min | 1 Std | 1 Tag vorher

---

## UI-Screens

### 1. CalendarScreen (Hauptscreen im Tab)
- **TableCalendar** Monatsansicht, deutsche Locale, Montag als Wochenstart
- Darunter: **Eventliste** des ausgewaehlten Tages
- Toggle zwischen Monat / 2-Wochen / Woche per Geste
- Farbige Marker-Dots fuer Events im Kalender
- FAB (+) zum Erstellen, vorausgefuellt mit ausgewaehltem Datum

### 2. EventEditorScreen
- Titel (Pflicht), Beschreibung, Ort
- Ganztaegig-Toggle (blendet Zeitauswahl aus)
- Start/End Datum + Uhrzeit (Material 3 Picker)
- Farbauswahl (8 Kreise horizontal)
- Erinnerungs-Auswahl (Dropdown)
- Loeschen-Button im Bearbeitungsmodus
- Unsaved-Changes-Warnung

### 3. DayDetailScreen (spaeter)
- Tagesansicht mit Zeitstrahl — nicht in Phase 1

---

## Technische Details

### Dependencies
```yaml
table_calendar: ^3.1.0
flutter_local_notifications: ^18.0.0
timezone: ^0.10.0
```

### Android-Permissions (AndroidManifest.xml)
- `SCHEDULE_EXACT_ALARM` (Android 12+)
- `POST_NOTIFICATIONS` (Android 13+ — Laufzeit-Permission)
- `RECEIVE_BOOT_COMPLETED` (geplante Notifications nach Neustart)

### NotificationService
- Singleton in `lib/services/notification_service.dart`
- Init in `main.dart` vor `runApp()`
- `scheduleEventReminder(eventId, title, eventTime, minutesBefore)`
- `cancelEventReminder(eventId)`
- Event-ID = Notification-ID (1:1 Mapping)

### Timezone
- `timezone` Package initialisieren mit `Europe/Berlin`
- `TZDateTime` fuer geplante Notifications

---

## Implementierungsreihenfolge

1. **Dependencies + Android-Setup** — pubspec.yaml, AndroidManifest
2. **Datenmodell + Migration** — Tabelle, Schema v3, CRUD-Methoden, build_runner
3. **Provider** — eventsForMonth, eventsForDay, todayEventCount
4. **Konstanten + Widgets** — Farbpalette, EventListTile, ColorPicker, ReminderPicker
5. **CalendarScreen** — TableCalendar + Tagesliste
6. **EventEditorScreen** — Formular mit allen Feldern
7. **NotificationService** — Erinnerungen planen/canceln
8. **Home-Dashboard** — "X Termine heute" dynamisch

---

## Stolperfallen

- **DateTime UTC vs. Lokal**: SQLite speichert UTC, Queries muessen lokalen Tag-Bereich berechnen
- **Android 13+ Notification Permission**: Muss zur Laufzeit angefragt werden
- **Exact Alarm ab Android 14**: User muss Permission in Einstellungen gewaehren
- **build_runner**: Nach jeder Drift-Tabellenaenderung neu ausfuehren
- **Locale-Init**: `initializeDateFormatting('de_DE')` noetig fuer deutsche Monatsnamen

## Defaults bei Neuerstellung
- Startzeit: naechste volle Stunde
- Endzeit: +1 Stunde
- Ganztaegig: aus
- Farbe: Blau (Index 0)
- Erinnerung: keine

---

## Spaeter (nicht Phase 1)
- [ ] Wiederkehrende Termine (RRULE — Feld ist vorbereitet)
- [ ] Wochenansicht mit Zeitraster
- [ ] ICS-Export/Import
- [ ] Mehrtaegige Events visuell im Kalender
- [ ] Google Calendar Sync
