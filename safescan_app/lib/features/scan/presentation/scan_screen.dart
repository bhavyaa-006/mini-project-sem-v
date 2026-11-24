import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 600;

            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? AppSpacing.xl : AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Choose what to scan', style: AppTypography.headline),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Get safety information quickly from a barcode or product label.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: _BarcodeOption()),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _LabelOption()),
                          ],
                        )
                      else
                        const Column(
                          children: <Widget>[
                            _BarcodeOption(),
                            SizedBox(height: AppSpacing.md),
                            _LabelOption(),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      const _HowItWorks(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BarcodeOption extends StatelessWidget {
  const _BarcodeOption();

  @override
  Widget build(BuildContext context) {
    return _ScanOptionCard(
      title: 'Scan Barcode',
      explanation: 'Scan a product barcode for a fast safety check.',
      icon: Icons.qr_code_scanner,
      tips: const <String>['Use bright, even lighting', 'Hold the phone steady', 'Keep the barcode flat and in frame'],
      onTap: () => context.go(AppRoutes.barcodeScanner),
    );
  }
}

class _LabelOption extends StatelessWidget {
  const _LabelOption();

  @override
  Widget build(BuildContext context) {
    return _ScanOptionCard(
      title: 'Scan Label',
      explanation: 'Upload or photograph an ingredient and nutrition label.',
      icon: Icons.document_scanner_outlined,
      tips: const <String>['Use bright, even lighting', 'Hold the phone steady', 'Lay the label flat and avoid shadows'],
      onTap: () => context.go(AppRoutes.labelScanner),
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  const _ScanOptionCard({
    required this.title,
    required this.explanation,
    required this.icon,
    required this.tips,
    required this.onTap,
  });

  final String title;
  final String explanation;
  final IconData icon;
  final List<String> tips;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppSizing.iconXl,
            height: AppSizing.iconXl,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(icon, size: AppSizing.iconLg, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(explanation, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          for (final tip in tips) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.check_circle_outline, size: AppSizing.iconSm, color: AppColors.success),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(tip, style: AppTypography.bodySmall)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filled(
              tooltip: 'Open $title',
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('How it works', style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const items = <(IconData, String)>[
                (Icons.document_scanner_outlined, 'Scan'),
                (Icons.psychology_outlined, 'Analyse'),
                (Icons.health_and_safety_outlined, 'Understand'),
              ];

              if (constraints.maxWidth < 420) {
                return Column(
                  children: <Widget>[
                    for (var i = 0; i < items.length; i++) ...<Widget>[
                      Row(children: <Widget>[Icon(items[i].$1, color: AppColors.primary), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(items[i].$2, style: AppTypography.body))]),
                      if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (final item in items)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[Icon(item.$1, color: AppColors.primary), const SizedBox(width: AppSpacing.sm), Flexible(child: Text(item.$2, style: AppTypography.body))],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
