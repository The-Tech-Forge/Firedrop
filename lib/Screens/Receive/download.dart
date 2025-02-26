import 'package:firedrop/Service/States/receive_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadDialog extends StatefulWidget {
  final String path;
  const DownloadDialog({required this.path, Key? key}) : super(key: key);

  @override
  _DownloadDialogState createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReceiveState>(
      builder: (context, receive, child) {
        double progress = receive.downloadProgress.clamp(0.0, 1.0);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Downloading..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 10),
              Text("${(progress * 100).toStringAsFixed(1)}% completed"),
            ],
          ),
          actions: [
            if (progress == 1.0) 
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
          ],
        );
      },
    );
  }
}
