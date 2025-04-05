import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'review_after_edit.dart';

class EditReceiptScreen extends StatefulWidget {
  final List<Map<String, String>> items;

  EditReceiptScreen({required this.items});

  @override
  _EditReceiptScreenState createState() => _EditReceiptScreenState();
}

class _EditReceiptScreenState extends State<EditReceiptScreen> {
  late List<TextEditingController> _itemControllers;
  late List<TextEditingController> _quantityControllers;
  late List<TextEditingController> _priceControllers;
  late TextEditingController _editableTotalController;

  @override
void initState() {
  super.initState();
  _itemControllers = widget.items
      .map((item) => TextEditingController(text: item['name']))
      .toList();
  _quantityControllers = widget.items
      .map((item) => TextEditingController(text: item['quantity'] ?? '1'))
      .toList();
  _priceControllers = widget.items
      .map((item) => TextEditingController(text: _formatAmount(item['price'] ?? '')))
      .toList();

  // Editable total price
  _editableTotalController = TextEditingController(
    text: _formatAmount(_calculateTotal().toString()),
  );

  // Add listeners for price auto-format and quantity change
  for (var controller in _priceControllers) {
    controller.addListener(() {
      _formatPrice(controller);
      _calculateTotal(); // Update total when price changes
      setState(() {});
    });
  }

  for (var controller in _quantityControllers) {
    controller.addListener(() {
      _calculateTotal(); // Update total when quantity changes
      setState(() {});
    });
  }

  _editableTotalController.addListener(() {
    _formatPrice(_editableTotalController);
    setState(() {}); // Update UI to show warning and disable button
  });
}


  @override
  void dispose() {
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    _editableTotalController.dispose();
    super.dispose();
  }

  // Formats input dynamically while typing (thousand separators)
  void _formatPrice(TextEditingController controller) {
    String text = controller.text.replaceAll(',', '').trim();
    if (text.isEmpty) return;

    double? value = double.tryParse(text);
    if (value != null) {
      String formattedValue = NumberFormat("#,###").format(value);
      if (controller.text != formattedValue) {
        controller.value = TextEditingValue(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length),
        );
      }
    }
  }

  // Formats number when loading
  String _formatAmount(String text) {
    if (text.isEmpty) return '';
    double? value = double.tryParse(text.replaceAll(',', ''));
    return value != null ? NumberFormat("#,###").format(value) : text;
  }

  double _calculateTotal() {
    double total = 0.0;
    for (int i = 0; i < _priceControllers.length; i++) {
      String priceText = _priceControllers[i].text.replaceAll(',', '');
      double price = double.tryParse(priceText) ?? 0.0;
      int quantity = int.tryParse(_quantityControllers[i].text) ?? 1;
      total += price * quantity;
    }
    return total;
  }

  

  void _addItem() {
  setState(() {
    _itemControllers.add(TextEditingController());
    _quantityControllers.add(TextEditingController(text: '1'));
    _priceControllers.add(TextEditingController());

    // Add listener to auto-format price
    _priceControllers.last.addListener(() {
      _formatPrice(_priceControllers.last);
      setState(() {}); // Update the UI when price is changed
    });

    // Ensure total updates when an item is added
    _calculateTotal();
  });
}


  void _removeItem(int index) {
  setState(() {
    _itemControllers[index].dispose();
    _quantityControllers[index].dispose();
    _priceControllers[index].dispose();

    _itemControllers.removeAt(index);
    _quantityControllers.removeAt(index);
    _priceControllers.removeAt(index);

    // Recalculate total after removing an item
    _calculateTotal();
  });
}


  void _saveEdits() {
    List<Map<String, String>> editedItems = [];
    for (int i = 0; i < _itemControllers.length; i++) {
      editedItems.add({
        'name': _itemControllers[i].text,
        'quantity': _quantityControllers[i].text,
        'price': _priceControllers[i].text.replaceAll(',', ''),
      });
    }
    print(editedItems);
  }

  @override
  Widget build(BuildContext context) {
    double calculatedTotal = _calculateTotal();
    double enteredTotal = double.tryParse(_editableTotalController.text.replaceAll(',', '')) ?? 0.0;
    bool totalsMatch = calculatedTotal == enteredTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Receipt'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _itemControllers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Editable Item Name (Underlined)
                          Expanded(
                            child: TextField(
                              controller: _itemControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Item Name',
                                border: UnderlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Editable Quantity
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _quantityControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Qty',
                                border: UnderlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Editable & Auto-formatted Price
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _priceControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Price',
                                border: UnderlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _formatPrice(_priceControllers[index]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Total Calculation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calculated Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${NumberFormat("#,###").format(calculatedTotal)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Editable Total Input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _editableTotalController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            // Warning Text
            if (!totalsMatch)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Total does not match",
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: 20),
            // Full Width Confirm Button (Disabled when totals don't match)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: totalsMatch ? () {
            List<Map<String, String>> editedItems = [];
            for (int i = 0; i < _itemControllers.length; i++) {
              editedItems.add({
                'name': _itemControllers[i].text,
                'quantity': _quantityControllers[i].text,
                'price': _priceControllers[i].text.replaceAll(',', ''),
              });
            }

            double totalAmount = double.tryParse(_editableTotalController.text.replaceAll(',', '')) ?? 0.0;

            // Navigate to ReviewReceiptScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewReceiptScreen(
                  items: editedItems,
                  total: totalAmount,
                ),
              ),
            );
          } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: totalsMatch ? Colors.red : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

