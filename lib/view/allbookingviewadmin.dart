import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Allbookingviewadmin extends StatelessWidget {
  const Allbookingviewadmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "All Bookings - Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('history') // ✅ ADMIN QUERY
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
          


              /// SAFE TIMESTAMPS
              final Timestamp? createdAt =
                  data['createdAt'] is Timestamp ? data['createdAt'] : null;
              final Timestamp? checkin =
                  data['checkin'] is Timestamp ? data['checkin'] : null;
              final Timestamp? checkout =
                  data['checkout'] is Timestamp ? data['checkout'] : null;
                 final num price = data['price'] ?? 0;
  final int rooms = data['rooms'] ?? 1;
  final num tax = data['tax'] ?? 0;

  /// CALCULATION
  final num subtotal = price * rooms;
  final num totalPaid = subtotal + tax;


              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HOTEL INFO
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: data['hotelImage'] != null
                                ? Image.network(
                                    data['hotelImage'],
                                    width: 120,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported,
                                            size: 60),
                                  )
                                : const Icon(Icons.image_not_supported,
                                    size: 60),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['hotelName'] ?? "Hotel",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// USER INFO
                      Text(
                        "User Email: ${data['userEmail'] ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 6),

                      /// BOOKING DETAILS
                      Text("Guests: ${data['guests'] ?? 1}"),
                      Text("Rooms: ${data['rooms'] ?? 1}"),
                      Text("Nights: ${data['nights'] ?? 1}"),

                      const SizedBox(height: 6),

                      Text("Booking Date: ${_formatDate(createdAt)}"),
                      Text("Check-in: ${_formatDate(checkin)}"),
                      Text("Check-out: ${_formatDate(checkout)}"),

                      const Divider(height: 24),

                      /// BILLING
                     /// BILLING
/// BILLING
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Bill Details",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),

    const SizedBox(height: 6),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Price"),
        Text("₹$price"),
      ],
    ),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Rooms"),
        Text("$rooms"),
      ],
    ),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Subtotal"),
        Text("₹$subtotal"),
      ],
    ),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Tax"),
        Text("₹$tax"),
      ],
    ),

    const Divider(height: 24),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Total Paid",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "₹$totalPaid",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ],
),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final d = timestamp.toDate();
    return "${d.day}-${d.month}-${d.year}";
  }
}
