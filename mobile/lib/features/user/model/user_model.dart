import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String? businessName;
  final String? businessType;

  final String? aiPersonality;
  final String? customAiPersonality;

  final int onboardingStep;
  final bool onboardingComplete;

  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone,
    this.businessName,
    this.businessType,
    this.aiPersonality,
    this.customAiPersonality,
    this.onboardingStep = 1,
    this.onboardingComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      businessName: map['businessName'] as String?,
      businessType: map['businessType'] as String?,

      aiPersonality: map['aiPersonality'] as String?,
      customAiPersonality: map['customAiPersonality'] as String?,

      onboardingStep: (map['onboardingStep'] as num?)?.toInt() ?? 1,
      onboardingComplete:
          map['onboardingComplete'] as bool? ?? false,

      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      if (businessName != null) 'businessName': businessName,
      if (businessType != null) 'businessType': businessType,

      if (aiPersonality != null)
        'aiPersonality': aiPersonality,

      if (customAiPersonality != null)
        'customAiPersonality': customAiPersonality,

      'onboardingStep': onboardingStep,
      'onboardingComplete': onboardingComplete,

      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? businessName,
    String? businessType,
    String? aiPersonality,
    String? customAiPersonality,
    int? onboardingStep,
    bool? onboardingComplete,
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

      aiPersonality:
          aiPersonality ?? this.aiPersonality,

      customAiPersonality:
          customAiPersonality ?? this.customAiPersonality,

      onboardingStep:
          onboardingStep ?? this.onboardingStep,

      onboardingComplete:
          onboardingComplete ?? this.onboardingComplete,

      createdAt: createdAt ?? this.createdAt,
    );
  }

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
        other.aiPersonality == aiPersonality &&
        other.customAiPersonality == customAiPersonality &&
        other.onboardingStep == onboardingStep &&
        other.onboardingComplete == onboardingComplete &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      fullName,
      username,
      email,
      phone,
      businessName,
      businessType,
      aiPersonality,
      customAiPersonality,
      onboardingStep,
      onboardingComplete,
      createdAt,
    );
  }
}