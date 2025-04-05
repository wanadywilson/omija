import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'assign_person.dart';

class ReviewReceiptScreen extends StatelessWidget {
  final List<Map<String, String>> items;
  final double total;

  ReviewReceiptScreen({
    required this.items,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255,94,19,16),
        title: Text("Review your bill",style: TextStyle(color: Colors.white)),

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Receipt Container
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    "Western BBQ Grill",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),

                  // List of Items
                  Column(
                    children: items.map((item) {
                      double price = double.tryParse(item['price']!.replaceAll(',', '')) ?? 0;
                      int quantity = int.tryParse(item['quantity']!) ?? 1;
                      double itemTotal = price * quantity;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Item Name
                            Text(
                              item['name']!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            // Single Price, Quantity, Total in One Line
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  NumberFormat("#,###").format(price), // Single Price
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "x$quantity", // Quantity
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  NumberFormat("#,###").format(itemTotal), // Total Price
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Divider(),

                  // Total
                  _buildSummaryRow("Total Pembayaran", total, isTotal: true),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color.fromARGB(255,94,19,16)),
                  ),
                  child: Text("Back", style: TextStyle(color: Color.fromARGB(255,94,19,16))),
                ),
                ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignPersonScreen(
          items: items,
          total: total, // Pass items from previous screen
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255,94,19,16),
  ),
  child: Text("Next", style: TextStyle(color: Colors.white)),
),

              ],
            ),
          ],
        ),
      ),
    );
  }

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
            NumberFormat("#,###").format(amount),
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
