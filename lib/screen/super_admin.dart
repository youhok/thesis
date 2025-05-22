import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/composables/useStorage.dart';
import 'package:sankaestay/screen/login_screen.dart';

import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Triangle_Painter.dart';

import 'package:sankaestay/util/alert/alert.dart';
import 'package:toastification/toastification.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  _SuperAdminScreenState createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  bool _obscurePassword = true;
  XFile? _pickedFile;
  File? _imageFile;
  Uint8List? _webImage;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storageService = StorageService();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          if (kIsWeb) {
            pickedFile.readAsBytes().then((value) {
              setState(() {
                _webImage = value;
              });
            });
          } else {
            _imageFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Widget _buildImagePreview() {
    if (_webImage != null && kIsWeb) {
      return Image.memory(
        _webImage!,
        width: 170,
        height: 170,
        fit: BoxFit.cover,
      );
    } else if (_imageFile != null && !kIsWeb) {
      return Image.file(
        _imageFile!,
        width: 170,
        height: 170,
        fit: BoxFit.cover,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 40,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Photo',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    try {
      // First create the user account
      final user = await _authService.signUp(
          _emailController.text, _passwordController.text);

      if (user != null) {
        String? imageURL;

        // If image was selected, upload it
        if (_pickedFile != null) {
          final path = 'users/${user.uid}.jpg';
          final bytes = await _pickedFile!.readAsBytes();
          imageURL = await _storageService.uploadImageBytes(path, bytes);
        }

        // Update Firestore document with additional info
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _usernameController.text,
          'email': _emailController.text,
          'role': 'Super Admin',
          'password': _passwordController.text,
          'profileImage': imageURL,
          'createdAt': DateTime.now(),
        });

        await _authService.signOut();

        // Show success message using Alert
        Alert.show(
          type: ToastificationType.success,
          title: 'Success',
          description: 'Super Admin account created successfully!',
        );

        // Navigate to LoginScreen and remove all previous routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Show error message using Alert
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: e.toString(),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: Size(170, 330),
                painter: TrianglePainter(direction: TriangleDirection.right),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: CustomPaint(
                size: Size(150, 230),
                painter: TrianglePainter(direction: TriangleDirection.left),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipOval(
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildImagePreview(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Welcome text
                    const Text(
                      'Create Super Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Username field
                    SizedBox(
                      width: 380,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Username',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 380,
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Enter Username',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email field
                    SizedBox(
                      width: 380,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 380,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Enter Email',
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
                        onPressed: _isLoading ? null : _handleSignUp,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              )
                            : const Text('Create'),
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
