import 'package:flutter/material.dart';
import 'package:receipt_parser/features/capture/capture_screen.dart';
import 'package:receipt_parser/theme/app_theme.dart';

class ReceiptParserApp extends StatelessWidget {
  const ReceiptParserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Intel',
      theme: AppTheme.light(),
      home: const CaptureScreen(),
    );
  }
}
