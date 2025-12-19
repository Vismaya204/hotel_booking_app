import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/hoteladd.dart';
import 'package:hotelbookingapp/view/hoteldetails.dart';
import 'package:hotelbookingapp/view/hotelhome.dart';
import 'package:hotelbookingapp/view/hotelprofile.dart';
import 'package:hotelbookingapp/view/hotelview_all_bookings.dart';

class Hotelallscr extends StatefulWidget {
  const Hotelallscr({super.key});

  @override
  State<Hotelallscr> createState() => _HotelallscrState();
}

class _HotelallscrState extends State<Hotelallscr> {
  
  int _selectedIndexhotel = 0;
  final List<Widget> _allhotelscreen = [Hotelhome(),Hoteladd(),HotelviewAllBookings(),Hotelprofile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: _allhotelscreen[_selectedIndexhotel],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexhotel,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {setState(() {
          _selectedIndexhotel=index;
        });
          
        },
        items: [BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.add_box),label: "Add"),
        BottomNavigationBarItem(icon: Icon(Icons.book),label: "Allbooking"),
        BottomNavigationBarItem(icon: Icon(Icons.people),label: "Profile"),
        ],
      ),
    );
  }
}
