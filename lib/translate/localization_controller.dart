import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationController extends GetxController {
  var selectedLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage(); // Load the language when the controller initializes
  }

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
  }

  // Public method to load saved language
  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLang = prefs.getString('selectedLanguage');
    if (savedLang != null) {
      selectedLanguage.value = savedLang;
      Get.updateLocale(Locale(savedLang)); // Update locale when the language is loaded
    }
  }
}
