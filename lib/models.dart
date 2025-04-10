import 'package:flutter/widgets.dart';

class Person {
  String name;
  String phone;
  double amount;
  double percentage;
  double tax;              
  double serviceCharge;    
  bool verified;
  List<Item> items;
  Color? avatarColor;

  Person({
    required this.name,
    this.phone = '',
    this.amount = 0.0,
    this.percentage = 0.0,
    this.tax = 0.0,
    this.serviceCharge = 0.0,
    this.verified = false,
    this.avatarColor,
    List<Item>? items,
  }) : items = items ?? [];
}




class Receipt {
  final String title;
  final String date;
  double grandTotal;
  List<Person> people;
  double subTotal;
  double serviceCharge;
  double tax;
  double serviceChargePercentage;
  double taxPercentage;
  List<Item> items;
  String method;
  

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
    required this.method,
    
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

class User {
  final String username;
  final String longName;
  final String phoneNumber;

  User({
    required this.username,
    required this.longName,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      longName: json['long_name'],
      phoneNumber: json['phone_number'],
    );
  }
}
