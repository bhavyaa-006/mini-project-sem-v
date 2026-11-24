import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../providers/scan_provider.dart';

class ScanProcessingScreen extends ConsumerStatefulWidget {
  const ScanProcessingScreen({required this.barcode, super.key});

  final String barcode;

  @override
  ConsumerState<ScanProcessingScreen> createState() => _ScanProcessingScreenState();
}

class _ScanProcessingScreenState extends ConsumerState<ScanProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(widget.barcode == 'label'
        ? ref.read(scanProcessingProvider.notifier).processLabel()
        : ref.read(scanProcessingProvider.notifier).processBarcode(Uri.decodeComponent(widget.barcode)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    ref.read(scanProcessingProvider.notifier).cancel();
    if (!mounted) return;
    context.go(AppRoutes.scanHub);
  }

  void _navigateSuccess(String id) {
    if (!mounted) return;
    context.go(AppRoutes.productResultPath(id));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScanProcessingState>(scanProcessingProvider, (previous, next) {
      if (next.status == ProcessingStatus.success && next.result != null) {
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (mounted) _navigateSuccess(next.result!.id);
        });
      }
    });

    final state = ref.watch(scanProcessingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing scan'),
        leading: IconButton(tooltip: 'Cancel processing', onPressed: _cancel, icon: const Icon(Icons.close)),
      ),
      body: SafeArea(
        child: switch (state.status) {
          ProcessingStatus.loading => _LoadingView(controller: _controller, onCancel: _cancel),
          ProcessingStatus.cancelled => _LoadingView(controller: _controller, onCancel: _cancel),
          ProcessingStatus.success => _SuccessView(resultName: state.result?.product.name ?? 'Product'),
          ProcessingStatus.notFound => _NotFoundView(barcode: widget.barcode),
          ProcessingStatus.error => _ProcessingErrorView(
              message: state.message ?? 'The scan could not be analysed.',
              barcode: widget.barcode,
            ),
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.controller, required this.onCancel});

  final AnimationController controller;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RotationTransition(turns: controller, child: const Icon(Icons.document_scanner_outlined, size: AppSizing.iconXl, color: AppColors.primary)),
              const SizedBox(height: AppSpacing.lg),
              Text('Checking the product', style: AppTypography.headline, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text('Looking up and analysing the scanned information...', style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              LinearProgressIndicator(borderRadius: BorderRadius.circular(999), color: AppColors.primary, backgroundColor: AppColors.mint),
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.resultName});

  final String resultName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.check_circle_outline, size: AppSizing.iconXl, color: AppColors.success),
            const SizedBox(height: AppSpacing.md),
            Text('Scan complete', style: AppTypography.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(resultName, textAlign: TextAlign.center, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}

class _NotFoundView extends ConsumerWidget {
  const _NotFoundView({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.search_off_outlined, size: AppSizing.iconXl, color: AppColors.secondaryText),
                const SizedBox(height: AppSpacing.md),
                Text('Product not found', style: AppTypography.headline, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text('We could not find this barcode in the mock catalogue.', style: AppTypography.body, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Retry scan', icon: Icons.qr_code_scanner, onPressed: () {
                  ref.read(scanProcessingProvider.notifier).reset();
                  context.go(AppRoutes.barcodeScanner);
                }),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(label: 'Scan the label instead', icon: Icons.document_scanner_outlined, onPressed: () => context.go(AppRoutes.labelScanner)),
                const SizedBox(height: AppSpacing.sm),
                TextButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Go home')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProcessingErrorView extends ConsumerWidget {
  const _ProcessingErrorView({required this.message, required this.barcode});

  final String message;
  final String barcode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.cloud_off_outlined, size: AppSizing.iconXl, color: AppColors.warning),
                const SizedBox(height: AppSpacing.md),
                Text('Could not finish the scan', style: AppTypography.headline, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(message, style: AppTypography.body, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xs),
                Text('Offline hint: reconnect to your network and try again.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Retry', icon: Icons.refresh, onPressed: () {
                  if (barcode == 'label') {
                    ref.read(scanProcessingProvider.notifier).processLabel();
                  } else {
                    ref.read(scanProcessingProvider.notifier).processBarcode(Uri.decodeComponent(barcode));
                  }
                }),
                const SizedBox(height: AppSpacing.sm),
                TextButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Go home')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
