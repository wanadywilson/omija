import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../Qr_details.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../main.dart'; // for `cameras` and HomeScreen
import '../globals.dart';


ScreenshotController screenshotController = ScreenshotController();



class SuccessReceiptScreen extends StatefulWidget {
  final Receipt receipt;

  SuccessReceiptScreen({required this.receipt});

  @override
  State<SuccessReceiptScreen> createState() => _SuccessReceiptScreenState();
}




class _SuccessReceiptScreenState extends State<SuccessReceiptScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<void> _shareReceipt() async {
  try {
    final imageBytes = await screenshotController.capture();
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/receipt_summary.png').create();
    await imagePath.writeAsBytes(imageBytes!);

    final buffer = StringBuffer();
    buffer.writeln("Split Bill with 🐙 OCTO Mobile by CIMB Niaga");
    buffer.writeln("📄 ${widget.receipt.title}");
    buffer.writeln("🗓️ ${widget.receipt.date}\n");

    for (final person in widget.receipt.people) {
      buffer.writeln("👤 ${person.name}: Rp${NumberFormat("#,###").format(person.amount)}");
    }

    await Share.shareXFiles(
      [XFile(imagePath.path)],
      text: buffer.toString(),
      subject: "Receipt Summary",
    );
  } catch (e) {
    print("❌ Share failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to share receipt.")),
    );
  }
}


  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double grandTotal = widget.receipt.people.fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94,19,16),
      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 94, 19, 16),
  elevation: 0,
  automaticallyImplyLeading: false, // hide default back
  title: Row(
    children: [
      IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(cameras: cameras)),
            (route) => false,
          );
        },
      ),
      Text("Close", style: TextStyle(color: Colors.white, fontSize: 15)),
    ],
  ),
  actions: [
    TextButton.icon(
      onPressed: _shareReceipt,
      icon: Icon(Icons.share, color: Colors.white),
      label: Text("Share", style: TextStyle(color: Colors.white)),
    ),
  ],
  bottom: TabBar(
    controller: _tabController,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white60,
    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
    indicatorColor: Colors.white,
    tabs: const [
      Tab(text: "Summary"),
      Tab(text: "People"),
    ],
  ),
),

      body: Screenshot(
  controller: screenshotController,
  child: TabBarView(
    controller: _tabController,
    children: [
      _buildSuccessSummary(widget.receipt.transactionTime, grandTotal),
      _buildPeopleTab(),
    ],
  ),
),


    );
  }

  Widget _buildSuccessSummary(String transactionTime, double grandTotal) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            SizedBox(height: 10),
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Successful!", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Your transaction is successful", style: TextStyle(color: Colors.grey)),

            SizedBox(height: 20),
            Image.asset("images/logo_omo.jpg", scale: 2), // Replace with your logo path

            SizedBox(height: 20),
            Text("Split Bill by ${widget.receipt.method}", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.receipt.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            _buildDetailRow("Receipt Date", widget.receipt.date),
            _buildDetailRow("Transaction Time", widget.receipt.transactionTime),

            Divider(height: 30, color: Colors.grey),

            // People and their amounts
            ...widget.receipt.people.map((p) => _buildDetailRow(
              p.name,
              "Rp${NumberFormat("#,###").format(p.amount)}",
              subtitle: widget.receipt.method == "Percentage" ? "${p.percentage.toStringAsFixed(2)}%" : null,
            )),

            Divider(height: 30, color: Colors.grey),

            _buildDetailRow(
              "Grand Total",
              "Rp${NumberFormat("#,###").format(grandTotal)}",
              isBold: true,
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTab() {
  return Container(
    color: Colors.white,
    padding: EdgeInsets.all(20),
    child: ListView.separated(
      itemCount: widget.receipt.people.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final person = widget.receipt.people[index];
        final isCurrentUser = person.phone == phoneNumber;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: person.avatarColor,
                  child: Text(person.name[0].toUpperCase(), style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              person.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (person.verified) ...[
                            SizedBox(width: 6),
                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                          ],
                        ],
                      ),
                      if (person.phone.isNotEmpty)
                        Text(
                          person.phone,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                    ],
                  ),
                ),
                Text(
                  "Rp${NumberFormat("#,###").format(person.amount)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!isCurrentUser)
                  IconButton(
                    icon: Icon(Icons.qr_code, color: Colors.grey.shade800),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRPersonDetailScreen(
                            method: widget.receipt.method,
                            receiptDate: widget.receipt.date,
                            personName: person.name,
                            amount: person.amount,
                            receiptTitle: widget.receipt.title,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildDetailRow(String label, String value, {String? subtitle, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
              if (subtitle != null)
                Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
