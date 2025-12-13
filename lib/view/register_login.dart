import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/login.dart';
import 'package:hotelbookingapp/view/user_register.dart';
import 'package:hotelbookingapp/view/hotel_register.dart';

class RegisterLogin extends StatelessWidget {
  const RegisterLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Register Button
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
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;

                    final result = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        overlay.size.width / 2 - 100, // left
                        overlay.size.height / 2 - 50, // top
                        overlay.size.width / 2 + 100, // right
                        overlay.size.height / 2 + 50, // bottom
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'user',
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Register as User",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'hotel',
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Register as Hotel",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                      ],
                      color: Colors.black,
                    );

                    if (result == 'user') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserRegister(),
                        ),
                      );
                    } else if (result == 'hotel') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HotelRegisterScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Login Button
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
