import 'package:firedrop/Screens/Receive/receive.dart';
import 'package:firedrop/Screens/Send/send.dart';
import 'package:firedrop/Service/Permission.dart';
import 'package:firedrop/Widgets/Appbar.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    await PermissionManager().requestPermissions(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarClass().buildHomeAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                backgroundColor: Colors.cyanAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Send()));
              },
              icon: Icon(Icons.send, color: Colors.black),
              label: Text(
                "Send",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(20),
                backgroundColor: Colors.cyanAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Receive()));
              },
              icon: Icon(Icons.download, color: Colors.black),
              label: Text(
                "Receive",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
