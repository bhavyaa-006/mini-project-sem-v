import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/report/data/report_repository.dart';
import 'package:safescan_app/features/report/providers/report_provider.dart';

class TestReportRepository implements ReportRepository {
  TestReportRepository({required this.file, this.fail = false});

  final File file;
  final bool fail;

  @override
  Future<File> generateSampleReport(String productId) async {
    if (fail) throw Exception('MOCK report failure');
    await file.writeAsString('SAMPLE $productId');
    return file;
  }
}

void main() {
  test('report state moves from idle to success with a file', () async {
    final temp = File('${Directory.systemTemp.path}/safe_scan_report_test.txt');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete();
    });

    final container = ProviderContainer(overrides: [reportRepositoryProvider.overrideWithValue(TestReportRepository(file: temp))]);
    addTearDown(container.dispose);

    await container.read(reportProvider.notifier).generate('mock-food-good');

    expect(container.read(reportProvider).status, ReportStatus.success);
    expect(await temp.exists(), isTrue);
  });

  test('report state exposes friendly error and can reset', () async {
    final temp = File('${Directory.systemTemp.path}/safe_scan_report_error_test.txt');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete();
    });

    final container = ProviderContainer(overrides: [reportRepositoryProvider.overrideWithValue(TestReportRepository(file: temp, fail: true))]);
    addTearDown(container.dispose);

    await container.read(reportProvider.notifier).generate('mock-food-good');

    expect(container.read(reportProvider).status, ReportStatus.error);
    expect(container.read(reportProvider).message, contains('could not'));

    container.read(reportProvider.notifier).reset();
    expect(container.read(reportProvider).status, ReportStatus.idle);
  });
}
