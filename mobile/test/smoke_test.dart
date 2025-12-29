import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_parser/theme/app_theme.dart';

void main() {
  testWidgets('theme builds and renders basic scaffold', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: Text('Receipt Intel')),
        ),
      ),
    );

    expect(find.text('Receipt Intel'), findsOneWidget);
  });
}
