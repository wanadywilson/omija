import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'summary_transfer.dart';
import 'package:intl/intl.dart'; // For number formatting

class TransferMoney extends StatefulWidget {
  final String? prefillPhone;
  final String? prefillAmount;
  final String? prefillMessage;

  TransferMoney({
    this.prefillPhone,
    this.prefillAmount,
    this.prefillMessage,
  });

  @override
  _TransferMoneyState createState() => _TransferMoneyState();
}


class _TransferMoneyState extends State<TransferMoney> {
  bool isScheduled = false;
  bool isButtonEnabled = false;

  // Controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
@override
void initState() {
  super.initState();

  if (widget.prefillPhone != null) {
    phoneController.text = widget.prefillPhone!;
  }
  if (widget.prefillAmount != null) {
    amountController.text = _formatAmount(widget.prefillAmount!);
  }
  if (widget.prefillMessage != null) {
    messageController.text = widget.prefillMessage!;
  }

  phoneController.addListener(_checkInput);
  amountController.addListener(_checkInput);

  // ✅ Check immediately after setting controllers
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkInput();
  });
}



  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    messageController.dispose();
    super.dispose();
  }

  // Function to check if required fields are filled
  void _checkInput() {
    setState(() {
      isButtonEnabled = phoneController.text.trim().isNotEmpty &&
          amountController.text.trim().isNotEmpty;
    });
  }

  // Format number with commas
  String _formatAmount(String value) {
    if (value.isEmpty) return "";
    final formatter = NumberFormat("#,###");
    return formatter.format(int.tryParse(value.replaceAll(",", "")) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Other OCTO Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
          children: [
            SizedBox(height: 20),
            _sectionTitle("Transfer from"),
            SizedBox(height: 20),
            _transferFromCard(),
            SizedBox(height: 20),

            // Transfer To
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("Transfer to"),
                Text(
                  "Select from contact list",
                  style: TextStyle(color: Color.fromARGB(255, 94, 19, 16)),
                ),
              ],
            ),

            // Phone Number Input (Only Numbers)
            _inputField(
              "Phone Number", 
              "Type or select phone number", 
              Icons.favorite_border, 
              controller: phoneController, 
              isNumeric: true
            ),
            SizedBox(height: 15),

            // Transfer Amount Input (Only Numbers + Comma Formatting)
            _inputField(
              "Transfer Amount", 
              "Enter amount", 
              Icons.calculate, 
              prefix: "IDR", 
              controller: amountController, 
              isNumeric: true, 
              formatAmount: true
            ),
            SizedBox(height: 15),

            // Message (Text Allowed)
            _inputField(
              "Message (optional)", 
              "Enter message", 
              null, 
              controller: messageController, 
              isNumeric: false
            ),
            SizedBox(height: 15),

            _scheduleToggle(),
            SizedBox(height: 30),

            // Continue Button
            _continueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('images/account.jpg', scale: 1),
            SizedBox(width: 10),
            Text(
              "OCTO Savers (••••5891)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]), // ⬇️ New Icon
      ],
    ),
  );
}


  Widget _inputField(String label, String hint, IconData? icon, {String? prefix, required TextEditingController controller, bool isNumeric = false, bool formatAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(label),
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
              if (prefix != null)
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text(prefix, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                  inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
                  onChanged: (text) {
                    _checkInput();
                    if (formatAmount) {
                      String formatted = _formatAmount(text);
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: Color.fromARGB(255, 94, 19, 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Set schedule for this transaction"),
        Switch(
          value: isScheduled,
          onChanged: (value) {
            setState(() {
              isScheduled = value;
            });
          },
          activeColor: Color.fromARGB(255, 94, 19, 16),
        ),
      ],
    );
  }

  Widget _continueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isButtonEnabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      phoneNumber: phoneController.text.trim(),
                      amount: amountController.text.trim(),
                      message: messageController.text.trim(),
                    ),
                  ),
                );
              }
            : null, // Disable button if inputs are empty
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Color.fromARGB(255, 94, 19, 16) : Colors.grey,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
