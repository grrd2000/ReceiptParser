import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:receipt_parser/features/ocr/ocr_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      setState(() {
        _controller = controller;
        _initFuture = controller.initialize();
        _starting = false;
      });
    } catch (e) {
      setState(() => _starting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się uruchomić kamery: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      await _initFuture;
      final photo = await controller.takePicture();
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OcrScreen(imagePath: photo.path)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd przy robieniu zdjęcia: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Intel')),
      body: _starting
          ? const Center(child: CircularProgressIndicator())
          : controller == null
              ? const Center(child: Text('Brak dostępu do kamery'))
              : FutureBuilder<void>(
                  future: _initFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Stack(
                      children: [
                        CameraPreview(controller),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: Center(
                            child: FilledButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Zrób zdjęcie'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
