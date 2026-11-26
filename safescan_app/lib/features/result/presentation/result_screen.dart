import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/nutri_score_badge.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_badge.dart';
import 'widgets/ingredient_summary_card.dart';
import 'widgets/legal_metrology_card.dart';
import 'widgets/verified_uncertain_section.dart';
import 'widgets/why_score_section.dart';
import '../data/models/product.dart';
import '../data/models/scan_result.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/services/personal_warning_service.dart';
import '../providers/result_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(scanResultProvider(widget.id));

    return result.when(
      loading: () => const Scaffold(body: SafeArea(child: _ResultSkeleton())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Product result')),
        body: ErrorState(
          message: 'The product result could not be loaded.',
          onRetry: () => ref.invalidate(scanResultProvider(widget.id)),
        ),
      ),
      data: (scan) {
        if (scan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product result')),
            body: ErrorState(
              message: 'This product result is not available.',
              onRetry: () => ref.invalidate(scanResultProvider(widget.id)),
            ),
          );
        }
        _controller.forward();
        return _ResultDataView(result: scan);
      },
    );
  }
}

class _ResultDataView extends StatelessWidget {
  const _ResultDataView({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_ResultScreenState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 56,
                    right: 16,
                    bottom: 12,
                  ),
                  title: Text(
                    result.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title,
                  ),
                  background: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: ProductImage(
                            imageUrl: result.product.imageUrl,
                            size: 112,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: parent?._fade ?? const AlwaysStoppedAnimation<double>(1),
              child: SlideTransition(
                position:
                    parent?._slide ??
                    const AlwaysStoppedAnimation<Offset>(Offset.zero),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _ProductIdentity(result: result),
                          const SizedBox(height: AppSpacing.md),
                          _SafetySection(result: result),
                          const SizedBox(height: AppSpacing.md),
                          if (result.product.category == ProductCategory.food)
                            _FoodScoreSection(result: result)
                          else
                            _CosmeticScoreSection(result: result),
                          const SizedBox(height: AppSpacing.md),
                          _WarningSection(result: result),
                          const SizedBox(height: AppSpacing.lg),
                          _ActionBar(result: result),
                          const SizedBox(height: AppSpacing.lg),
                          LegalMetrologyCard(legal: result.legalMetrology),
                          const SizedBox(height: AppSpacing.lg),
                          WhyScoreSection(explanation: result.explanation),
                          const SizedBox(height: AppSpacing.md),
                          VerifiedUncertainSection(
                            explanation: result.explanation,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          IngredientSummaryCard(
                            ingredients: result.ingredients,
                            productId: result.id,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _Disclaimer(),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductIdentity extends StatelessWidget {
  const _ProductIdentity({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(result.product.name, style: AppTypography.headline),
        const SizedBox(height: AppSpacing.xs),
        Text(result.product.brand, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            result.product.category == ProductCategory.food
                ? 'Food'
                : 'Cosmetic',
            style: AppTypography.label.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SafetySection extends StatelessWidget {
  const _SafetySection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final status = result.safetyClassification == SafetyClassification.safe
        ? AppStatus.safe
        : result.safetyClassification == SafetyClassification.needsAttention
        ? AppStatus.needsAttention
        : result.safetyClassification == SafetyClassification.flagged
        ? AppStatus.flagged
        : AppStatus.informationMissing;

    final summary = switch (result.safetyClassification) {
      SafetyClassification.safe =>
        'This mock result indicates a generally safe choice.',
      SafetyClassification.needsAttention =>
        'Some details need attention before use.',
      SafetyClassification.flagged =>
        'This mock result contains points to review.',
      SafetyClassification.unknown =>
        'The available information is incomplete.',
    };

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ring = ScoreRing(
            score: result.overallSafetyScore,
            label: 'Safety score',
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Overall safety', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              StatusBadge(status: status),
              const SizedBox(height: AppSpacing.sm),
              Text(summary, style: AppTypography.bodySmall),
            ],
          );

          if (constraints.maxWidth < 420) {
            return Column(
              children: <Widget>[
                ring,
                const SizedBox(height: AppSpacing.sm),
                details,
              ],
            );
          }
          return Row(
            children: <Widget>[
              ring,
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _FoodScoreSection extends StatelessWidget {
  const _FoodScoreSection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    if (result.nutriScore == null) return const SizedBox.shrink();
    final grade = result.nutriScore!.name.toUpperCase();

    return AppCard(
      child: Row(
        children: <Widget>[
          NutriScoreBadge(grade: grade),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Nutri-Score', style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Grade $grade — overall food nutritional rating.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmeticScoreSection extends StatelessWidget {
  const _CosmeticScoreSection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.cosmeticSafetyScore?.value ?? 0;

    return AppCard(
      child: Row(
        children: <Widget>[
          ScoreRing(score: score, label: 'Cosmetic'),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Cosmetic Safety Score', style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$score out of 100 — based on mock ingredient and skin-risk data.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningSection extends ConsumerWidget {
  const _WarningSection({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return AppCard(
      child: profile.when(
        loading: () => Text(
          'Checking personal warnings...',
          style: AppTypography.bodySmall,
        ),
        error: (_, __) => Text(
          'Personal warnings could not be loaded.',
          style: AppTypography.bodySmall,
        ),
        data: (data) {
          const service = PersonalWarningService();
          if (!service.isProfileComplete(data)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Personal warnings', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Complete your profile for personalised warnings.',
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.profile),
                        child: const Text('Go to Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final warnings = service.findWarnings(data, result.ingredients);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Personal warnings', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              if (warnings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'No personal warnings matched this product.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final warning in warnings)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(warning.title, style: AppTypography.label),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                warning.message,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actions = <Widget>[
            TextButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to mock history')),
              ),
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Save'),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.pdfReportPath(result.id)),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Report'),
            ),
            TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.alternativesPath(result.id)),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Alternatives'),
            ),
          ];

          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[for (final action in actions) action],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions,
          );
        },
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        'These results are informational and not medical advice. Confirm important concerns with a qualified professional.',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall,
      ),
    );
  }
}

class _ResultSkeleton extends StatelessWidget {
  const _ResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          SkeletonLoader(width: 112, height: 112),
          SizedBox(height: AppSpacing.lg),
          SkeletonLoader(width: 220, height: 24),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(width: 160, height: 16),
          SizedBox(height: AppSpacing.lg),
          SkeletonLoader(width: double.infinity, height: 180),
          SizedBox(height: AppSpacing.md),
          SkeletonLoader(width: double.infinity, height: 112),
        ],
      ),
    );
  }
}
