import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../globals.dart';

class ReceiptScreen extends StatelessWidget {
  final String amount;
  final String phoneNumber;
  final String transactionId;
  final DateTime transactionTime;
  final String message;

  const ReceiptScreen({
    required this.amount,
    required this.phoneNumber,
    required this.transactionId,
    required this.transactionTime,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('dd MMM yyyy HH:mm').format(transactionTime);
    
     return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      appBar: AppBar(
        
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        automaticallyImplyLeading: false, // Remove default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close Button
            // Close Button
GestureDetector(
  onTap: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(cameras: cameras)),
      (Route<dynamic> route) => false,
    );
  },
  child: Row(
    children: [
      Icon(Icons.close, color: Colors.white),
      SizedBox(width: 5),
      Text(
        "Close",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ],
  ),
),


            // Share Button
            GestureDetector(
              onTap: () {
                // Implement share functionality here
              },
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.white),
                  SizedBox(width: 5), // Space between icon and text
                  Text(
                    "Share",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(25),
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  Text("Successful!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text("Your transaction is successful", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  
                  SizedBox(height: 10),
                  Image.asset("images/logo_omo.jpg", scale: 2), // OCTO Logo

                  SizedBox(height: 15),
                  Text("AMOUNT", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height:10),
                  Text("IDR ${amount}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),
                  // Transfer To (Left: Label, Right: Recipient Name & Number)
// Transfer To (Left: Label, Right: Name & Phone)
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns to opposite ends
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Transfer to",
        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Align name & number to the right
        children: [
          Text(
            'JEXXXXX SAXXXXX', // Pass actual recipient's name (JEXXX)
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height:7),
          Text(
            phoneNumber, // Pass actual phone number (135000)
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    ],
  ),
),



                  SizedBox(height: 10),
                 // Add to Favorites Button (Aligned Right)
// Add to Favorites Button (Aligned Right, Icon After Text)
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
    children: [
      ElevatedButton(
        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 194, 30, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prevents button from stretching
          children: [
            Text("Add to Favorites", style: TextStyle(color: Colors.white)),
            SizedBox(width: 6), // Spacing between text and icon
            Icon(Icons.favorite, color: Colors.white),
          ],
        ),
      ),
    ],
  ),
),


                  // Transaction Details Row
// Transaction Details Section
// Transaction Details Section
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    // Transaction Time & Transaction ID in Row
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transaction Time",
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                formattedTime, // Example: "03 Mar 2025 23:36"
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Transaction ID",
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                transactionId, // Example: "TXN174019769747"
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ),

    // Transfer From Section
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer from",
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            longName, // Example: "OCTO Savers (••••5891)"
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),

    // Message Section (Moved Below)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Messages",
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message, // Example: "MB174019769747"
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ),
  ],
),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
}