// Auth_Service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Email & Password Sign Up and Store to Firestore
  Future<User?> createUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Store additional user info in Firestore
        await _firestore.collection('Users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          // Add any other relevant information you want to store
        });
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    } catch (e) {
      print("Error creating user and storing data: $e");
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

  // Google Sign In and Store to Firestore if new user
  Future<User?> signInWithGoogle({String? accessToken, String? idToken}) async {
    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('Users').doc(user.uid).set({
            'uid': user.uid,
            'fullName': user.displayName,
            'email': user.email,
            // Add any other relevant information
          });
        }
      }
      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      throw e;
    }
  }

  // Facebook Sign In and Store to Firestore if new user
  Future<User?> signInWithFacebook({String? accessToken}) async {
    try {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken!);
      final UserCredential userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (!userDoc.exists) {
          // You might want to fetch more user data from Facebook Graph API
          // to get the full name. For simplicity, we'll just store basic info.
          await _firestore.collection('Users').doc(user.uid).set({
            'uid': user.uid,
            // 'fullName': ..., // Consider fetching from Facebook
            'email': user.email, // May not always be available
            // Add any other relevant information
          });
        }
      }
      return user;
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
