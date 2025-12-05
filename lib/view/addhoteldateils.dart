import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:provider/provider.dart';

class AddHotelDetails extends StatefulWidget {
  final String hotelName; // fetched from login
  final String hotelId; // hotel UID from Firebase Auth

  const AddHotelDetails({
    super.key,
    required this.hotelName,
    required this.hotelId,
  });

  @override
  State<AddHotelDetails> createState() => _AddHotelDetailsState();
}

class _AddHotelDetailsState extends State<AddHotelDetails> {
  final TextEditingController roomType = TextEditingController();
  final TextEditingController floor = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController available = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HotelBookingController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.hotelName),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Room Images
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => controller.pickRoomImages(),
                  child: const Text("Add Room Images"),
                ),
              ),
              const SizedBox(height: 10),

              // ✅ Preview selected images (handles both web & mobile)
              Wrap(
                children: kIsWeb
                    ? controller.roomImagesWeb.map((bytes) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(
                            bytes,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList()
                    : controller.roomImagesMobile.map((xfile) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(xfile.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
              ),

              const SizedBox(height: 20),

              // Room Type
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: roomType,
                decoration: InputDecoration(
                  hintText: "Room Type",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Floor
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: floor,
                decoration: InputDecoration(
                  hintText: "Floor",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Price
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: available,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Available",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
             
              SizedBox(height: 10),
              // Description
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: description,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await controller.saveRoomDetails(
                    hotelId: widget.hotelId,
                    roomType: roomType.text,
                    floor: floor.text,
                    price: price.text,
                    available: available.text,
                    
                    

                    description: description.text,

                    context: context,
                  );
                },
                child: Text(
                  "Submit Room Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
