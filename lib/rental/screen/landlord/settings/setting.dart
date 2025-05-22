import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/auth/role/role_screen.dart';
import 'package:sankaestay/composables/useAuth.dart';
import 'package:sankaestay/rental/screen/landlord/settings/edit_profile_landlord.dart';
import 'package:sankaestay/rental/screen/language/language.dart';
import 'package:sankaestay/rental/widgets/Outlined_Button.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/rental/widgets/profile_menu_Item.dart';
import 'package:sankaestay/rental/widgets/profile_user.dart';
import 'package:sankaestay/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

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
    return BaseScreen(
      title: "settings.title".tr,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGrey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0), // Add padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        FutureBuilder<Map<String, String>>(
                          future: getUserData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final name =
                                snapshot.data?['name'] ?? 'Unknown User';
                            final imageUrl = snapshot.data?['imageUrl'] ?? '';

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
                            Get.to(() => const EditProfileLandlord());
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
                        Spacer(),
                        CustomOutlinedButton(
                          text: "settings.log_out".tr,
                          onPressed: () async {
                            // Your logout logic here
                            final auth = AuthService();
                            await auth.signOut();
                            Get.offAll(() => const RoleScreen());
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
