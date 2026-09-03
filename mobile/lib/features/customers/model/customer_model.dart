import 'package:cloud_firestore/cloud_firestore.dart';

class _UnsetSentinel {
  const _UnsetSentinel();
}

const _unset = _UnsetSentinel();

class CustomerModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? company;
  final String? notes;
  final int totalCalls;
  final DateTime? lastCallAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.company,
    this.notes,
    this.totalCalls = 0,
    this.lastCallAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      email: map['email'] as String?,
      company: map['company'] as String?,
      notes: map['notes'] as String?,
      totalCalls: (map['totalCalls'] as num?)?.toInt() ?? 0,
      lastCallAt: _parseTimestamp(map['lastCallAt']),
      createdAt: _parseTimestamp(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (company != null) 'company': company,
      if (notes != null) 'notes': notes,
      'totalCalls': totalCalls,
      if (lastCallAt != null) 'lastCallAt': Timestamp.fromDate(lastCallAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return null;
    }

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }

    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return null;
  }

  String get formattedLastCallDate {
    if (lastCallAt == null) return 'Never';
    return '${lastCallAt!.day}/${lastCallAt!.month}/${lastCallAt!.year} '
        '${lastCallAt!.hour.toString().padLeft(2, '0')}:${lastCallAt!.minute.toString().padLeft(2, '0')}';
  }

  CustomerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phoneNumber,
    Object? email = _unset,
    Object? company = _unset,
    Object? notes = _unset,
    int? totalCalls,
    Object? lastCallAt = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email == _unset ? this.email : email as String?,
      company: company == _unset ? this.company : company as String?,
      notes: notes == _unset ? this.notes : notes as String?,
      totalCalls: totalCalls ?? this.totalCalls,
      lastCallAt: lastCallAt == _unset ? this.lastCallAt : lastCallAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerModel &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.company == company &&
        other.notes == notes &&
        other.totalCalls == totalCalls &&
        other.lastCallAt == lastCallAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      name,
      phoneNumber,
      email,
      company,
      notes,
      totalCalls,
      lastCallAt,
      createdAt,
      updatedAt,
    ]);
  }
}