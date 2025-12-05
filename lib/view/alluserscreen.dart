import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/Favourit.dart';
import 'package:hotelbookingapp/view/bookinghistory.dart';
import 'package:hotelbookingapp/view/home.dart';
import 'package:hotelbookingapp/view/profile.dart';


class Alluserscreen extends StatefulWidget {
  const Alluserscreen({super.key});

  @override
  State<Alluserscreen> createState() => _AlluserscreenState();
}

class _AlluserscreenState extends State<Alluserscreen> {
   int _selectedIndex = 0;
   final List<Widget>_allscreen=[Home(),Favourit(),Bookinghistory(),Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _allscreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _selectedIndex,backgroundColor: Colors.black,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.black,
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
