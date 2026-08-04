import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String businessName;
  final String businessType;
  final Timestamp? createdAt;


  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.businessType,
    required this.createdAt,

  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
  uid: map['uid'],
  fullName: map['fullName'],
  username: map['username'],
  email: map['email'],
  phone: map['phone'],
  businessName: map['businessName'],
  businessType: map['businessType'],
  createdAt: map['createdAt'],
);
  }

  Map<String, dynamic> toMap() {
    return {
  'uid': uid,
  'fullName': fullName,
  'username': username,
  'email': email,
  'phone': phone,
  'businessName': businessName,
  'businessType': businessType,
  'createdAt': createdAt,
};
  }
}