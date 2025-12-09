import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/alluserscreen.dart';

class Success extends StatelessWidget {
  const Success({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f9fc),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// Illustration Image
                SizedBox(
                  height: 250,
                  child: Image.asset(
                    "assets/successpay.jpg",
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 30),

                /// Title
                const Text(
                  "Congratulations!!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff007BFF),
                  ),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                const Text(
                  "Your hotel stay is secured.\nCounting down to your dream vacation!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff4b4b4b),
                  ),
                ),

                const SizedBox(height: 40),

                /// GO HOME  button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff007BFF),foregroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => Alluserscreen(),));
                    },
                    child: const Text(
                      "GO HOME",
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Receipt
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "VIEW E-RECEIPT",
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: Color(0xff007BFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
