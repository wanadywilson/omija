import 'package:flutter/material.dart';
import 'receipt_after_split.dart';

class PinConfirmationPopup extends StatefulWidget {
  final List<Map<String, dynamic>> peopleBills;
  final List<Map<String, String>> items;
  final double totalAmount;

  PinConfirmationPopup({
    required this.peopleBills,
    required this.items,
    required this.totalAmount,
  });


  @override
  _PinConfirmationPopupState createState() => _PinConfirmationPopupState();
}

class _PinConfirmationPopupState extends State<PinConfirmationPopup> {
  List<String> enteredPin = ["", ""]; // Stores 2 required PIN digits
  int pinIndex = 0; // Tracks which digit is being entered

  void _addDigit(String digit) {
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

  void _confirmPin() {
  print("Entered PIN Digits: ${enteredPin.join(", ")}");
  
  // Navigate to SplitBillReceiptScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SplitBillReceiptScreen(
        peopleBills: widget.peopleBills, // List of people and their assigned items
        items: widget.items, // Full list of receipt items
        total: widget.totalAmount, // Total bill amount
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 700, // Increased height to fit everything
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
          // Title
          Text(
            "Ready to confirm your transaction?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Enter the 1st and 6th digit of your PIN",
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          // PIN Indicator Dots
          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(6, (index) {
    bool isFirstOrLast = index == 0 || index == 5;
    int pinIndex = index == 0 ? 0 : (index == 5 ? 1 : -1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isFirstOrLast
              ? Border.all(
                  color: enteredPin[pinIndex] != "" ? Color.fromARGB(255, 94, 19, 16) : Color.fromARGB(255, 94, 19, 16),
                  width: 2,
                ) // Only add border for 1st and 6th digits
              : null,
          color: pinIndex != -1 && enteredPin[pinIndex] != ""
              ? Color.fromARGB(255, 94, 19, 16) // Only fill if digit is entered
              : Colors.grey[300], // Default grey
        ),
      ),
    );
  }),
),
          SizedBox(height: 25),

          // Custom Numpad (Bigger, All in View)
          Expanded(
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.85, // Bigger buttons
              ),
              itemBuilder: (context, index) {
                if (index == 9) return SizedBox(); // Empty placeholder
                if (index == 11) {
                  return IconButton(
                    icon: Icon(Icons.backspace, color: Colors.black, size: 28),
                    onPressed: _removeDigit,
                  );
                }
                String digit = (index == 10 ? "0" : (index + 1).toString());
                return GestureDetector(
                  onTap: () => _addDigit(digit),
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      digit,
                      style: TextStyle(fontSize: 28, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confirm Button (Bigger & Centered)

          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (enteredPin[0].isNotEmpty && enteredPin[1].isNotEmpty)
                  ? _confirmPin
                  : null, // Disable button if PIN is incomplete
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
