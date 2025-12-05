import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hoteldetails extends StatefulWidget {
  final QueryDocumentSnapshot hotelData; // ⬅ hotel Firestore document

  const Hoteldetails({super.key, required this.hotelData});

  @override
  State<Hoteldetails> createState() => _HoteldetailsState();
}

class _HoteldetailsState extends State<Hoteldetails> {
  List<String> allRoomImages = [];
  bool loadingRooms = true;

  @override
  void initState() {
    super.initState();
    fetchRoomImages();
  }

  /// 🔥 FETCH ROOM IMAGES FROM FIRESTORE:
  /// hotels → hotelId → rooms → images[]
  Future<void> fetchRoomImages() async {
    try {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection("hotels")
          .doc(widget.hotelData.id)
          .collection("rooms")
          .get();

      List<String> temp = [];

      for (var room in roomsSnapshot.docs) {
        List images = room["images"] ?? [];
        for (var img in images) {
          temp.add(img.toString());
        }
      }

      setState(() {
        allRoomImages = temp;
        loadingRooms = false;
      });
    } catch (e) {
      print("Room Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var hotel = widget.hotelData.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber,
        title: Text(
          hotel["name"],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ MAIN HOTEL IMAGE
            Image.network(
              hotel["image"],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 10),

            // ⭐ HOTEL NAME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                hotel["name"],
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 5),

            // ⭐ LOCATION + RATING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  Text(hotel["location"]),
                  const Spacer(),
                  const Icon(Icons.star, color: Colors.amber),
                  Text(hotel["rating"].toString()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ ROOM IMAGES TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Room Images",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ ROOM IMAGES LIST
            loadingRooms
                ? const Center(child: CircularProgressIndicator())
                : allRoomImages.isEmpty
                    ? const Center(
                        child: Text(
                          "No room images available",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allRoomImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              width: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(allRoomImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

            const SizedBox(height: 20),

            // ⭐ DISCOUNT + REVIEWS
            Row(
              children: [
                const SizedBox(width: 12),
                if (hotel["discount"] != null &&
                    hotel["discount"].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "${hotel['discount']}% OFF",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(width: 15),
                Text("Reviews: ⭐ ${hotel["rating"]}"),
              ],
            ),

            const SizedBox(height: 20),

            // ⭐ DESCRIPTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Description",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Text(
                hotel["description"] ?? "No description available.",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 25),

            // ⭐ PRICE + BOOK NOW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "₹${hotel["price"]}/night",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {},
                      child: const Text("BOOK NOW"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
