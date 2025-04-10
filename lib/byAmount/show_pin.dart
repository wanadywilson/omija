import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octo_split/globals.dart';
import '../models.dart';
import 'success_receipt_details_amount.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class PinConfirmationPop extends StatefulWidget {
  final Receipt receipt;

  const PinConfirmationPop({required this.receipt});

  @override
  _PinConfirmationPopupState createState() => _PinConfirmationPopupState();
}

class _PinConfirmationPopupState extends State<PinConfirmationPop> {
  List<String> enteredPin = ["", ""]; // Stores only the 1st and 6th digits
  int pinIndex = 0;
  

  void _addDigit(String digit) {
  widget.receipt.transactionTime = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    if (pinIndex < 2) {
      setState(() {
        enteredPin[pinIndex] = digit;
        pinIndex++;
      });
    }
  }

  void _removeDigit() {
    if (pinIndex > 0) {
      setState(() {
        pinIndex--;
        enteredPin[pinIndex] = "";
      });
    }
  }

  Map<String, dynamic> receiptToJson(Receipt receipt) {
  return {
    "title": receipt.title,
    "date": receipt.date,
    "creator": username,
    "transactionTime": receipt.transactionTime,
    "grandTotal": receipt.grandTotal,
    "subTotal": receipt.subTotal,
    "serviceCharge": receipt.serviceCharge,
    "tax": receipt.tax,
    "serviceChargePercentage": receipt.serviceChargePercentage,
    "taxPercentage": receipt.taxPercentage,
    "method": receipt.method,
    "people": receipt.people.map((p) => {
      "name": p.name,
      "phone": p.phone,
      "amount": p.amount,
      "username":p.username,
      "percentage": p.percentage,
      "tax": p.tax,
      "serviceCharge": p.serviceCharge,
      "items": p.items.map((item) => {
        "name": item.name,
        "quantity": item.quantity,
        "singlePrice": item.singlePrice,
        "totalPrice": item.totalPrice,
      }).toList()
    }).toList(),
    "items": receipt.items.map((item) => {
      "name": item.name,
      "quantity": item.quantity,
      "singlePrice": item.singlePrice,
      "totalPrice": item.totalPrice,
    }).toList(),
  };
}


  void _confirmPin() async {
  // Convert receipt to JSON
  final receiptJson = receiptToJson(widget.receipt);

  try {
    final response = await http.post(
      Uri.parse(urlKirimReceipt), // 🔁 Replace with real URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(receiptJson),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context); // Close the popup

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessReceiptScreen(receipt: widget.receipt),
        ),
      );
    } else {
      throw Exception("Failed to send receipt: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error sending receipt: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Close Button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.close, color: Color.fromARGB(255, 94, 19, 16)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            "Ready to confirm your transaction?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Enter the 1st and 6th digit of your PIN",
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              bool isFirstOrLast = index == 0 || index == 5;
              int pinPos = index == 0 ? 0 : (index == 5 ? 1 : -1);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isFirstOrLast
                        ? Border.all(
                            color: Color.fromARGB(255, 94, 19, 16),
                            width: 2,
                          )
                        : null,
                    color: pinPos != -1 && enteredPin[pinPos] != ""
                        ? Color.fromARGB(255, 94, 19, 16)
                        : Colors.grey[300],
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 25),

          // Numpad
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.85,
              ),
              itemBuilder: (context, index) {
                if (index == 9) return SizedBox();
                if (index == 11) {
                  return IconButton(
                    icon: Icon(Icons.backspace, size: 28),
                    onPressed: _removeDigit,
                  );
                }

                String digit = index == 10 ? "0" : (index + 1).toString();
                return GestureDetector(
                  onTap: () => _addDigit(digit),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(8),
                    child: Text(
                      digit,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (enteredPin[0].isNotEmpty && enteredPin[1].isNotEmpty)
                  ? _confirmPin
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 94, 19, 16),
                padding: EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Confirm", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}