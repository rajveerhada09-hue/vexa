import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String? businessName;
  final String? businessType;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone,
    this.businessName,
    this.businessType,
    required this.createdAt,
  });

  /// Factory constructor to safely create a UserModel from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      businessName: map['businessName'] as String?,
      businessType: map['businessType'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  /// Converts the UserModel into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      if (businessName != null) 'businessName': businessName,
      if (businessType != null) 'businessType': businessType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this UserModel with the given fields replaced with the new values
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? businessName,
    String? businessType,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Safely parses a Firestore Timestamp (or other formats) into a DateTime object
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
  return DateTime.fromMillisecondsSinceEpoch(0);
}
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
  return DateTime.tryParse(timestamp) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Overriding == and hashCode for object equality (important for Provider/State management)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.uid == uid &&
      other.fullName == fullName &&
      other.username == username &&
      other.email == email &&
      other.phone == phone &&
      other.businessName == businessName &&
      other.businessType == businessType &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      fullName.hashCode ^
      username.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      businessName.hashCode ^
      businessType.hashCode ^
      createdAt.hashCode;
  }
}