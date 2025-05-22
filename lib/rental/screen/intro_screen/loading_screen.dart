import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/auth/role/role_screen.dart';
import 'package:sankaestay/widgets/Triangle_Painter.dart';
import 'package:sankaestay/rental/widgets/tenentwidgets/Bottom_navbar.dart';
import 'package:sankaestay/rental/screen/landlord/dash_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId') ?? '',
      'userEmail': prefs.getString('userEmail') ?? '',
      'userName': prefs.getString('userName') ?? '',
      'userRole': prefs.getString('userRole') ?? '',
    };
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // First check SharedPreferences for logged in status
    final isLoggedIn = await checkLoginStatus();
    if (isLoggedIn) {
      final userData = await getUserData();
      final role = userData['userRole'];

      // Navigate based on stored role
      if (role == 'Tenant') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
        return;
      } else if (role == 'Landlord') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
        return;
      } else if (role == 'Admin' || role == 'Super Admin') {
        Navigator.of(context).pushReplacementNamed('/dashboard');
        return;
      }
    }

    // If not logged in or no role stored, continue with Firebase check
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleScreen()),
      );
    } else {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoleScreen()),
          );
          return;
        }

        final userData = userDoc.data();
        final role = userData?['role'] as String?;

        // Save user data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', userData?['name'] ?? '');
        await prefs.setString('userRole', role ?? '');
        await prefs.setBool('isLoggedIn', true);

        if (role == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoleScreen()),
          );
          return;
        }

        if (role == 'Tenant') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        } else if (role == 'Landlord') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else if (role == 'Admin' || role == 'Super Admin') {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoleScreen()),
          );
        }
      } catch (e) {
        print('Error checking user role: $e');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue, // Dark blue background color
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo (replace with your logo asset if you have one)
                  Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                          "images/sangkaestay.ico"), // Replace with your asset path
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App name
                  const Text(
                    'SangkaeStay',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'loading_screen.findroom'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
