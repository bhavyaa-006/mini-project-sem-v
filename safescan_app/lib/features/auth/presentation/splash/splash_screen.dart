import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/services/app_start_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navigationTimer;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    unawaited(_finishSplash());
  }

  Future<void> _finishSplash() async {
    final completer = Completer<void>();
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () => completer.complete());
    await completer.future;
    if (!mounted) return;

    final destination = await ref.read(appStartDestinationProvider.future);
    if (!mounted) return;

    context.go(StorageAppStartService.routeFor(destination));
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _SafeScanLogo(),
                    const SizedBox(height: AppSpacing.lg),
                    Text('SafeScan', style: AppTypography.display),
                    const SizedBox(height: AppSpacing.xs),
                    Text("Know What's Inside.", style: AppTypography.body.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SafeScanLogo extends StatelessWidget {
  const _SafeScanLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 104,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(Icons.shield_rounded, size: 104, color: AppColors.primary),
          CustomPaint(
            size: const Size(48, 48),
            painter: _BarcodePainter(),
          ),
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    final bars = <double>[4, 8, 14, 19, 23, 28, 34, 39, 44];
    for (final x in bars) {
      canvas.drawLine(Offset(x, 7), Offset(x, 37), paint);
    }
    canvas.drawLine(const Offset(4, 42), Offset(size.width - 4, 42), paint..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
