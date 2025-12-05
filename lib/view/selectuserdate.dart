import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';


class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  DateTime? checkInDate;
DateTime? checkOutDate;

final TextEditingController checkInController = TextEditingController();
final TextEditingController checkOutController = TextEditingController();
final TextEditingController location=TextEditingController();

  int guests = 1;
  int rooms = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPmaRSgLbkrFHU264KUW6iP8Qmc__C2vy12Ynb9UquSJ1F9EAOVXhDLrc&s"
             , // Replace with your image
              fit: BoxFit.cover,
            ),
          ),

          // White rounded container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              height: 520,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to your next\nAdventure!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Discover the Perfect Stay with WanderStay",
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location Field
                    const Text("Where?"),
                    const SizedBox(height: 5),
                    TextField(controller: location,
                      decoration: InputDecoration(
                        hintText: "Location",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Date fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Check-in"),
                              const SizedBox(height: 5),
                              TextField(
  controller: checkInController,
  readOnly: true,
  onTap: () async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        checkInDate = picked;
        checkInController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  },
  decoration: InputDecoration(
    hintText: "DD/MM/YY",
    suffixIcon: Icon(Icons.calendar_month),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Check-out"),
                              const SizedBox(height: 5),
                             TextField(
  controller: checkOutController,
  readOnly: true,
  onTap: () async {
    if (checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select Check-in date first")),
      );
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: checkInDate!.add(Duration(days: 1)),
      firstDate: checkInDate!.add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        checkOutDate = picked;
        checkOutController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  },
  decoration: InputDecoration(
    hintText: "DD/MM/YY",
    suffixIcon: Icon(Icons.calendar_month),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Guests & Rooms counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Guests
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Guests"),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _counterButton(Icons.remove, () {
                                  setState(() {
                                    if (guests > 1) guests--;
                                  });
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    guests.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                _counterButton(Icons.add, () {
                                  setState(() {
                                    guests++;
                                  });
                                }),
                              ],
                            ),
                          ],
                        ),

                        // Rooms
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Room"),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                _counterButton(Icons.remove, () {
                                  setState(() {
                                    if (rooms > 1) rooms--;
                                  });
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    rooms.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                _counterButton(Icons.add, () {
                                  setState(() {
                                    rooms++;
                                  });
                                }),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // FIND button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () { 

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>Alluserscreen() ,));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "FIND",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Counter button widget
  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
