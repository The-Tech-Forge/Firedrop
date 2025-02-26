import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionManager {
  Future<void> requestPermissions(BuildContext context) async {
    try {
      // Check current permission statuses
      final storageStatus = await Permission.storage.status;
      final manageStorageStatus = await Permission.manageExternalStorage.status;
      final locationStatus = await Permission.location.status;
      final wifiStatus = await Permission.nearbyWifiDevices.status;

      // Request permissions only if not already granted
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }
      if (!manageStorageStatus.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }
      if (!wifiStatus.isGranted) {
        await Permission.nearbyWifiDevices.request();
      }

      // Recheck permissions after request
      if (await Permission.storage.isGranted &&
          await Permission.manageExternalStorage.isGranted &&
          await Permission.location.isGranted &&
          await Permission.nearbyWifiDevices.isGranted) {
        debugPrint("✅ All permissions granted!");
      } else {
        // Show dialog if any permission is denied
        // _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      debugPrint("❌ Error requesting permissions: $e");
    }
  }

  // void _showPermissionDeniedDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Permission Error"),
  //       content: const Text(
  //         "Some required permissions were denied. Please enable them in the app settings.",
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             openAppSettings(); // Open app settings for the user
  //           },
  //           child: const Text("Open Settings"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
