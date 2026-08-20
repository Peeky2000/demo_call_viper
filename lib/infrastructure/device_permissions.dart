import 'package:permission_handler/permission_handler.dart';

import '../domain/ports.dart';

/// Quyền mic + camera. Cả hai đều bắt buộc: demo là cuộc gọi video.
class DevicePermissions implements PermissionsPort {
  const DevicePermissions();

  @override
  Future<bool> ensureCallPermissions() async {
    final Map<Permission, PermissionStatus> result =
        await <Permission>[Permission.microphone, Permission.camera].request();
    return result.values.every((PermissionStatus s) => s.isGranted);
  }

  @override
  Future<void> openSystemSettings() => openAppSettings();
}
