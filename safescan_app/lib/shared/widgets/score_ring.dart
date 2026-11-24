import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_score_colors.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_typography.dart';

class ScoreRing extends StatefulWidget {
  const ScoreRing({required this.score, this.label = 'Safety score', super.key});

  final int score;
  final String label;

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _animation = Tween<double>(begin: 0, end: widget.score.clamp(0, 100).toDouble()).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(ScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: _animation.value, end: widget.score.clamp(0, 100).toDouble()).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    final score = widget.score.clamp(0, 100);
    if (score >= 80) return AppScoreColors.safetyBands[80]!;
    if (score >= 60) return AppScoreColors.safetyBands[60]!;
    if (score >= 40) return AppScoreColors.safetyBands[40]!;
    if (score >= 20) return AppScoreColors.safetyBands[20]!;
    return AppScoreColors.safetyBands[0]!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final score = _animation.value.round();
        return SizedBox.square(
          dimension: AppSizing.scoreRing,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: _animation.value / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.border,
                  color: _color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('$score', style: AppTypography.display),
                  Text(widget.label, textAlign: TextAlign.center, style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
