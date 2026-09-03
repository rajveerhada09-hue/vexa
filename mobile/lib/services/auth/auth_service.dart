import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AuthService {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> registerWithEmail({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
    String? businessName,
    String? businessType,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

class AuthServiceImpl implements AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


@override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Ensure user profile exists in Firestore (safety net)
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        final Map<String, dynamic> userData = {
          'uid': user.uid,
          'fullName': user.displayName ?? 'User',
          'username': user.email?.split('@').first ?? 'user',
          'email': user.email ?? '',
          'phone': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
      }
    }
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
    String? businessName,
    String? businessType,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception("User creation failed");
    }

    await user.updateDisplayName(fullName);


    final Map<String, dynamic> userData = {
      'uid': user.uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (businessName != null && businessName.isNotEmpty) {
      userData['businessName'] = businessName;
    }

    if (businessType != null && businessType.isNotEmpty) {
      userData['businessType'] = businessType;
    }

    await _firestore.collection('users').doc(user.uid).set(userData);
  }

@override
  Future<void> signInWithGoogle() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await signIn.initialize();

    final GoogleSignInAccount googleUser = await signIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Ensure user profile exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        final Map<String, dynamic> userData = {
          'uid': user.uid,
          'fullName': user.displayName ?? 'User',
          'username': user.email?.split('@').first ?? 'user',
          'email': user.email ?? '',
          'phone': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
