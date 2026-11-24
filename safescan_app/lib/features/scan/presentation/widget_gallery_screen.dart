import 'package:material_ui/material_ui.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/nutri_score_badge.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_badge.dart';

import '../../../core/theme/app_spacing.dart';
class WidgetGalleryScreen extends StatelessWidget {
  const WidgetGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Gallery')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 720 ? 2 : 1;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _buttonsCard()),
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _fieldsCard()),
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _scoresCard()),
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _statusCard()),
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _imageCard()),
                      SizedBox(width: columns == 2 ? (width - AppSpacing.md) / 2 : width, child: _stateCard()),
                      SizedBox(width: width, child: _skeletonCard()),
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

  Widget _buttonsCard() => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(title: 'Buttons'),
            SizedBox(height: AppSpacing.sm),
            PrimaryButton(label: 'Primary', onPressed: null),
            SizedBox(height: AppSpacing.sm),
            PrimaryButton(label: 'Loading', onPressed: null, isLoading: true),
            SizedBox(height: AppSpacing.sm),
            SecondaryButton(label: 'Secondary', onPressed: null, icon: Icons.add),
          ],
        ),
      );

  Widget _fieldsCard() => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(title: 'Text fields'),
            SizedBox(height: AppSpacing.sm),
            AppTextField(label: 'Name', hint: 'Enter product name'),
            SizedBox(height: AppSpacing.md),
            AppTextField(label: 'Password', obscureText: true),
            SizedBox(height: AppSpacing.sm),
            AppTextField(label: 'Email', hint: 'Example: name@email.com', errorText: 'Enter a valid email'),
          ],
        ),
      );

  Widget _scoresCard() => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(title: 'Scores'),
            SizedBox(height: AppSpacing.md),
            Wrap(alignment: WrapAlignment.spaceAround, spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: <Widget>[ScoreRing(score: 92), ScoreRing(score: 58), ScoreRing(score: 18)]),
            SizedBox(height: AppSpacing.lg),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: <Widget>[NutriScoreBadge(grade: 'A'), NutriScoreBadge(grade: 'B'), NutriScoreBadge(grade: 'C'), NutriScoreBadge(grade: 'D'), NutriScoreBadge(grade: 'E')]),
          ],
        ),
      );

  Widget _statusCard() => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(title: 'Status badges'),
            SizedBox(height: AppSpacing.sm),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: <Widget>[StatusBadge(status: AppStatus.safe), StatusBadge(status: AppStatus.needsAttention), StatusBadge(status: AppStatus.flagged), StatusBadge(status: AppStatus.compliant), StatusBadge(status: AppStatus.nonCompliant), StatusBadge(status: AppStatus.informationMissing), StatusBadge(status: AppStatus.unableToVerify)]),
          ],
        ),
      );

  Widget _imageCard() => const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[SectionHeader(title: 'Product image'), SizedBox(height: AppSpacing.sm), OfflineBanner(), SizedBox(height: AppSpacing.sm), Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: <Widget>[ProductImage(), ProductImage(imageUrl: 'https://invalid.example/product.png')])],
        ),
      );

  Widget _stateCard() => const AppCard(
        child: Column(
          children: <Widget>[
            EmptyState(title: 'Nothing here', message: 'A list or search result is empty.'),
            SizedBox(height: AppSpacing.md),
            ErrorState(message: 'Something could not be loaded.'),
          ],
        ),
      );

  Widget _skeletonCard() => const AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[SectionHeader(title: 'Skeleton loaders'), SizedBox(height: AppSpacing.md), SkeletonLoader(width: 180, height: 24), SizedBox(height: AppSpacing.sm), SkeletonLoader(width: double.infinity, height: 16), SizedBox(height: AppSpacing.sm), SkeletonLoader(width: double.infinity, height: 16), SizedBox(height: AppSpacing.sm), SkeletonLoader(width: 240, height: 16)]),
      );
}
