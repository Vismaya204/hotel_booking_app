import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/hotel_allscr.dart';
import 'package:hotelbookingapp/view/hoteladd.dart';
import 'package:hotelbookingapp/view/hotelview_all_bookings.dart';
import 'package:hotelbookingapp/view/register_login.dart';

class Hotelprofile extends StatelessWidget {
  const Hotelprofile({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelId = FirebaseAuth.instance.currentUser!.uid;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Hotelallscr()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Hotel Profile"),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("hotels")
              .doc(hotelId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.data!.exists) {
              return const Center(
                child: Text("Hotel data not found",
                    style: TextStyle(color: Colors.white)),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /// HOTEL IMAGE
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: data["image"] != null &&
                            data["image"].toString().isNotEmpty
                        ? NetworkImage(data["image"])
                        : const AssetImage("assets/hotel.png")
                            as ImageProvider,
                  ),

                  const SizedBox(height: 20),

                  /// HOTEL NAME
                  ListTile(
                    tileColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: const Icon(Icons.other_houses_outlined,
                        color: Colors.black),
                    title: Text(
                      data["name"] ?? "Hotel Name",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOCATION
                  ListTile(
                    tileColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: const Icon(Icons.location_on,
                        color: Colors.black),
                    title: Text(
                      data["location"] ?? "Location",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ALL BOOKINGS
                  ListTile(
                    tileColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading:
                        const Icon(Icons.book, color: Colors.black),
                    title: const Text("All bookings",
                        style: TextStyle(color: Colors.black)),
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HotelPaymentsHistory(hotelId: hotelId),));
                      // navigate to bookings page
                    },
                  ),

                  const SizedBox(height: 20),

                  /// HOTEL ADD
                  ListTile(onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Hoteladd(),));
                  },
                    tileColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: const Icon(Icons.add_home,
                        color: Colors.black),
                    title: const Text("Hotel Add",
                        style: TextStyle(color: Colors.black)),
                  ),SizedBox(height: 20,),
                   ListTile(onTap: () {
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterLogin(),));
                   },
                    tileColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: const Icon(Icons.logout,
                        color: Colors.black),
                    title: const Text("Logout",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
