import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart'; // or correct relative path
import '../qr_details.dart';
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

  @override
void initState() {
  _tabController = TabController(length: 3, vsync: this); // ⬅️ update to 3
  super.initState();
}


  @override
  Widget build(BuildContext context) {
    double grandTotal = widget.receipt.people.fold(0.0, (sum, p) => sum + p.amount);
    String transactionTime = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 94, 19, 16),
  elevation: 0,
  automaticallyImplyLeading: false, // disable default back button
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
      Text(
        "Close",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
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
      Tab(text: "Receipt"),
    ],
  ),
),


 body: Screenshot(
  controller: screenshotController,
  child: TabBarView(
    controller: _tabController,
    children: [
      _buildSummaryTab(transactionTime, grandTotal),
      _buildPeopleTab(),
      _buildReceiptTab(),
    ],
  ),
),


    );
  }


Future<void> _shareReceipt() async {
  try {
    // Capture the screenshot
    final imageBytes = await screenshotController.capture();

    // Save to temporary directory
    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/receipt_screenshot.png').create();
    await imagePath.writeAsBytes(imageBytes!);

    // Generate receipt summary text
    final buffer = StringBuffer();
    buffer.writeln("Split Bill with 🐙 OCTO Mobile by CIMB Niaga");
    buffer.writeln("📄 ${widget.receipt.title}");
    buffer.writeln("🗓️ ${widget.receipt.date}\n");

    for (final person in widget.receipt.people) {
      buffer.writeln("👤 ${person.name}: Rp${NumberFormat("#,###").format(person.amount)}");
    }

    // Share both image and text
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


Widget _buildReceiptTab() {
  final formatter = NumberFormat("#,###");

  return SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Container(
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
                widget.receipt.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.receipt.date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Divider(),

          // Item list
          ...widget.receipt.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Rp${formatter.format(item.singlePrice)}", style: TextStyle(color: Colors.grey)),
                      Text("x${item.quantity}"),
                      Text("Rp${formatter.format(item.totalPrice)}", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          }),

          Divider(),

          // Totals
          _buildDetailRow("Subtotal (items only)", "Rp${formatter.format(widget.receipt.subTotal)}"),
          _buildDetailRow("Service Charge (${widget.receipt.serviceChargePercentage.toStringAsFixed(2)}%)", "Rp${formatter.format(widget.receipt.serviceCharge)}"),
          _buildDetailRow("Tax (${widget.receipt.taxPercentage.toStringAsFixed(2)}%)", "Rp${formatter.format(widget.receipt.tax)}"),

          Divider(),

          _buildDetailRow("Grand Total", "Rp${formatter.format(widget.receipt.grandTotal)}", isBold: true),
        ],
      ),
    ),
  );
}

  Widget _buildSummaryTab(String transactionTime, double grandTotal) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(Icons.check_circle, color: Colors.green, size: 50)),
            SizedBox(height: 10),
            Center(child: Text("Successful!", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold))),
            Center(child: Text("Your transaction is successful", style: TextStyle(color: Colors.grey))),
            SizedBox(height: 20),
            Center(child: Image.asset("images/logo_omo.jpg", scale: 2)),
            SizedBox(height: 20),
            Center(child:Text("Split Bill by Items", style: TextStyle(fontWeight: FontWeight.bold))),
            Center(child: Text(widget.receipt.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            SizedBox(height: 20),

            _buildDetailRow("Receipt Date", widget.receipt.date),
            _buildDetailRow("Transaction Time", transactionTime),

            Divider(height: 30, color: Colors.grey),

            ...widget.receipt.people.map((p) => _buildDetailRow(
              p.name,
              "Rp${NumberFormat("#,###").format(p.amount)}",
            )),

            Divider(height: 30, color: Colors.grey),

            _buildDetailRow("Grand Total", "Rp${NumberFormat("#,###").format(grandTotal)}", isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: ListView.separated(
        itemCount: widget.receipt.people.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final person = widget.receipt.people[index];
          final formatter = NumberFormat("#,###");

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    CircleAvatar(
      backgroundColor: person.avatarColor,
      radius: 22,
      child: Text(
        person.name[0].toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
    ),
    SizedBox(width: 10),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Flexible(
      child: Row(
        children: [
          Flexible(
            child: Text(
              person.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (person.verified)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.check_circle, color: Colors.green, size: 18),
            ),
        ],
      ),
    ),
    if (person.phone != phoneNumber)
      IconButton(
        icon: Icon(Icons.qr_code, color: Colors.grey[700]),
        tooltip: "Show QR",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QRPersonDetailScreen(
                personName: person.name,
                amount: person.amount,
                receiptTitle: widget.receipt.title,
                receiptDate: widget.receipt.date,
                method: "Items",
                percentage: null,
              ),
            ),
          );
        },
      ),
  ],
),

          if (person.phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                person.phone,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    ),
  ],
),


                  SizedBox(height: 10),

                  ...person.items.map((item) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 2),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: Colors.black87),
        ),
      ),
      SizedBox(width: 10),
      Text("Rp${formatter.format(item.totalPrice)}"),
    ],
  ),
)),

                  Divider(),
                  _buildDetailRow("Tax", "Rp${formatter.format(person.tax)}"),
                  _buildDetailRow("Service Charge", "Rp${formatter.format(person.serviceCharge)}"),
                  Divider(),
                  _buildDetailRow("Total", "Rp${formatter.format(person.amount)}", isBold: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
