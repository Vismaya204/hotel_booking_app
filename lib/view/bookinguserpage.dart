import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/payment.dart';

class BookingSummary extends StatelessWidget {
  // const constructor
  final String hotelName;
  final String hotelImage;
  final String price;
  final DateTime checkin;
  final DateTime checkout;
  final int guests;
  final int rooms;
  final String hotelId;

  const BookingSummary({
    super.key,
    required this.hotelName,
    required this.hotelImage,
    required this.price,
    required this.checkin,
    required this.checkout,
    required this.guests,
    required this.rooms,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context) {
    // price numeric
    final priceNum = int.tryParse(price) ?? 0;

    final nights = checkout.difference(checkin).inDays;
    final amount = priceNum * nights;
    final tax = (amount * 0.05).round();
    final total = amount + tax;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Booking Summary",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    hotelImage,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hotelName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Text("Price: ₹$price / night"),

            SizedBox(height: 20),

            Text(
              "Booking Date: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
            ),
            Text("Check-in: ${checkin.day}-${checkin.month}-${checkin.year}"),
            Text(
              "Check-out: ${checkout.day}-${checkout.month}-${checkout.year}",
            ),
            Text("Guests: $guests"),
            Text("Rooms: $rooms"),

            Divider(height: 40, color: Colors.black),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Amount"), Text("₹$price x $nights")],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Tax (5%)"), Text("₹$tax")],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("₹$total", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            Spacer(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Payment(
                          hotelId: hotelId,
                          hotelName: hotelName,
                          hotelImage: hotelImage,
                          price: int.parse(price),
                          checkin: checkin,
                          checkout: checkout,
                          guests: guests,
                          rooms: rooms,
                          email: FirebaseAuth.instance.currentUser!.email,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "CONTINUE TO PAYMENT",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
