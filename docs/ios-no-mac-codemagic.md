# iOS Deployment ohne Mac (Codemagic)

Diese Anleitung bringt eure Flutter-App von Windows nach TestFlight.

## 1) Vorbereitungen

1. Apple Developer Account aktiv.
2. App Store Connect App angelegt.
3. Bundle Identifier muss zu `BUNDLE_ID` in `codemagic.yaml` passen.
4. In Firebase ist `apple.com` als Auth Provider aktiv.

## 2) Codemagic Projekt verbinden

1. Auf codemagic.io einloggen.
2. Repository verbinden.
3. Workflow `ios_testflight` aus `codemagic.yaml` auswaehlen.

## 3) App Store Connect Integration in Codemagic

1. In Codemagic bei Integrations Apple App Store Connect verbinden.
2. API Key (Issuer ID, Key ID, private key .p8) hinterlegen.
3. Integration beim Workflow auf `auth: integration` belassen.

## 4) Werte in codemagic.yaml anpassen

1. `BUNDLE_ID` auf eure echte iOS Bundle ID setzen.
2. `YOUR_EMAIL@example.com` durch eure Mail ersetzen.

## 5) Erster Build

1. Build starten.
2. Codemagic erstellt Signaturen/Profiles automatisch.
3. Bei Erfolg wird der Build zu TestFlight hochgeladen.

## 6) TestFlight pruefen

1. In App Store Connect -> TestFlight den Build abwarten.
2. Interne Tester hinzufuegen.
3. App auf iPhone via TestFlight installieren und Apple Login pruefen.

## 7) Typische Fehler

1. Bundle ID Fehler: `BUNDLE_ID` stimmt nicht mit App Store Connect ueberein.
2. Signing Fehler: App Store Connect Integration oder Rollenrechte fehlen.
3. Apple Login Fehler: Capability `Sign in with Apple` in App ID nicht aktiv.
