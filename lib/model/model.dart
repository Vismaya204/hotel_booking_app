import 'package:cloud_firestore/cloud_firestore.dart';

class HotelAppModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final int? phonenumber;
  final double? price;
  final String? image;
  final String? location;
  final String? available;
  final int? guest;
  final DateTime?checkInDate;

  final DateTime?checkOutDate;
  final String? review;
  final double? rating;
  final String? discount;
  final DateTime? createdAt;

  HotelAppModel({
    this.id = "",
    required this.name,
    required this.email,
    required this.password,
    this.location,
    this.phonenumber,
    this.review,
    this.price,
    this.image,
    this.available,
    this.guest,
    this.rating,
    this.discount,
    this.checkInDate,
    this.checkOutDate,
    this.createdAt,

   
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'price': price,
      'phonenumber': phonenumber,
      'image': image,
      'location': location,
      'available': available,
      'guest': guest,    
      'review': review,
      'rating': rating,
      'discount': discount,
      'checkin': checkInDate,
      'checkout': checkOutDate,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory HotelAppModel.fromMap(Map<String, dynamic> map, String docId) {
    return HotelAppModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: '',
      price: (map['price'] ?? 0).toDouble(),
      phonenumber: map['phonenumber'],
      location: map['location'] ?? '',
      available: map['available'] ?? '',
      image: map['image'] ?? '',
      guest: map['guest'],     
      review: map['review'],
      rating: (map['rating'] ?? 0).toDouble(),
      discount: map['discount'],
      checkInDate: (map['checkin'] as Timestamp?)?.toDate(),
      checkOutDate: (map['checkout'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),

     
    );
  }
}
