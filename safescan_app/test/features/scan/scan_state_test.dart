import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/core/permissions/camera_permission.dart';
import 'package:safescan_app/features/scan/providers/scan_provider.dart';

class MockCameraPermissionService implements CameraPermissionService {
  MockCameraPermissionService(this.permission);

  final CameraPermissionStatus permission;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<CameraPermissionStatus> request() async => permission;

  @override
  Future<CameraPermissionStatus> status() async => permission;
}

void main() {
  test('scan detects a value once and ignores duplicate detection', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(barcodeScanProvider.notifier);
    await notifier.detect('890100100001');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(container.read(barcodeScanProvider).status, BarcodeScanStatus.detected);
    expect(container.read(barcodeScanProvider).barcode, '890100100001');

    await notifier.detect('890100100002');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(container.read(barcodeScanProvider).barcode, '890100100001');
  });

  test('scan state exposes friendly errors and reset', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(barcodeScanProvider.notifier);
    notifier.setError('No barcode was found in that image.');
    expect(container.read(barcodeScanProvider).status, BarcodeScanStatus.error);

    notifier.reset();
    expect(container.read(barcodeScanProvider).status, BarcodeScanStatus.idle);
  });

  test('permission states map through the injectable service', () async {
    final container = ProviderContainer(overrides: [
      cameraPermissionServiceProvider.overrideWithValue(MockCameraPermissionService(CameraPermissionStatus.permanentlyDenied)),
    ]);
    addTearDown(container.dispose);

    final service = container.read(cameraPermissionServiceProvider);
    expect(await service.status(), CameraPermissionStatus.permanentlyDenied);
    expect(await service.request(), CameraPermissionStatus.permanentlyDenied);
  });
}
