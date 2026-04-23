import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Counter'),
          const SizedBox(height: 8),
          Text(
            '$_count',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _increment,
            icon: const Icon(Icons.add),
            label: const Text('Erhoehen'),
          ),
        ],
      ),
    );
  }
}
