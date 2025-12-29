import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_parser/domain/parsing/receipt_basic_parser.dart';
import 'package:receipt_parser/features/receipt_edit/receipt_edit_screen.dart';

class OcrScreen extends StatefulWidget {
  final String imagePath;
  const OcrScreen({super.key, required this.imagePath});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  late final TextRecognizer _recognizer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _runOcr();
  }

  Future<void> _runOcr() async {
    try {
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final recognizedText = await _recognizer.processImage(inputImage);

      final lines = <String>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final t = line.text.trim();
          if (t.isNotEmpty) lines.add(t);
        }
      }

      final parser = ReceiptBasicParser();
      final draft = parser.parse(lines);

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReceiptEditScreen(draft: draft, ocrLines: lines),
        ),
      );
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(child: Text(_error ?? 'Gotowe')),
    );
  }
}
