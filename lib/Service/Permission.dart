import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionManager {
  Future<void> requestPermissions(BuildContext context) async {
    try {
      // Request all necessary permissions
      final storagePermission = await Permission.storage.request();
      final manageStoragePermission =
          await Permission.manageExternalStorage.request();
      final locationPermission = await Permission.location.request();
      final wifiPermission = await Permission.locationWhenInUse.request();

      // Check if any permission is denied
      if (!storagePermission.isGranted ||
          !manageStoragePermission.isGranted ||
          !locationPermission.isGranted ||
          !wifiPermission.isGranted) {
        // Show a dialog if any permission is denied
        _showPermissionDeniedDialog(context);
      } else {
        // All permissions granted
        debugPrint("All permissions granted!");
      }
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Error"),
        content: const Text(
          "Some required permissions were denied. Please enable them in the app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Open app settings for the user
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
