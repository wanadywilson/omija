import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'final_summary.dart';

class AssignPersonByItemsManualScreen extends StatefulWidget {
  final Receipt receipt;

  AssignPersonByItemsManualScreen({required this.receipt});

  @override
  _AssignPersonByItemsManualScreenState createState() =>
      _AssignPersonByItemsManualScreenState();
}

class _AssignPersonByItemsManualScreenState
    extends State<AssignPersonByItemsManualScreen> {
  int? selectedPersonIndex;
  Map<String, List<int>> assignedItems = {};

  void _assignItem(int itemIndex) {
    if (selectedPersonIndex == null) return;

    setState(() {
      String itemName = widget.receipt.items[itemIndex].name;
      assignedItems[itemName] ??= [];

      if (!assignedItems[itemName]!.contains(selectedPersonIndex)) {
        assignedItems[itemName]!.add(selectedPersonIndex!);
      } else {
        assignedItems[itemName]!.remove(selectedPersonIndex);
      }
    });
  }

  void _selectPerson(int index) {
    setState(() {
      selectedPersonIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split your bill", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: List.generate(widget.receipt.people.length, (index) {
                final person = widget.receipt.people[index];
                return GestureDetector(
                  onTap: () => _selectPerson(index),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: selectedPersonIndex == index
                              ? person.avatarColor
                              : Colors.grey[300],
                          child: Text(
                            person.name[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(person.name, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.receipt.items.length,
              itemBuilder: (context, index) {
                final item = widget.receipt.items[index];

                return GestureDetector(
                  onTap: () => _assignItem(index),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (selectedPersonIndex != null)
                                Icon(
                                  assignedItems[item.name]?.contains(selectedPersonIndex) == true
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: assignedItems[item.name]?.contains(selectedPersonIndex) == true
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                            ],
                          ),

                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rp${NumberFormat("#,###").format(item.singlePrice)}",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text("x${item.quantity}"),
                              Text(
                                "Rp${NumberFormat("#,###").format(item.totalPrice)}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Assigned to:",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Row(
                            children: assignedItems[item.name]
                                    ?.map((personIndex) {
                                  final p = widget.receipt.people[personIndex];
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: CircleAvatar(
                                      backgroundColor: p.avatarColor,
                                      radius: 12,
                                      child: Text(
                                        p.name[0].toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add side padding here
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
  // Clear previous assignments
  for (var person in widget.receipt.people) {
    person.items = [];
    person.amount = 0;
    person.tax = 0;
    person.serviceCharge = 0;
  }

  Map<int, double> personSubtotals = {};

  // Assign items and calculate subtotal per person
  for (var item in widget.receipt.items) {
    final assignees = assignedItems[item.name] ?? [];
    if (assignees.isEmpty) continue;

    final share = item.totalPrice / assignees.length;

    for (var index in assignees) {
      final person = widget.receipt.people[index];
      final itemShare = Item(
        name: item.name,
        singlePrice: item.singlePrice,
        quantity: item.quantity,
        totalPrice: share,
      );
      person.items.add(itemShare);

      personSubtotals[index] = (personSubtotals[index] ?? 0) + share;
    }
  }

  final taxPercentage = widget.receipt.taxPercentage;
  final serviceChargePercentage = widget.receipt.serviceChargePercentage;

  for (int i = 0; i < widget.receipt.people.length; i++) {
    final person = widget.receipt.people[i];
    final subtotal = personSubtotals[i] ?? 0;

    final tax = subtotal * (taxPercentage / 100);
    final serviceCharge = subtotal * (serviceChargePercentage / 100);

    person.tax = tax;
    person.serviceCharge = serviceCharge;
    person.amount = subtotal + tax + serviceCharge;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SplitSummaryScreen(receipt: widget.receipt),
    ),
  );
},



      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  ),
),

          SizedBox(height: 35),
        ],
      ),
    );
  }
}


