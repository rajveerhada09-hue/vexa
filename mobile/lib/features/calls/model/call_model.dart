import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String userId;
  final String callerName;
  final String phoneNumber;
  final int durationSeconds;
  final DateTime startedAt;
  final String? purpose;
  final CallStatus status;
  final bool aiHandled;
  final CallOutcome? outcome;
  final String? transcript;
  final DateTime createdAt;
  final String? customerId;

  const CallModel({
    required this.id,
    required this.userId,
    required this.callerName,
    required this.phoneNumber,
    required this.durationSeconds,
    required this.startedAt,
    this.purpose,
    required this.status,
    required this.aiHandled,
    this.outcome,
    this.transcript,
    required this.createdAt,
    this.customerId,
  });

  factory CallModel.fromMap(String id, Map<String, dynamic> map) {
    return CallModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      callerName: map['callerName'] as String? ?? 'Unknown Caller',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      startedAt: _parseTimestamp(map['startedAt']),
      purpose: map['purpose'] as String?,
      status: CallStatus.fromString(map['status'] as String?),
      aiHandled: map['aiHandled'] as bool? ?? false,
      outcome: CallOutcome.fromString(map['outcome'] as String?),
      transcript: map['transcript'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      customerId: map['customerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'callerName': callerName,
      'phoneNumber': phoneNumber,
      'durationSeconds': durationSeconds,
      'startedAt': Timestamp.fromDate(startedAt),
      if (purpose != null) 'purpose': purpose,
      'status': status.value,
      'aiHandled': aiHandled,
      if (outcome != null) 'outcome': outcome!.value,
      if (transcript != null) 'transcript': transcript,
      if (customerId != null) 'customerId': customerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
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

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get formattedDateTime {
    return '${startedAt.day}/${startedAt.month}/${startedAt.year} '
        '${startedAt.hour.toString().padLeft(2, '0')}:${startedAt.minute.toString().padLeft(2, '0')}';
  }

  CallModel copyWith({
    String? id,
    String? userId,
    String? callerName,
    String? phoneNumber,
    int? durationSeconds,
    DateTime? startedAt,
    String? purpose,
    CallStatus? status,
    bool? aiHandled,
    CallOutcome? outcome,
    String? transcript,
    DateTime? createdAt,
    String? customerId,
  }) {
    return CallModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      callerName: callerName ?? this.callerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      aiHandled: aiHandled ?? this.aiHandled,
      outcome: outcome ?? this.outcome,
      transcript: transcript ?? this.transcript,
      createdAt: createdAt ?? this.createdAt,
      customerId: customerId ?? this.customerId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CallModel &&
        other.id == id &&
        other.userId == userId &&
        other.callerName == callerName &&
        other.phoneNumber == phoneNumber &&
        other.durationSeconds == durationSeconds &&
        other.startedAt == startedAt &&
        other.purpose == purpose &&
        other.status == status &&
        other.aiHandled == aiHandled &&
        other.outcome == outcome &&
        other.transcript == transcript &&
        other.createdAt == createdAt &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      userId,
      callerName,
      phoneNumber,
      durationSeconds,
      startedAt,
      purpose,
      status,
      aiHandled,
      outcome,
      transcript,
      createdAt,
      customerId,
    ]);
  }
}

enum CallStatus {
  answered('answered'),
  missed('missed'),
  declined('declined'),
  voicemail('voicemail'),
  inProgress('in_progress');

  const CallStatus(this.value);
  final String value;

  static CallStatus fromString(String? value) {
    return CallStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CallStatus.missed,
    );
  }
}

enum CallOutcome {
  booking('booking'),
  inquiry('inquiry'),
  support('support'),
  spam('spam'),
  callback('callback'),
  transferred('transferred'),
  noOutcome('no_outcome');

  const CallOutcome(this.value);
  final String value;

  static CallOutcome? fromString(String? value) {
    if (value == null) return null;
    return CallOutcome.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CallOutcome.noOutcome,
    );
  }
}