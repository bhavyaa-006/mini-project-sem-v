import '../../../shared/widgets/status_badge.dart';

class RecentScan {
  const RecentScan({
    required this.id,
    required this.name,
    required this.score,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String name;
  final int score;
  final AppStatus status;
  final String? imageUrl;
}

class HomeDashboardData {
  const HomeDashboardData({
    required this.totalScans,
    required this.safeProducts,
    required this.needingAttention,
    required this.recentScans,
  });

  final int totalScans;
  final int safeProducts;
  final int needingAttention;
  final List<RecentScan> recentScans;
}
