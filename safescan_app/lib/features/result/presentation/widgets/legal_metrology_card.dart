import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/safety_models.dart';

class LegalMetrologyCard extends StatelessWidget {
  const LegalMetrologyCard({required this.legal, super.key});

  final LegalMetrologyInfo legal;

  static AppStatus _badge(LegalFieldStatus status) {
    switch (status) {
      case LegalFieldStatus.compliant:
        return AppStatus.compliant;
      case LegalFieldStatus.nonCompliant:
        return AppStatus.nonCompliant;
      case LegalFieldStatus.missing:
        return AppStatus.informationMissing;
      case LegalFieldStatus.unableToVerify:
        return AppStatus.unableToVerify;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = <String, String?>{
      'MRP': legal.mrp,
      'Net quantity': legal.netQuantity,
      'Manufacturer': legal.manufacturer,
      'Expiry date': legal.expiryDate,
    };

    final statuses = legal.fieldStatuses.values;
    final overall = legal.isCompliant
        ? AppStatus.compliant
        : statuses.contains(LegalFieldStatus.nonCompliant)
            ? AppStatus.nonCompliant
            : statuses.contains(LegalFieldStatus.missing)
                ? AppStatus.informationMissing
                : statuses.contains(LegalFieldStatus.unableToVerify)
                    ? AppStatus.unableToVerify
                    : AppStatus.needsAttention;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text('Legal Metrology', style: AppTypography.title)),
              StatusBadge(status: overall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final entry in values.entries) ...<Widget>[
            _LegalField(
              label: entry.key,
              value: entry.value,
              status: legal.fieldStatuses[entry.key] ?? LegalFieldStatus.missing,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text('Mandatory declarations', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (final declaration in legal.mandatoryDeclarations)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(declaration, style: AppTypography.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalField extends StatelessWidget {
  const _LegalField({required this.label, required this.value, required this.status});

  final String label;
  final String? value;
  final LegalFieldStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldName = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: AppTypography.label), const SizedBox(height: AppSpacing.xs), Text(value == null || value!.trim().isEmpty ? 'Not available' : value!, style: AppTypography.bodySmall)]);
          final badge = StatusBadge(status: LegalMetrologyCard._badge(status));

          if (constraints.maxWidth < 420) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[fieldName, const SizedBox(height: AppSpacing.sm), badge]);
          }
          return Row(children: <Widget>[Expanded(child: fieldName), const SizedBox(width: AppSpacing.sm), badge]);
        },
      ),
    );
  }
}
