import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: const Color.fromARGB(255, 94, 19, 16),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/receipt_omo2.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // SafeArea to prevent overlap with status bar
          SafeArea(
            child: Stack(
              children: [
                // Close Button (top left)
                Positioned(
                  top: 12,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.white),
                        SizedBox(width: 5),
                        Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                // Share Button (top right)
                Positioned(
                  top: 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Add your share logic here
                    },
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 5),
                        Text("Share", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlayed content inside the receipt
          Positioned(
            top: 320,
            left: 45,
            right: 45,
            bottom: 50,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Amount Section
                  Text("AMOUNT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      )),
                  SizedBox(height: 4),
                  Text("IDR $amount",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  SizedBox(height: 20),

                  // Transfer to section
                  _infoRowDouble(
                    "Transfer to",
                    "JEXXXXX SAXXXXX",
                    trailing: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 194, 30, 30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Add to Favorites", style: TextStyle(color: Colors.white, fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.favorite, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    subtitle: phoneNumber,
                  ),

                  SizedBox(height: 16),

                  // Transaction Time + ID
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _infoBlock("Transaction Time", formattedTime),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: _infoBlock("Transaction ID", transactionId, alignRight: true),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _infoBlock("Transfer from", "Octo Cumi"),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _infoBlock("Message", message),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowDouble(String label, String value, {Widget? trailing, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left label
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          // Right content
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: TextStyle(color: Colors.black)),
                if (subtitle != null) SizedBox(height: 4),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                if (trailing != null) SizedBox(height: 6),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            )),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}
