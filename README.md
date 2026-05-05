# KontoKlar

KontoKlar ist eine persönliche Finanz-App (iOS) zum **Erfassen von Einnahmen und Ausgaben**, zum **Behalten des Überblicks über dein Budget** und zum **Verfolgen deiner Sparziele** – alles **lokal auf deinem Gerät**.

## Highlights

- **Dashboard-Überblick**: Saldo, Einnahmen, Ausgaben und **durchschnittliche Ausgaben pro Tag** (für den gewählten Zeitraum).
- **Budget & Ziele**: Monatsbudget und Sparziel mit Fortschrittsanzeige.
- **Kategorien**: Eigene Kategorien für Einnahmen/Ausgaben erstellen – inklusive **Icon** und **Farbe**.
- **Transaktionen**: Einnahmen und Ausgaben mit Betrag, Datum, Kategorie und Notiz erfassen, bearbeiten und löschen.
- **Zeiträume filtern**: Woche/Monat/Jahr oder **benutzerdefinierter Zeitraum**.
- **Mehrsprachig**: Deutsch & Englisch (Localization via `Localizable.strings`).
- **Währung & Rundung**: Währung beim Start wählen, optional Zahlen runden.

## Datenschutz

KontoKlar speichert deine Daten **ausschließlich auf deinem Gerät** (persistiert mit **SwiftData**).  
Du behältst die volle Kontrolle – es gibt keine serverseitige Speicherung in diesem Projektstand.

## Tech Stack

- **SwiftUI** (UI)
- **SwiftData** (lokale Persistenz)
- **MVVM** (ViewModels/Stores/UseCases)
- **Localization**: `de.lproj` / `en.lproj`

## Projekt starten (Xcode)

Voraussetzungen:

- Xcode (aktuelle Version empfohlen)
- iOS Simulator oder echtes Gerät

Schritte:

1. Repository klonen
2. `KontoKlar.xcodeproj` in Xcode öffnen
3. Target **KontoKlar** auswählen
4. Run (⌘R)

## Erste Schritte in der App

Beim ersten Start kannst du:

- eine **Währung** auswählen
- optional **Basis-Kategorien** für Einnahmen und Ausgaben automatisch anlegen lassen

Danach kannst du Transaktionen hinzufügen und deine Ausgaben im Dashboard nach Zeitraum analysieren.

## Tests

Es sind Unit-Tests im Ordner `KontoKlarTests` vorhanden (z. B. Repositories/Stores).  
Ausführen in Xcode: **Product → Test** (⌘U).

## Screenshots
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-05-05 at 17 42 38" src="https://github.com/user-attachments/assets/2f9da02e-6556-4ceb-92fd-41988592bcde" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-05-05 at 17 42 14" src="https://github.com/user-attachments/assets/db57bfa6-0dcb-46bd-b431-26418d3c13ed" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-05-05 at 17 32 56" src="https://github.com/user-attachments/assets/a0e46a9d-4a25-4e21-a89a-bd89b0cc2ed0" />


## Lizenz

Noch keine Lizenzdatei hinterlegt. Falls du das Projekt veröffentlichen möchtest, füge z. B. eine `LICENSE` (MIT/Apache-2.0/etc.) hinzu.
