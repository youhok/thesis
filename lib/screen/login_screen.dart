import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/util/alert/alert.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Triangle_Painter.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _loginIdentifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_loginIdentifierController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Alert.show(
        type: ToastificationType.error,
        title: 'Validation Error',
        description: 'Please fill in all fields',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final identifier = _loginIdentifierController.text.trim();
      String email = identifier;

      // If identifier doesn't look like an email, try to find the user by name
      if (!identifier.contains('@')) {
        final nameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: identifier)
            .get();

        if (nameQuery.docs.isEmpty) {
          Alert.show(
            type: ToastificationType.error,
            title: 'Login Failed',
            description: 'User not found',
          );
          setState(() => _isLoading = false);
          return;
        }
        email = nameQuery.docs.first.data()['email'];
      }

      // Now try to login with email
      final user = await _authService.signIn(
        email,
        _passwordController.text,
      );

      if (user != null) {
        final role = await _authService.getUserRole();

        if (role == 'Admin' || role == 'Super Admin') {
          // Get user data from Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', userDoc.data()?['name'] ?? '');
          await prefs.setString('userRole', role);
          await prefs.setBool('isLoggedIn', true);

          // Replace the existing navigation line with:
          if (mounted) {
  Get.offAllNamed('/dashboard');
}
        } else {
          await _authService.signOut();
          Alert.show(
            type: ToastificationType.error,
            title: 'Access Denied',
            description: 'You do not have admin privileges',
          );
        }
      } else {
        Alert.show(
          type: ToastificationType.error,
          title: 'Login Failed',
          description: 'Invalid credentials',
        );
      }
    } catch (e) {
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: 'Login failed: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // Top triangle
            Align(
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: Size(170, 330),
                painter: TrianglePainter(direction: TriangleDirection.right),
              ),
            ),
            // Bottom triangle
            Align(
              alignment: Alignment.bottomRight,
              child: CustomPaint(
                size: Size(150, 230),
                painter: TrianglePainter(direction: TriangleDirection.left),
              ),
            ),
            // Center content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Image.asset("images/10.png"),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Welcome text
                    const Text(
                      'Welcome Admin!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email or Username field
                    SizedBox(
                      width: 380,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email or Username',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 380,
                      child: TextField(
                        controller: _loginIdentifierController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Enter Email or Username',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    SizedBox(
                      width: 380,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 380,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Enter Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login button
                    SizedBox(
                      width: 380,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
