import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;
  int bookingCount = 0;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  loadCounts() async {
    var pending = await FirebaseFirestore.instance
        .collection("hotels")
        .where("status", isEqualTo: "pending")
        .get();

    var approved = await FirebaseFirestore.instance
        .collection("hotels")
        .where("status", isEqualTo: "approved")
        .get();

    var rejected = await FirebaseFirestore.instance
        .collection("hotels")
        .where("status", isEqualTo: "rejected")
        .get();

     int totalBookings = 0;

  var users = await FirebaseFirestore.instance.collection("payments").get();

  for (var u in users.docs) {
    var hist = await FirebaseFirestore.instance
        .collection("payments")
        .doc(u.id)
        .collection("history")
        .get();

    totalBookings += hist.size;
  }
    setState(() {
      pendingCount = pending.size;
      approvedCount = approved.size;
      rejectedCount = rejected.size;
      bookingCount = totalBookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔥 Dashboard Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                statCard("Pending", pendingCount, Colors.orange),
                statCard("Approved", approvedCount, Colors.green),
                statCard("Rejected", rejectedCount, Colors.red),
                statCard("Bookings", bookingCount, Colors.blue),
              ],
            ),

            const SizedBox(height: 20),

            dashboardButton(context, "Pending Hotels", const PendingHotels()),
            dashboardButton(context, "Approved Hotels", const ApprovedHotels()),
            dashboardButton(context, "Rejected Hotels", const RejectedHotels()),
            dashboardButton(context, "All Bookings", const AllBookingsScreen()),
          ],
        ),
      ),
    );
  }

  // ⭐ Count Card
  Widget statCard(String text, int count, Color color) {
    return Container(
      height: 80,
      width: 85,
      decoration: BoxDecoration(
        color: color.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$count",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  // ⭐ Navigation Button
  Widget dashboardButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Text(title),
      ),
    );
  }
}

// 🚀 Placeholder Screens
class PendingHotels extends StatelessWidget {
  const PendingHotels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Hotels")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("hotels")
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending hotels"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var hotel = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(hotel["name"] ?? "Unnamed Hotel"),
                  subtitle: Text("Location: ${hotel["location"] ?? "Unknown"}"),
                  trailing: Text(hotel["status"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ApprovedHotels extends StatelessWidget {
  const ApprovedHotels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approved Hotels")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("hotels")
            .where("status", isEqualTo: "approved")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No approved hotels"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var hotel = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(hotel["name"] ?? "Unnamed Hotel"),
                  subtitle: Text("Location: ${hotel["location"] ?? "Unknown"}"),
                  trailing: Text(hotel["status"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RejectedHotels extends StatelessWidget {
  const RejectedHotels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rejected Hotels")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("hotels")
            .where("status", isEqualTo: "rejected")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No rejected hotels"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var hotel = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(hotel["name"] ?? "Unnamed Hotel"),
                  subtitle: Text("Location: ${hotel["location"] ?? "Unknown"}"),
                  trailing: Text(hotel["status"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AllBookingsScreen extends StatelessWidget {
  const AllBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("All Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .doc(uid)
            .collection("history").where("status", isEqualTo: "booking")
            .orderBy(
              "date",
              descending: true,
            ) // make sure this is the right collection
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

                        subtitle: Column(
                          children: [Text(data["useremail"]??"No user email"),
                            Text(
                              "Paid: ₹${data["price"] ?? 0}\nMethod: ${data["paymentMethod"] ?? ""}",
                            ),
                          ],
                        ),

                        trailing: Text(
                          data["date"] == null ? "" : formatDate(data["date"]),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
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
    ); 
    
  }
  String formatDate(Timestamp t) {
    final d = t.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
  }

