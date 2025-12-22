import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:hotelbookingapp/model/model.dart';
import 'package:provider/provider.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController location = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.amber),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Username
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: username,
                  decoration: _inputDecoration("Username"),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Email
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: email,
                  decoration: _inputDecoration("Email"),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email cannot be empty";
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Password
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: password,
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
                      return "Password cannot be empty";
                    } else if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Phone number
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: phonenumber,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("Phone number"),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone number cannot be empty";
                    } else if (value.length < 10) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Location
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: location,
                  decoration: _inputDecoration("Location"),
                  cursorColor: Colors.amber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Location cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Sign Up Button
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
                        if (_formKey.currentState!.validate()) {
                          final usermodel = HotelAppModel(
                            userId: "",
                            name: username.text,
                            email: email.text,
                            password: password.text,
                            userPhoneNumber: phonenumber.text,
                            location: location.text,
                          );
                          Provider.of<HotelBookingController>(
                            context,
                            listen: false,
                          ).usersignup(user: usermodel, context: context);
                        }
                      },
                      child: const Text("Sign Up"),
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

  // Reusable InputDecoration
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