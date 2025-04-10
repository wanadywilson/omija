import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:octo_split/byAmount/summary_receipt_details_amount.dart';
import '../models.dart'; // Ensure this contains Receipt and Person classes

class ConfirmReceiptDetailsAmountScreen extends StatefulWidget {
  final Receipt receipt;
  

  ConfirmReceiptDetailsAmountScreen({required this.receipt});

  @override
  State<ConfirmReceiptDetailsAmountScreen> createState() => _ConfirmReceiptDetailsAmountScreenState();
}





class _ConfirmReceiptDetailsAmountScreenState extends State<ConfirmReceiptDetailsAmountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TextEditingController> _percentageControllers = [];
double _remainingPercentage = 100;

List<TextEditingController> _exactAmountControllers = [];
double _exactRemaining = 0;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);

  _percentageControllers = List.generate(
    widget.receipt.people.length,
    (index) => TextEditingController()..addListener(_updateRemainingPercentage),
  );

  _exactAmountControllers = List.generate(
    widget.receipt.people.length,
    (index) => TextEditingController()..addListener(_updateExactRemaining),
  );

  // 🧠 Set initial remaining to total grandTotal
  _exactRemaining = double.tryParse(widget.receipt.grandTotal.toString().replaceAll(',', '')) ?? 0;
}





@override
void dispose() {
  _tabController.dispose();
  for (var c in _percentageControllers) c.dispose();
  for (var c in _exactAmountControllers) c.dispose();
  super.dispose();
}


void _updateExactRemaining() {
  double total = double.tryParse(widget.receipt.grandTotal.toString().replaceAll(',', '')) ?? 0;
  double sum = 0;

  for (var controller in _exactAmountControllers) {
    final val = int.tryParse(controller.text.replaceAll(',', '')) ?? 0;
    sum += val;
  }

  setState(() {
    _exactRemaining = total - sum;
  });
}

