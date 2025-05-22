import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppTranslations extends Translations {
  static final Map<String, Map<String, String>> _translations = {};

  static Future<void> loadTranslations() async {
    _translations['en'] = await _loadJson('assets/english.json');
    _translations['km'] = await _loadJson('assets/khmer.json');
  }

  static Future<Map<String, String>> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return _flattenMap(jsonMap);
  }

  static Map<String, String> _flattenMap(Map<String, dynamic> map, [String prefix = '']) {
    final flatMap = <String, String>{};

    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map) {
        flatMap.addAll(_flattenMap(value as Map<String, dynamic>, newKey));
      } else {
        flatMap[newKey] = value.toString();
      }
    });

    return flatMap;
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
