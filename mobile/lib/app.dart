import 'package:flutter/material.dart';
import 'package:receipt_parser/features/capture/capture_screen.dart';
import 'package:receipt_parser/features/history/history_screen.dart';
import 'package:receipt_parser/theme/app_theme.dart';

class ReceiptParserApp extends StatelessWidget {
  const ReceiptParserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Intel',
      theme: AppTheme.light(),
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  final _historyKey = GlobalKey<HistoryScreenState>();

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CaptureScreen(),
      HistoryScreen(key: _historyKey),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          if (i == 1) {
            _historyKey.currentState?.reload();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_camera_outlined),
            selectedIcon: Icon(Icons.photo_camera),
            label: 'Skanuj',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_toggle_off),
            label: 'Historia',
          ),
        ],
      ),
    );
  }
}
