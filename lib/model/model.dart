import 'package:cloud_firestore/cloud_firestore.dart';

class HotelAppModel {
  final String userId;     // for user signup
  final String hotelId;    // for hotel / room
  final String name;
  final String email;
  final String password;

  final String? location;
  final int? userPhoneNumber;
  final double? price;
  final String? image;
  final String? description;
  final String? availableRoom;

  final int? guest;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  // final String? review;
  // final double? rating;

  final String? roomType;
   final int? roomscount;
  final String? discount;

  final DateTime? createdAt;

  HotelAppModel({
    this.userId = "",
    this.hotelId = "",
    required this.name,
    required this.email,
    required this.password,
    this.location,
    this.userPhoneNumber,
    this.price,
    this.image,
    this.description,
    this.availableRoom,
    this.guest,
    this.roomscount,
    // this.review,
    // this.rating,
    this.roomType,
    this.discount,
    this.checkInDate,
    this.checkOutDate,
    this.createdAt,
  });

  /// Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'location': location,
      'image': image,
      'price': price,
      'phonenumber': userPhoneNumber,

      'description': description,
      'available': availableRoom,
      'guest': guest,
      'rooms':roomscount,
      'roomType': roomType,     
      'discount': discount,

      // 'review': review,
      // 'rating': rating,

      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,

      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert document to model
  factory HotelAppModel.fromMap(Map<String, dynamic> map, String docId) {
    return HotelAppModel(
      hotelId: map['hotelId'] ?? docId,
      userId: map['userId'] ?? "",
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      password: "", // never store password

      location: map['location'],
      image: map['image'],
      price: (map['price'] ?? 0).toDouble(),

      userPhoneNumber: map['phonenumber'],
      description: map['description'],
      availableRoom: map['available'],

      guest: map['guest'],
      // review: map['review'],
      // rating: (map['rating'] ?? 0).toDouble(),
      roomscount: map['rooms'],

      roomType: map['roomType'],
      discount: map['discount']??'',

      checkInDate: (map['checkInDate'] as Timestamp?)?.toDate(),
      checkOutDate: (map['checkOutDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
