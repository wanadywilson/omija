import 'dart:io';
import 'package:flutter/material.dart';
import 'edit_receipt.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath, Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    List<Map<String, String>> dummyData = [
      {'name': 'Burger', 'price': '65000', 'quantity':'2'},
      {'name': 'Fries', 'price': '24900', 'quantity':'4'},
      {'name': 'Soda', 'price': '19900', 'quantity':'5'},
      {'name': 'Ice Cream', 'price': '34900', 'quantity':'6'},
      {'name': 'Salad', 'price': '49999', 'quantity':'1'},
    ];
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
    color: Colors.white, // Change back arrow color here
  ),title: Text('Confirm your picture',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.file(File(imagePath)), // Show the captured image
            ),
          ),

          Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 72), // Adds space on both left & right sides
  child:
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Red for "Go Back"
          foregroundColor: Colors.black, // White text
          elevation: 5,
          shadowColor: Color.fromARGB(255,94,19,16),
          padding: EdgeInsets.symmetric(vertical: 16), // Same height padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
          )
        ),
        onPressed: () {
          Navigator.pop(context); // Go back to Camera screen
        },
        child: Text('Retake picture', style: TextStyle(fontSize: 16)),
      ),
    ),
    SizedBox(width: 10), // Space between buttons
    Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255,94,19,16), // Green for "Go Next"
          foregroundColor: Colors.white, // White text
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditReceiptScreen(items: dummyData)),
          );
        },
        child: Text('Next', style: TextStyle(fontSize: 16)),
      ),
    ),
  ],
),),

          SizedBox(height: 20), // Add spacing
        ],
      ),
    );
  }
}
