import 'dart:convert';
import 'dart:io';
import 'package:firedrop/Service/Permission.dart';
import 'package:firedrop/Widgets/Dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Send extends StatefulWidget {
  const Send({super.key});

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  bool isCheck = false;
  bool isHotspotOn = false;
  HttpServer? server; // Reference to the server
  List<String> serverAddresses = []; // List to store server IPs
  static const platform = MethodChannel("hotspot_control");

  Future<void> checkHotspotStatus() async {
    try {
      // Show loading dialog
      DialogClass().showLoadingDialog(context: context, isLoading: true);

      // Check if the hotspot is ON
      isHotspotOn = await platform.invokeMethod("isHotspotOn");

      // Close the loading dialog
      DialogClass().showLoadingDialog(context: context, isLoading: false);

      setState(() {
        isCheck = true;
      });

      // If hotspot is ON, start the server
      if (isHotspotOn) {
        server = await HttpServer.bind(
          InternetAddress.anyIPv4,
          8080,
        );
        print("Server running on port: ${server!.port}");

        // Get all IP addresses for the current device
        final interfaces = await NetworkInterface.list();
        for (var interface in interfaces) {
          for (var address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4) {
              serverAddresses.add("${address.address}:${server!.port}");
              print("Server accessible at: ${address.address}:${server!.port}");
            }
          }
        }
        server!.listen((HttpRequest request) async {
          try {
            final path = request.uri.path;
            // Get the requested path
            final queryParameters =
                request.uri.queryParameters; 
            final rootDirectory =
                "/storage/emulated/0"; 
            final requestedPath;
            if (path == "/files") {
              if (queryParameters['path'] == null) {
               requestedPath = queryParameters['path'] ?? rootDirectory;
              }else{
              requestedPath  = "$rootDirectory${queryParameters['path']}";
              }
              final directory = Directory(requestedPath);
              if (await directory.exists()) {
                final files = directory.listSync().map((file) {
                  final name = file.path.split('/').last;
                  return {
                    "name": name,
                    "isDirectory": file is Directory,
                    "path": file.path,
                  };
                }).toList();

                request.response
                  ..headers.contentType = ContentType.json
                  ..write(jsonEncode(
                      files)) // Send the list of files/directories as JSON
                  ..close();
              } else {
                request.response
                  ..statusCode = HttpStatus.notFound
                  ..write("Directory not found")
                  ..close();
              }
            } else if (path.startsWith("/download")) {
              // Serve a specific file for download
              final filePath = queryParameters['filePath'];
              print("$rootDirectory$filePath");
              if (filePath != null) {
                final file = File("$rootDirectory$filePath");

                if (await file.exists()) {
                  final fileName = file.path.split('/').last;
                  request.response.headers.add("content-disposition",
                      'attachment; filename="$fileName"');
                  request.response
                    ..add(await file.readAsBytes())
                    ..close();
                } else {
                  request.response
                    ..statusCode = HttpStatus.notFound
                    ..write("File not found")
                    ..close();
                }
              } else {
                request.response
                  ..statusCode = HttpStatus.badRequest
                  ..write("File path not provided")
                  ..close();
              }
            } else {
              request.response
                ..statusCode = HttpStatus.badRequest
                ..write("Invalid endpoint")
                ..close();
            }
          } catch (e) {
            print("Error: $e");
            request.response
              ..statusCode = HttpStatus.internalServerError
              ..write("An error occurred: $e")
              ..close();
          }
        });
        setState(() {}); // Update UI
      } else {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Hotspot",
          message: "Hotspot is OFF. Please turn it ON to start the server.",
        );
      }
    } on PlatformException catch (e) {
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Hotspot Error",
        message: "Failed to check hotspot status: $e",
      );
    } catch (e) {
      print("Error: $e");
      DialogClass().showCustomDialog(
        context: context,
        icon: Icons.error,
        title: "Error",
        message: "An unexpected error occurred: $e",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        PermissionManager().requestPermissions(context);
        checkHotspotStatus(); // Start server after permissions are granted
      } catch (e) {
        DialogClass().showCustomDialog(
          context: context,
          icon: Icons.error,
          title: "Permission Error",
          message: e.toString(),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the server when the widget is removed
    server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send"),
      ),
      body: Center(
        child: isCheck
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hotspot is ON",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (serverAddresses.isNotEmpty)
                    ...serverAddresses.map(
                      (address) => Text(
                        "Server accessible at: $address",
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : const Text("Hotspot is OFF"),
      ),
    );
  }
}
