import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthService {
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();
}

/// Temporary concrete implementation so UI compiles.
/// Replace with real FirebaseAuth + GoogleSignIn later.
class AuthServiceImpl implements AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;



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
    required String name,
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _auth.currentUser?.updateDisplayName(name);
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