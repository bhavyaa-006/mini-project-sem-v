import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class ReportRepository {
  Future<File> generateSampleReport(String productId);
}

class MockReportRepository implements ReportRepository {
  const MockReportRepository({this.delay = const Duration(milliseconds: 900)});

  final Duration delay;

  @override
  Future<File> generateSampleReport(String productId) async {
    await Future<void>.delayed(delay);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/SAMPLE_SafeScan_Report_$productId.txt');

    await file.writeAsString(
      'SAFE-SCAN / PACK-CHECK AI\n'
      'SAMPLE PLACEHOLDER REPORT — NOT A REAL PDF\n'
      'Product ID: $productId\n\n'
      'Report sections:\n'
      '- Product details\n'
      '- Safety and Nutri-Score / cosmetic score\n'
      '- Legal Metrology compliance\n'
      '- Ingredient analysis\n'
      '- Allergy and skin warnings\n'
      '- Verified vs uncertain information\n\n'
      'Informational mock data only. Not medical advice.\n',
      flush: true,
    );

    return file;
  }
}

class RealReportRepository implements ReportRepository {
  const RealReportRepository();

  @override
  Future<File> generateSampleReport(String productId) {
    throw UnimplementedError('Real report generation contract is not confirmed.');
  }
}
