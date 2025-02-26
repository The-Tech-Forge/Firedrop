import 'package:firedrop/Screens/Receive/file_manager.dart';
import 'package:firedrop/Service/States/receive_state.dart';
import 'package:firedrop/Widgets/Appbar.dart';
import 'package:firedrop/Widgets/Buttons.dart';
import 'package:firedrop/Widgets/InputField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Receive extends StatefulWidget {
  const Receive({super.key});

  @override
  State<Receive> createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  TextEditingController ip = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final receive = Provider.of<ReceiveState>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppbarClass().buildSubScreenAppBar(context, "Receive"),
      body: Container(
        margin: EdgeInsets.all(20),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Inputfield().textFieldInput(
                context: context,
                controller: ip,
                labelText: "IP Address",
                hintText: "192.XXX.XX.XXX",
                prefixIcon: Icons.no_encryption,
                keyboardType: TextInputType.number),
            SizedBox(
              height: 20,
            ),
            Buttons().submitButton(
                onPressed: () async {
                  await receive.connectToHost(ip.text);
                      receive.sendRequest("/",);
// Wait until data is received
                  while (receive.files.isEmpty) {
                    await Future.delayed(Duration(
                        milliseconds: 100)); // Small delay to wait for data
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileManager( items: receive.files['/']!),
                    ),
                  );
                },
                isLoading: receive.isConnecting),
          ],
        ),
      ),
    );
  }
}
