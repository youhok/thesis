import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/role/role_screen.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/screen/language/language.dart';
import 'package:sankaestay/rental/screen/tenants/settings/edit_profile_tenants.dart';
import 'package:sankaestay/rental/widgets/Outlined_Button.dart';
import 'package:sankaestay/rental/widgets/profile_menu_Item.dart';
import 'package:sankaestay/rental/widgets/profile_user.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'Unknown User';
    final imageUrl = prefs.getString('userImageUrl') ?? '';
    final telegram = prefs.getString('userTelegram') ?? '';
    final email = prefs.getString('userEmail') ?? '';
    final phone = prefs.getString('userPhoneNumber') ?? '';
    // Save this in EditProfile
    return {
      'name': name,
      'imageUrl': imageUrl,
      'telegram': telegram,
      'email': email,
      'phone': phone
    };
  }

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
                            FutureBuilder<Map<String, String>>(
                              future: getUserData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                final name =
                                    snapshot.data?['name'] ?? 'Unknown User';
                                final imageUrl =
                                    snapshot.data?['imageUrl'] ?? '';

                                return ProfileUser(
                                  name: name,
                                  imagePath: imageUrl.isNotEmpty
                                      ? imageUrl
                                      : 'images/user.png', // fallback to default
                                  isNetworkImage: imageUrl.isNotEmpty,
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                            ProfileMenuItem(
                              icon: Icons.edit,
                              text: 'settings.edit_profile'.tr,
                              onTap: () {
                                Get.to(() => const EditProfileTenants());
                              },
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
