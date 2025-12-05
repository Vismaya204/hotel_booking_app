import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Column(
        children: [
          // ✅ Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search hotels or bookings...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // ✅ Hotel list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hotels')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No pending hotel registrations",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                var hotels = snapshot.data!.docs;

                // ✅ Apply search filter
                var filteredHotels = hotels.where((hotel) {
                  String name = hotel['name'].toString().toLowerCase();
                  String id = hotel['id'].toString().toLowerCase();
                  return name.contains(searchQuery) || id.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredHotels.length,
                  itemBuilder: (context, index) {
                    var hotel = filteredHotels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(hotel['name']),
                        subtitle: Text("ID: ${hotel['id']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('hotels')
                                    .doc(hotel.id)
                                    .update({'status': 'approved'});
                              },
                              child: const Text("Approved"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('hotels')
                                    .doc(hotel.id)
                                    .update({'status': 'rejected'});
                              },
                              child: const Text("Rejected"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ User booking details section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No user bookings found",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                var bookings = snapshot.data!.docs;

                // ✅ Apply search filter
                var filteredBookings = bookings.where((booking) {
                  String userName = booking['userName'].toString().toLowerCase();
                  String hotelName = booking['hotelName'].toString().toLowerCase();
                  return userName.contains(searchQuery) || hotelName.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    var booking = filteredBookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text("User: ${booking['userName']}"),
                        subtitle: Text("Hotel: ${booking['hotelName']}"),
                        trailing: Text("Status: ${booking['status']}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}