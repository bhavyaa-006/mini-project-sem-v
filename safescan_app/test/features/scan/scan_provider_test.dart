import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/scan/providers/scan_provider.dart';

void main() {
  group('LabelScanNotifier', () {
    test('rejects a missing image with a recoverable error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final accepted = await container
          .read(labelScanProvider.notifier)
          .selectImage('/definitely/not/a/real/image.jpg');

      expect(accepted, isFalse);
      expect(container.read(labelScanProvider).status, LabelScanStatus.error);
      expect(container.read(labelScanProvider).message, contains('no longer available'));
    });

    test('rejects an empty image and accepts a valid small image', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final file = File('${Directory.systemTemp.path}/safescan-label-${DateTime.now().microsecondsSinceEpoch}.jpg');
      addTearDown(() async {
        if (await file.exists()) await file.delete();
      });
      await file.create();

      expect(await container.read(labelScanProvider.notifier).selectImage(file.path), isFalse);
      expect(container.read(labelScanProvider).message, contains('empty'));

      await file.writeAsBytes(<int>[1, 2, 3]);
      expect(await container.read(labelScanProvider.notifier).selectImage(file.path), isTrue);
      expect(container.read(labelScanProvider).status, LabelScanStatus.selected);
      expect(container.read(labelScanProvider).imagePath, file.path);
    });
  });
}
