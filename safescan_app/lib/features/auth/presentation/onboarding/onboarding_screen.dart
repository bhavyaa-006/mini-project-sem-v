import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/services/app_start_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizing.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      title: 'Scan Before You Buy',
      message: 'Check a barcode or product label before it goes into your basket.',
      icon: Icons.qr_code_scanner,
    ),
    _OnboardingSlide(
      title: "Know What's Inside",
      message: 'See ingredients, nutrition, safety scores and important warnings clearly.',
      icon: Icons.visibility_outlined,
    ),
    _OnboardingSlide(
      title: 'Choose Better Products',
      message: 'Compare alternatives and keep a clear history of the products you check.',
      icon: Icons.eco_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appStartServiceProvider).completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _finish, child: const Text('Skip')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (context, index) => _OnboardingPage(slide: _slides[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      margin: EdgeInsets.only(right: i == _slides.length - 1 ? 0 : AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: AppSizing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(last ? 'Get Started' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({required this.title, required this.message, required this.icon});

  final String title;
  final String message;
  final IconData icon;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize = constraints.maxHeight > 420 ? 220.0 : 160.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _OriginalIllustration(icon: slide.icon, size: illustrationSize),
                const SizedBox(height: AppSpacing.xl),
                Text(slide.title, textAlign: TextAlign.center, style: AppTypography.headline),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(slide.message, textAlign: TextAlign.center, style: AppTypography.body),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OriginalIllustration extends StatelessWidget {
  const _OriginalIllustration({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
          ),
          Positioned(top: size * 0.18, right: size * 0.12, child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle))),
          Positioned(bottom: size * 0.16, left: size * 0.10, child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle))),
          Container(
            width: size * 0.48,
            height: size * 0.48,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x1F202A25), blurRadius: 16, offset: Offset(0, 8))]),
            child: Icon(icon, size: size * 0.24, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
