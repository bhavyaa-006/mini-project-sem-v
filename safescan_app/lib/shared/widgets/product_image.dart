import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({this.imageUrl, this.size = AppSizing.productImage, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.inventory_2_outlined,
            size: size <= 64 ? AppSizing.iconSm : AppSizing.iconLg,
            color: AppColors.secondaryText,
          ),
          if (size > 64) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text('No image', style: AppTypography.bodySmall),
          ],
        ],
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
