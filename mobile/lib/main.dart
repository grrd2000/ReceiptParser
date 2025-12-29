import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:receipt_parser/ocr_screen.dart'; 


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt Intel',
      theme: ThemeData(useMaterial3: true),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  XFile? _lastPhoto;

  @override
  void initState() {
    super.initState();
    final camera = widget.cameras.first; // na start bierzemy pierwszą
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initFuture = _controller!.initialize();
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
      body: controller == null
          ? const Center(child: Text('Brak kamery'))
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
      floatingActionButton: _lastPhoto == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PhotoPreviewScreen(path: _lastPhoto!.path),
                  ),
                );
              },
              label: const Text('Podgląd'),
              icon: const Icon(Icons.image),
            ),
    );
  }
}

class PhotoPreviewScreen extends StatelessWidget {
  final String path;
  const PhotoPreviewScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podgląd zdjęcia')),
      body: Center(
        child: Image.file(
          // ignore: avoid_slow_async_io
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text('Nie można wczytać zdjęcia'),
        ),
      ),
    );
  }
}
