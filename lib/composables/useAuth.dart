import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('userEmail', user.email ?? '');
    await prefs.setString('userRole', role);
    await prefs.setBool('isLoggedIn', true);
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Sign up with email & password
  Future<User?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user in Firestore
      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now(),
        'role': 'User',
      });

      // Save user data to SharedPreferences
      await _saveUserData(result.user!, 'User');
      
      return result.user;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user role from Firestore
      final userDoc = await _db.collection('users').doc(result.user!.uid).get();
      final role = userDoc.data()?['role'] ?? 'Tenant';

      // Save user data to SharedPreferences
      await _saveUserData(result.user!, role);
      
      return result.user;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Google sign in
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // If new user, add to Firestore
      if (result.additionalUserInfo!.isNewUser) {
        await _db.collection('users').doc(result.user!.uid).set({
          'email': result.user!.email,
          'name': result.user!.displayName,
          'imageURL': result.user!.photoURL,
          'role': 'User',
          'createdAt': DateTime.now(),
        });
      }

      // Get user role from Firestore
      final userDoc = await _db.collection('users').doc(result.user!.uid).get();
      final role = userDoc.data()?['role'] ?? 'User';

      // Save user data to SharedPreferences
      await _saveUserData(result.user!, role);

      return result.user;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _clearUserData(); // Clear SharedPreferences on sign out
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Reset Password Error: $e');
      return false;
    }
  }
  

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Get user role
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole') ?? 'Tenant';
  }

  // Get current user stream
  Stream<User?> get userChanges => _auth.authStateChanges();
}