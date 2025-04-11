import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:octo_split/globals.dart';

import '../models.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Receipt> _history = [];
  bool _isLoading = true;

  List<Receipt> _forMeHistory = [];
  bool _isForMeLoading = true;


  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);
  _fetchHistory();          // For "By Me"
  _fetchForMeHistory();     // For "For Me"
}


  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse(urlGetHistoryByMe + username)); // Replace with real URL
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _history = jsonData.map((json) => Receipt.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load history");
      }
    } catch (e) {
      print("Error fetching history: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchForMeHistory() async {
  try {
    final response = await http.get(Uri.parse(urlGetHistoryForMe + username)); // Use new endpoint
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _forMeHistory = jsonData.map((json) => Receipt.fromJson(json)).toList();
        _isForMeLoading = false;
      });
    } else {
      throw Exception("Failed to load For Me history");
    }
  } catch (e) {
      print("Error fetching For Me history: $e");
      setState(() => _isForMeLoading = false);
  }
}


  String _formatNumber(double value) => NumberFormat("#,###").format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F1F8),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split Bill History", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: "By Me"),
            Tab(text: "For Me"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading
              ? Center(
  child: Container(
    
    width: 180,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('images/omo_loading.png', width: 120), // adjust path/size as needed
        SizedBox(height: 16),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 94, 19, 16)),
        ),
        SizedBox(height: 12),
        
      ],
    ),
  ),
)
              : _history.isEmpty
                  ? Center(child: Text("No history available"))
                  : ListView.builder(
  padding: EdgeInsets.all(16),
  itemCount: _history.length,
  itemBuilder: (context, index) {
    return _buildHistoryCard(_history[index]);
  },
),


          // 🕓 Placeholder for “For Me”
          _isForMeLoading
  ? Center(child: CircularProgressIndicator())
  : _forMeHistory.isEmpty
    ? Center(child: Text("No history found for you."))
    : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _forMeHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(_forMeHistory[index]);
        },
      )

        ],
      ),
    );
  }

 Widget _buildHistoryCard(Receipt receipt) {
  IconData methodIcon;
  switch (receipt.method.toLowerCase()) {
    case "percentage":
      methodIcon = Icons.percent;
      break;
    case "equal":
      methodIcon = Icons.format_list_numbered;
      break;
    case "exact":
      methodIcon = Icons.money;
      break;
    case "ocr":
      methodIcon = Icons.document_scanner;
      break;
    default:
      methodIcon = Icons.receipt;
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryDetailScreen(receipt: receipt),
        ),
      );
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Receipt icon + Title + Transaction Time
            Row(
              children: [
                Icon(Icons.receipt_long, size: 25, color: Color.fromARGB(255, 94, 19, 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    receipt.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 94, 19, 16)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  receipt.transactionTime,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 4),

            // Row 2: Date under title (with time icon)
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(receipt.date, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),

            SizedBox(height: 8),

            // Split method with icon
            Row(
              children: [
                Icon(methodIcon, size: 18, color: Colors.grey[700]),
                SizedBox(width: 6),
                Text("Split by ${receipt.method}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),

            SizedBox(height: 10),

            // Bottom: Amount and arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rp ${_formatNumber(receipt.grandTotal)}",
                    style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}





}
