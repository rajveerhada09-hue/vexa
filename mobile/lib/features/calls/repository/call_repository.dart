import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/call_model.dart';

class CallRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CallRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _callsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('calls');
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<List<CallModel>> fetchRecentCalls({int limit = 10}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log('fetchRecentCalls called when user is not authenticated');
        return [];
      }

      final snapshot = await _callsCollection(userId)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CallModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchRecentCalls',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching recent calls.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchRecentCalls',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching recent calls.');
    }
  }

  Future<List<CallModel>> fetchCallsWithLimit(int limit) async {
    return fetchRecentCalls(limit: limit);
  }

  Future<List<CallModel>> fetchTodaysCalls() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log('fetchTodaysCalls called when user is not authenticated');
        return [];
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _callsCollection(userId)
          .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CallModel.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchTodaysCalls',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching today\'s calls.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchTodaysCalls',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching today\'s calls.');
    }
  }

  Future<int> getTodaysCallsCount() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return 0;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _callsCollection(userId)
          .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .count()
          .get();

      return snapshot.count ?? 0;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getTodaysCallsCount',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in getTodaysCallsCount',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  Future<void> createCallRecord(CallModel call) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log('createCallRecord called when user is not authenticated');
        throw Exception('User not authenticated');
      }

      if (call.userId != userId) {
        throw Exception('Cannot create call record for another user');
      }

      await _callsCollection(userId).doc(call.id).set(call.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in createCallRecord',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while creating call record.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in createCallRecord',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while creating call record.');
    }
  }

  Future<void> updateCallRecord(CallModel call) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log('updateCallRecord called when user is not authenticated');
        throw Exception('User not authenticated');
      }

      if (call.userId != userId) {
        throw Exception('Cannot update call record for another user');
      }

      await _callsCollection(userId).doc(call.id).update(call.toMap());
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateCallRecord',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while updating call record.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in updateCallRecord',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while updating call record.');
    }
  }

  /// Fetches calls for a specific customer by customerId.
  /// Falls back to phone number matching for legacy calls without customerId.
  Future<List<CallModel>> fetchCallsForCustomer({
    required String customerId,
    required String phoneNumber,
    int limit = 50,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        developer.log('fetchCallsForCustomer called when user is not authenticated');
        return [];
      }

      // First try to fetch by customerId
      final customerIdSnapshot = await _callsCollection(userId)
          .where('customerId', isEqualTo: customerId)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      final callsByCustomerId = customerIdSnapshot.docs
          .map((doc) => CallModel.fromMap(doc.id, doc.data()))
          .toList();

      // If we have calls with customerId, return them
      if (callsByCustomerId.isNotEmpty) {
        return callsByCustomerId;
      }

      // Fallback: fetch by normalized phone number for legacy calls
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      final phoneSnapshot = await _callsCollection(userId)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      final callsByPhone = phoneSnapshot.docs
          .map((doc) => CallModel.fromMap(doc.id, doc.data()))
          .toList();

      // Also try with normalized phone if different
      if (normalizedPhone != phoneNumber) {
        final normalizedPhoneSnapshot = await _callsCollection(userId)
            .where('phoneNumber', isEqualTo: normalizedPhone)
            .orderBy('startedAt', descending: true)
            .limit(limit)
            .get();

        final normalizedCalls = normalizedPhoneSnapshot.docs
            .map((doc) => CallModel.fromMap(doc.id, doc.data()))
            .toList();

        // Merge and deduplicate by call ID
        final allCalls = <String, CallModel>{};
        for (final call in callsByPhone) {
          allCalls[call.id] = call;
        }
        for (final call in normalizedCalls) {
          allCalls[call.id] = call;
        }

        final mergedCalls = allCalls.values.toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        return mergedCalls.take(limit).toList();
      }

      return callsByPhone;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in fetchCallsForCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching customer calls.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in fetchCallsForCustomer',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching customer calls.');
    }
  }

  /// Normalizes phone number for comparison (removes non-digits)
  String _normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
}