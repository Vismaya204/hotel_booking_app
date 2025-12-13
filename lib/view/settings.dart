import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phonenumber = TextEditingController();
  final TextEditingController location = TextEditingController();

  XFile? selectedImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// 🔹 Fetch user data
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        username.text = data['username'] ?? '';
        email.text = user.email ?? '';
        phonenumber.text = data['phonenumber'] ?? '';
        location.text = data['location'] ?? '';
        profileImageUrl = data['profileimage'];
        
      });
    }
  }

  /// 🔹 Pick image directly from Gallery (NO bottom sheet)
  Future<void> pickProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // 🔥 Show image instantly
    setState(() {
      selectedImage = pickedFile;
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child("profileImages/${user.uid}.jpg");

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );
    } else {
      await ref.putFile(File(pickedFile.path));
    }

    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({'profileimage': downloadUrl});

    setState(() {
      profileImageUrl = downloadUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture updated")),
    );
  }

  /// 🔹 Save profile details
  Future<void> saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'username': username.text.trim(),
      'phonenumber': phonenumber.text.trim(),
      'location': location.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 Profile Image
            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: selectedImage != null
                    ? (kIsWeb
                        ? NetworkImage(selectedImage!.path)
                        : FileImage(File(selectedImage!.path))
                            as ImageProvider)
                    : profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                child: selectedImage == null && profileImageUrl == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.black54,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: username,
              decoration: InputDecoration(
                labelText: "Username",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: email,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: phonenumber,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: location,
              decoration: InputDecoration(
                labelText: "Location",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: saveUserData,
                child: const Text(
                  "Save",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
