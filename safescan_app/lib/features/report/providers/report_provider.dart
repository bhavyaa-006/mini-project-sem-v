import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/report_repository.dart';

enum ReportStatus { idle, generating, success, error }

class ReportState {
  const ReportState({this.status = ReportStatus.idle, this.file, this.message});

  final ReportStatus status;
  final File? file;
  final String? message;
}

class ReportNotifier extends Notifier<ReportState> {
  @override
  ReportState build() => const ReportState();

  ReportRepository get _repository => ref.read(reportRepositoryProvider);

  Future<void> generate(String productId) async {
    state = const ReportState(status: ReportStatus.generating);
    try {
      final file = await _repository.generateSampleReport(productId);
      state = ReportState(status: ReportStatus.success, file: file);
    } catch (_) {
      state = const ReportState(status: ReportStatus.error, message: 'The sample report could not be created. Please retry.');
    }
  }

  void reset() => state = const ReportState();
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) => const MockReportRepository());
final reportProvider = NotifierProvider<ReportNotifier, ReportState>(ReportNotifier.new);
