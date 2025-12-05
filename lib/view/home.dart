import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/view/hoteldetails.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        iconTheme: const IconThemeData(color: Colors.black),
        leading: const CircleAvatar(
          backgroundColor: Colors.black,
          child: Icon(Icons.person, color: Colors.white),
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
                    onPressed: () => openFilterSheet(),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>Hoteldetails(hotelData: hotel) ));
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

                            const SizedBox(height: 8),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                hotel["name"],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                hotel["location"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      // Text(
                                      //   hotel["rating"].toString(),
                                      //   style: const TextStyle(
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                    ],
                                  ),
                                  if (hotel['discount'] != null &&
                                      hotel['discount'] != 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${hotel['discount']}% OFF",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
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

  // 🔥 FILTER BOTTOMSHEET
  void openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                      const Text("Filter",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = 0;
                            minPrice = 0;
                            maxPrice = 500;
                            selectedLocation = "";
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Ratings")),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (i) {
                      int rating = i + 1;
                      return GestureDetector(
                        onTap: () {
                          setStateSheet(() => selectedRating = rating);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selectedRating == rating
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Text("$rating",
                                  style: TextStyle(
                                      color: selectedRating == rating
                                          ? Colors.white
                                          : Colors.black)),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),
                  // const Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text("Price Range")),

                  RangeSlider(
                    values: RangeValues(minPrice, maxPrice),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                        "\$${minPrice.toInt()}",
                        "\$${maxPrice.toInt()}"),
                    onChanged: (value) {
                      setStateSheet(() {
                        minPrice = value.start;
                        maxPrice = value.end;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue),
                    onPressed: () {
                      setState(() {}); // update UI
                      Navigator.pop(context);
                    },
                    child: const Text("APPLY",
                        style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
