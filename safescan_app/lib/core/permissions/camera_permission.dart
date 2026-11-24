import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

enum CameraPermissionStatus { granted, denied, permanentlyDenied }

abstract interface class CameraPermissionService {
  Future<CameraPermissionStatus> status();
  Future<CameraPermissionStatus> request();
  Future<bool> openSettings();
}

class PermissionHandlerCameraService implements CameraPermissionService {
  const PermissionHandlerCameraService();

  @override
  Future<CameraPermissionStatus> status() async {
    final result = await permission.Permission.camera.status;
    return _map(result);
  }

  @override
  Future<CameraPermissionStatus> request() async {
    final result = await permission.Permission.camera.request();
    return _map(result);
  }

  @override
  Future<bool> openSettings() => permission.openAppSettings();

  CameraPermissionStatus _map(permission.PermissionStatus result) {
    if (result.isGranted) return CameraPermissionStatus.granted;
    if (result.isPermanentlyDenied) return CameraPermissionStatus.permanentlyDenied;
    return CameraPermissionStatus.denied;
  }
}

final cameraPermissionServiceProvider = Provider<CameraPermissionService>((ref) {
  return const PermissionHandlerCameraService();
});
