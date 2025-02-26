import 'package:flutter/material.dart';

class AppbarClass {


  AppBar buildHomeAppBar() {
    return AppBar(
      toolbarHeight: 70,
      elevation: 4,
      backgroundColor: Colors.white70,
      centerTitle: false,
       flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white], // Add gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title:Row(
              children: [
                SizedBox(width: 5),
                Image.asset(
                  'assets/logo1.png',
                  height: 50,
                ),
                SizedBox(width: 10),
               Text(
                      "Fire Drop", // Placeholder while waiting
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ],
            ),   actions: [
        IconButton(
          iconSize: 25,
          onPressed: () {},
          icon: Icon(Icons.notifications, color: Colors.black87),
        ),
        PopupMenuButton(
          iconSize: 25,
          icon: Icon(Icons.more_vert, color: Colors.black87),
          onSelected: (value) {
            // Handle menu selection
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Option 1',
              child: Text('Option 1'),
            ),
            PopupMenuItem(
              value: 'Option 2',
              child: Text('Option 2'),
            ),
          ],
        ),
      ],
    );
  }

  /// AppBar for sub-screens
  AppBar buildSubScreenAppBar(BuildContext context, String screenName) {
    return AppBar(
      elevation: 4,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Text(
        screenName, // Display the screen name
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Image.asset(
            'assets/logo1.png', // Replace with your logo asset
            height: 50,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16), // Add rounded corners at the bottom
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white], // Add gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
