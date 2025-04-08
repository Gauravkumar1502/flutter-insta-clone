import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request a single permission
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();

    switch (status) {
      case PermissionStatus.granted:
        return true;

      case PermissionStatus.denied:
        // You can show a custom dialog here
        return false;

      case PermissionStatus.permanentlyDenied:
        // Open App Settings
        await openAppSettings();
        return false;

      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return false;
    }
  }
}
