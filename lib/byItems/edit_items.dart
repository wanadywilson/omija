import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import 'review_items.dart';

class EditItemsScreen extends StatefulWidget {
  final Receipt receipt;

  EditItemsScreen({required this.receipt});

  @override
  _EditItemsScreenState createState() => _EditItemsScreenState();
}

class _EditItemsScreenState extends State<EditItemsScreen> {
  List<Item> items = [];

  late TextEditingController taxPercentageController;
  late TextEditingController taxAmountController;
  late TextEditingController serviceChargePercentageController;
  late TextEditingController serviceChargeAmountController;

  @override
  void initState() {
    super.initState();
    items = widget.receipt.items;

    taxPercentageController = TextEditingController(text: widget.receipt.taxPercentage.toStringAsFixed(2));
    taxAmountController = TextEditingController(text: NumberFormat("#,###").format(widget.receipt.tax));
    serviceChargePercentageController = TextEditingController(text: widget.receipt.serviceChargePercentage.toStringAsFixed(2));
    serviceChargeAmountController = TextEditingController(text: NumberFormat("#,###").format(widget.receipt.serviceCharge));

    taxPercentageController.addListener(_updateTaxAmount);
    taxAmountController.addListener(_updateTaxPercentage);
    serviceChargePercentageController.addListener(_updateServiceChargeAmount);
    serviceChargeAmountController.addListener(_updateServiceChargePercentage);
  }

  void _addNewItem() {
    setState(() {
      items.add(Item(name: "", singlePrice: 0.0, quantity: 1, totalPrice: 0.0));
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _updateTotals() {
    setState(() {});
  }

  double _calculateSubtotal() {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    widget.receipt.subTotal = subtotal;
    return subtotal;
}


  double _calculateTotal() {
    final subtotal = _calculateSubtotal(); // also updates widget.receipt.subTotal
    final tax = double.tryParse(taxAmountController.text.replaceAll(',', '')) ?? 0;
    final serviceCharge = double.tryParse(serviceChargeAmountController.text.replaceAll(',', '')) ?? 0;
    final grandTotal = subtotal + tax + serviceCharge;
    widget.receipt.grandTotal = grandTotal;
    return grandTotal;
}


  void _updateTaxAmount() {
  final subtotal = _calculateSubtotal();
  final percentage = double.tryParse(taxPercentageController.text) ?? 0;
  final amount = subtotal * (percentage / 100);
  taxAmountController.text = NumberFormat("#,###").format(amount);

  widget.receipt.taxPercentage = percentage;
  widget.receipt.tax = amount;
  setState(() {});
}

void _updateTaxPercentage() {
  final subtotal = _calculateSubtotal();
  final amount = double.tryParse(taxAmountController.text.replaceAll(',', '')) ?? 0;
  final percentage = subtotal > 0 ? (amount / subtotal) * 100 : 0;

  widget.receipt.taxPercentage = percentage.toDouble();
  widget.receipt.tax = amount;
  taxPercentageController.text = percentage.toString();

  setState(() {});
}

void _updateServiceChargeAmount() {
  final subtotal = _calculateSubtotal();
  final percentage = double.tryParse(serviceChargePercentageController.text) ?? 0;
  final amount = subtotal * (percentage / 100);
  serviceChargeAmountController.text = NumberFormat("#,###").format(amount);

  widget.receipt.serviceChargePercentage = percentage;
  widget.receipt.serviceCharge = amount;
  setState(() {});
}

void _updateServiceChargePercentage() {
  final subtotal = _calculateSubtotal();
  final amount = double.tryParse(serviceChargeAmountController.text.replaceAll(',', '')) ?? 0;
  final percentage = subtotal > 0 ? (amount / subtotal) * 100 : 0;
  
  serviceChargePercentageController.text = percentage.toString();
  widget.receipt.serviceChargePercentage = percentage.toDouble();
  widget.receipt.serviceCharge = amount;
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Items", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _addNewItem,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReceiptInfo(),
            SizedBox(height: 10),
            Expanded(child: _buildItemList()),
            _buildTaxServiceCharge(),
            _buildGrandTotal(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

Widget _buildReceiptInfo() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.receipt.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 10), // spacing between title and date
        Text(
          widget.receipt.date,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );
}


  Widget _buildItemList() {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];

      // Attach listeners
      item.singlePriceController.addListener(() {
        final price = double.tryParse(item.singlePriceController.text.replaceAll(',', '')) ?? 0;
        final qty = int.tryParse(item.quantityController.text) ?? 1;
        final total = price * qty;
        if (item.totalPriceController.text != NumberFormat("#,###").format(total)) {
          item.totalPriceController.text = NumberFormat("#,###").format(total);
        }
        setState(() {});
      });

      item.totalPriceController.addListener(() {
        final total = double.tryParse(item.totalPriceController.text.replaceAll(',', '')) ?? 0;
        final qty = int.tryParse(item.quantityController.text) ?? 1;
        if (qty > 0) {
          final price = total / qty;
          if (item.singlePriceController.text != NumberFormat("#,###").format(price)) {
            item.singlePriceController.text = NumberFormat("#,###").format(price);
          }
        }
        setState(() {});
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: item.nameController,
            decoration: InputDecoration(labelText: "Item Name"),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item.singlePriceController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Single Price"),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: item.quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: "Qty"),
                  onChanged: (val) {
                    final qty = int.tryParse(val) ?? 1;
                    final price = double.tryParse(item.singlePriceController.text.replaceAll(',', '')) ?? 0;
                    final total = price * qty;
                    item.totalPriceController.text = NumberFormat("#,###").format(total);
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: item.totalPriceController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Total Price"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    item.dispose(); // dispose controllers
                    items.removeAt(index);
                  });
                },
              ),
            ],
          ),
          Divider(),
        ],
      );
    },
  );
}





  Widget _buildTaxServiceCharge() {
    return Column(
      children: [
        _buildTaxField("Service Charge", serviceChargePercentageController, serviceChargeAmountController),
        _buildTaxField("Tax", taxPercentageController, taxAmountController),
      ],
    );
  }

  Widget _buildTaxField(String label, TextEditingController percent, TextEditingController amount) {
  return Row(
    children: [
      // % input
      Expanded(
        child: TextField(
          controller: percent,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "$label %"),
          onChanged: (_) {
            if (label == "Tax") {
              _updateTaxAmount();
            } else {
              _updateServiceChargeAmount();
            }
          },
        ),
      ),
      SizedBox(width: 10),

      // amount input
      Expanded(
        child: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "$label Amount"),
          onChanged: (_) {
            if (label == "Tax") {
              _updateTaxPercentage();
            } else {
              _updateServiceChargePercentage();
            }
          },
        ),
      ),
    ],
  );
}


  Widget _buildGrandTotal() {
  _calculateTotal(); // ensures receipt.subTotal and grandTotal are updated

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal (items only):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "Rp${NumberFormat("#,###").format(widget.receipt.subTotal)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Grand Total:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "Rp${NumberFormat("#,###").format(widget.receipt.grandTotal)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ],
  );
}



  Widget _buildNextButton() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24), // 👈 adds space from bottom
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _calculateTotal(); // ensures the latest totals are stored
          widget.receipt.items = items;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewItemsScreen(receipt: widget.receipt),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 94, 19, 16),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    ),
  );
}
}
