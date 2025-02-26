// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class MobileScanner extends StatefulWidget {
//   const MobileScanner({super.key});

//   @override
//   State<MobileScanner> createState() => _MobileScannerState();
// }

// class _MobileScannerState extends State<MobileScanner> {
//   GlobalKey qrKey = GlobalKey(debugLabel: "QR");
//   Barcode? result;
//   QRViewController? controller;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       children: [
//         Expanded(
//           flex: 5,
//           child: QRView(key: qrKey, onQRViewCreated: onQRViewCreated),
//         ),
//         Expanded(
//           flex: 1,
//           child: Center(
//             child: Text("lkdsfjlks"),
//           ),
//         )
//       ],
//     ));
//   }

//   void onQRViewCreated(QRViewController controller){
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData){
//        setState(() {
//         result = scanData;
//       });
//       print(scanData);
//     });
//   }
// }
