import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Alluserscreen()),
      );
    });
    return Scaffold(backgroundColor: Colors.amber,body: Center(child: Lottie.asset("assets/"),),);
  }
}
