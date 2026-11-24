import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/navigation.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../providers/scan_provider.dart';

class LabelCaptureScreen extends ConsumerWidget {
  const LabelCaptureScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2400, maxHeight: 2400);
      if (file == null) return;

      final selected = await ref.read(labelScanProvider.notifier).selectImage(file.path);
      if (!selected) return;
    } catch (_) {
      if (!context.mounted) return;
      ref.read(labelScanProvider.notifier).setError(
        source == ImageSource.camera
            ? 'Camera permission was denied or the camera is unavailable.'
            : 'The image could not be opened. Please try another photo.',
      );
    }
  }

  Future<void> _analyse(BuildContext context, WidgetRef ref) async {
    await ref.read(labelScanProvider.notifier).analyse();
    final state = ref.read(labelScanProvider);
    if (!context.mounted) return;

    if (state.status == LabelScanStatus.success && state.result != null) {
      context.go(AppRoutes.scanProcessingPath('label'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labelScanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan label'),
        leading: IconButton(tooltip: 'Back', onPressed: () => safeGoBack(context, AppRoutes.scanHub), icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: state.status == LabelScanStatus.processing
                      ? _ProcessingView(progress: state.progress)
                      : state.status == LabelScanStatus.error && state.imagePath != null
                          ? _ErrorWithImageView(state: state, onRetry: () => _analyse(context, ref), onRetake: () => ref.read(labelScanProvider.notifier).reset())
                          : state.status == LabelScanStatus.error
                              ? _ErrorView(onRetry: () => ref.read(labelScanProvider.notifier).reset(), onGallery: () => _pick(context, ref, ImageSource.gallery), onBarcode: () => context.go(AppRoutes.barcodeScanner))
                              : state.status == LabelScanStatus.selected || state.status == LabelScanStatus.success
                                  ? _PreviewView(imagePath: state.imagePath!, onRetake: () => ref.read(labelScanProvider.notifier).reset(), onAnalyse: () => _analyse(context, ref))
                                  : _CaptureChoiceView(onCamera: () => _pick(context, ref, ImageSource.camera), onGallery: () => _pick(context, ref, ImageSource.gallery)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CaptureChoiceView extends StatelessWidget {
  const _CaptureChoiceView({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Choose a label photo', style: AppTypography.headline),
        const SizedBox(height: AppSpacing.xs),
        Text('Capture the full ingredient and legal-information area.', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        AppCard(onTap: onCamera, child: const _CaptureOption(icon: Icons.photo_camera_outlined, title: 'Take photo', explanation: 'Use the camera for a new label photo')),
        const SizedBox(height: AppSpacing.md),
        AppCard(onTap: onGallery, child: const _CaptureOption(icon: Icons.photo_library_outlined, title: 'Choose from gallery', explanation: 'Select an existing clear label photo')),
        const SizedBox(height: AppSpacing.lg),
        const _LabelTips(),
      ],
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({required this.icon, required this.title, required this.explanation});

  final IconData icon;
  final String title;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(AppRadius.lg)), child: Icon(icon, color: AppColors.primary, size: AppSizing.iconLg)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: AppTypography.title), const SizedBox(height: AppSpacing.xs), Text(explanation, style: AppTypography.bodySmall)])),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}

class _LabelTips extends StatelessWidget {
  const _LabelTips();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('For a good label photo', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          const _Tip(icon: Icons.light_mode_outlined, text: 'Use bright, even lighting'),
          const _Tip(icon: Icons.square_outlined, text: 'Keep the label flat and frame the whole text'),
          const _Tip(icon: Icons.wb_sunny_outlined, text: 'Avoid glare, shadows and blur'),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(children: <Widget>[Icon(icon, size: AppSizing.iconSm, color: AppColors.primary), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(text, style: AppTypography.body))]),
    );
  }
}

class _PreviewView extends StatelessWidget {
  const _PreviewView({required this.imagePath, required this.onRetake, required this.onAnalyse});

  final String imagePath;
  final VoidCallback onRetake;
  final VoidCallback onAnalyse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Label preview', style: AppTypography.headline),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AspectRatio(aspectRatio: 4 / 3, child: Image.file(File(imagePath), fit: BoxFit.cover)),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(label: 'Upload / Analyze', icon: Icons.auto_awesome_outlined, onPressed: onAnalyse),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: 'Retake', icon: Icons.refresh, onPressed: onRetake),
      ],
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 420),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.document_scanner_outlined, size: AppSizing.iconXl, color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text('OCR processing', style: AppTypography.headline),
          const SizedBox(height: AppSpacing.sm),
          Text('Reading ingredients and legal information...', textAlign: TextAlign.center, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(AppRadius.pill), color: AppColors.primary, backgroundColor: AppColors.mint)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.onGallery, required this.onBarcode});

  final VoidCallback onRetry;
  final VoidCallback onGallery;
  final VoidCallback onBarcode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ErrorState(message: 'The label photo could not be opened.', onRetry: onGallery),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: 'Scan a barcode instead', icon: Icons.qr_code_scanner, onPressed: onBarcode),
        TextButton(onPressed: onRetry, child: const Text('Start over')),
      ],
    );
  }
}

class _ErrorWithImageView extends StatelessWidget {
  const _ErrorWithImageView({required this.state, required this.onRetry, required this.onRetake});

  final LabelScanState state;
  final VoidCallback onRetry;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ErrorState(message: state.message ?? 'Label analysis failed.', onRetry: onRetry),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(label: 'Retake', icon: Icons.refresh, onPressed: onRetake),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: () => context.go(AppRoutes.barcodeScanner), child: const Text('Scan a barcode instead')),
      ],
    );
  }
}
