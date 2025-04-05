import 'package:flutter/material.dart';
import 'show_pin_transfer.dart';

class SummaryScreen extends StatelessWidget {
  final String phoneNumber;
  final String amount;
  final String message;

  // Constructor to receive data
  SummaryScreen({required this.phoneNumber, required this.amount, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        centerTitle: true,
        title: Text("Summary", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // Amount Card
            _amountCard(amount, "Jennifer Santoso", phoneNumber),
            SizedBox(height: 30),

            // Transfer From Section
            _sectionTitle("Transfer from"),
            SizedBox(height:10),
            _transferFromCard(),

            SizedBox(height: 25),

            // Transfer Details Section
            _sectionTitle("Transfer Details"),
            SizedBox(height:10),
            _transferDetailsCard("OCTO Pay", message),

            Spacer(), // Pushes "Continue" button to the bottom

            _continueButton(context),
          ],
        ),
      ),
    );
  }

 Widget _amountCard(String amount, String recipientName, String recipientPhone) {
  return SizedBox(
    width: double.infinity, // Ensures full width
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center text
        children: [
          // "AMOUNT" Title
          Text(
            "AMOUNT",
            style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),

          // "IDR" and Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "IDR ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                amount.split('.')[0], // Main amount
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              
            ],
          ),

          SizedBox(height: 15),

          // Transfer to Section
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transfer to",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  recipientName,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  recipientPhone,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}




  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

 Widget _transferDetailsCard(String transferType, String message) {
  return SizedBox(
    width: double.infinity, // Ensures full width
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer Type
          Text(
            "Transfer Type",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            transferType,
            style: TextStyle(fontSize: 16),
          ),

          // Show Message section only if there is a message
          if (message.isNotEmpty) ...[
            SizedBox(height:15),
            Text(
              "Message",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    ),
  );
}



  Widget _transferFromCard() {
  return Container(
    height: 80,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
    ),
    child: Row(
      children: [
        // Account Icon
        Image.asset('images/account.jpg', scale: 1),
        SizedBox(width: 10),

        // Account Name
        Text(
          "OCTO Savers (••••5891)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}


  Widget _continueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showPinConfirmationPopup(context, amount, phoneNumber,message);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 94, 19, 16),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

void _showPinConfirmationPopup(BuildContext context, String amount, String phoneNumber, String message) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (BuildContext ctx) {
      return PinConfirmationPopup(
        amount: amount,
        phoneNumber: phoneNumber,
        message: message,
      );
    },
  );
}

