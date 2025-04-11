import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'byItems/byOCR/camera.dart';
import 'split_bill_manual_selection.dart';
import 'history/history_screen.dart';

class SplitBillScreen extends StatelessWidget {
  const SplitBillScreen({super.key, required this.cameras});
  final List<CameraDescription> cameras; // Accept cameras from main.dart


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Split Bill', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        iconTheme: IconThemeData(
    color: Colors.white, // Change back arrow color here
  ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.red.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.notification_important, color: Color.fromARGB(255, 247, 85, 80)),
                title: Text('You have 1 outstanding bill',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {},
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.document_scanner, color: Color.fromARGB(255, 247, 85, 80)),
                title: Text('Create New (Scan)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Create new split bill by scanning or uploading your receipt'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)), // Pass the first camera
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.receipt_long, color: Color.fromARGB(255, 247, 85, 80)),
                title: Text('Create New (Manual)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Create new split bill by manual input'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SplitBillSelectionScreen()), // Pass the first camera
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.payments, color: Color.fromARGB(255, 247, 85, 80)),
                title: Text('Bill History',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Check your past bills and possible outstanding'),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HistoryScreen()),
  );
},

              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
