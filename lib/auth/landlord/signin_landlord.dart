import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/forget_password.dart';
import 'package:sankaestay/auth/landlord/signup_landlord.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/screen/landlord/dash_board.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/button_ggle.dart';
import 'package:sankaestay/rental/widgets/language_dropdown.dart';
import 'package:sankaestay/util/alert/alert.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class SigninLandlord extends StatefulWidget {
  const SigninLandlord({super.key});

  @override
  State<SigninLandlord> createState() => _SigninLandlordState();
}

class _SigninLandlordState extends State<SigninLandlord> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final auth = AuthService();

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
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
        _emailOrUsernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['role'] == 'Landlord') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user.uid);
          await prefs.setString('userEmail', user.email ?? '');
          await prefs.setString('userName', userDoc.data()?['name'] ?? '');
          await prefs.setString('userRole', 'Landlord');
          await prefs.setBool('isLoggedIn', true);

          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else {
          await auth.signOut();
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.of(context).pop();
          Alert.show(
            type: ToastificationType.error,
            title: 'Access Denied',
            description: 'Access denied. Landlords only.',
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
          'role': 'Landlord',
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userName', user.displayName ?? '');
        await prefs.setString('userRole', 'Landlord');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isGoogleSignIn', true);

        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dashboard()),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      SvgPicture.asset('images/logo_blue.svg', height: 110),
                      const SizedBox(height: 20),
                      Text(
                        'signin_landlord.title'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CustomTextField(
                        label: "Username or Email",
                        hintText: "Username or Email",
                        controller: _emailOrUsernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name or email';
                          } else if (value.length < 3) {
                            return 'Name must be at least 3 characters long';
                          } else if (value.length > 20) {
                            return 'Name must be less than 20 characters long';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
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
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                        height: 5,
                      ),
                      Custombutton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signIn();
                            }
                          },
                          text: "signin_landlord.sign_in".tr),
                      const SizedBox(height: 20),
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
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'signin_landlord.already_have_account'.tr,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupLandlord()),
                              );
                            },
                            child: Text(
                              'signin_landlord.sign_up'.tr,
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
