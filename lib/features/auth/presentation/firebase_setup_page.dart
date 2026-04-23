import 'package:flutter/material.dart';

class FirebaseSetupPage extends StatelessWidget {
  const FirebaseSetupPage({
    super.key,
    required this.errorText,
  });

  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Firebase-Konfiguration fehlt',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fuer Google/Apple Login und eindeutige Accountnamen muss Firebase eingerichtet sein.',
                  ),
                  const SizedBox(height: 16),
                  const Text('Naechste Schritte:'),
                  const SizedBox(height: 8),
                  const Text('1. Firebase Projekt erstellen (Console).'),
                  const Text('2. Authentication aktivieren: Google und Apple.'),
                  const Text('3. Firestore aktivieren.'),
                  const Text('4. flutterfire configure ausfuehren.'),
                  const SizedBox(height: 16),
                  SelectableText(
                    'Technischer Fehler: $errorText',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
