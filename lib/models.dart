import 'package:flutter/widgets.dart';

class Person {
  String name;
  String phone;
  double amount;
  double percentage;
  double tax;              
  double serviceCharge;    
  List<Item> items;

  Person({
    required this.name,
    this.phone = '',
    this.amount = 0.0,
    this.percentage = 0.0,
    this.tax = 0.0,
    this.serviceCharge = 0.0,
    List<Item>? items,
  }) : items = items ?? [];
}




class Receipt {
  final String title;
  final String date;
  double grandTotal;
  final List<Person> people;
  double subTotal;
  double serviceCharge;
  double tax;
  double serviceChargePercentage;
  double taxPercentage;
  List<Item> items;
  

  Receipt({
    required this.title,
    required this.date,
    required this.grandTotal,
    required this.people,
    List<Item>? items,
    required this.serviceCharge,
    required this.serviceChargePercentage,
    required this.tax,
    required this.taxPercentage,
    required this.subTotal,
    
  }): items = items ?? [];
}


class Item {
  TextEditingController nameController;
  TextEditingController singlePriceController;
  TextEditingController quantityController;
  TextEditingController totalPriceController;

  Item({
    String name = '',
    double singlePrice = 0.0,
    int quantity = 1,
    double totalPrice = 0.0,
  })  : nameController = TextEditingController(text: name),
        singlePriceController = TextEditingController(text: singlePrice.toStringAsFixed(0)),
        quantityController = TextEditingController(text: quantity.toString()),
        totalPriceController = TextEditingController(text: totalPrice.toStringAsFixed(0));

  String get name => nameController.text;
  double get singlePrice => double.tryParse(singlePriceController.text.replaceAll(',', '')) ?? 0.0;
  int get quantity => int.tryParse(quantityController.text) ?? 1;
  double get totalPrice => double.tryParse(totalPriceController.text.replaceAll(',', '')) ?? 0.0;

  void updateTotalFromSingleAndQuantity() {
    double total = singlePrice * quantity;
    totalPriceController.text = total.toStringAsFixed(0);
  }

  void updateSingleFromTotalAndQuantity() {
    int qty = quantity;
    if (qty > 0) {
      double price = totalPrice / qty;
      singlePriceController.text = price.toStringAsFixed(0);
    }
  }

  void dispose() {
    nameController.dispose();
    singlePriceController.dispose();
    quantityController.dispose();
    totalPriceController.dispose();
  }
}