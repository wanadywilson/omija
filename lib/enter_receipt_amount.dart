import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnterReceiptAmountScreen extends StatefulWidget {
  final String receiptTitle;
  final String receiptDate;

  EnterReceiptAmountScreen({
    required this.receiptTitle,
    required this.receiptDate,
  });

  @override
  _EnterReceiptAmountScreenState createState() => _EnterReceiptAmountScreenState();
}

class _EnterReceiptAmountScreenState extends State<EnterReceiptAmountScreen> {
  TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Receipt Amount"),
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Receipt Title
            Text("Receipt Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(widget.receiptTitle, style: TextStyle(fontSize: 16)),

            SizedBox(height: 16),

            // ✅ Receipt Date
            Text("Receipt Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(widget.receiptDate, style: TextStyle(fontSize: 16)),

            SizedBox(height: 30),

            // ✅ Amount Input
            Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  Text("Rp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                        final formatted = NumberFormat("#,###").format(int.tryParse(digitsOnly) ?? 0);
                        amountController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String finalAmount = amountController.text.replaceAll(',', '');
                  print("Amount: $finalAmount");
                  // You can navigate or pass data forward here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 94, 19, 16),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
