import 'dart:developer';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/app_setting.dart';
import '../../data/en_enclave.dart';
import '../../main_logic.dart';
import '../../pages/setting/setting_state.dart';
import '../../shared/enclave_dialog.dart';

///
/// Controller for Setting
///
class SettingLogic extends GetxController {
  final state = SettingState();

  @override
  onInit() {
    super.onInit();
  }

  @override
  onReady() {
    super.onReady();
  }

  @override
  onClose() {
    super.onClose();
  }

  Future<bool> initSettingPageAsync() async {
    final _getCacheProvider = GetStorageCache();
    await Settings.init(cacheProvider: _getCacheProvider);
    return true;
  }
}

class GetStorageCache extends CacheProvider {
  @override
  bool? containsKey(String key) {
    final givenKeys = gAppStorage.getKeys();

    for (String givenKey in givenKeys) {
      print(givenKey);
    }

    return givenKeys.contains(key);
  }

  @override
  bool? getBool(String key) {
    return gAppStorage.read<bool>(key);
  }

  @override
  double? getDouble(String key) {
    return gAppStorage.read<double>(key);
  }

  @override
  int? getInt(String key) {
    return gAppStorage.read<int>(key);
  }

  @override
  Set? getKeys() {
    return gAppStorage.getKeys<String>() as Set;
  }

  @override
  String? getString(String key) {
    return gAppStorage.read<String>(key);
  }

  @override
  T getValue<T>(String key, T defaultValue) {
    return gAppStorage.read<T>(key) ?? defaultValue;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> remove(String key) async {
    await gAppStorage.remove(key);
  }

  @override
  Future<void> removeAll() async {
    gAppStorage.erase();
  }

  @override
  Future<void> setBool(String key, bool? value, {bool? defaultValue}) async {
    await gAppStorage.write(key, value ?? defaultValue);
  }

  @override
  Future<void> setDouble(String key, double? value, {double? defaultValue}) async {
    await gAppStorage.write(key, value ?? defaultValue);
  }

  @override
  Future<void> setInt(String key, int? value, {int? defaultValue}) async {
    await gAppStorage.write(key, value ?? defaultValue);
  }

  @override
  Future<void> setObject<T>(String key, T value) async {
    await gAppStorage.write(key, value);
  }

  @override
  Future<void> setString(String key, String? value, {String? defaultValue}) async {
    await gAppStorage.write(key, value ?? defaultValue);
  }
}

///
/// Class: AppSetting
///
late GetStorage gAppStorage;
late AppSetting gAppSetting;

class AppSetting {
  // pref data restored from gStorage
  final rxPrefSoundOn = Rx<bool>(true);
  final rxPrefDarkTheme = Rx<bool>(false);
  final rxPrefFontScale = Rx<double>(1.0);
  final rxPrefShowTutorial = Rx<bool>(true);
  final rxPrefHideEmptyData = Rx<bool>(true);

  String recentMobilePhone = ''; // given in login page
  String recentEnclaveCode = '';
  bool recentEnclaveCodeValidated = false;

  int loginCount = 0;
  int lastLoginGap = 0;

  // sensors
  bool canVibrate = false;

  static AppSetting? _instance;

  factory AppSetting() => _instance ??= AppSetting._();

  AppSetting._() {
    try {
      _initSettingAsync();

      rxPrefSoundOn.value = gAppStorage.read<bool>(PrefKey.soundOn.name) ?? true;
      rxPrefDarkTheme.value = gAppStorage.read<bool>(PrefKey.darkTheme.name) ?? false;
      rxPrefFontScale.value = gAppStorage.read<double>(PrefKey.fontScale.name) ?? 1.0;
      rxPrefShowTutorial.value = gAppStorage.read<bool>(PrefKey.showTutorial.name) ?? true;
      rxPrefHideEmptyData.value = gAppStorage.read<bool>(PrefKey.hideEmptyData.name) ?? true;

      // count how many times you have logged-in. increase 1 each login
      loginCount = (gAppStorage.read<int>(PrefKey.loginCount.name) ?? 0) + 1;
      gAppStorage.write(PrefKey.loginCount.name, loginCount);

      // catch time gap since last login. save current login time
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastLoginTime = gAppStorage.read<int>(PrefKey.lastLoginTime.name) ?? 0;
      gAppStorage.write(PrefKey.lastLoginTime.name, DateTime.now().millisecondsSinceEpoch);
      lastLoginGap = now - lastLoginTime;

      recentMobilePhone = gAppStorage.read<String>(PrefKey.recentMobilePhone.name) ?? '';
      recentEnclaveCode = gAppStorage.read<String>(PrefKey.recentEnclaveCode.name) ?? '';
      if (recentEnclaveCode == EnEnclave.dummyEnclave.code) recentEnclaveCode = '';

      recentEnclaveCodeValidated = recentEnclaveCode.isEmpty ? false : (gAppStorage.read<bool>(PrefKey.enclaveValidated.enclaveKey(recentEnclaveCode)) ?? false);
    } on Exception catch (e) {
      gEnDialog.showExceptionError('loadFromPref', e);
      debugger(when: testingStopDebugger);
    }
  }

  // for async initialization
  Future<void> _initSettingAsync() async {
    canVibrate = await Vibrate.canVibrate;
  }

  // for emergency initialization
  Future<bool> clearSharedPref() async {
    await gAppStorage.erase();
    return true;
  }

  // save phone number just after completing phone auth
  void saveRecentPhoneNumber(String mobilePhone) {
    gAppStorage.write(PrefKey.recentMobilePhone.name, mobilePhone);
    recentMobilePhone = mobilePhone;
  }

  void saveRecentEnclaveCode(String enclaveCode) {
    if (!currentEnclaveInitialized) return;

    gAppStorage.write(PrefKey.recentEnclaveCode.name, enclaveCode);
    recentEnclaveCode = enclaveCode;
    gCurrentEnclave.enclaveValidated = true;
    gAppStorage.write(PrefKey.enclaveValidated.enclaveKey(enclaveCode), true);
  }

  void saveEnclaveValidated(EnEnclave enclave) {
    enclave.enclaveValidated = true;
    gAppStorage.write(PrefKey.enclaveValidated.enclaveKey(enclave.code), true);
  }

  // reset sharedPref, except downTime
  void resetSharedPref() {
    final enclaveCode = currentEnclaveInitialized ? gCurrentEnclave.code : '';
    if (enclaveCode.isEmpty) {
      gAppStorage.erase();
    } else {
      final obDownTime = gAppStorage.read<int>(PrefKey.obRefreshTime.enclaveKey(enclaveCode)) ?? 0;
      final dataFileDownTime = gAppStorage.read<int>(PrefKey.dataFileRefreshTime.enclaveKey(enclaveCode)) ?? 0;

      gAppStorage.erase();

      gAppStorage.write(PrefKey.obRefreshTime.enclaveKey(enclaveCode), obDownTime);
      gAppStorage.write(PrefKey.dataFileRefreshTime.enclaveKey(enclaveCode), dataFileDownTime);
    }
  }
}
