import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'review_bill.dart';

class AssignPersonScreen extends StatefulWidget {
  final List<Map<String, String>> items;
  final double total;

  AssignPersonScreen({required this.items, required this.total});

  @override
  _AssignPersonScreenState createState() => _AssignPersonScreenState();
}

class _AssignPersonScreenState extends State<AssignPersonScreen> {
  List<Map<String, dynamic>> people = [];
  int? selectedPersonIndex;
  Map<String, List<int>> assignedItems = {};

  @override
  void initState() {
    super.initState();
    // Initialize with 'You' as a default person
    people.add({"name": "You", "phone": "", "selected": false});
  }

  void _showAddPersonDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tambah Orang"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Nomor Telepon (Opsional)"),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickContact,
                child: Text("Pilih dari Kontak"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    people.add({
                      "name": nameController.text,
                      "phone": phoneController.text,
                      "selected": false,
                    });
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        setState(() {
          people.add({
            "name": contact.displayName,
            "phone": contact.phones.isNotEmpty ? contact.phones.first.number : "",
            "selected": false,
          });
        });
      }
    }
  }

  void _assignItem(int itemIndex) {
    if (selectedPersonIndex == null) return;

    setState(() {
      String itemName = widget.items[itemIndex]['name'] ?? "";
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
        backgroundColor: Color.fromARGB(255,94,19,16),
        title: Text("Split your bill", style: TextStyle(color:Colors.white)),
        iconTheme: IconThemeData(
    color: Colors.white, // Change back arrow color here
  ),
      ),
      body: Column(
        children: [
          // People List at the Top
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showAddPersonDialog,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.add, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      Text("Tambah Orang", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // List of Added People
                ...List.generate(people.length, (index) {
                  return GestureDetector(
                    onTap: () => _selectPerson(index),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: selectedPersonIndex == index
                                ? Colors.blue
                                : Colors.grey[300],
                            child: Text(
                              people[index]["name"][0], // Placeholder avatar
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(people[index]["name"], style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                String itemName = widget.items[index]['name'] ?? "";
                double price =
                    double.tryParse(widget.items[index]['price']!.replaceAll(',', '')) ?? 0;
                int quantity = int.tryParse(widget.items[index]['quantity']!) ?? 1;
                double totalPrice = price * quantity;

                return GestureDetector(
                  onTap: () => _assignItem(index),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Rp${NumberFormat("#,###").format(price)}",
                                style: TextStyle(color: Colors.black54),
                              ),
                              Text("x$quantity"),
                              Text(
                                "Rp${NumberFormat("#,###").format(totalPrice)}",
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
                            children: assignedItems[itemName]?.map((personIndex) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 12,
                                      child: Text(
                                        people[personIndex]["name"][0],
                                        style: TextStyle(color: Colors.white, fontSize: 12),
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

          // Total Amount
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp${NumberFormat("#,###").format(widget.total)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
  List<Map<String, dynamic>> peopleBills = people.map((person) {
    List<Map<String, dynamic>> personItems = [];
    double personTotal = 0.0;

    // Loop through assigned items and assign them to the respective person
    assignedItems.forEach((itemName, assignedPeople) {
      if (assignedPeople.contains(people.indexOf(person))) {
        Map<String, String>? item = widget.items.firstWhere((element) => element["name"] == itemName);
        double price = double.tryParse(item?["price"]?.replaceAll(',', '') ?? "0") ?? 0;
        int quantity = int.tryParse(item?["quantity"] ?? "1") ?? 1;
        double itemTotal = price * quantity / assignedPeople.length; // Already calculated

        personItems.add({"name": itemName, "price": itemTotal});
      }
    });

   // Get total directly from the assigned list
personTotal = assignedItems.entries
  .where((entry) => entry.value.contains(people.indexOf(person)))
  .fold(0.0, (sum, entry) {
    // Ensure price is converted from String to double
    double price = double.tryParse(
      widget.items.firstWhere((item) => item["name"] == entry.key)["price"]
          ?.replaceAll(',', '') ?? "0"
    ) ?? 0.0;

    return sum + price;
  });

    return {
      "name": person["name"],
      "items": personItems,
      "total": personTotal, // Pass the already calculated total!
    };
  }).toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReviewBillScreen(peopleBills: peopleBills, items:widget.items),
    ),
  );
},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255,94,19,16),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
