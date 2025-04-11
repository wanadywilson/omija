import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'split_bill.dart';
import 'package:camera/camera.dart';
import 'transferMoney/transfer_money.dart';
import 'animated_splash.dart';
import 'globals.dart';


late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // assign to global
  runApp(OCTOMobileApp());
}


class OCTOMobileApp extends StatelessWidget {
  const OCTOMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
        primaryColor: Color.fromARGB(255,94,19,16),
        textTheme: GoogleFonts.poppinsTextTheme(), // Apply Poppins globally
         appBarTheme: AppBarTheme(
          color: const Color.fromARGB(255, 94, 19, 16),
        ),


      ),
      home: AnimatedSplash(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCTO Mobile',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.favorite_border), color: Colors.white, onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications), color: Colors.white,onPressed: () {}),
          
        ],
      ),
     body: Container(
  color: Colors.white, // ✅ Set white background
  child: Column(

        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Color.fromARGB(255, 94,19,16),
            child: Row(
              children: [
                Image.asset('images/icon_octo.png', scale:2),
                SizedBox(width: 10),
                Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    Text(
                         _getGreeting(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                        '$longName',
                        style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)
                    )
                   ]
                )
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 85,
              child:
              Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/background_octopay.jpg"),
                  fit: BoxFit.cover,),
                
      
                borderRadius: BorderRadius.circular(20),
              ),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                    Text('OCTO Pay (•••• 1908)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 1),
                    Row(
                      children:[
                        Icon(Icons.remove_red_eye, color: Colors.white),
                        SizedBox(width: 5),
                        Text('  IDR •••', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ]
                    ),
                    
                ]
              ))
            ), // Increase height
          SizedBox(height: 16),

           GridView.count(
             crossAxisCount: 4, // 3 columns
              shrinkWrap: true, // Ensures GridView takes only needed space
              physics: NeverScrollableScrollPhysics(),
            children:[

                  GestureDetector(
                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TransferMoney()),
                    );
                    },

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('images/transfer_icon.jpg', scale:3),
                      Text('Transfer', textAlign: TextAlign.center),
                    ],
                  ),
                  ),

                  _buildGridItemImage('cardless.jpg', 'Cardless'),
                  
                  GestureDetector(
                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplitBillScreen(cameras: cameras)),
                    );
                    },

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('images/bills.jpg', scale:3),
                      Text('Split Bill', textAlign: TextAlign.center),
                    ],
                  ),
                  ),

                  _buildGridItemImage('promotion.jpg', 'Promotion'),
                  _buildGridItemImage('voucher.jpg', 'Voucher'),
                  _buildGridItemImage('electronic_money.jpg','Electronic Money'),
                  _buildGridItemImage('apply_invest.jpg','Apply & Invest'),
                  GestureDetector(
  onTap: () {
    showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🖼️ Image as icon
          Image.asset(
            'images/octo_notif.png', // <-- replace with your actual path
            scale: 2.5,
          ),
          SizedBox(height: 15),

          // ✏️ Message
          Text(
            "Omija (081290003829) has sent you a split bill for:",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),

          Text(
            "Hachi Grill",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 15),

          Text(
            "Rp 273.000",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 94, 19, 16)),
          ),
          SizedBox(height: 25),

          Text(
            "Want to Pay Now?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 94, 19, 16)),
          ),

          SizedBox(height: 25),

          // 🔘 Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Later", style: TextStyle(color: Colors.grey)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  
                ),
              ),
              ElevatedButton(
  onPressed: () {
    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferMoney(
          prefillPhone: "081290003829",
          prefillAmount: "273000",
          prefillMessage: "Hachi Grill",
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 94, 19, 16),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  child: Text("Pay Now", style: TextStyle(color: Colors.white)),
),

            ],
          ),
        ],
      ),
    );
  },
);

  },
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('images/all_menu.jpg', scale: 3),
      Text('All Menu', textAlign: TextAlign.center),
    ],
  ),
),


              ],
            ),


          Padding(
            padding: const EdgeInsets.symmetric( horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "All",
                  style: TextStyle(color: Color.fromARGB(255,94,19,16), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 20),
                Text(
                  "Promo",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(width: 20),
                Text(
                  "News",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),

          SizedBox(height:20),

          SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 200,
              child:
              Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/banner_promo.png"),
                  fit: BoxFit.contain,),
                
      
                borderRadius: BorderRadius.circular(20),
              ),
              )
            ),



                ],
      ),
  ),


          bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Color.fromARGB(255, 94, 19, 16),
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset("images/bottom_first.jpg", scale: 2.2),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset("images/bottom_second.jpg", scale: 2.2),
              label: 'My Accounts',
            ),
            BottomNavigationBarItem(
              icon: Image.asset("images/bottom_third.jpg", scale: 2.2),
              label: 'Wealth',
            ),
            BottomNavigationBarItem(
              icon: Image.asset("images/bottom_fourth.jpg", scale: 2.2),
              label: 'Settings',
            ),
          ],
        ),
      ),)

      
    );
  }


  Widget _buildGridItemImage(String filename, String label){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('images/$filename', scale:3),
        Text(label, textAlign: TextAlign.center),
      ],
    );

  }

  String _getGreeting() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return 'Good morning,';
  } else if (hour >= 12 && hour < 17) {
    return 'Good afternoon,';
  } else if (hour >= 17 && hour < 21) {
    return 'Good evening,';
  } else {
    return 'Good night,';
  }
}

}
