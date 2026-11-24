import '../../../shared/widgets/status_badge.dart';
import '../models/recent_scan.dart';

abstract interface class HomeRepository {
  Future<HomeDashboardData> loadDashboard();
}

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository();

  @override
  Future<HomeDashboardData> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return const HomeDashboardData(
      totalScans: 24,
      safeProducts: 17,
      needingAttention: 7,
      recentScans: <RecentScan>[
        RecentScan(id: 'mock-oats-001', name: 'Organic Rolled Oats', score: 92, status: AppStatus.safe),
        RecentScan(id: 'mock-shampoo-002', name: 'Daily Gentle Shampoo', score: 68, status: AppStatus.needsAttention),
        RecentScan(id: 'mock-snack-003', name: 'Salted Energy Snack', score: 31, status: AppStatus.flagged),
        RecentScan(id: 'mock-cleanser-004', name: 'Foaming Face Cleanser', score: 86, status: AppStatus.safe),
        RecentScan(id: 'mock-sauce-005', name: 'Tomato Cooking Sauce', score: 74, status: AppStatus.needsAttention),
      ],
    );
  }
}

class MockEmptyHomeRepository implements HomeRepository {
  const MockEmptyHomeRepository();

  @override
  Future<HomeDashboardData> loadDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const HomeDashboardData(totalScans: 0, safeProducts: 0, needingAttention: 0, recentScans: <RecentScan>[]);
  }
}
