import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotelbookingapp/view/hoteladd.dart';
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
  String? hotelId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      hotelId = user.uid; // ✅ hotel id
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⛔ wait until hotelId loads
    if (hotelId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _allhotelscreen = [
      // 🏨 HOME
      Hotelhome(hotelId: hotelId!),

      // ➕ ADD
      const Hoteladd(),

      // 📖 ALL BOOKINGS (ALL USERS → THIS HOTEL)
    // Allbookingviewadmin(hotelId: hotelId!),
    HotelPaymentsHistory(hotelId: hotelId!),

      // 👤 PROFILE
      const Hotelprofile(),
    ];

    return Scaffold(
      body: _allhotelscreen[_selectedIndexhotel],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexhotel,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndexhotel = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "All Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Profile"),
        ],
      ),
    );
  }
}
