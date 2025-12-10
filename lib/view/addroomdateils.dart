import 'package:flutter/material.dart';
import 'package:hotelbookingapp/controller/controller.dart';
import 'package:provider/provider.dart';
import 'package:hotelbookingapp/model/model.dart';

class AddRoomScreen extends StatefulWidget {
  final String hotelId;

  const AddRoomScreen({super.key, required this.hotelId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController roomType = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController available = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HotelBookingController>(context);

    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.black),
        title: const Text("Add Room",style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.amber,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 ROOM TYPE
            TextField(style: TextStyle(color: Colors.white),
              controller: roomType,
              decoration: const InputDecoration(
                hintText: "Room Type",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            

            
            const SizedBox(height: 12),

          
            

            // 🔹 PRICE
            TextField(style: TextStyle(color: Colors.white),
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Price",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 AVAILABLE
            TextField(style: TextStyle(color: Colors.white),
              controller: available,
              decoration: const InputDecoration(
                hintText: "Available (Yes/No)",hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),                   
            const SizedBox(height: 20),

            // 🔹 IMAGE PICKER
            
                
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(height: 50,width: double.infinity,
                      child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber,foregroundColor: Colors.black),
                        onPressed: () => controller.pickRoomImages(),
                        child: const Text("Pick Room Images",style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),      
            
            const SizedBox(height: 30),

            // 🔹 SUBMIT BUTTON
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(height: 50,width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        )),
                    onPressed: () async {
                      final controller = Provider.of<HotelBookingController>(context, listen: false);
                
                      // 🛑 Input validation
                      if (roomType.text.isEmpty ||                         
                          price.text.isEmpty ||                        
                          available.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields")),
                        );
                        return;
                      }
                
                      if (controller.roomImagesMobile.isEmpty &&
                          controller.roomImagesWeb.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select room images")),
                        );
                        return;
                      }
                
                      // ✅ Create Model
                      final hotelModel = HotelAppModel(
                        hotelId: widget.hotelId,
                        name: "",   // not required for rooms
                        email: "",
                        password: "",
                
                        roomType: roomType.text,                      
                        price: double.tryParse(price.text),
                        availableRoom: available.text,
                       
                      );
                
                      // ✅ Save using controller
                      await controller.saveRoomDetails(
                        room: hotelModel,
                        context: context,
                      );
                
                      // 🔥 Clear fields
                      roomType.clear();                 
                      price.clear();
                      available.clear();
                     
                    },
                    child: const Text(
                      "SAVE ROOM",
                      style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),
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
