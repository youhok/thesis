import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/tenants/signin_tenants.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/button_ggle.dart';
import 'package:sankaestay/rental/widgets/language_dropdown.dart';
import 'package:sankaestay/rental/widgets/tenentwidgets/Bottom_navbar.dart';
import 'package:sankaestay/util/alert/alert.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class SignupTenants extends StatefulWidget {
  const SignupTenants({super.key});

  @override
  State<SignupTenants> createState() => _SignupTenantsState();
}

class _SignupTenantsState extends State<SignupTenants> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final auth = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = await auth.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': DateTime.now(),
          'imageURL': '',
          'role': 'Tenant',
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await prefs.setString('userEmail', _emailController.text.trim());
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('userRole', 'Tenant');
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        Navigator.of(context).pop();
        Alert.show(
          type: ToastificationType.error,
          title: 'Sign Up Failed',
          description: 'Failed to create account. Please try again.',
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = await auth.signInWithGoogle();

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'role': 'Tenant',
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? '');
        await prefs.setString('userRole', 'Tenant');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGoogleSignIn', true);

        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        Navigator.of(context).pop();
        Alert.show(
          type: ToastificationType.error,
          title: 'Google Sign In Failed',
          description: 'Unable to sign in with Google. Please try again.',
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Column(
        children: [
          // Top bar with language selector and back button
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: double.infinity,
            color: AppColors.primaryBlue,
            child: Row(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.only(top: 45, left: 20),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                // Language dropdown
                Padding(
                  padding: const EdgeInsets.only(top: 45, right: 20),
                  child: LanguageDropdown(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      SvgPicture.asset('images/logo_blue.svg', height: 110),
                      const SizedBox(height: 20),
                      Text(
                        'signup_Tenant.signUpAsTenant'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: "signup_landlord.name_label".tr,
                        hintText: "signup_landlord.name_hint".tr,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          } else if (value.length < 3) {
                            return 'Name must be at least 3 characters long';
                          } else if (value.length > 20) {
                            return 'Name must be less than 20 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                          label: "signup_landlord.email_label".tr,
                          hintText: "signup_landlord.email_hint".tr,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          }),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: "signup_landlord.password_label".tr,
                        hintText: "signup_landlord.password_hint".tr,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      // sign up button
                      Custombutton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUp();
                          }
                        },
                        text: "signup_landlord.sign_up".tr,
                      ),
                      // sign up with Google button
                      const SizedBox(height: 20),

                      GoogleSignUpButton(onPressed: signInWithGoogle),

                      const SizedBox(height: 70),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'signup_landlord.already_have_account'.tr,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SigninTenants(),
                              ),
                            ),
                            child: Text(
                              'signup_landlord.sign_in'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
