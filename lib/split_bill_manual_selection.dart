import 'package:flutter/material.dart';
import 'package:octo_split/byAmount/enter_receipt_details_amount.dart';

import 'byItems/edit_receipt_details.dart';
import 'models.dart';
import '../globals.dart';

class SplitBillSelectionScreen extends StatelessWidget {


  // Constructor to receive the values
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Split Bill", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "How would you like to split your bill?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Button: By Amount (No need to pass receipt details here)
            _buildOptionCard(
              context,
              title: "By Amount",
              description: "Quick and easy split with percentage, equal, or exact amount",
              icon: Icons.attach_money,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnterReceiptDetailsAmountScreen()),
                );
              },
            ),

            SizedBox(height: 15),

            // Button: By Items (Passing receipt details)
            _buildOptionCard(
              context,
              title: "By Items",
              description: "Assign items to each person",
              icon: Icons.shopping_basket,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditReceiptDetailsScreen(initialReceipt: Receipt(
                      title: "",
                      date: "",
                      grandTotal: 0,
                      serviceCharge: 0,
                      serviceChargePercentage: 0,
                      tax: 0,
                      taxPercentage: 0,
                      subTotal: 0,
                      people: [Person(name: longName, phone: phoneNumber, verified: true)]
                      
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to create styled option cards
  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.red, size: 28),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder Screen for Amount Split (No need to pass receipt details)
class AmountSplitScreen extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Split by Amount")),
      body: Center(child: Text("Split by Amount Screen")),
    );
  }
}