Color getColorForPerson(int index) {
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


void _updateRemainingPercentage() {
  double total = 0;
  for (var controller in _percentageControllers) {
    final val = double.tryParse(controller.text) ?? 0;
    total += val;
  }

  setState(() {
    _remainingPercentage = (100 - total).clamp(-1000, 100); // clamp to prevent wild negatives
  });
}

String _format(double value) => NumberFormat("#,###").format(value);

  String _formatNumber(String input) {
    final raw = input.replaceAll(',', '');
    final value = double.tryParse(raw) ?? 0;
    return NumberFormat("#,###").format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split your bill", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
  controller: _tabController,
  indicatorColor: Colors.white,
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white30,

  labelStyle: TextStyle(fontWeight: FontWeight.bold),
  tabs: const [
    Tab(
      icon: Icon(Icons.percent, color: Colors.white),
      text: "Percentage",
    ),
    Tab(
      icon: Icon(Icons.format_list_numbered, color: Colors.white),
      text: "Equal",
    ),
    Tab(
      icon: Icon(Icons.money, color: Colors.white),
      text: "Exact",
    ),
  ],
),

      ),
      body: Column(
        children: [
          _buildReceiptHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPercentageTab(),
                _buildEqualAmountTab(),
                _buildExactAmountTab(),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(widget.receipt.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Text(widget.receipt.date, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
              Divider(height: 30),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount", style: TextStyle(fontSize: 14)),
                  Text("Rp${_formatNumber(widget.receipt.grandTotal.toString())}",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), // ⬅️ Increased bottom padding
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Color.fromARGB(255, 94, 19, 16)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Back", style: TextStyle(color: Color.fromARGB(255, 94, 19, 16))),
          ),
        ),
        ElevatedButton(
          onPressed: () {
  final selectedMethodIndex = _tabController.index;
  final selectedMethod = ["Percentage", "Equal", "Exact"][selectedMethodIndex];
  widget.receipt.method = selectedMethod;
  // ⬇️ Force equal amount calculation before navigating
  if (selectedMethod == "Equal") {
    double total = double.tryParse(widget.receipt.grandTotal.toString().replaceAll(',', '')) ?? 0;
    double perPerson = widget.receipt.people.isNotEmpty ? total / widget.receipt.people.length : 0;
    
    for (var person in widget.receipt.people) {
      person.amount = perPerson;
      person.percentage = 0;
    }
  }

  if (selectedMethod == "Exact") {
  for (int i = 0; i < widget.receipt.people.length; i++) {
    final controller = _exactAmountControllers[i];
    final val = controller.text.replaceAll(',', '');
    final parsed = double.tryParse(val);
    if (parsed != null) {
      widget.receipt.people[i].amount = parsed;
    }
  }

}


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SummaryReceiptDetailsAmountScreen(
        receipt: widget.receipt,
        splitMethod: selectedMethod,
      ),
    ),
  );
},

          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 94, 19, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Next", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildPercentageTab() {
  double totalAmount = double.tryParse(widget.receipt.grandTotal.toString().replaceAll(',', '')) ?? 0;

  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: widget.receipt.people.length,
          itemBuilder: (context, index) {
            final person = widget.receipt.people[index];
            final controller = _percentageControllers[index];

            double percent = double.tryParse(controller.text) ?? 0;
            double calculatedAmount = (percent / 100) * totalAmount;

            // Update the person object
            person.percentage = percent;
            person.amount = calculatedAmount;

            return ListTile(
              leading: CircleAvatar(backgroundColor: person.avatarColor, child: Text(person.name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
              title: Row(
  children: [
    Text(person.name),
    if (person.verified) ...[
      SizedBox(width: 6),
      Icon(Icons.check_circle, color: Colors.green, size: 18),
    ],
  ],
),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (person.phone.isNotEmpty) Text(person.phone),
                  Text("Rp${NumberFormat("#,###").format(calculatedAmount)}"),
                ],
              ),
              trailing: SizedBox(
                width: 80,
                child: TextField(
  controller: controller,
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
  ],
  decoration: InputDecoration(
    suffixText: "%",
    hintText: "0",
  ),
),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          "Remaining: ${_remainingPercentage.toStringAsFixed(2)}%",
          style: TextStyle(
            color: _remainingPercentage < 0 ? Colors.red : Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}



  Widget _buildEqualAmountTab() {
  double total = double.tryParse( widget.receipt.grandTotal.toString().replaceAll(',', '')) ?? 0;
  double perPerson =  widget.receipt.people.isNotEmpty ? total /  widget.receipt.people.length : 0;

  // ✅ Assign equal amount to each person
  for (var person in  widget.receipt.people) {
    person.amount = perPerson;
    person.percentage = 0; // Optional: set to 0 if splitMethod is Equal
  }

  return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: widget.receipt.people.length,
    itemBuilder: (context, index) {
      final person =  widget.receipt.people[index];
      return ListTile(
        leading: CircleAvatar(backgroundColor: person.avatarColor, child: Text(person.name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
        title: Row(
  children: [
    Text(person.name),
    if (person.verified) ...[
      SizedBox(width: 6),
      Icon(Icons.check_circle, color: Colors.green, size: 18),
    ],
  ],
),

        subtitle: person.phone.isNotEmpty ? Text(person.phone) : null,
        trailing: Text("Rp${_format(perPerson)}"),
      );
    },
  );
}


  Widget _buildExactAmountTab() {
  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: widget.receipt.people.length,
          itemBuilder: (context, index) {
            final person = widget.receipt.people[index];
            final controller = _exactAmountControllers[index];

            return ListTile(
              leading: CircleAvatar(backgroundColor: person.avatarColor, child: Text(person.name[0].toUpperCase(), style: TextStyle(color: Colors.white))),
              title: Row(
  children: [
    Text(person.name),
    if (person.verified) ...[
      SizedBox(width: 6),
      Icon(Icons.check_circle, color: Colors.green, size: 18),
    ],
  ],
),

              subtitle: Text(person.phone),
              trailing: SizedBox(
                width: 120,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "0"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (val) {
                    String raw = val.replaceAll(',', '');
                    int? parsed = int.tryParse(raw);
                    if (parsed != null) {
                      person.amount = parsed.toDouble();  // Store to person
                      final formatted = NumberFormat("#,###").format(parsed);
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                    _updateExactRemaining();
                  },
                ),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          "Remaining: Rp${NumberFormat("#,###").format(_exactRemaining)}",
          style: TextStyle(
            color: _exactRemaining == 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}


}
