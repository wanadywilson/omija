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
      child: _buildCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.receipt.people.map((p) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(p.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (p.username != null && p.username!.isNotEmpty)
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ],
                      ),
                    ),
                    Text("Rp${_format(p.amount)}", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (p.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(p.phone, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ),
                ...p.items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item.name} x${item.quantity}", style: TextStyle(fontSize: 14)),
                      Text("Rp${_format(item.totalPrice)}", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                )),
                Divider(),
              ],
            );
          }).toList(),
        ),
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
            ...widget.receipt.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("${item.name} x${item.quantity}")),
                  Text("Rp${_format(item.totalPrice)}"),
                ],
              ),
            )),
            Divider(),
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
