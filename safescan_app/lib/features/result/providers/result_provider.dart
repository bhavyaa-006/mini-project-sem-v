import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/repository_config.dart';
import '../data/analysis_repository.dart';
import '../data/models/scan_result.dart';

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final mode = ref.watch(repositoryModeProvider);
  return mode == RepositoryMode.mock
      ? const MockAnalysisRepository()
      : const RealAnalysisRepository();
});

final scanResultProvider = FutureProvider.family<ScanResult?, String>((ref, id) {
  return ref.watch(analysisRepositoryProvider).getResult(id);
});
