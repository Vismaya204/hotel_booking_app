import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Allbookingviewadmin extends StatelessWidget {
  final String userId;

  const Allbookingviewadmin({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Booking Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .doc(userId)
            .collection('history')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No booking found"));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final Timestamp? createdAt = data['createdAt'];
          final Timestamp? checkinTs = data['checkin'];
          final Timestamp? checkoutTs = data['checkout'];

          final checkin = checkinTs?.toDate();
          final checkout = checkoutTs?.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HOTEL INFO
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['hotelImage'] ?? '',
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['hotelName'] ?? 'Hotel',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text("Price: ₹${data['price'] ?? 0} / night"),

                const SizedBox(height: 20),

                /// BOOKING DETAILS
                Text(
                  "Booking Date: ${createdAt != null ? _formatDate(createdAt) : '-'}",
                ),
                Text(
                  "Check-in: ${checkin != null ? _formatDate(checkinTs!) : '-'}",
                ),
                Text(
                  "Check-out: ${checkout != null ? _formatDate(checkoutTs!) : '-'}",
                ),
                Text("Guests: ${data['guests'] ?? 1}"),
                Text("Rooms: ${data['rooms'] ?? 1}"),

                const Divider(height: 40),

                /// BILLING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Amount"),
                    Text("₹${data['price'] ?? 0} x ${data['nights'] ?? 1}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tax (5%)"),
                    Text("₹${data['tax'] ?? 0}"),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${data['total'] ?? 0}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}-${date.month}-${date.year}";
  }
}
