import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:intl/intl.dart';
import 'split_bill_method.dart'; // Your next screen
import '../models.dart'; // Import the Person and Receipt class
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import '../globals.dart';

class EnterReceiptDetailsAmountScreen extends StatefulWidget {
  @override
  _EnterReceiptDetailsAmountScreenState createState() => _EnterReceiptDetailsAmountScreenState();
}

class _EnterReceiptDetailsAmountScreenState extends State<EnterReceiptDetailsAmountScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool isButtonEnabled = false;
  String? matchedUsername;

  List<Person> _people = []; // Default user

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkInput);
    _dateController.addListener(_checkInput);
    _amountController.addListener(_formatAndCheckAmount);

    _people.add(Person(
    name: longName,
    phone: phoneNumber,
    verified: true,
    avatarColor: _getColorForPerson(0),
  ));

  }

  void _checkInput() {
    setState(() {
      isButtonEnabled = _titleController.text.trim().isNotEmpty &&
          _dateController.text.trim().isNotEmpty &&
          _amountController.text.trim().isNotEmpty;
    });
  }


  void _formatAndCheckAmount() {
    String raw = _amountController.text.replaceAll(',', '');
    double? value = double.tryParse(raw);
    if (value != null) {
      String formatted = NumberFormat("#,###").format(value);
      if (_amountController.text != formatted) {
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    _checkInput();
  }

  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

Future<void> _pickContactAndFill(TextEditingController nameController, TextEditingController phoneController) async {
  try {
    final Contact? contact = await _contactPicker.selectContact();
    if (contact != null) {
      nameController.text = contact.fullName ?? '';
      phoneController.text = contact.phoneNumbers?.isNotEmpty == true
          ? contact.phoneNumbers!.first
          : '';
    }
  } catch (e) {
    print("Contact picking failed: $e");
  }
}



  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _dateController.text = DateFormat('dd MMM yyyy').format(pickedDate);
      _checkInput();
    }
  }

 void _addPersonDialog() {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isVerified = false;

  void _checkVerification() {
    final match = knownUsers.firstWhere(
      (user) => user['phone_number'] == phoneController.text.trim(),
      orElse: () => {},
    );

  if (match.isNotEmpty) {
    nameController.text = match['long_name'];
    matchedUsername = match['username'];
    isVerified = true;
  } else {
    isVerified = false;
  }

    setState(() {}); // trigger rebuild to show tick
  }

  showDialog(
    context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Person", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 10),

              TextField(
                controller: phoneController,
                onChanged: (_) {
                  _checkVerification();
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Phone Number (optional)",
                  suffixIcon: isVerified
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 15),

              OutlinedButton.icon(
                onPressed: () => _pickContactAndFill(nameController, phoneController),
                icon: Icon(Icons.contact_page, color: Color.fromARGB(255, 94, 19, 16)),
                label: Text("Select from Contacts",
                    style: TextStyle(color: Color.fromARGB(255, 94, 19, 16))),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color.fromARGB(255, 94, 19, 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
  if (nameController.text.trim().isNotEmpty) {
    setState(() {
      _people.add(Person(
  name: nameController.text.trim(),
  phone: phoneController.text.trim(),
  verified: isVerified,
  avatarColor: _getColorForPerson(_people.length),
  username: matchedUsername,
));

    });
    Navigator.pop(context);
  }
},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 94, 19, 16),
                    ),
                    child: Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
  
  );
}


Color _getColorForPerson(int index) {
  const colors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
    Colors.deepOrange,
  ];
  return colors[index % colors.length];
}



 


  Widget _inputField(
    String label,
    String hint,
    TextEditingController controller,
    bool isNumeric, {
    bool isReadOnly = false,
    bool showIcon = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                  readOnly: isReadOnly,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                  ),
                ),
              ),
              if (showIcon)
                Icon(Icons.calendar_today, color: Color.fromARGB(255, 94, 19, 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("People", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              // Header with Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add your friends here."),
                  OutlinedButton.icon(
                    icon: Icon(Icons.add, color: Colors.red),
                    label: Text("Add Person", style: TextStyle(color: Colors.red)),
                    onPressed: _addPersonDialog,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ..._people.asMap().entries.map((entry) {
                final index = entry.key;
                final person = entry.value;

                return ListTile(
  contentPadding: EdgeInsets.zero,
 leading: CircleAvatar(
  backgroundColor: person.avatarColor = _getColorForPerson(index),
  child: Text(
    person.name[0].toUpperCase(),
    style: TextStyle(color: Colors.white),
  ),
),

  title: Row(
    children: [
      Text("${index + 1}. ${person.name}"),
      if (person.verified) ...[
        SizedBox(width: 6),
        Icon(Icons.check_circle, color: Colors.green, size: 18),
      ],
    ],
  ),
  subtitle: person.phone.isNotEmpty ? Text(person.phone) : null,
  trailing: index == 0
      ? null
      : IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _people.removeAt(index);
            });
          },
        ),
);

              }).toList(),
            ],
          ),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Receipt Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _inputField("Receipt Title", "Enter receipt title", _titleController, false, showIcon: false),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: _inputField("Receipt Date", "Select receipt date", _dateController, false, isReadOnly: true),
                      ),
                    ),
                    SizedBox(height: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Amount", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  readOnly: false,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter total amount",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),
                    _buildPeopleSection(),
                  ],
                ),
              ),
            ),
           Padding(
  padding: const EdgeInsets.only(bottom: 30), // adds space above bottom nav
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isButtonEnabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmReceiptDetailsAmountScreen(
                    receipt: Receipt(
                      transactionTime: "",
                      title: _titleController.text.trim(),
                      date: _dateController.text.trim(),
                      grandTotal: double.parse(_amountController.text.trim().replaceAll(',', '')),
                      people: _people,
                      serviceCharge: 0,
                      serviceChargePercentage: 0,
                      tax: 0,
                      taxPercentage: 0,
                      subTotal: 0,
                      method: "",
                    ),
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonEnabled ? Color.fromARGB(255, 94, 19, 16) : Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
