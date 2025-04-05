import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_receipt_details.dart';
import '../models.dart';

// API placeholders
const receiptInfoUrl = 'http://141.11.241.147:8080/masterreceipt/?id=1';
const receiptItemsUrl = 'http://141.11.241.147:8080/receipt-detail/?id=1';
const uploadImageUrl = 'http://141.11.241.147:8080/process-ocr/'; // <-- Replace with your actual API URL

Future<Receipt> fetchReceiptAndItems() async {
  final receiptResponse = await http.get(Uri.parse(receiptInfoUrl));
  final itemsResponse = await http.get(Uri.parse(receiptItemsUrl));

  if (receiptResponse.statusCode == 200 && itemsResponse.statusCode == 200) {
    final receiptJson = jsonDecode(receiptResponse.body)[0]; // assuming list
    final itemsJson = jsonDecode(itemsResponse.body);

    final List<Item> items = itemsJson.map<Item>((item) {
      final name = item['food'];
      final quantity = item['quantity'];
      final singlePrice = item['quantity_price'] * 1.0;
      final totalPrice = singlePrice * quantity;

      return Item(
        name: name,
        quantity: quantity,
        singlePrice: singlePrice,
        totalPrice: totalPrice,
      );
    }).toList();

    return Receipt(
      title: receiptJson['restaurant_name'],
      date: receiptJson['invoice_date'],
      tax: receiptJson['restaurant_tax'] * 1.0,
      taxPercentage: 0,
      serviceCharge: 0,
      serviceChargePercentage: 0,
      subTotal: receiptJson['total_price_for_all_items'] * 1.0,
      grandTotal: (receiptJson['total_price_for_all_items'] + receiptJson['restaurant_tax']) * 1.0,
      people: [Person(name: 'Me')],
      items: items,
    );
  } else {
    throw Exception('Failed to fetch receipt data');
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath, Key? key}) : super(key: key);

  Future<void> sendImageToApi(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(uploadImageUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image_base64': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to upload image. Status: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Confirm your picture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 94, 19, 16),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(child: Image.file(File(imagePath))),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 72),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shadowColor: Color.fromARGB(255, 94, 19, 16),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Retake picture', style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 94, 19, 16),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      try {
                        // 1. Send the image
                        await sendImageToApi(imagePath);

                        // 2. Fetch data from the backend (receipt + items)
                        Receipt populatedReceipt = await fetchReceiptAndItems();

                        // 3. Go to edit screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReceiptDetailsScreen(initialReceipt: populatedReceipt),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to process image: $e")),
                        );
                      }
                    },
                    child: Text('Next', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
