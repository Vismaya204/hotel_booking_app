import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:hotelbookingapp/model/model.dart';
import 'package:provider/provider.dart';

class HotelRegisterScreen extends StatefulWidget {
  const HotelRegisterScreen({super.key});

  @override
  State<HotelRegisterScreen> createState() => _HotelRegisterScreenState();
}

class _HotelRegisterScreenState extends State<HotelRegisterScreen> {
  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController discount=TextEditingController();
  final TextEditingController description=TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HotelBookingController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.amber),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),SizedBox(height: 30,),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: hotelNameController,
                decoration: InputDecoration(
                  hintText: "Hotel Name",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber),
                    borderRadius: BorderRadius.circular(10),
                  ),focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: Colors.amber),
                  ),focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
              ),
              SizedBox(height: 10),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
              ),SizedBox(height: 10,),
              TextField(controller:description ,maxLines: 4,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: "Descritipon",hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
              ),SizedBox(height: 10,),
               TextField(controller: discount,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: "Discount",hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),cursorColor: Colors.amber,
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
                    onPressed: () async {
                      await controller.pickHotelImage();
                    },
                    child: const Text("Upload Proof of Hotel"),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Preview selected image
              if (controller.hotelImage != null ||
                  controller.webImageBytes != null)
                kIsWeb && controller.webImageBytes != null
                    ? Image.memory(
                        controller.webImageBytes!,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(controller.hotelImage!.path),
                        height: 150,
                        fit: BoxFit.cover,
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
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final hotel = HotelAppModel(
                        hotelId: "",
                        name: hotelNameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        location: locationController.text,
                        discount: discount.text,
                        description: description.text
                      );

                      await controller.hotelRegister(
                        hotel: hotel,
                        context: context,
                      );
                        /// after success clear fields
  hotelNameController.clear();
  locationController.clear();
  emailController.clear();
  passwordController.clear();
  discount.clear();
  description.clear();

 
                    },
                    child: const Text("Register"),
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
