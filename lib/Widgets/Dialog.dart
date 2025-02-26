import 'package:flutter/material.dart';

class DialogClass {
  void showCustomDialog({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onPressed ?? () => Navigator.of(context).pop(), // Use default function if null
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

   void showLoadingDialog({
    required BuildContext context,
    required bool isLoading,
  }) {
    if (isLoading) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }


  Widget downloadDialogBox({
  required String filename,
  required double sizeInMB,
  required double progressSizeInMB,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      double progress = (progressSizeInMB / sizeInMB).clamp(0.0, 1.0);

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.download,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "Downloading File...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15),

              // File Name
              Row(
                children: [
                  Icon(Icons.file_present, color: Colors.grey[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filename,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Download Progress
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).primaryColor,
                minHeight: 8,
              ),
              SizedBox(height: 10),

              // Progress Text
              Text(
                "${progressSizeInMB.toStringAsFixed(2)} MB / ${sizeInMB.toStringAsFixed(2)} MB",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),

              // Percentage Completed
              Center(
                child: Text(
                  "${(progress * 100).toStringAsFixed(1)}% Completed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

}
