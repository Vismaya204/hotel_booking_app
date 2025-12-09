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

  var bookingCountSnap = await FirebaseFirestore.instance
      .collectionGroup("history")
      .count()
      .get();

  setState(() {
    pendingCount = pending.size;
    approvedCount = approved.size;
    rejectedCount = rejected.size;
    bookingCount = bookingCountSnap.count ?? 0;

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
      appBar: AppBar(backgroundColor: Colors.amber,title: const Text("Pending Hotels")),
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
      appBar: AppBar(backgroundColor: Colors.amber,title: const Text("Approved Hotels")),
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
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber,title: const Text("All Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup("history")
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
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
  margin: const EdgeInsets.all(10),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        /// 🔵 Hotel Name
        Text(
          data["hotelName"] ?? "Hotel",
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 5),

        /// 🏙 Location
        if (data["location"] != null)
          Text("📍 ${data["location"]}"),

        const SizedBox(height: 5),

        /// 🖼 Hotel Image
        if (data["hotelImage"] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              data["hotelImage"],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 10),

        /// 💼 Room
        if (data["room"] != null)
          Text("Room: ${data["room"]}"),

        /// 🔥 Price
        Text("Paid: ₹${data["price"]}"),
        
        /// 🟡 Dates
        if (data["checkIn"] != null)
          Text("Check-in: ${data["checkIn"]}"),

        if (data["checkOut"] != null)
          Text("Check-out: ${data["checkOut"]}"),

        /// 👤 User
        Text("User: ${data["useremail"]}"),

        const SizedBox(height: 8),

        /// 🔴 Cancel Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await docs[index].reference.delete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking removed")),
              );
            },
            child: const Text("Cancel Booking"),
          ),
        )
      ],
    ),
  ),
);


            },
          );
        },
      ),
    );
  }
}
