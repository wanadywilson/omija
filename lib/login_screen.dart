import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart'; // For HomeScreen and cameras

class OctoLoginScreen extends StatefulWidget {

  const OctoLoginScreen();

  @override
  _OctoLoginScreenState createState() => _OctoLoginScreenState();
}

class _OctoLoginScreenState extends State<OctoLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _username;

  void _login() {
    setState(() {
      _username = _usernameController.text.trim();
    });

    if (_username != null && _username!.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(cameras:cameras)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your username')),
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
                  suffixText: "Lupa user ID?",
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
              Text("Saya punya rekening tapi belum punya user ID", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: Text("Daftar OCTO Mobile", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 24),
              Text("Saya belum punya rekening", style: TextStyle(color: Colors.white70)),
              GestureDetector(
                onTap: () {},
                child: Text("Buka rekening sekarang",
                    style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
              ),
              Spacer(),
              Column(
                children: [
                  Image.asset('images/logo_omo.jpg', scale: 2),
                  SizedBox(height: 10),
                  Text("OCTO Mobile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("by CIMB Niaga", style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
