import '../data/models/mock_scan_data.dart';
import '../data/models/scan_result.dart';

abstract interface class AnalysisRepository {
  Future<ScanResult?> getResult(String id);
}

class MockAnalysisRepository implements AnalysisRepository {
  const MockAnalysisRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  @override
  Future<ScanResult?> getResult(String id) async {
    await Future<void>.delayed(delay);
    for (final result in buildMockScanResults().values) {
      if (result.id == id) return result;
    }
    return null;
  }
}

class RealAnalysisRepository implements AnalysisRepository {
  const RealAnalysisRepository();

  @override
  Future<ScanResult?> getResult(String id) {
    throw UnimplementedError('Real analysis repository is not implemented.');
  }
}
