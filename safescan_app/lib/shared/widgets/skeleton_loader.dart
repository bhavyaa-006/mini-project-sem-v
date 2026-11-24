import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({this.width = double.infinity, this.height = 16, this.borderRadius, super.key});

  final double width;
  final double height;
  final double? borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _controller.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.sm),
            gradient: LinearGradient(
              begin: Alignment(position - 0.8, 0),
              end: Alignment(position + 0.8, 0),
              colors: const <Color>[AppColors.surfaceVariant, AppColors.white, AppColors.surfaceVariant],
            ),
          ),
        );
      },
    );
  }
}
