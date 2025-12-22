import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/hotel_allscr.dart';

class HotelPaymentsHistory extends StatefulWidget {
  final String hotelId;

  const HotelPaymentsHistory({
    super.key,
    required this.hotelId,
  });

  @override
  State<HotelPaymentsHistory> createState() => _HotelPaymentsHistoryState();
}

class _HotelPaymentsHistoryState extends State<HotelPaymentsHistory> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async{
      Navigator.push(context, MaterialPageRoute(builder: (context) => Hotelallscr(),));return false;
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text(
            "Payments History",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('history') // ✅ all users' history subcollections
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
      
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (!snapshot.hasData) {
              return const Center(child: Text("No bookings found"));
            }
      
            /// ✅ FILTER ONLY SELECTED HOTEL
            final filteredDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['hotelId'] == widget.hotelId; // 👈 use widget.hotelId
            }).toList();
      
            if (filteredDocs.isEmpty) {
              return const Center(child: Text("No bookings for this hotel"));
            }
      
            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final data = filteredDocs[index].data() as Map<String, dynamic>;
      
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: data["hotelImage"] != null
                        ? Image.network(
                            data["hotelImage"],
                            width: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.hotel, size: 40),
                    title: Text(
                      data["hotelName"] ?? "No hotel",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Paid: ₹${data["total"] ?? 0}"),
                        Text("User: ${data["userEmail"] ?? ""}"),
                        Text("Method: ${data["paymentMethod"] ?? ""}"),
                        Text("Guests: ${data["guests"] ?? ""}\n Rooms: ${data["rooms"] ?? ""}"),
                        Text("Check-in: ${formatDate(data["checkin"])}"),
                        Text("Check-out: ${formatDate(data["checkout"])}"),
                      ],
                    ),
                    trailing: Text(
                      data["createdAt"] == null ? "" : formatDate(data["createdAt"]),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String formatDate(Timestamp? t) {
    if (t == null) return "";
    final d = t.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}