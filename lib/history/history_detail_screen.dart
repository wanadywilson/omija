import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models.dart';

class HistoryDetailScreen extends StatefulWidget {
  final Receipt receipt;

  HistoryDetailScreen({required this.receipt});

  @override
  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _format(double value) => NumberFormat("#,###").format(value);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _showTabs() ? 3 : 1, vsync: this);
  }

  bool _showTabs() {
    return widget.receipt.method.toLowerCase() == 'items' || widget.receipt.method.toLowerCase() == 'scan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 19, 16),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 19, 16),
        title: Text("Split Bill Detail", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: _showTabs()
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(text: "Summary"),
                  Tab(text: "People"),
                  Tab(text: "Receipt"),
                ],
              )
            : null,
      ),
      body: _showTabs()
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildPeopleTab(),
                _buildReceiptTab(),
              ],
            )
          : _buildSummaryTab(),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _buildCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("images/logo_omo.jpg", scale: 2),
            SizedBox(height: 20),
            Text("Split Bill by ${widget.receipt.method}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(widget.receipt.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _row("Receipt Date", widget.receipt.date),
            _row("Transaction Time", widget.receipt.transactionTime),
            SizedBox(height: 20),
            Divider(),
            ...widget.receipt.people.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(p.name, style: TextStyle(fontSize: 14)),
                        if (p.username != null && p.username!.isNotEmpty)
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                      ],
                    ),
                  ),
                  Text("Rp${_format(p.amount)}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            Divider(),
            _row("Grand Total", "Rp${_format(widget.receipt.grandTotal)}", bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTab() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      children: widget.receipt.people.map((p) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧑 Avatar + Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with initials
                    CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '',
                        style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 6,
  children: [
    Text(
      p.name,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    if (p.username != null && p.username!.isNotEmpty)
      Icon(Icons.check_circle, color: Colors.green, size: 16),
  ],
),

                          if (p.phone.isNotEmpty)
                            Text(
                              p.phone,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),

                // 📦 Item breakdown
                ...p.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item.name)),
                      Text("Rp${_format(item.totalPrice)}"),
                    ],
                  ),
                )),

                SizedBox(height: 10),
                Divider(),
                // 🧾 Tax & Service
                _row("Tax", "Rp${_format(p.tax)}"),
                _row("Service Charge", "Rp${_format(p.serviceCharge)}"),
                Divider(),
                _row("Total", "Rp${_format(p.amount)}", bold: true),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}


  Widget _buildReceiptTab() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧾 Title & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.receipt.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                widget.receipt.date,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),
          Divider(),

          // 🧾 List of items with single price, qty, total
          ...widget.receipt.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Name (Top line)
                Text(
                  item.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                // Bottom line: single price - qty - total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rp${_format(item.singlePrice)}", style: TextStyle(color: Colors.grey[700])),
                    Text("x${item.quantity}", style: TextStyle(color: Colors.black)),
                    Text("Rp${_format(item.totalPrice)}", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )),

          Divider(),

          // 💵 Breakdown rows
          _row("Sub Total", "Rp${_format(widget.receipt.subTotal)}"),
          _row("Tax (${widget.receipt.taxPercentage.toStringAsFixed(1)}%)", "Rp${_format(widget.receipt.tax)}"),
          _row("Service Charge (${widget.receipt.serviceChargePercentage.toStringAsFixed(1)}%)", "Rp${_format(widget.receipt.serviceCharge)}"),

          Divider(),

          _row("Grand Total", "Rp${_format(widget.receipt.grandTotal)}", bold: true),
        ],
      ),
    ),
  );
}



  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: child,
      ),
    );
  }
}
