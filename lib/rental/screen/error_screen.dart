import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/util/constants.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue, // Dark blue background
      body: Column(
        children: [
          // Top Blue Section
          Container(
            height: MediaQuery.of(context).size.height *
                0.1, // Adjust top section height
            width: double.infinity,
            color: AppColors.primaryBlue, // Same as background
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 45.0), // Adjust padding as needed
              child: Row(
                children: [
                  // Add your image here
                  Image.asset(
                    'images/sangkaestay.ico', // Replace with your image asset path
                    height: 50, // Adjust size
                  ),
                  const SizedBox(
                      width: 10), // Add spacing between image and text
                   Text(
                    'SangkaeStay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content Section
          Expanded(
            child: Container(
              width: double.infinity, // Ensures full width
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Illustration
                  Image.asset(
                    'images/Error.jpg', // Replace with your image asset path
                    height: 250, // Adjust size as needed
                  ),
                  const SizedBox(height: 30),
                  // Back Button
                  SizedBox(
                    width: 150, // Adjust width as needed
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate back
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue, // Dark blue
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'error_screen.back'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
