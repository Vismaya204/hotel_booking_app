import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';

class Paymenthistory extends StatefulWidget {
  const Paymenthistory({super.key});

  @override
  State<Paymenthistory> createState() => _PaymenthistoryState();
}

class _PaymenthistoryState extends State<Paymenthistory> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Alluserscreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text(
            "Payment History",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("payments")
              .doc(uid)
              .collection("history")
              .orderBy("date", descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No Payment Found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final docs = snap.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: data["hotelImage"] != null
                            ? Image.network(
                                data["hotelImage"],
                                width: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.hotel, size: 40),

                        title: Text(data["hotelName"] ?? "No hotel"),

                        subtitle: Text(
                          "Paid: ₹${data["price"] ?? 0}\nMethod: ${data["paymentMethod"] ?? ""}",
                        ),

                        trailing: Text(
                          data["date"] == null ? "" : formatDate(data["date"]),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),

                      // Cancel button placed neatly below
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection("payments")
                                .doc(uid)
                                .collection("history")
                                .doc(doc.id)
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Payment canceled")),
                            );
                          },
                          child: const Text("Cancel"),
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
    );
  }

  String formatDate(Timestamp t) {
    final d = t.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}
