import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.label, required this.onPressed, this.icon, this.isLoading = false, super.key});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(dimension: AppSizing.iconSm, child: CircularProgressIndicator(strokeWidth: 2))
        : icon == null
            ? Text(label)
            : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, size: AppSizing.iconSm), const SizedBox(width: AppSpacing.sm), Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis))]);

    return SizedBox(
      width: double.infinity,
      height: AppSizing.buttonHeight,
      child: OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
    );
  }
}
