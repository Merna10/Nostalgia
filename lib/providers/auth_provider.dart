import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nostalgia/screens/home_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:nostalgia/models/user.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLogin = true;
  bool _isAuthenticating = false;
  bool _loggedIn = false;

  bool get isLogin => _isLogin;
  bool get isAuthenticating => _isAuthenticating;
  bool get loggedIn => _loggedIn;

  set isLogin(bool value) {
    _isLogin = value;
    notifyListeners();
  }

  set isAuthenticating(bool value) {
    _isAuthenticating = value;
    notifyListeners();
  }

  Future<void> submit(String email, String password, BuildContext context) async {
    try {
      isAuthenticating = true;
      if (_isLogin) {
        final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null && userCredential.user!.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified. Please check your email.'),
            ),
          );
          isAuthenticating = false; 
          notifyListeners();
        }
      } else {
        final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await userCredential.user!.sendEmailVerification();

        Users user = Users(
          id: const Uuid().v4(),
          email: email,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(user.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please verify your email before logging in.'),
          ),
        );
        isAuthenticating = false; // Stop authentication process
        notifyListeners();
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );
      isAuthenticating = false; 
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
          final userSnapshot = await userDoc.get();

          if (!userSnapshot.exists) {
            Users newUser = Users(
              id: Uuid().v4(),
              email: userCredential.user!.email!,
            );

            await userDoc.set(newUser.toMap());
          }

          if (user.emailVerified ) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email not verified. Please check your email.'),
              ),
            );
            isAuthenticating = false; // Stop authentication process
            notifyListeners();
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${error.toString()}'),
        ),
      );
      isAuthenticating = false; // Stop authentication process in case of error
      notifyListeners();
    }
  }
}
