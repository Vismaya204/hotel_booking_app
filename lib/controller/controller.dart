import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/addhoteldateils.dart';
import 'package:hotelbookingapp/view/admin.dart';
import 'package:hotelbookingapp/view/selectuserdate.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelbookingapp/model/model.dart';

class HotelBookingController extends ChangeNotifier {
  final ImagePicker picker = ImagePicker();

  // State variables
  XFile? hotelImage;
  Uint8List? webImageBytes; // 🔹 for web support

  // Separate lists for mobile & web
  List<XFile> roomImagesMobile = [];
  List<Uint8List> roomImagesWeb = [];

  Future<void> pickHotelImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      hotelImage = picked;
      if (kIsWeb) {
        webImageBytes = await picked.readAsBytes();
      }
      notifyListeners();
    }
  }

  /// Pick multiple room images
  Future<void> pickRoomImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      if (kIsWeb) {
        // Convert each XFile to bytes for web
        roomImagesWeb = await Future.wait(
          pickedFiles.map((file) => file.readAsBytes()),
        );
      } else {
        // On mobile, keep XFile list
        roomImagesMobile = pickedFiles;
      }
      notifyListeners();
    }
  }

  /// Upload image
  /// Upload image to Cloudinary (works for both mobile & web)
  Future<String?> uploadImageToCloudinary() async {
    const cloudName = "dc0ny45w9"; // 🔹 replace with your Cloudinary cloud name
    const uploadPreset = "hotelimg"; // 🔹 replace with your preset

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    try {
      http.MultipartRequest request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset;

      if (kIsWeb && webImageBytes != null) {
        // ✅ Web: use bytes
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            webImageBytes!,
            filename: "upload.jpg",
          ),
        );
      } else if (hotelImage != null) {
        // ✅ Mobile/Desktop: use File
        request.files.add(
          await http.MultipartFile.fromPath('file', hotelImage!.path),
        );
      } else {
        return null; // no image selected
      }
      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        return data['secure_url']; // ✅ permanent Cloudinary URL
      } else {
        print("Cloudinary upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }

  /// Upload multiple room images to Cloudinary
  Future<List<String>> uploadRoomImagesToCloudinary() async {
    const cloudName = "dc0ny45w9";
    const uploadPreset = "hotelimg";
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    List<String> imageUrls = [];

    try {
      if (kIsWeb) {
        for (var bytes in roomImagesWeb) {
          http.MultipartRequest request = http.MultipartRequest("POST", url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: "room.jpg"),
            );

          final response = await request.send();
          if (response.statusCode == 200) {
            final res = await http.Response.fromStream(response);
            final data = json.decode(res.body);
            imageUrls.add(data['secure_url']);
          }
        }
      } else {
        for (var img in roomImagesMobile) {
          http.MultipartRequest request = http.MultipartRequest("POST", url)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', img.path));

          final response = await request.send();
          if (response.statusCode == 200) {
            final res = await http.Response.fromStream(response);
            final data = json.decode(res.body);
            imageUrls.add(data['secure_url']);
          }
        }
      }
    } catch (e) {
      print("Error uploading room images: $e");
    }

    return imageUrls;
  }

  /// Upload multiple room images to Cloudinary and save details in Firestore
  Future<void> saveRoomDetails({
    required String hotelId,
    required String roomType,
    required String floor,
    required String price,
    required String available,
    required String description,
    required BuildContext context,
  }) async {
    try {
      List<String> imageUrls = await uploadRoomImagesToCloudinary();

      await FirebaseFirestore.instance
          .collection("hotels")
          .doc(hotelId)
          .collection("rooms")
          .add({
            "roomType": roomType,
            "floor": floor,
            "price": price,
            "description": description,
            "available": available,
            "images": imageUrls,
            "createdAt": FieldValue.serverTimestamp(),
          });

      roomImagesMobile.clear();
      roomImagesWeb.clear();
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room details saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving room: $e")));
    }
  }

  /// User Signup
  Future<void> usersignup({
    required HotelAppModel user,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'id': userCredential.user!.uid,
            'username': user.name,
            'email': user.email,
            "phonenumber": user.phonenumber,
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    notifyListeners();
  }

  /// Hotel Register
  Future<void> hotelRegister({
    required HotelAppModel hotel,
    required BuildContext context,
  }) async {
    try {
      // 🔹 Upload proof image to Cloudinary (single function handles both mobile & web)
      String? imageUrl = await uploadImageToCloudinary();

      if (imageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image upload failed")));
        return;
      }

      // ✅ Create hotel admin in Firebase Auth
      UserCredential hotelCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: hotel.email,
            password: hotel.password,
          );

      // ✅ Save hotel details in Firestore with Cloudinary URL
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(hotelCredential.user!.uid)
          .set({
            'id': hotelCredential.user!.uid,
            'name': hotel.name,
            'location': hotel.location,
            'image': imageUrl, // ✅ Cloudinary URL
            'email': hotel.email,
            "discount": hotel.discount,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hotel registered successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving room: $e")));
    }
    notifyListeners();
  }

  Future<void> approveHotel(String hotelId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('hotels').doc(hotelId).update({
      'status': 'approved',
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Hotel approved")));
  }

  Future<void> rejectHotel(String hotelId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('hotels').doc(hotelId).update({
      'status': 'rejected',
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Hotel rejected")));
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // ✅ Admin hardcoded login
      if (email == "admin@gmail.com" && password == "admin1234") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Admin login successful")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Admin()),
        );
        return;
      }

      // ✅ Firebase Auth login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // ✅ Check user collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // ✅ Check hotel collection
      DocumentSnapshot hotelDoc = await FirebaseFirestore.instance
          .collection('hotels')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        // ✅ Normal user login
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User login successful")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HotelSearchScreen()),
        );
      } else if (hotelDoc.exists) {
        // ✅ Hotel login with admin approval check
        String status = hotelDoc['status'] ?? 'pending';

        if (status == 'approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hotel login successful")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddHotelDetails(
                hotelId: hotelDoc['id'],
                hotelName: hotelDoc['name'],
              ),
            ),
          );
        } else if (status == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hotel registration pending admin approval"),
            ),
          );
        } else if (status == 'rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hotel registration rejected by admin"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful, but no role found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    notifyListeners();
  }

  /// Forgot Password
  Future<void> forgotpassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Check your email")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
