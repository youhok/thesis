import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/forget_password.dart';
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

class SigninTenants extends StatefulWidget {
  const SigninTenants({super.key});

  @override
  State<SigninTenants> createState() => _SigninTenantsState();
}

class _SigninTenantsState extends State<SigninTenants> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = await auth.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['role'] == 'Tenant') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', userDoc.data()?['name'] ?? '');
          await prefs.setString('userRole', 'Tenant');
          await prefs.setBool('isLoggedIn', true);

          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        } else {
          await auth.signOut();
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.of(context).pop();
          Alert.show(
            type: ToastificationType.error,
            title: 'Access Denied',
            description: 'Access denied. Tenants only.',
          );
        }
      } else {
        Navigator.of(context).pop();
        Alert.show(
          type: ToastificationType.error,
          title: 'Invalid Credentials',
          description: 'Please check your email and password.',
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
          // Top bar with language selector
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: double.infinity,
            color: AppColors.primaryBlue,
            child: Align(
              alignment: Alignment.topRight,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    SvgPicture.asset('images/logo_blue.svg', height: 110),
                    const SizedBox(height: 20),
                    Text(
                      'signin_tenant.signInAsTenant'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                        label: "signin_tenant.phoneOrEmail".tr,
                        hintText: "signin_tenant.enterPhoneOrEmail".tr),
                    const SizedBox(height: 10),
                    CustomTextField(
                        label: "signin_tenant.password".tr,
                        hintText: "signin_tenant.enterPassword".tr),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment
                          .centerRight, // Aligns the child to the right
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .end, // Ensures text is aligned right
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => ForgetPassword()),
                                );
                              },
                              child: Text(
                                'signin_landlord.forgot_password'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Custombutton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signIn();
                          }
                        },
                        text: "signin_tenant.signIn".tr),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "signin_tenant.orSignUpWithGmail".tr,
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GoogleSignUpButton(onPressed: signInWithGoogle),
                    SizedBox(
                      height: 120,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'signin_tenant.alreadyHaveAccount'.tr,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          'signin_tenant.signUp'.tr,
                          style: TextStyle(
                              fontSize: 16, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
