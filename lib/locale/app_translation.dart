import 'dart:ui';

import 'package:get/get.dart';

import 'en.dart';
import 'ko.dart';

class AppTranslations extends Translations {
  // fallbackLocale saves the day when the locale gets in trouble
  static const fallbackLocale = Locale('en', 'US');

  // Supported languages
  // Needs to be same order with locales
  static final languages = [
    'English',
    '한국어',
  ];

  // Supported locales
  // Needs to be same order with languages
  static final locales = [
    const Locale('en', 'US'),
    const Locale('ko', 'KR'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': localeEnglish, // localization/en_us.dart
        'ko_KR': localeKorean, // localization/ko_KR.dart
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String language) {
    final locale = _getLocaleFromLanguage(language);
    Get.updateLocale(locale!);
  }

  // Finds language in `languages` list and returns it as Locale
  Locale? _getLocaleFromLanguage(String language) {
    for (int i = 0; i < languages.length; i++) {
      if (language == languages[i]) return locales[i];
    }
    return Get.locale;
  }
}
