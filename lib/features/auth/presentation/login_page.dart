import 'package:cross_platform_app/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authService,
    this.initialErrorText,
    this.diagnosticText,
  });

  final AuthService authService;
  final String? initialErrorText;
  final String? diagnosticText;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _errorText = widget.initialErrorText;
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await action();
    } catch (e) {
      setState(() {
        _errorText = 'Fehler: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Anmelden',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Melde dich mit Google oder Apple an.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _runAuth(widget.authService.signInWithGoogle),
                    icon: const Icon(Icons.login),
                    label: const Text('Mit Google anmelden'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _runAuth(widget.authService.signInWithApple),
                    icon: const Icon(Icons.apple),
                    label: const Text('Mit Apple ID anmelden'),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (widget.diagnosticText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.diagnosticText!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  if (_isLoading) ...[
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
