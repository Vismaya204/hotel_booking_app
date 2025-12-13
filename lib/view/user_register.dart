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
  TextEditingController username=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController phonenumber=TextEditingController();
  TextEditingController location=TextEditingController();

 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,appBar: AppBar(iconTheme: IconThemeData(color: Colors.amber),backgroundColor: Colors.black,),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Register",style: TextStyle(
              fontSize: 30,color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),),SizedBox(height: 20,),
            TextField(style: TextStyle(color: Colors.white),controller: username,
              decoration: InputDecoration(
                hintText: "Username",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),SizedBox(height: 10,),
            TextField(style: TextStyle(color:Colors.white ),controller: email,
              decoration: InputDecoration(
                hintText: "Email",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),SizedBox(height: 10,),
            TextField(style: TextStyle(color: Colors.white),controller: password,
              decoration: InputDecoration(
                hintText: "Password",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),SizedBox(height: 10,),
            TextField(style: TextStyle(color: Colors.white),controller: phonenumber,
              decoration: InputDecoration(
                hintText: "Phone number",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),SizedBox(height: 10,),
            TextField(style: TextStyle(color: Colors.white)
              ,controller: location,
            decoration: InputDecoration(hintText: "Location",hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(height: 50,width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {final usermodel=HotelAppModel(
                      userId:"",
                      name: username.text,
                      email: email.text,
                      password: password.text,
                      userPhoneNumber: phonenumber.text, 
                      location: location.text             
                    );Provider.of<HotelBookingController>(context,listen: false).usersignup(
                      user: usermodel,
                      context: context,
                    );
                    
                    
                      
                     
                    },
                  
                    child: Text("Sign Up"),
                  ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
