import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/Favourit.dart';
import 'package:hotelbookingapp/view/home.dart';
import 'package:hotelbookingapp/view/paymenthistory.dart';
import 'package:hotelbookingapp/view/profile.dart';


class Alluserscreen extends StatefulWidget {
  const Alluserscreen({super.key});

  @override
  State<Alluserscreen> createState() => _AlluserscreenState();
}

class _AlluserscreenState extends State<Alluserscreen> {
   int _selectedIndex = 0;
   final List<Widget>_allscreen=[Home(),Favourit(),Paymenthistory(),Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _allscreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
     backgroundColor: Colors.black, // ✅ Fix: set your desired color here
        type: BottomNavigationBarType.fixed, // ensures background applies to all items

        onTap: (index){
          setState(() {
            _selectedIndex=index;
          });
        },
       
        items: [BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite),label: "Favorites"),
        BottomNavigationBarItem(icon: Icon(Icons.book_online),label: "My Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
        ],
      ),
    );
  }
}
