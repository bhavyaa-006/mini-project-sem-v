import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.actionLabel, this.onAction, super.key});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: AppTypography.title)),
        if (actionLabel != null && onAction != null) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
