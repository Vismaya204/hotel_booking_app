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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController discount = TextEditingController();
  final TextEditingController description = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HotelBookingController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 30),

                // Hotel Name
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: hotelNameController,
                  decoration: _inputDecoration("Hotel Name"),
                  cursorColor: Colors.amber,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Hotel name required" : null,
                ),
                const SizedBox(height: 10),

                // Location
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: locationController,
                  decoration: _inputDecoration("Location"),
                  cursorColor: Colors.amber,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Location required" : null,
                ),
                const SizedBox(height: 10),

                // Email
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: emailController,
                  decoration: _inputDecoration("Email"),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email required";
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Password with toggle + validation
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _inputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password required";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Description
                TextFormField(
                  controller: description,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Description"),
                  cursorColor: Colors.amber,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Description required" : null,
                ),
                const SizedBox(height: 10),

                // Discount
                TextFormField(
                  controller: discount,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Discount"),
                  cursorColor: Colors.amber,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Discount required" : null,
                ),
                const SizedBox(height: 20),

                // Upload Proof Button
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

                const SizedBox(height: 10),

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

                const SizedBox(height: 20),

                // Register Button
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
                        if (_formKey.currentState!.validate()) {
                          final hotel = HotelAppModel(
                            hotelId: "",
                            name: hotelNameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            location: locationController.text,
                            discount: discount.text,
                            description: description.text,
                          );

                          await controller.hotelRegister(
                            hotel: hotel,
                            context: context,
                          );

                          // Clear fields after success
                          hotelNameController.clear();
                          locationController.clear();
                          emailController.clear();
                          passwordController.clear();
                          discount.clear();
                          description.clear();
                        }
                      },
                      child: const Text("Register"),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.amber),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
    );
  }
}