import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/register_login.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterLogin()),
      );
    });
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text("HOTEL",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),)),
          SizedBox(
            height: 200,
            width: 200,
            child: Center(child: Lottie.asset("assets/Hotel Booking.json")),
          ),
        ],
      ),
    );
  }
}
