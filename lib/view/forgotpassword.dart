import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:provider/provider.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  TextEditingController email=TextEditingController();
  final passkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
     final controller = Provider.of<HotelBookingController>(context, listen: false);


    return Scaffold(backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Forgot Password",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.amber),),
            SizedBox(height: 20,),
            TextField(style: TextStyle(color: Colors.white),controller: email,
              decoration: InputDecoration(
                hintText: "Email",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
           SizedBox(height: 20,),
           
              SizedBox(height: 50,width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {controller.forgotpassword(email: email.text.trim(), context: context);
                },
                  child: Text("Submit"),
                ),
              ),
            
          ],
        ),
      ),
    );
  }
}
