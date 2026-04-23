import 'package:cross_platform_app/features/profile/data/username_repository.dart';
import 'package:flutter/material.dart';

class UsernameSetupPage extends StatefulWidget {
  const UsernameSetupPage({
    super.key,
    required this.uid,
    required this.usernameRepository,
    required this.onSuccess,
  });

  final String uid;
  final UsernameRepository usernameRepository;
  final VoidCallback onSuccess;

  @override
  State<UsernameSetupPage> createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _errorText = 'Bitte gib einen Accountnamen ein.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final success = await widget.usernameRepository.reserveUniqueUsername(
        uid: widget.uid,
        username: raw,
      );

      if (!success) {
        setState(() {
          _errorText = 'Der Name ist bereits vergeben. Bitte waehle einen anderen.';
        });
        return;
      }

      widget.onSuccess();
    } on FormatException catch (e) {
      setState(() {
        _errorText = e.message;
      });
    } catch (_) {
      setState(() {
        _errorText = 'Fehler beim Speichern. Bitte erneut versuchen.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Accountname erstellen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dieser Name ist oeffentlich sichtbar und muss eindeutig sein.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    enabled: !_isSubmitting,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Accountname',
                      hintText: 'z. B. spieler_123',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Erlaubt: a-z, 0-9, _ | Laenge: 3-20'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: const Text('Namen speichern'),
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
                  if (_isSubmitting) ...[
                    const SizedBox(height: 16),
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
