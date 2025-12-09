import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/view/hoteldetails.dart';
import 'package:hotelbookingapp/view/profile.dart';
import 'package:hotelbookingapp/view/selectuserdate.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> favoriteHotels = [];
   // Add this
    @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Load favorite hotel IDs from Firestore
  void loadFavorites() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .get();

    setState(() {
      favoriteHotels = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Toggle favorite
  void toggleFavorite(String hotelId, Map<String, dynamic> data) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(hotelId);

    if (favoriteHotels.contains(hotelId)) {
      await docRef.delete();
      setState(() {
        favoriteHotels.remove(hotelId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Removed from favorites")));
    } else {
      await docRef.set(data);
      setState(() {
        favoriteHotels.add(hotelId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added to favorites")));
    }
  }
  addToFavorite(String hotelId, Map<String, dynamic> data) async {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .collection("favorites")
      .doc(hotelId)
      .set(data);

   ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to favorites")),
    );
  } 
  TextEditingController searchController = TextEditingController();

  String searchQuery = "";
  String selectedLocation = "";
  int selectedRating = 0;
  double minPrice = 0;
  double maxPrice = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme:  IconThemeData(color: Colors.black),
        leading:  Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
          },
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),

      backgroundColor: Colors.amber,

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔍 SEARCH BAR
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: "Search hotels…",
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 10),

                // FILTER BUTTON
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HotelSearchScreen(),));} ,
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "All Hotels",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🏨 HOTEL GRID
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("hotels")
                    .where("status", isEqualTo: "approved")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var hotels = snapshot.data!.docs;

                  // FILTER HOTELS
                  var filteredHotels = hotels.where((hotel) {
                    String name =
                        hotel['name'].toString().toLowerCase();
                    String location =
                        hotel['location'].toString().toLowerCase();
                    // double price =
                    //     double.tryParse(hotel['price'].toString()) ?? 0;
                    // int rating =
                        // int.tryParse(hotel['rating'].toString()) ?? 0;

                    bool matchesSearch =
                        name.contains(searchQuery) ||
                        location.contains(searchQuery);

                    bool matchesLocation = selectedLocation.isEmpty
                        ? true
                        : location == selectedLocation.toLowerCase();

                    // bool matchesRating =
                        // selectedRating == 0 ? true : rating == selectedRating;

                    // bool matchesPrice =
                    //     price >= minPrice && price <= maxPrice;

                    return matchesSearch &&
                        matchesLocation ;
                        // matchesRating ;
                        // matchesPrice;
                  }).toList();

                  return GridView.builder(
                    itemCount: filteredHotels.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      var hotel = filteredHotels[index];

                     return Card(
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10)),
  child: Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                           Hoteldetails(
        hotelId: hotel.id,
        hotel: hotel.data() as Map<String, dynamic>,
      ),));
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
              child: Image.network(
                hotel["image"],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(hotel["name"],
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(hotel["location"],
                style: TextStyle(color: Colors.grey)),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                  ],
                ),

                if (hotel['discount'] != null &&
                    hotel['discount'] != 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("${hotel['discount']}% OFF",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),

   Positioned(
  right: 8,
  top: 8,
  child: IconButton(
    icon: Icon(
      favoriteHotels.contains(hotel.id) 
          ? Icons.favorite    // Filled heart if favorite
          : Icons.favorite_border, // Outline heart if not favorite
      color: favoriteHotels.contains(hotel.id) 
          ? Colors.red      // Red color if favorite
          : Colors.grey,    // Grey color if not favorite
    ),
    onPressed: () {
      toggleFavorite(hotel.id, hotel.data() as Map<String, dynamic>);
    },
  ),
),


    ],
  ),
);

                    },
                  );
                },
              ),
            ),
            
          ],
        ),
      ),
    );
  }

}