import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

class SendState with ChangeNotifier {
  List<String> _ipAddress = [];
  final int port = 8080;
  String datar = "";
  bool _isServerOn = false;
  double _progress = 0.0; // Added progress tracking

  List<String> get ipAddresses => _ipAddress;
  bool get isServerOn => _isServerOn;
  double get progress => _progress; // Getter for progress

  Future<void> getAddress() async {
    try {
      if (_ipAddress.isEmpty) {
        List<NetworkInterface> interfaces = await NetworkInterface.list();
        for (NetworkInterface interface in interfaces) {
          for (InternetAddress address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4) {
              _ipAddress.add(address.address);
            }
          }
        }
        print(_ipAddress);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void hostServer() async {
    try {
      await getAddress();
      var server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      datar = "Server Started";
      notifyListeners();
      server.listen((Socket client) {
        client.listen((data) {
          String received_data = utf8.decode(data);
          print(received_data);
          var json_data = jsonDecode(received_data);
          handleRoutes(client, json_data);
          datar = data.toString();
          notifyListeners();
        });
      });

      _isServerOn = true;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void handleRoutes(Socket client, Map<String, dynamic> jsonData) {
    String route = jsonData['route'];
    var data = jsonData['data'];

    switch (route) {
      case 'path':
        List<Map<String, String>> files = listFilesAndDirectories(data);
        client.write(
            jsonEncode({'status': 'success', 'path': data, 'files': files}));
        break;

      case 'download':
        print("Handling Download Route with Data: $data");
        sendFile(client, data);
        break;

      default:
        print("Unknown Route: $route");
        client
            .write(jsonEncode({'status': 'error', 'message': 'Unknown route'}));
    }
  }

  void sendFile(Socket client, String filePath) async {
    File file = File(filePath);

    if (await file.exists()) {
      int fileSize = await file.length();
      String fileName = file.uri.pathSegments.last; // Extract filename

      // Send metadata (filename + file size)
      client.write(jsonEncode({'status': 'start', 'size': fileSize, 'filename': fileName}) + '\n');

      int sentBytes = 0;
      Stream<List<int>> fileStream = file.openRead();

      await for (var chunk in fileStream) {
        client.add(chunk);
        sentBytes += chunk.length;
        
        // Update progress
        _progress = sentBytes / fileSize;
        notifyListeners();

      }

      await client.flush();
      
      // Notify client that transfer is complete
      client.write(jsonEncode({'status': 'done', 'filename': fileName}) + '\n');

      // Reset progress after completion
      _progress = 0.0;
      notifyListeners();

      print('File "$fileName" sent successfully');
    } else {
      client.write(jsonEncode({'status': 'error', 'message': 'File not found'}) + '\n');
    }
  }

  List<Map<String, String>> listFilesAndDirectories(String path) {
    List<Map<String, String>> result = [];

    if (path == "/") {
      if (Platform.isWindows) {
        path = Platform.environment['USERPROFILE'] ?? "C:\\Users";
      } else if (Platform.isMacOS || Platform.isLinux) {
        path = Platform.environment['HOME'] ?? "/home";
      } else if (Platform.isAndroid) {
        path = "/storage/emulated/0"; // External storage on Android
      } else if (Platform.isIOS) {
        print("iOS does not allow direct external storage access.");
        return result;
      } else {
        print("Unsupported OS");
        return result;
      }
    }

    final directory = Directory(path);

    if (directory.existsSync()) {
      List<FileSystemEntity> entities = directory.listSync();
      for (var entity in entities) {
        String name = entity.uri.pathSegments.last;

        if (entity is File) {
          if (!name.startsWith('.')) {
            result.add({"type": "file", "path": entity.path});
          }
        } else if (entity is Directory) {
          String n = entity.path.split('/').last;
          if (!n.startsWith(".")) {
            result.add({"type": "directory", "path": entity.path});
          }
        }
      }
    } else {
      print("Directory does not exist.");
    }

    return result;
  }
}
