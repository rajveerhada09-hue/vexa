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
  required String businessName,
  required String businessType,
});

  Future<void> signInWithGoogle();
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
  }

  @override
  Future<void> registerWithEmail({
  required String fullName,
  required String username,
  required String email,
  required String password,
  required String phone,
  required String businessName,
  required String businessType,
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


await _firestore.collection('users').doc(user.uid).set({
  'uid': user.uid,
  'fullName': fullName,
  'username': username,
  'email': email,
  'phone': phone,
  'businessName': businessName,
  'businessType': businessType,
  'createdAt': FieldValue.serverTimestamp(),
});
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

  await _auth.signInWithCredential(credential);
}
}