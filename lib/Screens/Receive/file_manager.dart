import 'package:firedrop/Screens/Receive/download.dart';
import 'package:firedrop/Service/States/receive_state.dart';
import 'package:firedrop/Widgets/Appbar.dart';
import 'package:firedrop/Widgets/Dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FileManager extends StatefulWidget {
  final List<dynamic> items;
  FileManager({required this.items,  super.key});

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "File Manager"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.items.isEmpty
            ? _buildEmptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Files & Folders",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(children: getFolder()), // File list
                        if (isLoading)
                          _buildLoadingOverlay(), // Show loading when navigating
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          const Text(
            "No files found",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  List<Widget> getFolder() {
    List<Widget> widgets = [];
    for (var item in widget.items) {
      final isDirectory = item["type"] == "directory";
      final path = item["path"] ?? "";

      widgets.add(Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(
            isDirectory ? Icons.folder : Icons.insert_drive_file,
            color: isDirectory ? Colors.orange : Colors.blueGrey,
            size: 32,
          ),
          title: Text(
            path.split('/').last, // Show only the file/folder name
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(path,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: isDirectory
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : null,
          onTap: isDirectory ? () => _navigateToFolder(path) :()=> downloadFile(path),
        ),
      ));
    }
    return widgets;
  }

 void downloadFile(String path) {
  try {
    var receive = Provider.of<ReceiveState>(context, listen: false);
    receive.sendRequest(path, isDownload: true);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while downloading
      builder: (context) {
        return DownloadDialog(path: path);
      },
    );
  } catch (e) {
    print(e);
  }
}


  void _navigateToFolder(String path) async {
    try {
      setState(() => isLoading = true); // Show loading indicator

      var receive = Provider.of<ReceiveState>(context, listen: false);
      if (!receive.files.containsKey(path)) {
        await receive.sendRequest(path,);

        await Future.delayed(const Duration(milliseconds: 500));
      }
      // Simulate loading

      setState(() => isLoading = false); // Hide loading indicator
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FileManager(
              items: receive.files[path]!, 
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
    } catch (e) {
      DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Opps",
          message: "Some Error?");
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }


}
