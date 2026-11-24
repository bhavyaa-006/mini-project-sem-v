import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import 'primary_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

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
              const Icon(Icons.error_outline, size: AppSizing.iconLg),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Try again', onPressed: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
