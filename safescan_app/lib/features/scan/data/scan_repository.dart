import '../../result/data/models/mock_scan_data.dart';
import '../../result/data/models/scan_result.dart';

abstract interface class ProductLookupRepository {
  Future<ScanResult?> lookupByBarcode(String barcode);
  Future<ScanResult> analyseLabel(String labelImagePath);
}

class MockProductLookupException implements Exception {
  const MockProductLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MockProductLookupRepository implements ProductLookupRepository {
  const MockProductLookupRepository({this.delay = const Duration(milliseconds: 500)});

  final Duration delay;

  static final Map<String, ScanResult> _mockResults = buildMockScanResults();

  @override
  Future<ScanResult?> lookupByBarcode(String barcode) async {
    await Future<void>.delayed(delay);
    return _mockResults[barcode.trim()];
  }

  @override
  Future<ScanResult> analyseLabel(String labelImagePath) async {
    await Future<void>.delayed(delay);
    return _mockResults.values.first;
  }
}

class RealProductLookupRepository implements ProductLookupRepository {
  const RealProductLookupRepository();

  @override
  Future<ScanResult?> lookupByBarcode(String barcode) {
    throw UnimplementedError('Real product lookup is not implemented.');
  }

  @override
  Future<ScanResult> analyseLabel(String labelImagePath) {
    throw UnimplementedError('Real label analysis is not implemented.');
  }
}
