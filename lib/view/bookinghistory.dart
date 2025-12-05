import 'package:flutter/material.dart';

class Bookinghistory extends StatelessWidget {
  const Bookinghistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Booking History"),
      ),
      body: Column(children: [Card(),Text(""),],),
    );
  }
}
