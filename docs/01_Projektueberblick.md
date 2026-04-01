# Mein Organizer — Projektueberblick

## Vision
Eine persoenliche Android-App, die alle Produktivitaets-Tools an einem Ort vereint:
Terminkalender, Notizen mit Zeichenfunktion, Anki-kompatibles Karteikartensystem,
und ein integrierter Claude-Assistent — alles in einer App.

## Rahmenbedingungen

| Aspekt | Entscheidung |
|---|---|
| **Plattform** | Nur Android (kein iOS, kein Web) |
| **Nutzer** | Nur ich (kein App Store, kein Multi-User) |
| **Skalierung** | App wird ueber die Zeit groesser und komplexer |
| **Performance** | Muss auch bei wachsender Komplexitaet fluessig bleiben |
| **Distribution** | APK direkt aufs Handy installieren |
| **Entwicklung** | Mit Claude Code als Entwicklungspartner |

## App-Einstieg: Home-Dashboard
Beim Oeffnen der App wird ein **Dashboard** angezeigt, das alle verfuegbaren
Features als Kacheln/Karten auflistet. Jede Kachel zeigt:
- Icon + Name des Features
- Kurze Info (z.B. "3 Notizen", "12 Karten faellig", "2 Termine heute")
- Antippen oeffnet das jeweilige Feature

## Kernfeatures (geplant)

### Phase 1 — Fundament + Notizen
- **Home-Dashboard**: Uebersicht aller Features beim App-Start
- **Notizen**: Erstellen, bearbeiten, loeschen, durchsuchen
- **Zeichenfunktion**: Freihand-Zeichnen innerhalb von Notizen (Skizzen, Diagramme, handschriftliche Notizen)
- **Navigation**: Bottom Navigation fuer Seitenwechsel

### Phase 2 — Karteikarten (Anki-kompatibel)
- **Anki-Kompatibilitaet**: .apkg Import/Export, damit Decks zwischen Anki und dieser App austauschbar sind
- **FSRS-Algorithmus**: Moderner Spaced-Repetition-Algorithmus (wie Anki seit v23.10)
- **Decks erstellen**: Themenbasierte Karteikartensammlungen
- **Lernmodus**: Karte umdrehen, Selbstbewertung

### Phase 3 — Kalender
- **Tages-/Wochen-/Monatsansicht**
- **Termine erstellen** mit Titel, Zeit, Beschreibung
- **Erinnerungen** via lokale Android-Notifications

### Phase 4 — Claude-Assistent
- **Chat-Interface**: Claude direkt in der App als Support-Bot
- **App-Kontext**: Claude kann auf Notizen, Karteikarten und Termine zugreifen
- **Lernhilfe**: Claude kann beim Lernen helfen, Fragen beantworten, Karteikarten vorschlagen
- **API-Key**: Wird in den Einstellungen hinterlegt (Anthropic API)

### Phase 5+ — Erweiterungen (nach Bedarf)
- Todo-Listen / Aufgabenmanagement
- Gewohnheitstracker
- Sync zwischen Geraeten (Supabase)
- Widgets fuer den Android Homescreen
- Backup/Export der Daten

## Was diese App NICHT ist
- Kein Multi-User-System
- Kein Web-Frontend
- Kein kommerzielles Produkt
- Keine iOS-Version
