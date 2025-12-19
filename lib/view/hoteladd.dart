import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'edithotelscreen.dart';

class Hoteladd extends StatefulWidget {
  const Hoteladd({super.key});

  @override
  State<Hoteladd> createState() => _HoteladdState();
}

class _HoteladdState extends State<Hoteladd> {
  final picker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // ------------------------------------------------------------
  // 🔥 CLOUDINARY UPLOAD (REAL)
  // ------------------------------------------------------------
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
        http.MultipartFile.fromBytes("file", file, filename: "upload.jpg"),
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
      throw Exception("Cloudinary upload failed");
    }
  }

  // ------------------------------------------------------------
  // ➕ ADD ROOM DIALOG (WITH IMAGE PREVIEW)
  // ------------------------------------------------------------
  void addRoomDialog(String hotelId) {
    TextEditingController priceCtrl = TextEditingController();
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSB) {
          return AlertDialog(
            title: const Text("Add New Room"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  const SizedBox(height: 12),

                  // 🔥 IMAGE PREVIEW
                  if (pickedImage != null)
                    kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: pickedImage!.readAsBytes(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const CircularProgressIndicator();
                              }
                              return Image.memory(
                                snap.data!,
                                height: 120,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.file(
                            File(pickedImage!.path),
                            height: 120,
                            fit: BoxFit.cover,
                          ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      pickedImage = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      setSB(() {});
                    },
                    child: Text(
                      pickedImage == null ? "Select Image" : "Change Image",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (pickedImage == null || priceCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Price & Image required")),
                    );
                    return;
                  }

                  String url;
                  if (kIsWeb) {
                    Uint8List bytes = await pickedImage!.readAsBytes();
                    url = await uploadImageToCloudinary(bytes);
                  } else {
                    url = await uploadImageToCloudinary(pickedImage);
                  }

                  await FirebaseFirestore.instance
                      .collection("hotels")
                      .doc(hotelId)
                      .collection("rooms")
                      .add({
                        "price": priceCtrl.text,
                        "images": [url],
                        "createdAt": Timestamp.now(),
                      });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Room Added")));
                },
                child: const Text(
                  "ADD",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => addRoomDialog(user.uid),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Hotel Details"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("hotels")
            .doc(user.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || !snap.data!.exists) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditHotelFull(hotelId: user.uid, hotel: {}),
                    ),
                  );
                },
                child: const Text("Add Hotel Details"),
              ),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data["image"] ?? "",
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 200, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data["name"] ?? "Hotel",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditHotelFull(hotelId: user.uid, hotel: data),
                      ),
                    );
                  },
                  child: const Text("Edit Hotel"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("hotels")
                        .doc(user.uid)
                        .update({"status": "rejected"});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Hotel moved to rejected")),
                    );
                  },
                  child: const Text("Reject"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
