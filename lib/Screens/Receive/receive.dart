import 'dart:convert';
import 'dart:io';
import 'package:firedrop/Widgets/Buttons.dart';
import 'package:firedrop/Widgets/Dialog.dart';
import 'package:firedrop/Widgets/InputField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
class Receive extends StatefulWidget {
  const Receive({super.key});

  @override
  State<Receive> createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  TextEditingController ipController = TextEditingController();
  String _responseMessage = "No response yet";
  List<dynamic> _files = []; // List to store files and folders
  String _currentPath = "/"; // Current directory path
  final String ip =
      "192.168.43.1"; // Replace with dynamic server IP if needed

  @override
  void initState() {
    super.initState();

  }

  

  // Function to fetch files and folders from the server
  Future<void> fetchFiles(String path) async {
    if(ipController.text.isEmpty){
      DialogClass().showCustomDialog(context: context, icon: Icons.error, title: "IP Address", message: "Enter IP Adresss");
      return ;
    }
    String ip = ipController.text;
    final serverUrl;
    if (path == "/") {
      print("here");
      serverUrl = Uri.parse("http://$ip:8080/files");
    } else {
      print("http://$ip:8080/files?path=$path");
      serverUrl = Uri.parse("http://$ip:8080/files?path=$path");
    }

    try {
      setState(() {
        _responseMessage = "Fetching files...";
      });

      final response = await http.get(serverUrl);

      if (response.statusCode == 200) {
        setState(() {
          _files = jsonDecode(response.body);
          _responseMessage = "Files fetched successfully!";
        });
      } else {
        setState(() {
          _responseMessage =
              "Failed to fetch files: ${response.statusCode} ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "Error: $e";
      });
    }
  }

  Future<void> downloadFile(String _currentPath, String fileName) async {
  String filePath = "$_currentPath/$fileName";
  final downloadUrl = Uri.parse("http://$ip:8080/download?filePath=$filePath");

  try {
    final response = await http.get(downloadUrl);

    if (response.statusCode == 200) {
      String savePath;

      if (Platform.isAndroid) {
        // For Android
        String directory=  "/storage/emulated/0/FireDrop"; 
        Directory d = Directory(directory);
        if(!await d.exists()){
          await d.create(recursive: true);
        }
        savePath = "${directory}/$fileName";
      } else if (Platform.isLinux || Platform.isWindows) {
        // For Linux and Windows
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String adsDirPath = "${appDocDir.path}/firedrop";
        final Directory adsDir = Directory(adsDirPath);

        if (!await adsDir.exists()) {
          await adsDir.create(recursive: true);
        }
        final String localFilePath = "$adsDirPath/$fileName";
        
        // Save the file content from the response bytes
        final File file = File(localFilePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _responseMessage = "File downloaded successfully: $localFilePath";
        });

        return;  // Returning after saving the file
      } else {
        setState(() {
          _responseMessage = "Error: Unsupported platform.";
        });
        return;
      }

      // Save the downloaded file (Android case)
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _responseMessage = "File downloaded successfully: $savePath";
      });
    } else {
      setState(() {
        _responseMessage = "Failed to download file: ${response.statusCode} ${response.reasonPhrase}";
      });
    }
  } catch (e) {
    setState(() {
      _responseMessage = "Error downloading file: $e";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receive (Current Path: $_currentPath)"),
        leading: _currentPath != "/"
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to the parent directory
                  final parentPath =
                      _currentPath.substring(0, _currentPath.lastIndexOf('/'));
                  setState(() {
                    _currentPath = parentPath.isEmpty ? "/" : parentPath;
                  });
                  fetchFiles(_currentPath);
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Inputfield().textFieldInput(
              context: context, 
              controller:ipController, 
              labelText: "Enter Address", 
              hintText: "IP Address", 
              prefixIcon: Icons.location_city, 
              keyboardType: TextInputType.number),
             const SizedBox(height: 16),
            Buttons().submitButton(
            onPressed:(){
              fetchFiles(_currentPath);
            },
            buttonText: "Fetch Files",
            isLoading: false),
            
            
            const SizedBox(height: 16),
            Text(
              _responseMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  final file = _files[index];
                  final isDirectory = file['isDirectory'];
                  final name = file['name'];

                  return ListTile(
                    leading: Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file,
                    ),
                    title: Text(name),
                    onTap: () {
                      if (isDirectory) {
                        // Navigate into the folder
                        setState(() {
                          _currentPath = "$_currentPath/$name";
                        });
                        fetchFiles(_currentPath);
                      } else {
                        print(_currentPath);
                        print(name);
                        downloadFile(_currentPath, name);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
