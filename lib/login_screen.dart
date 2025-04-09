import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main.dart'; // For HomeScreen and cameras
import 'globals.dart'; // For global variables

class OctoLoginScreen extends StatefulWidget {
  const OctoLoginScreen();

  @override
  _OctoLoginScreenState createState() => _OctoLoginScreenState();
}

class _OctoLoginScreenState extends State<OctoLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _login() async {
  final input = _usernameController.text.trim();

  if (input.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter your username')),
    );
    return;
  }

  // Show loading spinner
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(child: CircularProgressIndicator()),
  );

  try {
    final data = [{"username":"dgsianipar","long_name":"Dedy Sianipar","phone_number":"088012341234"},{"username":"wwanady","long_name":"Wilson Wanady","phone_number":"088043211234"},{"username":"hsutomo","long_name":"Harto Sutomo","phone_number":"088011223344"}];
    knownUsers = List<Map<String, dynamic>>.from(data);
    // Fetch known users list once if empty
    /*
    if (knownUsers.isEmpty) {
      final response = await http.get(
        Uri.parse('http://141.11.241.147:8080/users/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          knownUsers = List<Map<String, dynamic>>.from(data);
        }
      } else {
        throw Exception("Failed to fetch known users");
      }
    }
    */

    Navigator.pop(context); // Close loading

    // Look for matching username
    final user = knownUsers.firstWhere(
      (u) => u['username'] == input,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      username = user['username'] ?? '';
      longName = user['long_name'] ?? '';
      phoneNumber = user['phone_number'] ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(cameras: cameras)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username')),
      );
    }
  } catch (e) {
    Navigator.pop(context); // Close loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login error. Please try again.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 94, 19, 16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              SizedBox(height: 40),
              Text("Login",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),

              TextField(
                controller: _usernameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '••••••••••••••',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixText: "Forgot User ID?",
                  suffixStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Login", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.fingerprint, color: Colors.white, size: 36),
                ],
              ),
              SizedBox(height: 24),
              Text("I have an account but no user ID", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: Text("Register to OCTO Mobile", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 24),
              Text("I don't have any account", style: TextStyle(color: Colors.white70)),
              GestureDetector(
                onTap: () {},
                child: Text("Open an account now",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold)),
              ),
              Spacer(),
              Column(
                children: [
                  Image.asset('images/logo_omo_login.png', scale: 0.8),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
