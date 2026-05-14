# OTurn (OurTurn)

Eine lokale Flutter-App für Android und iOS zur fairen Aufgabenverteilung in Teams.

## Projektbeschreibung

OTurn ermöglicht es, persistente Aufgaben mit festen Gruppen zu erstellen und diese fair zu verteilen. Jede Aufgabe hat ein Gedächtnis für faire Rotation, sodass nicht immer dieselben Personen ausgewählt werden.

## Kern-Konzept

### 1. Gruppen erstellen
- **Feste Personenkreise**: Einmalig Gruppe mit Namen erstellen (z.B. "Marketing Team")
- **Lokale Speicherung**: Gruppen werden persistent auf dem Gerät gespeichert
- **Wiederverwendbar**: Gruppen können für verschiedene Aufgaben genutzt werden

### 2. Aufgaben definieren
- **Persistente Aufgaben**: Aufgaben wie "Mail an GL verfassen" dauerhaft anlegen
- **Gruppe zuweisen**: Einer Aufgabe eine bestehende Gruppe hinzufügen
- **Flexible Teilnahme**:
  - Namen manuell zur Aufgabe hinzufügen
  - Gruppenmitglieder für spezifische Aufgabe ausschließen
  - Temporäre Teilnehmer hinzufügen

### 3. Faire Verteilung
- **Fair Switch ON**: Rotiert durch alle Personen, bis jeder einmal dran war
- **Fair Switch OFF**: Komplett zufällige Auswahl bei jedem Würfeln
- **Aufgaben-Historie**: Jede Aufgabe merkt sich, wer bereits dran war
- **Wiederkehrende Fairness**: Nach einer Runde beginnt die faire Rotation von vorn

### 4. Lokale Speicherung
- **Persistent**: Alle Daten werden lokal auf dem Gerät gespeichert
- **Offline-First**: App funktioniert komplett ohne Internet
- **Backup**: Export/Import-Funktionen für Datensicherung

## Zusätzliche Features

### Benutzerfreundlichkeit
- **Undo-Funktion**: Letzte Auswahl rückgängig machen
- **Quick-Actions**: Häufige Aufgaben als Shortcuts
- **Aufgaben-Templates**: Vorgefertigte Aufgaben (Daily Standup, Code Review, etc.)
- **Statistiken**: Wer hat wie oft welche Aufgabe gemacht
- **Export/Import**: Daten sichern und zwischen Geräten übertragen

### Smart Features
- **Abwesenheits-Modus**: Personen temporär als "nicht verfügbar" markieren
- **Gewichtung**: Manche Personen seltener/öfter auswählen
- **Aufgaben-Kategorien**: Verschiedene Fair-Switches für verschiedene Aufgabentypen
- **Batch-Modus**: Mehrere Aufgaben gleichzeitig verteilen

## Technische Architektur

### Frontend
- **Flutter**: Cross-platform Development für Android und iOS
- **Dart**: Programmiersprache
- **State Management**: Provider (aktuell implementiert)
- **Local Storage**: Hive für lokale Datenpersistierung

### Datenpersistierung
- **Local Storage**: Hive für lokale Datenspeicherung
- **Data Format**: Dart-basierte Datenstrukturen mit Hive TypeAdapters
- **Backup/Restore**: Export als JSON für Datensicherung (geplant)

### Datenstruktur
```json
{
  "groups": [
    {
      "id": "uuid",
      "name": "Marketing Team",
      "members": ["Alice", "Bob", "Charlie"],
      "created_at": "timestamp"
    }
  ],
  "tasks": [
    {
      "id": "uuid",
      "name": "Mail an GL verfassen",
      "group_id": "uuid",
      "additional_members": ["David"],
      "excluded_members": ["Charlie"],
      "fair_mode": true,
      "history": [
        {
          "selected_person": "Alice",
          "timestamp": "2024-01-15T10:30:00Z",
          "participants": ["Alice", "Bob", "David"]
        }
      ],
      "fair_queue": ["Bob", "David"],
      "created_at": "timestamp",
      "last_updated": "timestamp"
    }
  ]
}
```

## Entwicklungsstand

### ✅ Aktuell implementiert (Phase 1: MVP)
1. **Flutter Projekt Setup**: Grundstruktur mit Navigation ✅
2. **Gruppen-Management**: Gruppen erstellen, bearbeiten, löschen ✅
3. **Aufgaben-System**: Persistente Aufgaben mit Gruppenverknüpfung ✅
4. **Fair-Switch Logic**: Faire Rotation vs. Random-Modus ✅
5. **Lokale Datenpersistierung**: Hive für lokale Speicherung ✅
6. **Bilder-Support**: Gruppen und Aufgaben können Bilder haben ✅
7. **Theme-System**: Dark/Light Mode Support ✅

### 🚧 Geplant (Phase 2: Erweiterte Features)
1. **Statistiken & Analytics**: Übersicht über Aufgabenverteilung pro Person
2. **Export/Import**: Backup-Funktionen für Datensicherung
3. **Erweiterte UI/UX**: Animationen, bessere User Experience
4. **Aufgaben-Templates**: Vorgefertigte häufige Aufgaben

### Phase 3: Polish & Store
1. **Abwesenheits-Management**: Personen temporär ausschließen
2. **Gewichtung**: Personen unterschiedlich häufig auswählen
3. **Batch-Operationen**: Mehrere Aufgaben gleichzeitig verteilen
4. **App Icons & Branding**: Professionelles Design
5. **App Store Deployment**: iOS und Android Stores

### Zukünftige Features (V2)
- **Sharing-Funktionen**: Export/Import für Team-Synchronisation
- **Cloud-Backup**: Optionale Cloud-Speicherung
- **Advanced Analytics**: Detaillierte Statistiken und Reports

## Lizenz

TBD

## Mitwirkende

TBD