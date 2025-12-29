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
  bool _isTakingPhoto = false;

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

    setState(() => _isTakingPhoto = true);
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
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Intel'),
        toolbarHeight: 72,
        titleSpacing: 16,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Utrzymuj paragon w kadrze w dobrym świetle.'),
                ),
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Przechwyć paragon',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Nowoczesne OCR pomoże Ci wydobyć kluczowe informacje w kilku sekundach.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _starting
                        ? _buildLoading()
                        : controller == null
                            ? _buildCameraError()
                            : _buildCameraPreview(controller),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed:
                    controller != null && !_isTakingPhoto ? _takePhoto : null,
                icon: _isTakingPhoto
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.camera_alt_outlined),
                label: Text(
                    _isTakingPhoto ? 'Przetwarzanie...' : 'Zeskanuj paragon'),
              ),
              const SizedBox(height: 8),
              Text(
                'Wskazówka: połóż paragon na jednolitym tle, unikaj ostrych cieni.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Inicjalizacja aparatu...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildCameraError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Icon(Icons.videocam_off, size: 32, color: Colors.red.shade400),
          ),
          const SizedBox(height: 12),
          Text(
            'Brak dostępu do kamery',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Sprawdź uprawnienia i spróbuj ponownie.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withOpacity(0.02)),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.04),
                        Colors.black.withOpacity(0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CameraPreview(controller),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.white.withOpacity(0.9)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Utrzymuj paragon w ramce, wyrównaj do linii prowadzących.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
