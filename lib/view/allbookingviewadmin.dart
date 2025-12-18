import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Allbookingviewadmin extends StatelessWidget {
  final String hotelId;

  const Allbookingviewadmin({
    super.key,
    required this.hotelId,
  });

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
            .collectionGroup('history')
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
            return data['hotelId'] == hotelId;
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("No bookings for this hotel"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data =
                  filteredDocs[index].data() as Map<String, dynamic>;

              final Timestamp? createdAt =
                  data['createdAt'] is Timestamp ? data['createdAt'] : null;
              final Timestamp? checkin =
                  data['checkin'] is Timestamp ? data['checkin'] : null;
              final Timestamp? checkout =
                  data['checkout'] is Timestamp ? data['checkout'] : null;

              final num price = data['price'] ?? 0;
              final int rooms = data['rooms'] ?? 1;
              final num tax = data['tax'] ?? 0;

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

                      Text("User Email: ${data['userEmail'] ?? 'Unknown'}"),
                      Text("Guests: ${data['guests'] ?? 1}"),
                      Text("Rooms: ${data['rooms'] ?? 1}"),
                      Text("Nights: ${data['nights'] ?? 1}"),

                      const SizedBox(height: 6),

                      Text("Booking Date: ${_formatDate(createdAt)}"),
                      Text("Check-in: ${_formatDate(checkin)}"),
                      Text("Check-out: ${_formatDate(checkout)}"),

                      const Divider(height: 24),

                      const Text(
                        "Bill Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      _billRow("Price", "₹$price"),
                      _billRow("Rooms", "$rooms"),
                      _billRow("Subtotal", "₹$subtotal"),
                      _billRow("Tax", "₹$tax"),

                      const Divider(height: 24),

                      _billRow("Total Paid", "₹$totalPaid", bold: true),
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

  static Widget _billRow(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style:
                TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  static String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    final d = timestamp.toDate();
    return "${d.day}-${d.month}-${d.year}";
  }
}
