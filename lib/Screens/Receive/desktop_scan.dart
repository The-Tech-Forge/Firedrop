// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:zxing2/qrcode.dart';
// import 'package:image/image.dart' as img;

// class DesktopQrScanner extends StatefulWidget {
//   @override
//   _DesktopQrScannerState createState() => _DesktopQrScannerState();
// }

// class _DesktopQrScannerState extends State<DesktopQrScanner> {
//   CameraController? _cameraController;
//   bool isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isNotEmpty) {
//       _cameraController =
//           CameraController(cameras.first, ResolutionPreset.medium);
//       await _cameraController?.initialize();
//       setState(() {});
//     }
//   }

//   Future<void> _scanFrame() async {
//     if (_cameraController == null || isProcessing) return;

//     isProcessing = true;
//     final XFile? imgs = await _cameraController!.takePicture();
//     var image = img.decodePng(File(imgs!.path).readAsBytesSync())!;

//     LuminanceSource source = RGBLuminanceSource(
//         image.width,
//         image.height,
//         image
//             .convert(numChannels: 4)
//             .getBytes(order: img.ChannelOrder.abgr)
//             .buffer
//             .asInt32List());
//     var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

//     var reader = QRCodeReader();
//     var result = reader.decode(bitmap);
//     print(result.text);

//     isProcessing = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("QR Scanner (Desktop)")),
//       body: Column(
//         children: [
//           if (_cameraController != null &&
//               _cameraController!.value.isInitialized)
//             CameraPreview(_cameraController!)
//           else
//             Center(child: CircularProgressIndicator()),
//           ElevatedButton(onPressed: _scanFrame, child: Text("Scan QR Code")),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
// }
