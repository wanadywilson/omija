import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'show_pin.dart';


class SplitSummaryScreen extends StatelessWidget {
  final Receipt receipt;

  const SplitSummaryScreen({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Final Review", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text(
      receipt.title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 4),
    Text(
      receipt.date,
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    ),
    SizedBox(height: 16),
  ],
),


            // Scrollable people and summary cards
            Expanded(
              child: ListView(
                children: [
                  ...receipt.people.map((person) => _buildPersonCard(person)),
                  SizedBox(height: 10),
                  _buildSummaryCard(receipt),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: PinConfirmationPop(receipt: receipt),
    ),
  );
},

            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 94, 19, 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Send Split Bill", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

 Widget _buildPersonCard(Person person) {
  final formatter = NumberFormat("#,###");
  final List<Item> items = person.items ?? [];

  return Card(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Person Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(person.name[0].toUpperCase(), style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 10),
              Text(person.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),

          // Item List
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.name),
                Text("Rp${formatter.format(item.totalPrice)}"),
              ],
            ),
          )),

          Divider(),

          // Breakdown
          _breakdownRow("Subtotal", items.fold(0.0, (sum, item) => sum + item.totalPrice), formatter),
          _breakdownRow("Service Charge", person.serviceCharge, formatter),
          _breakdownRow("Tax", person.tax, formatter),

          Divider(),

          // Final Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Rp${formatter.format(person.amount)}", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _breakdownRow(String label, double value, NumberFormat formatter) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text("Rp${formatter.format(value)}"),
      ],
    ),
  );
}


  Widget _buildSummaryCard(Receipt receipt) {
    final formatter = NumberFormat("#,###");

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            ...receipt.people.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.name),
                  Text("Rp${formatter.format(p.amount)}"),
                ],
              ),
            )),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Rp${formatter.format(receipt.grandTotal)}", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
