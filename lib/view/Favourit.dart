import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';
import 'package:hotelbookingapp/view/hoteldetails.dart';

class Favourit extends StatefulWidget {
  const Favourit({super.key});

  @override
  State<Favourit> createState() => _FavouritState();
}

class _FavouritState extends State<Favourit> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    

    return WillPopScope(onWillPop: () async{Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Alluserscreen()),
      );
      return false;
      
    },
      child: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text("Favorite", style: TextStyle(color: Colors.black)),
        ),
      
        body: StreamBuilder(
        stream: FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("favorites") // <- make sure it matches Home screen
        .snapshots(),
        builder: (context, snap) {
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      
      var favs = snap.data!.docs;
      
      if (favs.isEmpty) {
        return const Center(child: Text("No favourites added"));
      }
      
      return ListView.builder(
        itemCount: favs.length,
        itemBuilder: (context, i) {
          var fav = favs[i].data();
          return ListTile(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Hoteldetails(hotelId: favs[i].id,
            hotel: fav,),));
          },
            leading: Image.network(fav["image"], width: 60, fit: BoxFit.cover,),
            title: Text(fav["name"]),
            subtitle: Text(fav["location"]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("favorites")
                    .doc(favs[i].id)
                    .delete();
              },
            ),
          );
        },
      );
        },
      ),
      
      ),
    );
  }
}
