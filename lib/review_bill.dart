import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'show_pin_split_ocr.dart';

class ReviewBillScreen extends StatelessWidget {
  final List<Map<String, dynamic>> peopleBills;
  final List<Map<String, String>> items;

  ReviewBillScreen({required this.peopleBills, required this.items});

  @override
  Widget build(BuildContext context) {
    // The grand total is directly received from assign_person.dart
    double grandTotal = peopleBills.fold(0, (sum, person) => sum + (person["items"] as List<Map<String, dynamic>>)
        .fold(0.0, (sum, item) => sum + (double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0)) );

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Final Review', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        iconTheme: IconThemeData(
          color: Colors.white, // Change back arrow color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "WESTERN BBQ GRILL",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Bill List with Cards
            Expanded(
              child: ListView(
                children: [
                  ...peopleBills.map((person) {
                    double personTotal = (person["items"] as List<Map<String, dynamic>>)
                        .fold(0.0, (sum, item) => sum + (double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0));

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile and Name
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    person["name"][0], // Placeholder avatar
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  person["name"],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(),

                            // Items List
                            ...person["items"].map<Widget>((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(item["name"])),
                                    Text(
                                      "Rp${NumberFormat("#,###").format(double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0)}",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            Divider(),

                            // Total Amount Calculation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Dibayar",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Rp${NumberFormat("#,###").format(personTotal)}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Summary Section: Shows only person name & their total
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Summary",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Divider(),

                          // Each person's total
                          ...peopleBills.map((person) {
                            double personTotal = (person["items"] as List<Map<String, dynamic>>)
                                .fold(0.0, (sum, item) => sum + (double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0));
                            return _summaryRow(person["name"], personTotal);
                          }).toList(),

                          Divider(),
                          _summaryRow("Grand Total", grandTotal, isBold: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  _showPinConfirmationPopup(context, peopleBills, items, grandTotal);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 94, 19, 16),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  "Send Split Bill",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
          Text("Rp${NumberFormat("#,###").format(amount)}",
              style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }
}

// Function to Show PIN Popup and Pass Data
void _showPinConfirmationPopup(BuildContext context, List<Map<String, dynamic>> peopleBills, List<Map<String, String>> items, double totalAmount) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PinConfirmationPopup(
      peopleBills: peopleBills, // Pass assigned people and their items
      items: items, // Pass all receipt items
      totalAmount: totalAmount, // Pass grand total
    ),
  );
}
