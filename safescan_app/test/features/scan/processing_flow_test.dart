import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/scan/data/scan_repository.dart';
import 'package:safescan_app/features/scan/providers/scan_provider.dart';

void main() {
  test('barcode flow succeeds for a known mock barcode', () async {
    final container = ProviderContainer(overrides: [
      productLookupRepositoryProvider.overrideWithValue(const MockProductLookupRepository(delay: Duration.zero)),
    ]);
    addTearDown(container.dispose);

    await container.read(scanProcessingProvider.notifier).processBarcode('890100100001');

    expect(container.read(scanProcessingProvider).status, ProcessingStatus.success);
    expect(container.read(scanProcessingProvider).result?.product.name, contains('MOCK'));
  });

  test('unknown barcode flow ends as not found', () async {
    final container = ProviderContainer(overrides: [
      productLookupRepositoryProvider.overrideWithValue(const MockProductLookupRepository(delay: Duration.zero)),
    ]);
    addTearDown(container.dispose);

    await container.read(scanProcessingProvider.notifier).processBarcode('UNKNOWN-BARCODE');

    expect(container.read(scanProcessingProvider).status, ProcessingStatus.notFound);
  });

  test('cancel prevents a stale processing success', () async {
    final container = ProviderContainer(overrides: [
      productLookupRepositoryProvider.overrideWithValue(const MockProductLookupRepository(delay: Duration(milliseconds: 100))),
    ]);
    addTearDown(container.dispose);

    final future = container.read(scanProcessingProvider.notifier).processBarcode('890100100001');
    container.read(scanProcessingProvider.notifier).cancel();
    await future;

    expect(container.read(scanProcessingProvider).status, ProcessingStatus.cancelled);
  });
}
