import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hotelhome extends StatefulWidget {
  final String hotelId;

  const Hotelhome({super.key, required this.hotelId});

  @override
  State<Hotelhome> createState() => _HotelhomeState();
}

class _HotelhomeState extends State<Hotelhome> {
  Map<String, dynamic>? hotelData;
  List<Map<String, dynamic>> rooms = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHotelDetails();
  }

  Future<void> fetchHotelDetails() async {
    try {
      // Fetch hotel document
      final doc = await FirebaseFirestore.instance
          .collection("hotels")
          .doc(widget.hotelId)
          .get();

      if (!doc.exists) return;

      hotelData = doc.data();

      // Fetch rooms
      final roomSnap = await FirebaseFirestore.instance
          .collection("hotels")
          .doc(widget.hotelId)
          .collection("rooms")
          .get();

      rooms = roomSnap.docs.map((r) {
        List images = r["images"] ?? [];
        String price = r["price"].toString();
        bool available = r["available"] ?? false;
        return {
          "images": images,
          "price": price,
          "available": available,
        };
      }).toList();

      setState(() => loading = false);
    } catch (e) {
      print("Error fetching hotel: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hotelData == null) {
      return const Scaffold(
        body: Center(child: Text("Hotel not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(hotelData!["name"] ?? "Hotel"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Hotel Image
            hotelData!["image"] != null
                ? Image.network(
                    hotelData!["image"],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey,
                    child: const Icon(Icons.hotel, size: 50),
                  ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                hotelData!["name"] ?? "",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 4),
                  Text(hotelData!["location"] ?? ""),
                ],
              ),
            ),

            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Rooms",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            rooms.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("No rooms available"),
                  )
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.all(8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: room["images"].isNotEmpty
                                    ? Image.network(
                                        room["images"][0],
                                        width: 180,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey,
                                        width: 180,
                                        height: 200,
                                        child: const Icon(Icons.room, size: 50),
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: room["available"]
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    room["available"]
                                        ? "Available"
                                        : "Unavailable",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  color: Colors.black54,
                                  child: Text(
                                    "₹${room["price"]}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                "Description",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                hotelData!["description"] ?? "No description available",
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                "User Reviews",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("hotels")
                  .doc(widget.hotelId)
                  .collection("reviews")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("No reviews yet"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    var data = docs[i].data() as Map<String, dynamic>;
                    int rating = data["rating"] ?? 0;
                    return ListTile(
                      title: Text(data["email"] ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              rating,
                              (index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                            ),
                          ),
                          Text(data["comment"] ?? ""),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
