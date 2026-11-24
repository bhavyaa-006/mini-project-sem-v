import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizing.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_badge.dart';
import '../models/recent_scan.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeDashboardProvider);
            await ref.read(homeDashboardProvider.future);
          },
          child: dashboard.when(
            loading: () => const _HomeSkeleton(),
            error: (_, __) => ErrorState(
              message: 'The dashboard could not be loaded.',
              onRetry: () => ref.invalidate(homeDashboardProvider),
            ),
            data: (data) => _HomeDataView(data: data),
          ),
        ),
      ),
    );
  }
}

class _HomeDataView extends StatelessWidget {
  const _HomeDataView({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Header(),
              const SizedBox(height: AppSpacing.lg),
              const _ScanCard(),
              const SizedBox(height: AppSpacing.lg),
              _Statistics(data: data),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent scans',
                actionLabel: 'See all',
                onAction: () => context.go(AppRoutes.history),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data.recentScans.isEmpty)
                const AppCard(
                  child: EmptyState(
                    title: 'No recent scans',
                    message: 'Scan or upload a product to build your safety history.',
                    icon: Icons.document_scanner_outlined,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: <Widget>[
                      for (var index = 0; index < data.recentScans.take(5).length; index++) ...<Widget>[
                        _RecentScanTile(scan: data.recentScans[index]),
                        if (index < data.recentScans.take(5).length - 1)
                          const Divider(indent: AppSpacing.md, endIndent: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Helpful reads'),
              const SizedBox(height: AppSpacing.sm),
              const _TipCards(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  void _openNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.notifications_none_outlined, size: AppSizing.iconLg),
              const SizedBox(height: AppSpacing.sm),
              Text('No notifications', style: AppTypography.headline),
              const SizedBox(height: AppSpacing.xs),
              Text('You are all caught up.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Good morning', style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('Aarav', style: AppTypography.headline),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _openNotifications(context),
          icon: const Icon(Icons.notifications_none_outlined),
        ),
        const SizedBox(width: AppSpacing.xs),
        Semantics(
          button: true,
          label: 'Open profile',
          child: InkResponse(
            onTap: () => context.go(AppRoutes.profile),
            radius: AppSizing.iconLg,
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.primary,
              child: Text('A'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Your products.\nYour safety.', style: AppTypography.headline),
          const SizedBox(height: AppSpacing.xs),
          Text('Check what goes on or into your body.', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 420;
              final barcode = PrimaryButton(label: 'Scan Barcode', icon: Icons.qr_code_scanner, onPressed: () => context.go(AppRoutes.barcodeScanner));
              final upload = SecondaryButton(label: 'Upload Label', icon: Icons.upload_outlined, onPressed: () => context.go(AppRoutes.labelScanner));
              if (stacked) {
                return Column(children: <Widget>[barcode, const SizedBox(height: AppSpacing.sm), upload]);
              }
              return Row(children: <Widget>[Expanded(child: barcode), const SizedBox(width: AppSpacing.sm), Expanded(child: upload)]);
            },
          ),
        ],
      ),
    );
  }
}

class _Statistics extends StatelessWidget {
  const _Statistics({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.sm * 2) / 3;
        return Row(
          children: <Widget>[
            SizedBox(width: width, child: _StatTile(value: '${data.totalScans}', label: 'Total scans', icon: Icons.document_scanner_outlined, color: AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(width: width, child: _StatTile(value: '${data.safeProducts}', label: 'Safe', icon: Icons.check_circle_outline, color: AppColors.success)),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(width: width, child: _StatTile(value: '${data.needingAttention}', label: 'Attention', icon: Icons.warning_amber_rounded, color: AppColors.warning)),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.icon, required this.color});

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: AppSizing.iconMd),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.headline),
          const SizedBox(height: AppSpacing.xs),
          Text(label, textAlign: TextAlign.center, style: AppTypography.bodySmall, maxLines: 2),
        ],
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({required this.scan});

  final RecentScan scan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.productResultPath(scan.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            const ProductImage(size: 56),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Text(scan.name, style: AppTypography.title, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: AppSpacing.xs), StatusBadge(status: scan.status)],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${scan.score}', style: AppTypography.title),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right, color: AppColors.secondaryText),
          ],
        ),
      ),
    );
  }
}

class _TipCards extends StatelessWidget {
  const _TipCards();

  static const tips = <Map<String, String>>[
    {'title': 'Read the whole label', 'body': 'Check serving size, ingredient order and the full ingredient list. Ingredients near the top make up more of the product.'},
    {'title': 'Know your allergens', 'body': 'Keep a personal allergy list and check both the ingredient list and allergy statements every time.'},
    {'title': 'Compare, do not guess', 'body': 'Use alternatives and safety scores as guidance, then check your own health needs and verified product details.'},
  ];

  void _openTip(BuildContext context, Map<String, String> tip) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tip['title']!, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Text(tip['body']!, style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return SizedBox(
            width: 240,
            child: AppCard(
              onTap: () => _openTip(context, tip),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(tip['title']!, style: AppTypography.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SkeletonLoader(width: 180, height: 24),
          SizedBox(height: AppSpacing.lg),
          SkeletonLoader(width: double.infinity, height: 180),
          SizedBox(height: AppSpacing.lg),
          Row(children: <Widget>[Expanded(child: SkeletonLoader(height: 100)), SizedBox(width: AppSpacing.sm), Expanded(child: SkeletonLoader(height: 100)), SizedBox(width: AppSpacing.sm), Expanded(child: SkeletonLoader(height: 100))]),
          SizedBox(height: AppSpacing.lg),
          SkeletonLoader(width: 180, height: 24),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(width: double.infinity, height: 72),
          SizedBox(height: AppSpacing.sm),
          SkeletonLoader(width: double.infinity, height: 72),
        ],
      ),
    );
  }
}
