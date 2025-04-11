import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Receipt receipt;

  HistoryDetailScreen({required this.receipt});

  String _format(double value) => NumberFormat("#,###").format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split Bill Detail", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("images/logo_omo.jpg", scale: 2), // OCTO Mobile logo
                  SizedBox(height: 20),
                  Text("Split Bill by ${receipt.method}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Text(receipt.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  // Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Receipt Date", style: TextStyle(color: Colors.grey[700])),
                      Text(receipt.date),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transaction Time", style: TextStyle(color: Colors.grey[700])),
                      Text(receipt.transactionTime),
                    ],
                  ),

                  SizedBox(height: 20),
                  Divider(),

                  // People
                  Column(
  children: receipt.people.map((p) {
    final isVerified = p.username != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Name + Tick + Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Name and tick in a Wrap for same-line appearance
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (isVerified)
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ],
                ),
                if (p.phone.trim().isNotEmpty)
                  Text(
                    p.phone,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          // Right: Amount
          Text(
            "Rp${_format(p.amount)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }).toList(),
),




                  Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp${_format(receipt.grandTotal)}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
