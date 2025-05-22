import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/util/icon_util.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:sankaestay/auth/landlord/signup_landlord.dart';
import 'package:sankaestay/auth/tenants/signup_tenants.dart';
// Import for SVG images

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  void _navigateToSignup(BuildContext context, String role) {
    if (role == 'landlord') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupLandlord(),
        ),
      );
    } else if (role == 'tenant') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupTenants(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue, // Dark blue background
      body: Column(
        children: [
          // Top Blue Section
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: double.infinity,
            color: AppColors.primaryBlue,
          ),
          // Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 70,
                  ), // Spacing for top padding

                  // Logo Section
                  SvgPicture.asset(
                    'images/logo_blue.svg', // Replace with your asset path
                    height: 110,
                  ),
                  const SizedBox(height: 20),

                  // Title Section
                   Text(
                    'role.title'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle Section
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'role.description'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Role Buttons Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Landlord Button
                        ElevatedButton(
                          onPressed: () =>
                              _navigateToSignup(context, 'landlord'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'role.landlord'.tr,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(
                                      "role.managelandlord".tr,
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    )
                                  ],
                                ),
                                Icon(AppIcons.arrowforward,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Tenant Button
                        ElevatedButton(
                          onPressed: () => _navigateToSignup(context, 'tenant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'role.tenants'.tr,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(
                                      'role.managetenants'.tr,
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Icon(AppIcons.arrowforward,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
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
