import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sankaestay/translate/localization_controller.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final LocalizationController langController = Get.find();

  final Map<String, Map<String, String>> languages = {
    'EN': {
      'code': 'en',
      'flag': 'images/united-states.png',
    },
    'KH': {
      'code': 'km',
      'flag': 'images/cambodiaflag.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ignore: unused_local_variable
      String selectedLangCode = langController.selectedLanguage.value.toUpperCase();
      String selectedDisplay = languages.entries.firstWhere(
        (entry) => entry.value['code'] == langController.selectedLanguage.value,
        orElse: () => MapEntry('EN', languages['EN']!),
      ).key;

      return Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        child: PopupMenuButton<String>(
          onSelected: (String value) {
            String langCode = languages[value]!['code']!;
            langController.changeLanguage(langCode);
          },
          itemBuilder: (BuildContext context) {
            return languages.entries.map((entry) {
              return PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    SizedBox(
                      width: 30,
                      child: Image.asset(entry.value['flag']!),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF001D57),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedDisplay,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 30,
                  child: Image.asset(languages[selectedDisplay]!['flag']!),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
