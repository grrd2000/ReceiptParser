import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrScreen extends StatefulWidget {
  final String imagePath;
  const OcrScreen({super.key, required this.imagePath});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  late final TextRecognizer _recognizer;
  String _text = '';
  bool _loading = true;

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

      // na start: cały tekst
      setState(() {
        _text = recognizedText.text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _text = 'OCR error: $e';
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
      appBar: AppBar(title: const Text('OCR wynik')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(_text),
            ),
    );
  }
}
