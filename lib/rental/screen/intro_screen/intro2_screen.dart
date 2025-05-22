import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/widgets/Custom_button.dart';
import 'package:sankaestay/util/constants.dart';


class Intro2Screen extends StatelessWidget {
  const Intro2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.primaryBlue, // Dark blue background
      body: Column(
        children: [
          // Top Blue Section
          Container(
            height: MediaQuery.of(context).size.height * 0.1, // Top section height
            width: double.infinity,
            color: Color(0xFF001D57), // Dark blue color
          ),
          // Content Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Illustration
                        SizedBox(height: 70,),
                        Image.asset(
                          'images/undraw_connecting-teams_nnjy.png', // Replace with your image asset path
                          height: 250, // Adjust size as needed
                        ),
                        SizedBox(height: 30),
                        // Title
                        Text(
                          'intro_2.title'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        // Subtitle
                        Text(
                          'intro_2.description'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Button Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Custombutton(onPressed: () {}, text: "intro_2.next".tr)
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