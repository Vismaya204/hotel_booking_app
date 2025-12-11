import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EditHotelFull extends StatefulWidget {
  final String hotelId;
  final Map<String, dynamic> hotel;

  const EditHotelFull({super.key, required this.hotelId, required this.hotel});

  @override
  State<EditHotelFull> createState() => _EditHotelFullState();
}

class _EditHotelFullState extends State<EditHotelFull> {
  late TextEditingController nameCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController imageCtrl;
  late TextEditingController descriptionCtrl;

  List<Map<String, dynamic>> rooms = [];
  bool loadingRooms = true;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.hotel["name"]);
    locationCtrl = TextEditingController(text: widget.hotel["location"]);
    imageCtrl = TextEditingController(text: widget.hotel["image"]);
    descriptionCtrl = TextEditingController(text: widget.hotel["description"]);

    fetchRooms();
  }

  // -----------------------------------------------------------------
  // 🔥 FETCH ROOMS
  // -----------------------------------------------------------------
  Future<void> fetchRooms() async {
    final snap = await FirebaseFirestore.instance
        .collection("hotels")
        .doc(widget.hotelId)
        .collection("rooms")
        .get();

    rooms = snap.docs
        .map(
          (e) => {
            "id": e.id,
            "price": e["price"],
            "images": List<String>.from(e["images"]),
          },
        )
        .toList();

    setState(() => loadingRooms = false);
  }

  // -----------------------------------------------------------------
  // 🔥 CLOUDINARY UPLOAD
  // -----------------------------------------------------------------
  Future<String> uploadImageToCloudinary(dynamic file) async {
    const cloudName = "dc0ny45w9";
    const uploadPreset = "hotelimg";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    http.MultipartRequest request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset;

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          file, // Uint8List
          filename: "upload.jpg",
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath("file", file.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      return data["secure_url"];
    } else {
      print("Cloudinary upload failed: ${response.statusCode}");
      return "";
    }
  }

  // -----------------------------------------------------------------
  // 📌 PICK HOTEL MAIN IMAGE
  // -----------------------------------------------------------------
  Future<void> pickHotelImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    String url;

    if (kIsWeb) {
      Uint8List bytes = await picked.readAsBytes();
      url = await uploadImageToCloudinary(bytes);
    } else {
      url = await uploadImageToCloudinary(picked);
    }

    setState(() {
      imageCtrl.text = url;
    });
  }

  // -----------------------------------------------------------------
  // 📌 SAVE HOTEL DETAILS
  // -----------------------------------------------------------------
  Future<void> updateHotel() async {
    await FirebaseFirestore.instance
        .collection("hotels")
        .doc(widget.hotelId)
        .update({
          "name": nameCtrl.text,
          "location": locationCtrl.text,
          "image": imageCtrl.text,
          "description": descriptionCtrl.text,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Hotel Updated")));
  }

  // -----------------------------------------------------------------
  // 📌 SAVE ROOM
  // -----------------------------------------------------------------
  Future<void> updateRoom(int index) async {
    final room = rooms[index];

    await FirebaseFirestore.instance
        .collection("hotels")
        .doc(widget.hotelId)
        .collection("rooms")
        .doc(room["id"])
        .update({"price": room["price"], "images": room["images"]});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Room Updated")));
  }

  // -----------------------------------------------------------------
  // ❌ DELETE ROOM
  // -----------------------------------------------------------------
  Future<void> deleteRoom(String roomId) async {
    await FirebaseFirestore.instance
        .collection("hotels")
        .doc(widget.hotelId)
        .collection("rooms")
        .doc(roomId)
        .delete();

    fetchRooms();
  }

  // -----------------------------------------------------------------
  // UI
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.amber, title: Text("Edit Hotel")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HOTEL MAIN IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageCtrl.text,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: pickHotelImage,
              child: Text("Change hotel Image"),
            ),

            SizedBox(height: 10),

            Text("Hotel Name", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                enabled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),

            Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: locationCtrl,
              decoration: InputDecoration(
                enabled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),

            Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: descriptionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                enabled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
              ),
              onPressed: updateHotel,
              child: Text("SAVE HOTEL DETAILS"),
            ),

            SizedBox(height: 30),

            Text(
              "Rooms",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            loadingRooms
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: rooms.length,
                    itemBuilder: (context, i) => roomCard(i),
                  ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
              ),
              onPressed: addRoomDialog,
              child: Text("ADD NEW ROOM"),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // ROOM CARD WIDGET
  // -----------------------------------------------------------------
  Widget roomCard(int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Room ${index + 1}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // ROOM IMAGES
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: rooms[index]["images"].length,
                itemBuilder: (context, imgIndex) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(6),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              rooms[index]["images"][imgIndex],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // DELETE IMAGE
                      Positioned(
                        right: 5,
                        top: 5,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              rooms[index]["images"].removeAt(imgIndex);
                            });
                            updateRoom(index);
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => addImageDialog(index),
              child: Text("Add Image"),
            ),

            SizedBox(height: 10),

            Text("Price", style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
            TextField(
               keyboardType: TextInputType.number,
              onChanged: (val) {
                rooms[index]["price"] = val;
              },
              controller: TextEditingController(
                text: rooms[index]["price"].toString(),
              ),
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => updateRoom(index),
                  child: Text("Save Room"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => deleteRoom(rooms[index]["id"]),
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // ADD ROOM IMAGE
  // -----------------------------------------------------------------
  void addImageDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Choose Room Image", style: TextStyle(color: Colors.blue)),
        content: Text("Pick an image to upload"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                
                color: Colors.red,fontWeight: FontWeight.bold
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              XFile? picked = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (picked == null) return;

              String url;
              if (kIsWeb) {
                Uint8List bytes = await picked.readAsBytes();
                url = await uploadImageToCloudinary(bytes);
              } else {
                url = await uploadImageToCloudinary(picked);
              }

              setState(() {
                rooms[index]["images"].add(url);
              });

              updateRoom(index);
            },
            child: Text(
              "Pick Image",
              style: TextStyle(
                
                color: Colors.green,fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // ADD NEW ROOM
  // -----------------------------------------------------------------
  void addRoomDialog() {
    TextEditingController priceCtrl = TextEditingController();
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSB) {
          return AlertDialog(
            title: Text("Add New Room"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceCtrl,
                  decoration: InputDecoration(labelText: "Price"),
                ),
                SizedBox(height: 10),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
                  onPressed: () async {
                    pickedImage = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    setSB(() {});
                  },
                  child: Text(
                    pickedImage == null ? "Select Image" : "Selected!",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel",style: TextStyle(color: Colors.red),),
              ),
              TextButton(
                onPressed: () async {
                  if (pickedImage == null) return;

                  String url;

                  if (kIsWeb) {
                    Uint8List bytes = await pickedImage!.readAsBytes();
                    url = await uploadImageToCloudinary(bytes);
                  } else {
                    url = await uploadImageToCloudinary(pickedImage);
                  }

                  await FirebaseFirestore.instance
                      .collection("hotels")
                      .doc(widget.hotelId)
                      .collection("rooms")
                      .add({
                        "price": priceCtrl.text,
                        "images": [url],
                      });

                  Navigator.pop(context);
                  fetchRooms();
                },
                child: Text("ADD",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
              ),
            ],
          );
        },
      ),
    );
  }
}
