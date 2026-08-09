import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Fetches a user by their Firestore UID.
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
        );
      }

      return null;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getUserById',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while fetching user data.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getUserById',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        'An unexpected error occurred while fetching user data.',
      );
    }
  }

  /// Fetches the currently authenticated user.
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return null;
      }

      return await getUserById(currentUser.uid);
    } catch (e, stackTrace) {
      developer.log(
        'Exception in getCurrentUser',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  /// Saves Vexa's AI personality and moves onboarding to Screen 3.
  Future<void> updateAiPersonality({
    required String userId,
    required String aiPersonality,
    String? customAiPersonality,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'aiPersonality': aiPersonality,

        // Screen 2 completed.
        // The next screen is onboarding step 3.
        'onboardingStep': 3,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      final trimmedCustom = customAiPersonality?.trim();

      if (aiPersonality == 'custom' &&
          trimmedCustom != null &&
          trimmedCustom.isNotEmpty) {
        data['customAiPersonality'] = trimmedCustom;
      } else {
        data['customAiPersonality'] = FieldValue.delete();
      }

await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
  } on FirebaseException catch (e, stackTrace) {
    developer.log(
      'FirebaseException in updateAiPersonality',
      error: e,
      stackTrace: stackTrace,
    );

    throw Exception(
      e.message ??
          'A database error occurred while saving AI personality.',
    );
  } catch (e, stackTrace) {
    developer.log(
      'Unknown Exception in updateAiPersonality',
      error: e,
      stackTrace: stackTrace,
    );

    throw Exception(
      'An unexpected error occurred while saving AI personality.',
    );
  }
}

  /// Saves business info and moves onboarding to Screen 4.
  Future<void> updateBusinessInfo({
    required String userId,
    required String businessName,
    required String businessType,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'businessName': businessName,
        'businessType': businessType,

        // Screen 3 completed.
        // The next screen is onboarding step 4.
        'onboardingStep': 4,
        'onboardingComplete': false,

        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in updateBusinessInfo',
        error: e,
        stackTrace: stackTrace,
      );

      throw Exception(
        e.message ??
            'A database error occurred while saving business info.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in updateBusinessInfo',
        error: e,
        stackTrace: stackTrace,
      );

throw Exception(
        'An unexpected error occurred while saving business info.',
      );
    }
  }
}