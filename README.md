# cross_platform_app

Cross-platform Flutter app with Firebase auth and username onboarding.

## Apple Login (iOS) Setup

Damit Apple Login auf iOS funktioniert, muessen App, Firebase und Apple Developer zusammenpassen.

1. Apple Developer konfigurieren:
	- Unter Identifiers die App-ID mit der Capability Sign In with Apple aktivieren.
	- Sicherstellen, dass eure Bundle-ID mit iOS Runner uebereinstimmt.

2. Firebase konfigurieren:
	- In Firebase Console unter Authentication -> Sign-in method den Provider Apple aktivieren.
	- Service ID, Team ID, Key ID und private key (`.p8`) eintragen.
	- Die Redirect-URL aus Firebase in Apple Developer bei der Service ID hinterlegen.

3. iOS Projekt pruefen:
	- `ios/Runner/Runner.entitlements` enthaelt `com.apple.developer.applesignin`.
	- `ios/Runner.xcodeproj/project.pbxproj` setzt `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`.

4. Flutter/Firebase Dateien:
	- `lib/features/auth/data/auth_service.dart` nutzt `sign_in_with_apple` + Firebase Credential Sign-In.
	- `lib/features/auth/presentation/login_page.dart` bietet den Apple-Login-Button auf iOS/macOS/Web.

5. Test auf echtem iPhone:
	- Apple Login laeuft in der Regel nur auf realem Geraet sinnvoll durch.
	- In der Firebase Console pruefen, ob ein User mit Provider `apple.com` angelegt wird.

## Apple Login iOS Test (5 Minuten)

1. App auf iPhone im Debug starten und Login-Seite oeffnen.
2. Debug-Hinweis auf Login-Seite pruefen:
	- Erwartet: `Plattform=iOS` und `Apple verfuegbar=ja`.
3. Auf Mit Apple ID anmelden tippen und Login vollstaendig abschliessen.
4. Erwartung nach Erfolg:
	- Kein Fehlertext auf der Login-Seite.
	- Nutzer landet nicht mehr auf der Login-Seite.
5. Firebase Console pruefen:
	- Authentication -> Users: neuer/aktualisierter User vorhanden.
	- Provider des Users ist `apple.com`.
6. Abbruch-Test:
	- Apple-Dialog erneut oeffnen und abbrechen.
	- Erwartet: kein harter Fehler, App bleibt stabil auf Login-Seite.

## iOS Ohne Mac

Der komplette No-Mac Deployment-Flow ueber Codemagic steht hier:

- `docs/ios-no-mac-codemagic.md`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
hallo