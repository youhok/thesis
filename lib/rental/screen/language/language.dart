import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/rental/widgets/dynamicscreen/base_screen.dart';
import 'package:sankaestay/translate/localization_controller.dart';
import 'package:sankaestay/util/constants.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final LocalizationController langController = Get.find();

  final List<Map<String, String>> languages = [
    {"name": "Khmer", "flag": "images/cambodiaflag.png", "code": "km"},
    {"name": "English", "flag": "images/united-states.png", "code": "en"},
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "translate.language".tr,
      child: Obx(() {
        // Listen for language change and rebuild the widget when it changes
        return Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: languages.map((language) {
                    bool isSelected = langController.selectedLanguage.value ==
                        language["code"];
                    return GestureDetector(
                      onTap: () {
                        langController.changeLanguage(language["code"]!);
                        // Optionally navigate back after the language change
                        // Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.primaryBlue : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Image.asset(language["flag"]!, width: 30),
                            const SizedBox(width: 10),
                            Text(
                              language["name"]!,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
