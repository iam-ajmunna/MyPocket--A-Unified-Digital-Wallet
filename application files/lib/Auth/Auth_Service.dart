import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email & Password Sign Up
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  // Email & Password Login
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle({String? accessToken, String? idToken}) async {
    try {
      // This can be used if you're implementing the sign-in directly in AuthService
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a credential with the tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in with Firebase using the Google credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      throw e;
    }
  }

  // Facebook Sign In
  Future<User?> signInWithFacebook({String? accessToken}) async {
    try {
      // Create a credential using the access token
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(accessToken!);

      // Sign in with Firebase using the Facebook credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(facebookAuthCredential);

      return userCredential.user;
    } catch (e) {
      print("Error signing in with Facebook: $e");
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("Error signing out: $e");
      throw e;
    }
  }
}