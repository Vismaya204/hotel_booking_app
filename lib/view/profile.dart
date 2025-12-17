import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/view/Favourit.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';
import 'package:hotelbookingapp/view/paymenthistory.dart';
import 'package:hotelbookingapp/view/register_login.dart';
import 'package:hotelbookingapp/view/settings.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Alluserscreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                        color: Colors.white,
                      ),
                    ),

                    // Show Firestore email
                    Text(email, style: const TextStyle(color: Colors.white)),

                    const SizedBox(height: 30),

                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: Colors.amber,
                      leading: Icon(Icons.history, color: Colors.white),
                      title: const Text(
                        "History",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Paymenthistory(),
                            ),
                          );
                        },
                        child: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),

                    SizedBox(height: 20),

                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: Colors.amber,
                      leading: const Icon(Icons.favorite, color: Colors.white),
                      title: const Text(
                        "Favourite",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Favourit()),
                          );
                        },
                        child: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Setting()),
                        );
                      },
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Colors.amber,
                        leading: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        title: const Text(
                          "Settings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    SizedBox(height: 20),
                    ListTile(onTap: () {
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => RegisterLogin(),) );
                    },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: Colors.amber,
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                     
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
