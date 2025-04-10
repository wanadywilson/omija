import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../edit_receipt_details.dart';
import '../../models.dart';

// API URLs
const uploadImageUrl = 'http://141.11.241.147:8080/process-ocr/'; // <-- Ganti sesuai URL API kamu

Future<Receipt> parseReceiptFromOcrResponse(Map<String, dynamic> ocrJson) async {
  final data = ocrJson['ocr_result']; // <-- ambil bagian dalam 'ocr_result'

  final List<Item> items = (data['food_items'] as List).map<Item>((item) {
    final name = item['item'];
    final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
    final singlePrice = double.tryParse(item['price_per_quantity'].toString()) ?? 0.0;
    final totalPrice = double.tryParse(item['total_quantity_price'].toString()) ?? singlePrice * quantity;

    return Item(
      name: name,
      quantity: quantity,
      singlePrice: singlePrice,
      totalPrice: totalPrice,
    );
  }).toList();

  final double subTotal = double.tryParse(data['total_price'].toString()) ?? 0.0;
  final double tax = double.tryParse(data['tax'].toString()) ?? 0.0;
  final double grandTotal = subTotal + tax;

  return Receipt(
    title: data['place_name'] ?? "Unknown",
    date: data['invoice_date'] ?? "",
    tax: tax,
    taxPercentage: 0,
    serviceCharge: 0,
    serviceChargePercentage: 0,
    subTotal: subTotal,
    grandTotal: grandTotal,
    people: [Person(name: 'Me')],
    items: items,
    method: "OCR",
  );
}


class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath, Key? key}) : super(key: key);

  Future<Receipt> sendImageToApi(String imagePath) async {
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

    final Map<String, dynamic> ocrJson = jsonDecode(response.body);
    return await parseReceiptFromOcrResponse(ocrJson);
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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => Center(child: CircularProgressIndicator()),
                      );

                      try {
                        Receipt populatedReceipt = await sendImageToApi(imagePath);

                        Navigator.pop(context); // dismiss loading dialog

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditReceiptDetailsScreen(initialReceipt: populatedReceipt),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
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

// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'edit_receipt_details.dart';
// import '../models.dart';

// // API placeholders
// const receiptInfoUrl = 'http://141.11.241.147:8080/masterreceipt/?id=1';
// const receiptItemsUrl = 'http://141.11.241.147:8080/receipt-detail/?id=1';
// const uploadImageUrl = 'http://141.11.241.147:8080/process-ocr/'; // <-- Replace with your actual API URL


// Future<Receipt> parseReceiptFromOcrResponse(Map<String, dynamic> ocrJson) async {
//   final List<Item> items = (ocrJson['food_items'] as List).map<Item>((item) {
//     final name = item['item'];
//     final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
//     final singlePrice = double.tryParse(item['price_per_quantity'].toString()) ?? 0.0;
//     final totalPrice = double.tryParse(item['total_quantity_price'].toString()) ?? singlePrice * quantity;

//     return Item(
//       name: name,
//       quantity: quantity,
//       singlePrice: singlePrice,
//       totalPrice: totalPrice,
//     );
//   }).toList();

//   final double subTotal = double.tryParse(ocrJson['total_price'].toString()) ?? 0.0;
//   final double tax = double.tryParse(ocrJson['tax'].toString()) ?? 0.0;
//   final double grandTotal = subTotal + tax;

//   return Receipt(
//     title: ocrJson['place_name'] ?? "Unknown",
//     date: ocrJson['invoice_date'] ?? "",
//     tax: tax,
//     taxPercentage: 0,
//     serviceCharge: 0,
//     serviceChargePercentage: 0,
//     subTotal: subTotal,
//     grandTotal: grandTotal,
//     people: [Person(name: 'Me')],  // default sementara
//     items: items,
//   );
// }


// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   const DisplayPictureScreen({required this.imagePath, Key? key}) : super(key: key);

//   Future<void> sendImageToApi(String imagePath) async {
//     final bytes = await File(imagePath).readAsBytes();
//     final base64Image = base64Encode(bytes);

//     final response = await http.post(
//       Uri.parse(uploadImageUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'image_base64': base64Image}),
//     );

//     if (response.statusCode != 200) {
//       throw Exception("Failed to upload image. Status: ${response.statusCode}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: Text('Confirm your picture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color.fromARGB(255, 94, 19, 16),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Center(child: Image.file(File(imagePath))),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 72),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       elevation: 5,
//                       shadowColor: Color.fromARGB(255, 94, 19, 16),
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text('Retake picture', style: TextStyle(fontSize: 16)),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color.fromARGB(255, 94, 19, 16),
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onPressed: () async {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // prevent closing manually
//     builder: (_) => Center(
//       child: CircularProgressIndicator(),
//     ),
//   );

//   try {
//     await sendImageToApi(imagePath);
//     Receipt populatedReceipt = await fetchReceiptAndItems();

//     Navigator.pop(context); // dismiss loading dialog

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditReceiptDetailsScreen(initialReceipt: populatedReceipt),
//       ),
//     );
//   } catch (e) {
//     Navigator.pop(context); // dismiss loading dialog
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Failed to process image: $e")),
//     );
//   }
// },

//                     child: Text('Next', style: TextStyle(fontSize: 16)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }



// Future<Receipt> fetchReceiptAndItems() async {
//   final receiptResponse = await http.get(Uri.parse(receiptInfoUrl));
//   final itemsResponse = await http.get(Uri.parse(receiptItemsUrl));

//   if (receiptResponse.statusCode == 200 && itemsResponse.statusCode == 200) {
//     final receiptJson = jsonDecode(receiptResponse.body)[0];
//     final itemsJson = jsonDecode(itemsResponse.body);

//     final List<Item> items = itemsJson.map<Item>((item) {
//       final name = item['item'];
//       final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
//       final singlePrice = double.tryParse(item['quantity_price'].toString()) ?? 0.0;
//       final totalPrice = singlePrice * quantity;

//       return Item(
//         name: name,
//         quantity: quantity,
//         singlePrice: singlePrice,
//         totalPrice: totalPrice,
//       );
//     }).toList();

//     final double subTotal = double.tryParse(receiptJson['total_price'].toString()) ?? 0.0;
//     final double tax = double.tryParse(receiptJson['tax'].toString()) ?? 0.0;
//     final double grandTotal = subTotal + tax;

//     return Receipt(
//       title: receiptJson['place_name'],
//       date: receiptJson['invoice_date'],
//       tax: tax,
//       taxPercentage: 0,
//       serviceCharge: 0,
//       serviceChargePercentage: 0,
//       subTotal: subTotal,
//       grandTotal: grandTotal,
//       people: [Person(name: 'Me')],
//       items: items,
//     );
//   } else {
//     throw Exception('Failed to fetch receipt data');
//   }
// }