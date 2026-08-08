import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/dashboard_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Fetches dashboard data for the currently authenticated user from Firestore
  Future<DashboardModel?> getDashboard() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        developer.log('getDashboard called when user is not authenticated');
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('dashboard').doc(currentUser.uid).get();
      developer.log(docSnapshot.data().toString()); 
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
  return DashboardModel.fromMap(
    docSnapshot.data() as Map<String, dynamic>,
  );
}

developer.log(
  'Dashboard document not found for UID: ${currentUser.uid}',
);

return null;
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'FirebaseException in getDashboard',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        e.message ?? 'A database error occurred while fetching dashboard metrics.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected Exception in getDashboard',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('An unexpected error occurred while fetching dashboard data.');
    }
  }
}