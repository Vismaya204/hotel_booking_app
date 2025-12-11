import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:hotelbookingapp/view/forgotpassword.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 20),
              TextField(
  decoration: InputDecoration(
    hintText: 'Email',hintStyle: TextStyle(color: Colors.white),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.amber),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.yellow, ),
    ),
  
  ),
  style: TextStyle(color: Colors.white),
   cursorColor: Colors.amber,
),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: password,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.amber) ,
                    borderRadius: BorderRadius.circular(10),
                  ),focusedBorder: OutlineInputBorder(borderSide:BorderSide(color: Colors.amber))
                ),cursorColor: Colors.amber,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Forgotpassword()),
                  );
                },
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Provider.of<HotelBookingController>(
                        context,
                        listen: false,
                      ).login(
                        email: email.text,
                        password: password.text,
                        context: context,
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
