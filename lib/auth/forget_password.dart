import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/rental/widgets/language_dropdown.dart';
import 'package:sankaestay/util/alert/alert.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/widgets/Custom_Text_Field.dart';
import 'package:toastification/toastification.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _handleResetPassword(BuildContext context) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Navigator.pop(context); 
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: 'Please enter your email',
      );
      return;
    }

    final success = await _authService.resetPassword(email);

    Navigator.pop(context); // Close loading dialog

    if (success) {
      Alert.show(
        type: ToastificationType.success,
        title: 'Success',
        description: 'Password reset link has been sent to your email',
      );
      Get.back(); 
    } else {
      Alert.show(
        type: ToastificationType.error,
        title: 'Error',
        description: 'Failed to send reset link. Please check your email and try again',
      );
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    Alert.show(
      type: ToastificationType.error,
      title: 'Error',
      description: 'Failed to send reset link. Please check your email and try again',
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
                      'forget_password_screen.forgetpassword'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                        controller: _emailController,
                        label: "forget_password_screen.label".tr,
                        hintText: "forget_password_screen.placeholder".tr),
                    SizedBox(
                      height: 20,
                    ),
                    Custombutton(
                        onPressed: () => _handleResetPassword(context),
                        text: "forget_password_screen.continue".tr),
                    
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
