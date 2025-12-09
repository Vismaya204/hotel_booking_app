import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/bookinguserpage.dart';
import 'package:hotelbookingapp/view/reviewandratinguser.dart';

class Hoteldetails extends StatefulWidget {
    final String hotelId;
  final Map<String, dynamic> hotel;

  const Hoteldetails({
    super.key,
    required this.hotelId,
    required this.hotel,
  });
  @override
  State<Hoteldetails> createState() => _HoteldetailsState();
}

class _HoteldetailsState extends State<Hoteldetails> {
  List<Map<String, dynamic>> allRooms = []; // ⭐ store image + price
  bool loadingRooms = true;

  String? selectedImage;
  String? selectedRoomPrice; // ⭐ Track selected room price

  @override
  void initState() {
    super.initState();
    fetchRoomImages();
  }

  Future<void> fetchRoomImages() async {
    try {
      final roomsSnapshot = await FirebaseFirestore.instance
          .collection("hotels")
          .doc(widget.hotelId)
          .collection("rooms")
          .get();

      List<Map<String, dynamic>> temp = [];

      for (var room in roomsSnapshot.docs) {
        List images = room["images"] ?? [];
        String price = room["price"].toString(); // ⭐ assume each room has price

        for (var img in images) {
          temp.add({"image": img.toString(), "price": price});
        }
      }

      setState(() {
        allRooms = temp;
        loadingRooms = false;
      });
    } catch (e) {
      print("Room Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
  var hotel = widget.hotel;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          hotel["name"],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),actions: [IconButton(onPressed: () {
          
        }, icon: Icon(Icons.share_rounded,color: Colors.black,))],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ MAIN IMAGE
            Image.network(
              selectedImage ?? hotel["image"],
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ⭐ LOCATION + RATING
            Row(
              children: [
                Icon(Icons.location_on),
                Text(hotel["location"]),
                Spacer(),

                /// ⭐ Show live rating
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("hotels")
                     .doc(widget.hotelId)

                      .collection("reviews")
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return Text("0 ⭐");

                    var docs = snap.data!.docs;
                    double avg = 0;

                    if (docs.isNotEmpty) {
                      avg =
                          docs.fold<double>(
                            0,
                            (sum, e) => sum + (e["rating"] as num).toDouble(),
                          ) /
                          docs.length;
                    }

                    return Text(avg.toStringAsFixed(1) + "⭐");
                  },
                ),
              ],
            ),

            SizedBox(height: 20),
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
                : allRooms.isEmpty
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
                      itemCount: allRooms.length,
                      itemBuilder: (context, index) {
                        final room = allRooms[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = room["image"];
                              selectedRoomPrice = room["price"];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            width: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(room["image"]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 25),

            if (selectedRoomPrice != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "₹$selectedRoomPrice",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Description",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                hotel['description'] ?? "No description available",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            Reviewandratinguser(hotelId: widget.hotelId),

                      ),
                    );
                  },
                  child: Text(
                    " Add Reviews & Ratings",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 45),
                ),
                onPressed: () async {
  if (selectedRoomPrice == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select room")),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BookingSummary(
        hotelName: hotel["name"],
        hotelImage: selectedImage ?? hotel["image"],
        price: selectedRoomPrice!,
        checkin: DateTime.now(),
        checkout: DateTime.now().add(Duration(days: 1)),
        guests: 1,
        rooms: 1,
        hotelId: widget.hotelId,
      ),
    ),
  );
}
,

                child: const Text("BOOK NOW"),
              ),
            ), const SizedBox(height: 20),

 Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Text(
    "User Reviews",
    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  ),
),

StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection("hotels")
      .doc(widget.hotelId)

      .collection("reviews")
      .orderBy("date", descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    var docs = snapshot.data!.docs;

    if (docs.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Text("No reviews yet"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      itemBuilder: (context, i) {
        var data = docs[i].data();

        int rating = data["rating"] ?? 0;

        return ListTile(
          title: Text(
                data["email"] ?? "",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  rating,
                  (index) => Icon(Icons.star, color: Colors.amber, size: 20),
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
