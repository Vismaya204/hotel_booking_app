import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/view/allbookingviewadmin.dart';
import 'package:hotelbookingapp/view/edithotelscreenadmin.dart';


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
  int hotelscount = 0;

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

    var totalHotelsSnap = await FirebaseFirestore.instance
        .collection("hotels")
        .count()
        .get();

    setState(() {
      pendingCount = pending.size;
      approvedCount = approved.size;
      rejectedCount = rejected.size;
      bookingCount = bookingCountSnap.count ?? 0;
      hotelscount = totalHotelsSnap.count ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔥 Dashboard Cards
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: SizedBox(
               height: 70,
               child: ListView(
                 scrollDirection: Axis.horizontal,
                 children: [
                   SizedBox(
                     width: 70, 
                     child: statCard("Pending", pendingCount, Colors.orange),
                   ),
                   SizedBox(width: 10),
                   SizedBox(
                     width: 70,
                     child: statCard("Approved", approvedCount, Colors.green),
                   ),
                   SizedBox(width: 10),
                   SizedBox(
                     width: 70,
                     child: statCard("Rejected", rejectedCount, Colors.red),
                   ),
                   SizedBox(width: 10),
                   SizedBox(
                     width: 70,
                     child: statCard("Bookings", bookingCount, Colors.blue),
                   ),
                   SizedBox(width: 10),
                   SizedBox(
                     width: 70,
                     child: statCard("Hotels", hotelscount, Colors.purple),
                   ),
                 ],
               ),
             ),
           ),


            const SizedBox(height: 20),

            dashboardButton(context, "Pending Hotels", const PendingHotels()),SizedBox(height: 20),
            dashboardButton(context, "Approved Hotels", const ApprovedHotels()),SizedBox(height: 20),
            dashboardButton(context, "Rejected Hotels", const RejectedHotels()),SizedBox(height: 20),
            dashboardButton(context, "All Bookings", const AllBookingsScreen()),SizedBox(height: 20),
            dashboardButton(context,"All hotelsdetails",const AdminApprovedHotels()),
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
    return SizedBox(height: 80,width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            // minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
        ),
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
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Pending Hotels"),
      ),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${hotel["name"] ?? "Hotel"} approved ✅"),
                              backgroundColor: Colors.green,
                              
                            ),
                          );
                          await FirebaseFirestore.instance
                              .collection("hotels")
                              .doc(hotel.id)
                              .update({"status": "approved"});

                         
                        },
                        child: const Text("Approve"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async { ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${hotel["name"] ?? "Hotel"} rejected ❌"),
                              backgroundColor: Colors.red,
                              
                            ),
                          );
                          await FirebaseFirestore.instance
                              .collection("hotels")
                              .doc(hotel.id)
                              .update({"status": "rejected"});

                         
                        },
                        child: const Text("Reject"),
                      ),
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
class ApprovedHotels extends StatelessWidget {
  const ApprovedHotels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Approved Hotels"),
      ),
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
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("All Bookings"),
      ),
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
              final data =
                  docs[index].data() as Map<String, dynamic>? ?? {};

              /// 🔐 SAFE FETCH
              // final totalPaid = data['totalAmount'] ??
              //     data['totalPrice'] ??
              //     data['price'] ??
              //     0;

              // final userEmail =
              //     data['useremail'] ?? data['email'] ?? 'Unknown';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Allbookingviewadmin(),
                    ),
                  );
                },
                child: Card(
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
                            fontWeight: FontWeight.bold,
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

                       

                        /// 🔥 TOTAL PAID (CHANGED)
                      
                          Text("paid: ₹${data['total'] ?? 0}",
                            
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                       
                        /// 👤 USER EMAIL (CHANGED)
                          Text(
                        "User Email: ${data['userEmail'] ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 14),
                      ),


                        const SizedBox(height: 8),
                      ],
                    ),
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

class AdminApprovedHotels extends StatelessWidget {
  const AdminApprovedHotels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels"),
        backgroundColor: Colors.amber,
      ),

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
              final hotel =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>EditHotelFull(
                        hotelId: snapshot.data!.docs[index].id,
                        hotel: hotel,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(12),
                  elevation: 3,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📌 Image
                      hotel["image"] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                hotel["image"],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : SizedBox(),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel["name"] ?? "Unnamed Hotel",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),

                            Text(
                              "📍 ${hotel['location'] ?? 'Unknown location'}",
                            ),
                            SizedBox(height: 4),

                            Text("Owner: ${hotel['email'] ?? 'Unknown email'}"),
                            SizedBox(height: 4),

                            Text(
                              "Hotel: ${hotel['status'] ?? ''}",
                              style: TextStyle(color: Colors.green),
                            ),

                            SizedBox(height: 10),

                           Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection("hotels")
            .doc(snapshot.data!.docs[index].id)
            .update({"status": "rejected"});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hotel moved to rejected")),
        );
      },
      child: Text("Reject"),
    ),

    SizedBox(width: 50),

    IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditHotelFull(
              hotelId: snapshot.data!.docs[index].id,
              hotel: hotel,
            ),
          ),
        );
      },
      icon: Icon(Icons.edit, color: Colors.black),
    ),
  ],
)

                          ],
                        ),
                      ),
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
