import 'package:firedrop/Service/States/send_state.dart';
import 'package:firedrop/Widgets/Appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Send extends StatefulWidget {
  const Send({super.key});

  @override
  State<Send> createState() => _SendState();
}

class _SendState extends State<Send> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!Provider.of<SendState>(context, listen: false).isServerOn)
        Provider.of<SendState>(context, listen: false).hostServer();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final send = Provider.of<SendState>(context, listen: true);

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppbarClass().buildSubScreenAppBar(context, "Send"),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Data Received : ${send.datar}"),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: send.ipAddresses.length,
            itemBuilder: (BuildContext context, int index) {
              return Text(
                "IP Addresses : ${send.ipAddresses[index]}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              );
            },
          ),
        ),

        // Show Progress Bar only if progress is greater than 0
        if (send.progress > 0) ...[
          SizedBox(height: 20),
          Text("File Sending Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: send.progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 8,
          ),
          SizedBox(height: 10),
          Text(
            "${(send.progress * 100).toStringAsFixed(1)}% Completed",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    ),
  );
}

}
