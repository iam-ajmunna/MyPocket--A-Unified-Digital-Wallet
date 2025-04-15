import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Email & Password Sign Up and Store to Firestore
  Future<User?> createUserWithEmailAndPassword(
      String fullName, String email, String password, String phNumber) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'phNumber': phNumber, // Store phone number
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
      String identifier, String password) async {
    try {
      // Try signing in with email.
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: identifier, // Use identifier here
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // If email sign-in fails, try signing in with phone number.
        final QuerySnapshot phoneResult = await _firestore
            .collection('Users')
            .where('phNumber', isEqualTo: identifier)
            .limit(1)
            .get();

        if (phoneResult.docs.isNotEmpty) {
          final String email = phoneResult.docs.first.get('email');
          UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return result.user;
        } else {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'User not found');
        }
      } else {
        throw e;
      }
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle({String? accessToken, String? idToken}) async {
    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
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
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken!);
      final UserCredential userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Facebook: $e");
      throw e;
    }
  }

  // Get User Document by UID
  Future<DocumentSnapshot?> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('Users').doc(uid).get();
    } catch (e) {
      print("Error fetching user document: $e");
      return null;
    }
  }

  // Find Users by Phone Number
  Future<List<DocumentSnapshot>> findUserByPhoneNumber(
      String phoneNumber) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('Users')
          .where('phNumber', isEqualTo: phoneNumber)
          .get();
      return result.docs;
    } catch (e) {
      print("Error finding user by phone number: $e");
      return [];
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
