import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/role/role_screen.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/screen/language/language.dart';
import 'package:sankaestay/rental/widgets/Outlined_Button.dart';
import 'package:sankaestay/rental/widgets/profile_menu_Item.dart';
import 'package:sankaestay/rental/widgets/profile_user.dart';
import 'package:sankaestay/util/constants.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          children: [
                            // Profile Card
                            ProfileUser(
                                imagePath: 'images/person.png',
                                name: "Heng Youhok"),

                            const SizedBox(height: 20),
                            ProfileMenuItem(
                              icon: Icons.edit,
                              text: 'settings.edit_profile'.tr,
                              onTap: () {},
                            ),
                            ProfileMenuItem(
                              icon: Icons.language,
                              text: 'settings.language'.tr,
                              onTap: () {
                                Get.to(() => const Language());
                              },
                            ),
                            ProfileMenuItem(
                              icon: Icons.support_agent,
                              text: 'settings.support'.tr,
                              onTap: () {},
                            ),

                            CustomOutlinedButton(
                              text: "settings.log_out".tr,
                              onPressed: () {
                                final auth = AuthService();
                                auth.signOut();
                                Get.offAll(() => const RoleScreen());
                              },
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
