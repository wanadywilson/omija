import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'globals.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class QRPersonDetailScreen extends StatelessWidget {
  final String personName;
  final double amount;
  final String receiptTitle;
  final String receiptDate;
  final double? percentage;
  final String method;

  QRPersonDetailScreen({
    required this.personName,
    required this.amount,
    required this.receiptTitle,
    required this.receiptDate,
    required this.method,
    this.percentage,
  });

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Generate QRIS", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final formattedAmount = NumberFormat("#,###").format(amount);
              final buffer = StringBuffer();
              buffer.writeln("Split Bill with 🐙 OCTO Mobile by CIMB Niaga");
              buffer.writeln("Here's your QRIS for $receiptTitle - Rp $formattedAmount ");
              buffer.writeln("Download OCTO Mobile now to enjoy multiple cashback and easily split your bill! https://play.google.com/store/apps/details?id=id.co.cimbniaga.mobile.android&hl=id");

              try {
                final Uint8List? image = await screenshotController.capture();
                if (image != null) {
                  final directory = await getTemporaryDirectory();
                  final imagePath = File('${directory.path}/qris_share.png');
                  await imagePath.writeAsBytes(image);

                  await Share.shareXFiles(
                    [XFile(imagePath.path)],
                    text: buffer.toString(),
                  );
                }
              } catch (e) {
                print("Screenshot error: $e");
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset("images/logo_omo.jpg", scale: 2)),
                SizedBox(height: 10),

                Center(
                  child: Text(
                    "Split Bill by $method",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                SizedBox(height: 12),
                Center(
                  child: Text(
                    receiptTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                SizedBox(height: 20),
                _rowText("Receipt Date", receiptDate),

                Divider(height: 30, color: Colors.black),
                Center(child: Image.asset("images/qris.png", scale: 3)),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Transfer from:", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                          personName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Transfer To:", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                          longName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Center(
                  child: Text(
                    "Rp${NumberFormat("#,###").format(amount)}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                if (percentage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Center(
                      child: Text(
                        "${percentage!.toStringAsFixed(2)}%",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),

                SizedBox(height: 16),
                Center(child: Image.asset("images/qris_dummy.png", scale: 4.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowText(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(left, style: TextStyle(fontSize: 16))),
          Text(right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
