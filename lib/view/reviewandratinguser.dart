import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';   // ⭐ add this
import 'package:flutter/material.dart';

class Reviewandratinguser extends StatefulWidget {
  final String hotelId;

  const Reviewandratinguser({super.key, required this.hotelId});

  @override
  State<Reviewandratinguser> createState() => _ReviewandratinguserState();
}

class _ReviewandratinguserState extends State<Reviewandratinguser> {
  int rating = 0;
  TextEditingController reviewController = TextEditingController();

  buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        size: 35,
        color: index <= rating ? Colors.amber : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review & Rating"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rate your experience",
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),

            Row(children: List.generate(5, (i) => buildStar(i + 1))),

            const SizedBox(height: 20),

            const Text("Write your review",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            TextField(
              controller: reviewController,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () async {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select rating"),
                    ),
                  );
                  return;
                }

                // ⭐ get logged-in user email
                final user = FirebaseAuth.instance.currentUser;

                await FirebaseFirestore.instance
                    .collection("hotels")
                    .doc(widget.hotelId)
                    .collection("reviews")
                    .add({
                  "rating": rating,
                  "comment": reviewController.text,
                  "email": user?.email ?? "Guest",   // ⭐ save email
                  "date": Timestamp.now(),
                });

                Navigator.pop(context);
              },
              child: const Text("Submit Review"),
            )
          ],
        ),
      ),
    );
  }
}
