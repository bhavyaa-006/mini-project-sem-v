import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/permissions/camera_permission.dart';
import '../../../core/router/navigation.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../providers/scan_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _frameController;
  late final Animation<double> _frameAnimation;
  CameraPermissionStatus _permission = CameraPermissionStatus.denied;
  bool _permissionLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _frameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _frameAnimation = Tween<double>(begin: -44, end: 44).animate(CurvedAnimation(parent: _frameController, curve: Curves.easeInOut));
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final service = ref.read(cameraPermissionServiceProvider);
    var status = await service.status();
    if (status == CameraPermissionStatus.denied) {
      status = await service.request();
    }
    if (!mounted) return;
    setState(() {
      _permission = status;
      _permissionLoading = false;
    });
  }

  Future<void> _requestPermission() async {
    setState(() => _permissionLoading = true);
    final status = await ref.read(cameraPermissionServiceProvider).request();
    if (!mounted) return;
    setState(() {
      _permission = status;
      _permissionLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_permission != CameraPermissionStatus.granted) return;
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameController.dispose();
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  void _onDetected(BarcodeCapture capture) {
    if (ref.read(barcodeScanProvider).status == BarcodeScanStatus.detected) return;
    final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) {
      ref.read(barcodeScanProvider.notifier).setError('No readable barcode was found. Keep it in the frame and try again.');
      return;
    }

    ref.read(barcodeScanProvider.notifier).detect(value);
    _controller.stop();
    HapticFeedback.mediumImpact();

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final result = ref.read(barcodeScanProvider);
      if (result.status == BarcodeScanStatus.detected && result.barcode != null) {
        context.go(AppRoutes.scanProcessingPath(result.barcode!));
      }
    });
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (file == null) return;

    try {
      final capture = await _controller.analyzeImage(file.path);
      if (capture == null || capture.barcodes.isEmpty) {
        if (!mounted) return;
        ref.read(barcodeScanProvider.notifier).setError('No barcode was found in that image. Choose a clearer, well-lit image.');
        return;
      }
      _onDetected(capture);
    } catch (_) {
      if (!mounted) return;
      ref.read(barcodeScanProvider.notifier).setError('This image could not be scanned. Try another image.');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } catch (_) {
      ref.read(barcodeScanProvider.notifier).setError('The other camera is unavailable on this device.');
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      ref.read(barcodeScanProvider.notifier).setError('The flashlight is unavailable on this device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_permission != CameraPermissionStatus.granted) {
      return _PermissionView(
        permanentlyDenied: _permission == CameraPermissionStatus.permanentlyDenied,
        onRequest: _requestPermission,
        onOpenSettings: () => ref.read(cameraPermissionServiceProvider).openSettings(),
      );
    }

    final scanState = ref.watch(barcodeScanProvider);

    return Scaffold(
      backgroundColor: AppColors.text,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            MobileScanner(
              controller: _controller,
              onDetect: _onDetected,
              useAppLifecycleState: false,
              errorBuilder: (context, error) => const Center(child: Text('The camera could not start. Please try again.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.white))),
            ),
            IgnorePointer(child: ColoredBox(color: AppColors.text.withValues(alpha: 0.18))),
            Center(
              child: AnimatedBuilder(
                animation: _frameAnimation,
                builder: (context, child) => Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                    Positioned(top: 140 + _frameAnimation.value, child: Container(width: 236, height: 3, color: AppColors.success)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Row(
                children: <Widget>[
                  IconButton.filledTonal(onPressed: () => safeGoBack(context, AppRoutes.scanHub), tooltip: 'Cancel', icon: const Icon(Icons.close)),
                  const Spacer(),
                  IconButton.filledTonal(onPressed: _toggleTorch, tooltip: 'Toggle flashlight', icon: const Icon(Icons.flashlight_on_outlined)),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filledTonal(onPressed: _switchCamera, tooltip: 'Switch camera', icon: const Icon(Icons.cameraswitch_outlined)),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (scanState.status == BarcodeScanStatus.error)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.error_outline, color: AppColors.white),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(scanState.message ?? 'Try again.', style: AppTypography.bodySmall.copyWith(color: AppColors.white))),
                          IconButton(onPressed: () => ref.read(barcodeScanProvider.notifier).clearError(), icon: const Icon(Icons.close, color: AppColors.white)),
                        ],
                      ),
                    ),
                  const Text('Align the barcode inside the frame', textAlign: TextAlign.center, style: TextStyle(color: AppColors.white)),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(label: 'Choose from gallery', icon: Icons.photo_library_outlined, onPressed: _pickImage),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(onPressed: () => safeGoBack(context, AppRoutes.scanHub), child: const Text('Cancel', style: TextStyle(color: AppColors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.permanentlyDenied, required this.onRequest, required this.onOpenSettings});

  final bool permanentlyDenied;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera permission')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.photo_camera_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(permanentlyDenied ? 'Camera access is blocked' : 'Camera access needed', style: AppTypography.headline, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text(permanentlyDenied ? 'Open Settings and enable Camera to scan barcodes.' : 'SafeScan needs your camera to scan a barcode or label in real time.', style: AppTypography.body, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: permanentlyDenied ? 'Open settings' : 'Allow camera', icon: permanentlyDenied ? Icons.settings_outlined : Icons.photo_camera_outlined, onPressed: permanentlyDenied ? onOpenSettings : onRequest),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(onPressed: () => safeGoBack(context, AppRoutes.scanHub), child: const Text('Cancel')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
