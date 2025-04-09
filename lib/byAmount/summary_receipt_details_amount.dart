import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart'; // Ensure it has Person and Receipt classes
import 'show_pin.dart';

class SummaryReceiptDetailsAmountScreen extends StatelessWidget {
  final Receipt receipt;
  final String splitMethod; // "Percentage", "Equal", or "Exact"

  SummaryReceiptDetailsAmountScreen({required this.receipt, required this.splitMethod});

  String _format(double value) => NumberFormat("#,###").format(value);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F1F8),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split Summary", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Split by $splitMethod", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // 📄 Receipt card
            Card(
              color: Color(0xFFF6F6F6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(receipt.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(receipt.date, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Divider(),

                    // People
                    ...receipt.people.map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: p.avatarColor,
                                child: Text(p.name[0].toUpperCase(), style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 10),
                              Text(p.name),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (splitMethod == "Percentage")
                                Text("${p.percentage.toStringAsFixed(2)}%", style: TextStyle(fontSize: 12)),
                              Text("Rp${_format(p.amount)}", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    )),

                    Divider(),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Rp${_format(double.tryParse(receipt.grandTotal.toString().replaceAll(',', '')) ?? 0)}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // ✅ Split Bill Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  builder: (context) => PinConfirmationPop(
                    receipt: receipt,
                    splitMethod: splitMethod,
                  ),
                );
                  // Trigger split logic or go to next screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 94, 19, 16),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text("Split Bill", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
