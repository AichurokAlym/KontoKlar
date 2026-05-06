# KontoKlar

<img width="433" height="324" alt="Screenshot 2026-05-06 at 11 19 41" src="https://github.com/user-attachments/assets/01e553c8-8f82-42b9-b6e8-e8a36905e792" />


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
