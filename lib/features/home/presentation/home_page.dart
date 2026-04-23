import 'package:cross_platform_app/features/profile/data/username_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String?>(
      future: UsernameRepository().getUsername(user.uid),
      builder: (context, snapshot) {
        final username = snapshot.data ?? '-';

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Willkommen',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Du bist erfolgreich angemeldet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('E-Mail: ${user.email ?? 'nicht verfuegbar'}'),
                    const SizedBox(height: 8),
                    Text('Accountname: $username'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
