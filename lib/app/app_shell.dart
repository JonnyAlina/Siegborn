import 'package:cross_platform_app/features/auth/data/auth_service.dart';
import 'package:cross_platform_app/features/counter/presentation/counter_page.dart';
import 'package:cross_platform_app/features/home/presentation/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.authService,
    required this.user,
  });

  final AuthService authService;
  final User user;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CounterPage(),
  ];

  Widget _buildPage() {
    if (_currentIndex == 0) {
      return HomePage(user: widget.user);
    }
    return _pages.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Start' : 'Counter'),
        actions: [
          IconButton(
            onPressed: () async {
              await widget.authService.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
          ),
        ],
      ),
      body: _buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.exposure_plus_1), label: 'Counter'),
        ],
      ),
    );
  }
}
