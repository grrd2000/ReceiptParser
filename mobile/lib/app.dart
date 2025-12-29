import 'package:flutter/material.dart';
import 'package:receipt_parser/features/capture/capture_screen.dart';

class ReceiptParserApp extends StatelessWidget {
  const ReceiptParserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Intel',
      theme: ThemeData(useMaterial3: true),
      home: const CaptureScreen(),
    );
  }
}
