import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hexcolor/hexcolor.dart';

import '../data/app_setting.dart';
import '../pages/setting/setting_logic.dart';

class EnclaveColors {
  static final Color normalFieldTitle = Colors.green[50]!;
  static final Color distinctFieldTitle = Colors.red[50]!;

  // ignore: non_constant_identifier_names
  static final MaterialColor PRIMARY_COLOR = _factoryColor(0xff2B3340);

  // ignore: non_constant_identifier_names
  static final MaterialColor LIGHT = _factoryColor(0xfff4f4f8);

  // ignore: non_constant_identifier_names
  static final MaterialColor LIGHT_GREY = _factoryColor(0xffd8d8d8);

  // ignore: non_constant_identifier_names
  static final MaterialColor DARK = _factoryColor(0xff3a3a3a);

  // ignore: non_constant_identifier_names
  static final MaterialColor WHITE = _factoryColor(0xffffffff);

  // ignore: non_constant_identifier_names
  static final MaterialColor GREEN = _factoryColor(0xff349e40);

  // ignore: non_constant_identifier_names
  static final MaterialColor LIGHT_GREEN = _factoryColor(0xff3AB54A);

  // ignore: non_constant_identifier_names
  static final MaterialColor SHADOW = _factoryColor(0xffE7EAF0);

  static MaterialColor hex(String hex) => EnclaveColors._factoryColor(EnclaveColors._getColorHexFromStr(hex));

  static MaterialColor _factoryColor(int color) {
    return MaterialColor(color, <int, Color>{
      50: Color(color),
      100: Color(color),
      200: Color(color),
      300: Color(color),
      400: Color(color),
      500: Color(color),
      600: Color(color),
      700: Color(color),
      800: Color(color),
      900: Color(color),
    });
  }

  static int _getColorHexFromStr(String colorStr) {
    colorStr = "FF" + colorStr;
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        val = 0xFFFFFFFF;
      }
    }
    return val;
  }
}

late EnclaveTheme gEnTheme;

class EnclaveTheme {
  static final lightThemeDefault = ThemeData.light();
  static final darkThemeDefault = ThemeData.dark();

  static EnclaveTheme? _instance;

  EnclaveTheme._();

  factory EnclaveTheme() => _instance ??= EnclaveTheme._();

  // factory EnclaveTheme() => _instance ??= EnclaveTheme();

  // default theme
  final rxThemeLight = Rx<ThemeData?>(EnclaveTheme.lightThemeDefault);
  final rxThemeDark = Rx<ThemeData?>(EnclaveTheme.darkThemeDefault);

  final lightTheme = ThemeData.light().copyWith(
      inputDecorationTheme: const InputDecorationTheme(filled: true),
      indicatorColor: HexColor("#009D4D"),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: HexColor("#FFFFFF"),
      scaffoldBackgroundColor: HexColor("#FFFFFF"),
      canvasColor: HexColor("#FFFFFF"),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: HexColor("#009D4D")),
      buttonTheme: ButtonThemeData(
        buttonColor: HexColor("#009D4D"), //  <-- dark color
        textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange));

  final darkTheme = ThemeData.dark().copyWith(
    inputDecorationTheme: const InputDecorationTheme(filled: true),
    indicatorColor: HexColor("#009D4D"),
    primaryColor: HexColor("#009D4D"),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    backgroundColor: HexColor("#000000"),
    // accentColor: Color.fromARGB(1, 0, 39, 72),
    scaffoldBackgroundColor: HexColor("#021623"),
    canvasColor: HexColor("#021623"),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: HexColor("#009D4D")),
    buttonTheme: ButtonThemeData(
      buttonColor: HexColor("#009D4D"), //  <-- dark color
      textTheme: ButtonTextTheme.primary, //  <-- this auto selects the right color
    ),
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
  );

  /// Get isDarkMode info from local storage and return ThemeMode
  ThemeMode get theme => gAppSetting.rxPrefDarkTheme.value ? ThemeMode.dark : ThemeMode.light;

  /// Save isDarkMode to local storage
  void _saveThemeToBox(bool isDarkMode) => gAppStorage.write(PrefKey.darkTheme.name, isDarkMode);

  /// Switch theme and save to local storage
  void switchTheme({bool toggle = false}) {
    if (toggle) {
      gAppSetting.rxPrefDarkTheme.value = !gAppSetting.rxPrefDarkTheme.value;
      _saveThemeToBox(gAppSetting.rxPrefDarkTheme.value);
    }
    Get.changeThemeMode(gAppSetting.rxPrefDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
  }
}
