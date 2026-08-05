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

  /// Fetches a user by their Firestore UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      
      return null;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getUserById', 
        error: e, 
        stackTrace: stackTrace,
      );
      throw Exception(e.message ?? 'A database error occurred while fetching user data.');
    } catch (e, stackTrace) {
      developer.log(
        'Unknown Exception in getUserById', 
        error: e, 
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching user data.');
    }
  }

  /// Fetches the currently authenticated user
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
}