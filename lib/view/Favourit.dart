import 'package:flutter/material.dart';

class Favourit extends StatelessWidget {
  const Favourit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.amber,
      appBar: AppBar(backgroundColor: Colors.amber,iconTheme: IconThemeData(color: Colors.black),
      
        title: Text("Favourite", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
