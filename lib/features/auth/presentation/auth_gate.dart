import 'package:cross_platform_app/app/app_shell.dart';
import 'package:cross_platform_app/features/auth/data/auth_service.dart';
import 'package:cross_platform_app/features/auth/presentation/login_page.dart';
import 'package:cross_platform_app/features/profile/data/username_repository.dart';
import 'package:cross_platform_app/features/profile/presentation/username_setup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  final _usernameRepository = UsernameRepository();
  int _setupRefreshKey = 0;
  late final Future<void> _redirectResultFuture;
  String? _redirectErrorText;
  User? _redirectUser;
  String? _diagnosticText;

  @override
  void initState() {
    super.initState();
    _redirectResultFuture = _resolveRedirectResult();
  }

  Future<void> _resolveRedirectResult() async {
    if (!kIsWeb) {
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.getRedirectResult();
      _redirectUser = credential.user;
      if (credential.user != null) {
        final email = credential.user!.email ?? 'ohne E-Mail';
        _diagnosticText = 'Redirect erkannt. Firebase-User: $email';
      } else {
        _diagnosticText = 'Redirect abgeschlossen, aber Firebase hat keinen User zurueckgegeben.';
      }
    } on FirebaseAuthException catch (error) {
      _redirectErrorText = error.message ?? error.code;
      _diagnosticText = 'Firebase Auth Fehler: ${error.code}';
    } catch (_) {
      _redirectErrorText = 'Die Weiterleitung zur Anmeldung konnte nicht abgeschlossen werden.';
      _diagnosticText = 'Redirect-Auswertung fehlgeschlagen.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _redirectResultFuture,
      builder: (context, redirectSnapshot) {
        if (redirectSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = snapshot.data ?? _authService.currentUser ?? _redirectUser;
            if (user == null) {
              return LoginPage(
                authService: _authService,
                initialErrorText: _redirectErrorText,
                diagnosticText: _diagnosticText,
              );
            }

            return FutureBuilder<bool>(
              key: ValueKey(_setupRefreshKey),
              future: _usernameRepository.hasUsername(user.uid),
              builder: (context, usernameSnapshot) {
                if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final hasUsername = usernameSnapshot.data ?? false;
                if (!hasUsername) {
                  return UsernameSetupPage(
                    uid: user.uid,
                    usernameRepository: _usernameRepository,
                    onSuccess: () {
                      setState(() {
                        _setupRefreshKey++;
                      });
                    },
                  );
                }

                return AppShell(authService: _authService, user: user);
              },
            );
          },
        );
      },
    );
  }
}
