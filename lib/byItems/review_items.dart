import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'assign_person_by_items.dart';

class ReviewItemsScreen extends StatelessWidget {
  final Receipt receipt;

  ReviewItemsScreen({required this.receipt});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      title: Text("Review your bill", style: TextStyle(color: Colors.white)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReceiptSummaryCard(),
            SizedBox(height: 16),
            _buildPeopleCard(),
            SizedBox(height: 80), // Space for floating button
          ],
        ),
      ),
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AssignPersonByItemsManualScreen(receipt: receipt),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 94, 19, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    ),
  );
}


  // 📦 Receipt Summary
  Widget _buildReceiptSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                receipt.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                receipt.date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Divider(),

          // Item List
          ...receipt.items.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat("#,###").format(item.singlePrice),
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text("x${item.quantity}"),
                      Text(
                        NumberFormat("#,###").format(item.totalPrice),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

          Divider(),

          // Subtotal, Service Charge, Tax
          _buildSummaryRow("Subtotal (items only)", receipt.subTotal),
          _buildSummaryRow("Service Charge (${receipt.serviceChargePercentage.toStringAsFixed(2)}%)", receipt.serviceCharge),
          _buildSummaryRow("Tax (${receipt.taxPercentage.toStringAsFixed(2)}%)", receipt.tax),

          Divider(),

          _buildSummaryRow("Grand Total", receipt.grandTotal, isTotal: true),
        ],
      ),
    );
  }

  // 👤 People Summary
 Widget _buildPeopleCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("People", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Column(
          children: receipt.people.asMap().entries.map((entry) {
            int index = entry.key;
            Person person = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    child: Text(person.name.isNotEmpty ? person.name[0].toUpperCase() : '?'),
                  ),
                  SizedBox(width: 10),
                  Text("${index + 1}. ${person.name}", style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}


  // 💵 Summary Row Widget
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rp${NumberFormat("#,###").format(amount)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
