import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiveState with ChangeNotifier {
  late Socket socket;
  bool isConnected = false;
  bool isConnecting = false;
  bool isFetch = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  int fileSize = 0;
  int receivedBytes = 0;
  late IOSink fileSink;

  final int port = 8080;
  Map<String, List<dynamic>> files = {};
  late String saveDirectory;
  ReceiveState() {
    _setSaveDirectory(); // Set the file storage directory at initialization
  }



Future<void> _setSaveDirectory() async {
  // Request permission
  if (!(await Permission.storage.request().isGranted)) {
    print("Storage permission denied");
    return;
  }

  String path;
  if (Platform.isWindows) {
    path = Platform.environment['USERPROFILE'] ?? "C:\\Users";
  } else if (Platform.isMacOS || Platform.isLinux) {
    path = Platform.environment['HOME'] ?? "/home";
  } else if (Platform.isAndroid) {
    path = "/storage/emulated/0";  // External storage on Android
  } else if (Platform.isIOS) {
    print("iOS does not allow direct external storage access.");
    return;
  } else {
    print("Unsupported OS");
    return;
  }

  saveDirectory = "$path/Firedrop";
  Directory dir = Directory(saveDirectory);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  print("Files will be stored in: $saveDirectory");
}


  Future<void> connectToHost(String ip) async {
    try {
      isConnecting = true;
      notifyListeners();

      socket = await Socket.connect(ip, port);
      print("Successfully Connected: $ip:$port");
      isConnecting = false;
      isConnected = true;

      // Listen for response
      socket.listen(
        (data) {
          if (!isDownloading) {
            handleServerResponse(data);
          } else {
            handleFileDownload(data);
          }
        },
        onError: (error) {
          print('Error: $error');
          socket.close();
          isConnected = false;
          notifyListeners();
        },
        onDone: () {
          print('Disconnected from server');
          isConnected = false;
          notifyListeners();
        },
      );

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void handleServerResponse(Uint8List data) {
    isFetch = false;
    String receivedData = utf8.decode(data);
    print("Received: $receivedData");

    try {
      var jsonData = jsonDecode(receivedData);
      if (jsonData.containsKey('files')) {
        // Directory listing response
        files[jsonData['path']] = jsonData['files'];
        isFetch = true;
      } else if (jsonData['status'] == 'start') {
        // File download initiation
        startFileDownload(jsonData['size'], jsonData['filename']);
      }
    } catch (e) {
      print("Error decoding JSON: $e");
    }

    notifyListeners();
  }

  Future<void> sendRequest(String path, {bool isDownload = false}) async {
    if (isConnected) {
      var request = jsonEncode({
        'route': isDownload ? 'download' : 'path',
        'data': path,
      });
      socket.write(request);
      print("Request sent: $request");
    } else {
      print("Socket is not connected");
    }
  }

  void startFileDownload(int size, String filename) {
    print('Starting download for $filename, Size: $size bytes');
    fileSize = size;
    receivedBytes = 0;
    isDownloading = true;

    String savePath = "$saveDirectory/$filename"; // Save inside Firedrop folder
    fileSink = File(savePath).openWrite();
  }

  void handleFileDownload(Uint8List data) {
    fileSink.add(data);
    receivedBytes += data.length;

    downloadProgress = (receivedBytes / fileSize);
    notifyListeners(); // Update UI

    if (receivedBytes >= fileSize) {
      completeFileDownload();
    }
  }

  Future<void> completeFileDownload() async {
    await fileSink.close();
    isDownloading = false;
    print('Download completed. File saved to: $saveDirectory');
    notifyListeners();
  }

  void closeConnection() {
    socket.close();
    isConnected = false;
    notifyListeners();
  }
}
