import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String? businessName;
  final String? businessType;
  final String? businessOpeningTime;
  final String? businessClosingTime;
  final String? businessTimeZone;
  final String? languagePreference;
  final String? voicePreference;

  final String? aiPersonality;
  final String? customAiPersonality;

  final String? greetingTemplate;
  final String? customGreeting;

  final int productsCount;
  final int documentsCount;
  final int faqsCount;

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
    this.businessOpeningTime,
    this.businessClosingTime,
    this.businessTimeZone,
    this.languagePreference,
    this.voicePreference,
    this.aiPersonality,
    this.customAiPersonality,
    this.greetingTemplate,
    this.customGreeting,
    this.productsCount = 0,
    this.documentsCount = 0,
    this.faqsCount = 0,
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
      businessOpeningTime: map['businessOpeningTime'] as String?,
      businessClosingTime: map['businessClosingTime'] as String?,
      businessTimeZone: map['businessTimeZone'] as String?,
      languagePreference: map['languagePreference'] as String?,
      voicePreference: map['voicePreference'] as String?,

      aiPersonality: map['aiPersonality'] as String?,
      customAiPersonality: map['customAiPersonality'] as String?,

      greetingTemplate: map['greetingTemplate'] as String?,
      customGreeting: map['customGreeting'] as String?,

      productsCount: (map['productsCount'] as num?)?.toInt() ?? 0,
      documentsCount: (map['documentsCount'] as num?)?.toInt() ?? 0,
      faqsCount: (map['faqsCount'] as num?)?.toInt() ?? 0,

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
      if (businessOpeningTime != null)
        'businessOpeningTime': businessOpeningTime,
      if (businessClosingTime != null)
        'businessClosingTime': businessClosingTime,
      if (businessTimeZone != null) 'businessTimeZone': businessTimeZone,
      if (languagePreference != null) 'languagePreference': languagePreference,
      if (voicePreference != null) 'voicePreference': voicePreference,

      if (aiPersonality != null)
        'aiPersonality': aiPersonality,

      if (customAiPersonality != null)
        'customAiPersonality': customAiPersonality,

      if (greetingTemplate != null) 'greetingTemplate': greetingTemplate,
      if (customGreeting != null) 'customGreeting': customGreeting,

      'productsCount': productsCount,
      'documentsCount': documentsCount,
      'faqsCount': faqsCount,

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
    String? businessOpeningTime,
    String? businessClosingTime,
    String? businessTimeZone,
    String? languagePreference,
    String? voicePreference,
    String? aiPersonality,
    String? customAiPersonality,
    String? greetingTemplate,
    String? customGreeting,
    int? productsCount,
    int? documentsCount,
    int? faqsCount,
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
      businessOpeningTime:
          businessOpeningTime ?? this.businessOpeningTime,
      businessClosingTime:
          businessClosingTime ?? this.businessClosingTime,
      businessTimeZone: businessTimeZone ?? this.businessTimeZone,
      languagePreference: languagePreference ?? this.languagePreference,
      voicePreference: voicePreference ?? this.voicePreference,

      aiPersonality:
          aiPersonality ?? this.aiPersonality,

      customAiPersonality:
          customAiPersonality ?? this.customAiPersonality,

      greetingTemplate:
          greetingTemplate ?? this.greetingTemplate,

      customGreeting:
          customGreeting ?? this.customGreeting,

      productsCount: productsCount ?? this.productsCount,
      documentsCount: documentsCount ?? this.documentsCount,
      faqsCount: faqsCount ?? this.faqsCount,

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
        other.businessOpeningTime == businessOpeningTime &&
        other.businessClosingTime == businessClosingTime &&
        other.businessTimeZone == businessTimeZone &&
        other.languagePreference == languagePreference &&
        other.voicePreference == voicePreference &&
        other.aiPersonality == aiPersonality &&
        other.customAiPersonality == customAiPersonality &&
        other.greetingTemplate == greetingTemplate &&
        other.customGreeting == customGreeting &&
        other.productsCount == productsCount &&
        other.documentsCount == documentsCount &&
        other.faqsCount == faqsCount &&
        other.onboardingStep == onboardingStep &&
        other.onboardingComplete == onboardingComplete &&
        other.createdAt == createdAt;
  }

@override
  int get hashCode {
    return Object.hashAll([
      uid,
      fullName,
      username,
      email,
      phone,
      businessName,
      businessType,
      businessOpeningTime,
      businessClosingTime,
      businessTimeZone,
      languagePreference,
      voicePreference,
      aiPersonality,
      customAiPersonality,
      greetingTemplate,
      customGreeting,
      productsCount,
      documentsCount,
      faqsCount,
      onboardingStep,
      onboardingComplete,
      createdAt,
    ]);
  }
}