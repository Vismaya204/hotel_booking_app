import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController location = TextEditingController();

  String? profilelimageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// 🔹 Fetch user data
  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
         profilelimageUrl = data['profileimage'];

        });
      }
    }
  }

  /// 🔹 Choose image (Gallery / Camera)
  void selectProfileImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  uploadProfileImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb) // Camera not available on some web
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    uploadProfileImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Upload image and update Firestore
  Future<void> uploadProfileImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profileImages/${user.uid}.jpg");

    // Upload logic
    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
    } else {
      await ref.putFile(File(pickedFile.path));
    }

    // Get new URL
    final downloadUrl = await ref.getDownloadURL();

    // Firestore update
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({'profileimage': downloadUrl});


    // Update instantly
    setState(() {
      profilelimageUrl = downloadUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture updated")),
    );
  }

  /// 🔹 Save updated user data
  Future<void> saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': username.text.trim(),
        'phonenumber': phonenumber.text.trim(),
        'location': location.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Settings",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Photo
           GestureDetector(
  onTap: selectProfileImage,
  child: CircleAvatar(
    radius: 55,
    backgroundColor: Colors.grey.shade300,
    backgroundImage: profilelimageUrl != null
        ? NetworkImage(
            profilelimageUrl! + "?v=${DateTime.now().millisecondsSinceEpoch}")
        : null,
    child: profilelimageUrl == null
        ? const Icon(Icons.camera_alt, size: 40, color: Colors.black54)
        : null,
  ),
),

            const SizedBox(height: 30),

            TextField(
              controller: username,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: email,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: phonenumber,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: location,
              decoration: InputDecoration(
                labelText: "Location",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                child: const Text("Save",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
