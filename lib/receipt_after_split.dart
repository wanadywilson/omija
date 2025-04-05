import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SplitBillReceiptScreen extends StatefulWidget {
  final List<Map<String, dynamic>> peopleBills;
  final List<Map<String, String>> items;
  final double total;

  SplitBillReceiptScreen({
    required this.peopleBills,
    required this.items,
    required this.total,
  });

  @override
  _SplitBillReceiptScreenState createState() => _SplitBillReceiptScreenState();
}

class _SplitBillReceiptScreenState extends State<SplitBillReceiptScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 📸 Capture & Share Screenshot of First Tab
  Future<void> _shareReceipt() async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/receipt_summary.png');

      _screenshotController.capture().then((imageBytes) async {
        if (imageBytes != null) {
          await imagePath.writeAsBytes(imageBytes);
          await Share.shareXFiles([XFile(imagePath.path)], text: "Here's the split bill summary.");
        }
      });
    } catch (e) {
      print("Error sharing screenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Transaction Receipt"),
        backgroundColor: Colors.red.shade900,
        leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      Navigator.popUntil(context, ModalRoute.withName('/home')); 
    },
  ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareReceipt, // Calls function to share screenshot
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Summary"),
            Tab(text: "Full Receipt"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Screenshot(
            controller: _screenshotController,
            child: _buildSummaryTab(),
          ),
          _buildReceiptTab(),
        ],
      ),
    );
  }

  /// ✅ **Success Message & Summary of Split Bill**
  Widget _buildSummaryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ✅ Success Message
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 70),
                SizedBox(height: 10),
                Text(
                  "Successful!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  "Your split bill is successful",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // ✅ Summary Section
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
                  ...widget.peopleBills.map((person) {
                    double personTotal = (person["items"] as List<Map<String, dynamic>>)
                        .fold(0.0, (sum, item) => sum + (double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0));
                    return _summaryRow(person["name"], personTotal);
                  }).toList(),
                  Divider(),
                  _summaryRow("Grand Total", widget.total, isBold: true),
                ],
              ),
            ),
          ),

          // ✅ List of people and their payments
          Expanded(
            child: ListView.builder(
              itemCount: widget.peopleBills.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> person = widget.peopleBills[index];
                double personTotal = (person["items"] as List<Map<String, dynamic>>)
                    .fold(0.0, (sum, item) => sum + (double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0));

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                person["name"][0], // First letter of name
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
                        Column(
                          children: (person["items"] as List<Map<String, dynamic>>)
                              .map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item["name"], style: TextStyle(fontSize: 14)),
                                        Text(
                                          "Rp${NumberFormat("#,###").format(double.tryParse(item["price"].toString().replaceAll(',', '')) ?? 0.0)}",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Dibayar", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(
                              "Rp${NumberFormat("#,###").format(personTotal)}",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

  /// ✅ **Full Receipt Tab**
  Widget _buildReceiptTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: widget.items.map((item) {
                  double price = double.tryParse(item['price']!.replaceAll(',', '')) ?? 0;
                  int quantity = int.tryParse(item['quantity']!) ?? 1;
                  double itemTotal = price * quantity;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name']!),
                        Text("x$quantity"),
                        Text("Rp${NumberFormat("#,###").format(itemTotal)}"),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
