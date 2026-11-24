import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/permissions/camera_permission.dart';

import '../../../core/config/repository_config.dart';
import '../../result/data/models/mock_scan_data.dart';
import '../../result/data/models/scan_result.dart';
import '../../history/data/models/history_item.dart';
import '../../history/providers/history_provider.dart';
import '../../result/providers/result_provider.dart';
import '../data/scan_repository.dart';

final productLookupRepositoryProvider = Provider<ProductLookupRepository>((ref) {
  final mode = ref.watch(repositoryModeProvider);
  return mode == RepositoryMode.mock
      ? const MockProductLookupRepository()
      : const RealProductLookupRepository();
});

final barcodeLookupProvider = FutureProvider.family<ScanResult?, String>((ref, barcode) {
  return ref.watch(productLookupRepositoryProvider).lookupByBarcode(barcode);
});

final mockScanResultsProvider = Provider<Map<String, ScanResult>>((ref) => buildMockScanResults());

enum BarcodeScanStatus { idle, detected, error }

class BarcodeScanState {
  const BarcodeScanState({this.status = BarcodeScanStatus.idle, this.barcode, this.message});

  final BarcodeScanStatus status;
  final String? barcode;
  final String? message;

  BarcodeScanState copyWith({BarcodeScanStatus? status, String? barcode, String? message}) {
    return BarcodeScanState(status: status ?? this.status, barcode: barcode ?? this.barcode, message: message ?? this.message);
  }
}

class BarcodeScanNotifier extends Notifier<BarcodeScanState> {
  Timer? _debounce;

  @override
  BarcodeScanState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const BarcodeScanState();
  }

  Future<void> detect(String barcode) async {
    final value = barcode.trim();
    if (value.isEmpty || state.status == BarcodeScanStatus.detected) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (state.status == BarcodeScanStatus.detected) return;
      state = BarcodeScanState(status: BarcodeScanStatus.detected, barcode: value);
    });
  }

  void reset() {
    _debounce?.cancel();
    state = const BarcodeScanState();
  }

  void setError(String message) {
    state = BarcodeScanState(status: BarcodeScanStatus.error, message: message);
  }

  void clearError() {
    state = const BarcodeScanState();
  }
}

final barcodeScanProvider = NotifierProvider<BarcodeScanNotifier, BarcodeScanState>(BarcodeScanNotifier.new);

enum LabelScanStatus { idle, selected, processing, success, error }

class LabelScanState {
  const LabelScanState({this.status = LabelScanStatus.idle, this.imagePath, this.result, this.message, this.progress = 0});

  final LabelScanStatus status;
  final String? imagePath;
  final ScanResult? result;
  final String? message;
  final double progress;
}

class LabelScanNotifier extends Notifier<LabelScanState> {
  static const int maxImageBytes = 15 * 1024 * 1024;

  @override
  LabelScanState build() => const LabelScanState();

  Future<bool> selectImage(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      state = const LabelScanState(status: LabelScanStatus.error, message: 'That image is no longer available. Please choose it again.');
      return false;
    }

    final length = await file.length();
    if (length == 0) {
      state = const LabelScanState(status: LabelScanStatus.error, message: 'The selected image is empty. Please choose another photo.');
      return false;
    }
    if (length > maxImageBytes) {
      state = const LabelScanState(status: LabelScanStatus.error, message: 'This image is too large. Choose or capture a photo under 15 MB.');
      return false;
    }

    state = LabelScanState(status: LabelScanStatus.selected, imagePath: path);
    return true;
  }

  Future<void> analyse() async {
    final path = state.imagePath;
    if (path == null) {
      state = const LabelScanState(status: LabelScanStatus.error, message: 'Choose a label photo first.');
      return;
    }

    state = LabelScanState(status: LabelScanStatus.processing, imagePath: path, progress: 0.15);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = LabelScanState(status: LabelScanStatus.processing, imagePath: path, progress: 0.72);

    try {
      final result = await ref.read(productLookupRepositoryProvider).analyseLabel(path);
      state = LabelScanState(status: LabelScanStatus.success, imagePath: path, result: result, progress: 1);
    } catch (_) {
      state = LabelScanState(status: LabelScanStatus.error, imagePath: path, message: 'OCR could not analyse this label. Please retry or scan the barcode instead.', progress: 0);
    }
  }

  void reset() => state = const LabelScanState();

  void setError(String message) => state = LabelScanState(status: LabelScanStatus.error, message: message);
}

final labelScanProvider = NotifierProvider<LabelScanNotifier, LabelScanState>(LabelScanNotifier.new);

enum ProcessingStatus { loading, success, notFound, error, cancelled }

class ScanProcessingState {
  const ScanProcessingState({this.status = ProcessingStatus.loading, this.result, this.message});

  final ProcessingStatus status;
  final ScanResult? result;
  final String? message;
}

class ScanProcessingNotifier extends Notifier<ScanProcessingState> {
  bool _cancelled = false;

  @override
  ScanProcessingState build() {
    ref.onDispose(() => _cancelled = true);
    return const ScanProcessingState();
  }

  Future<void> processBarcode(String barcode) async {
    _cancelled = false;
    state = const ScanProcessingState(status: ProcessingStatus.loading);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (_cancelled) return;

      final found = await ref.read(productLookupRepositoryProvider).lookupByBarcode(barcode);
      if (_cancelled) return;
      if (found == null) {
        state = const ScanProcessingState(status: ProcessingStatus.notFound);
        return;
      }

      final analysed = await ref.read(analysisRepositoryProvider).getResult(found.id);
      if (_cancelled) return;
      if (analysed == null) {
        state = const ScanProcessingState(status: ProcessingStatus.notFound);
        return;
      }

      await _saveHistory(analysed);
      if (_cancelled) return;
      state = ScanProcessingState(status: ProcessingStatus.success, result: analysed);
    } catch (_) {
      if (_cancelled) return;
      state = const ScanProcessingState(status: ProcessingStatus.error, message: 'The scan could not be analysed. Check your connection and try again.');
    }
  }

  Future<void> processLabel() async {
    _cancelled = false;
    state = const ScanProcessingState(status: ProcessingStatus.loading);

    try {
      final labelState = ref.read(labelScanProvider);
      final result = labelState.result ?? await ref.read(productLookupRepositoryProvider).analyseLabel(labelState.imagePath ?? 'mock-label');
      if (_cancelled) return;

      await _saveHistory(result);
      if (_cancelled) return;
      state = ScanProcessingState(status: ProcessingStatus.success, result: result);
    } catch (_) {
      if (_cancelled) return;
      state = const ScanProcessingState(status: ProcessingStatus.error, message: 'The label could not be analysed. Check your connection and try again.');
    }
  }

  Future<void> _saveHistory(ScanResult result) async {
    await ref.read(historyRepositoryProvider).addHistoryItem(
      HistoryItem(
        id: 'mock-history-${result.id}-${DateTime.now().millisecondsSinceEpoch}',
        product: result.product,
        safetyScore: result.overallSafetyScore,
        classification: result.safetyClassification,
        scannedAt: DateTime.now(),
      ),
    );
  }

  void cancel() {
    _cancelled = true;
    state = const ScanProcessingState(status: ProcessingStatus.cancelled);
  }

  void reset() {
    _cancelled = false;
    state = const ScanProcessingState(status: ProcessingStatus.loading);
  }
}

final scanProcessingProvider = NotifierProvider<ScanProcessingNotifier, ScanProcessingState>(ScanProcessingNotifier.new);

final cameraPermissionProvider = FutureProvider<CameraPermissionStatus>((ref) {
  return ref.watch(cameraPermissionServiceProvider).status();
});
