import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/models/safety_models.dart';

class VerifiedUncertainSection extends StatelessWidget {
  const VerifiedUncertainSection({required this.explanation, super.key});

  final ScoreExplanation explanation;

  void _openInfoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Verified vs uncertain', style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Text('Verified items are clearly read or confirmed from the available mock label. Uncertain items could not be fully confirmed and may need manual checking.', style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it'))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[Expanded(child: Text('Verified vs uncertain', style: AppTypography.title)), IconButton(onPressed: () => _openInfoSheet(context), tooltip: 'What these terms mean', icon: const Icon(Icons.info_outline))]),
          const SizedBox(height: AppSpacing.sm),
          _InformationGroup(title: 'Verified', icon: Icons.verified_outlined, color: AppColors.success, items: explanation.verifiedItems),
          const SizedBox(height: AppSpacing.sm),
          _InformationGroup(title: 'Uncertain', icon: Icons.help_outline, color: AppColors.warning, items: explanation.uncertainItems),
        ],
      ),
    );
  }
}

class _InformationGroup extends StatelessWidget {
  const _InformationGroup({required this.title, required this.icon, required this.color, required this.items});

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[Icon(icon, size: 18, color: color), const SizedBox(width: AppSpacing.xs), Text(title, style: AppTypography.label.copyWith(color: color))]),
          const SizedBox(height: AppSpacing.xs),
          if (items.isEmpty)
            Text('None listed', style: AppTypography.bodySmall)
          else
            for (final item in items) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.xs), child: Text('• $item', style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
