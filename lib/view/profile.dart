import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/view/Favourit.dart';
import 'package:hotelbookingapp/view/bookinghistory.dart';
import 'package:hotelbookingapp/view/payment.dart';
import 'package:hotelbookingapp/view/settings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data found"));
          }

          final data = snapshot.data!.data()!;
          final username = data['username'] ?? "No Username";
          final email = data['email'] ?? "No Email";

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 10),

                  // Show Firestore username
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // Show Firestore email
                  Text(
                    email,
                    style: const TextStyle(color: Colors.black),
                  ),

                  const SizedBox(height: 30),

                  
                   ListTile(
                      tileColor: Colors.white,
                      leading: const Icon(Icons.history),
                      title: const Text("History"),
                      trailing: GestureDetector(onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Bookinghistory(),));
                      },child: const Icon(Icons.arrow_forward_ios)),
                    
                    ),
                  
                   SizedBox(height: 20),

                 ListTile(
                      tileColor: Colors.white,
                      leading: const Icon(Icons.favorite),
                      title: const Text("Favourite"),
                      trailing: GestureDetector(onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder:(context) => Favourit(), ));
                      },child: const Icon(Icons.arrow_forward_ios)),
                      
                    ),
                  
                  const SizedBox(height: 20),

                  GestureDetector(onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>Setting()));
                  },
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                     
                    ),
                  ),
                  const SizedBox(height: 20),

                 ListTile(
                      tileColor: Colors.white,
                      leading: const Icon(Icons.payment),
                      title: const Text("Payment"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Payment(),));},
                    ),
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}