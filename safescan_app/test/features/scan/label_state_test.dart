import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/scan/providers/scan_provider.dart';

void main() {
  test('label selection rejects missing and oversized files', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(labelScanProvider.notifier);

    final missing = await notifier.selectImage('/tmp/missing-safescan-label.jpg');
    expect(missing, isFalse);
    expect(container.read(labelScanProvider).status, LabelScanStatus.error);
  });

  test('label selection accepts an existing small file', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final file = await File('${Directory.systemTemp.path}/safescan_label_test.jpg').create();
    await file.writeAsBytes(<int>[1, 2, 3, 4]);
    addTearDown(file.delete);

    final notifier = container.read(labelScanProvider.notifier);
    expect(await notifier.selectImage(file.path), isTrue);
    expect(container.read(labelScanProvider).status, LabelScanStatus.selected);
  });

  test('reset clears label state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(labelScanProvider.notifier);
    notifier.setError('Could not open image');
    notifier.reset();

    expect(container.read(labelScanProvider).status, LabelScanStatus.idle);
    expect(container.read(labelScanProvider).imagePath, isNull);
  });
}
