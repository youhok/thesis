import 'package:flutter/material.dart';
import 'package:sankaestay/util/constants.dart';

class GoogleSignUpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignUpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal:98),
        side: const BorderSide(color: AppColors.primaryBlue), // Border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'images/google.png', // Make sure to add Google logo in assets
            height: 27,
          ),
          const SizedBox(width: 10),
          const Text(
            "Sign Up with Google",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.primaryBlue, // Text color
            ),
          ),
        ],
      ),
    );
  }
}
