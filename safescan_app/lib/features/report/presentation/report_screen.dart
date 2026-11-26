import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../providers/report_provider.dart';
import 'pdf_actions_button.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product report'),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: 'Back to result',
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Report summary', style: AppTypography.headline),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'The real PDF contract is not confirmed. This screen creates a clearly labelled SAMPLE text file.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Included sections',
                              style: AppTypography.title,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const _IncludedItem(
                              icon: Icons.inventory_2_outlined,
                              text: 'Product details',
                            ),
                            const _IncludedItem(
                              icon: Icons.speed_outlined,
                              text: 'Safety, Nutri-Score and cosmetic score',
                            ),
                            const _IncludedItem(
                              icon: Icons.gavel_outlined,
                              text: 'Legal Metrology compliance',
                            ),
                            const _IncludedItem(
                              icon: Icons.science_outlined,
                              text: 'Ingredient analysis',
                            ),
                            const _IncludedItem(
                              icon: Icons.warning_amber_rounded,
                              text: 'Personal and product warnings',
                            ),
                            const _IncludedItem(
                              icon: Icons.verified_outlined,
                              text: 'Verified vs uncertain information',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.status == ReportStatus.generating)
                        AppCard(
                          child: Column(
                            children: <Widget>[
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Preparing sample report...',
                                style: AppTypography.body,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const LinearProgressIndicator(),
                            ],
                          ),
                        )
                      else if (state.status == ReportStatus.error)
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Report failed', style: AppTypography.title),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                state.message ??
                                    'The report could not be created.',
                                style: AppTypography.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              PrimaryButton(
                                label: 'Retry',
                                icon: Icons.refresh,
                                onPressed: () => ref
                                    .read(reportProvider.notifier)
                                    .generate(productId),
                              ),
                            ],
                          ),
                        )
                      else
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (state.status ==
                                  ReportStatus.success) ...<Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Sample report ready',
                                        style: AppTypography.title,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  state.file?.path ?? '',
                                  style: AppTypography.bodySmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              PdfActionsButton(productId: productId),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      SecondaryButton(
                        label: 'Back to product',
                        icon: Icons.arrow_back,
                        onPressed: () => context.pop(),
                      ),
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

class _IncludedItem extends StatelessWidget {
  const _IncludedItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
