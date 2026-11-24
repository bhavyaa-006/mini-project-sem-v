import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_repository.dart';
import '../models/recent_scan.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const MockHomeRepository();
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  return ref.watch(homeRepositoryProvider).loadDashboard();
});
