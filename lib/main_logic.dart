import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:enclave/pages/setting/setting_logic.dart';
import 'package:enclave/shared/enclave_sound.dart';
import 'package:enclave/shared/enclave_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/constants.dart';
import '../../data/firebase.dart';
import '../../data/repository.dart';
import '../../shared/enclave_dialog.dart';
import '../../shared/enclave_menu.dart';
import '../../shared/enclave_utility.dart';
import 'enclave_app.dart';

/// for development purpose
const bool testingStopDebugger = false; // make false for release
const bool testingInvalidSystem = false; // make false for release

///
/// App level controller
///
class MainLogic extends GetxController {
  late BuildContext contextMain;

  final uuidGen = const Uuid();

  bool isSystem = false;
  bool isTester = false;
  late PackageInfo enclavePackageInfo;
  late DeviceInfoPlugin deviceInfoPlugin;

  // for firebase notification
  final Rxn<RemoteMessage> message = Rxn<RemoteMessage>();

  String get enclaveVersionString => '${enclavePackageInfo.version}+${enclavePackageInfo.buildNumber}';

  String get enclaveVersionFullString => '${enclavePackageInfo.appName} $enclaveVersionString';

  /// async initialization for mainController: before login screen
  Future<bool> initMainAppAsync() async {
    // for firebase notification
    // Android 에서는 별도의 확인 없이 리턴되지만, requestPermission()을 호출하지 않으면 수신되지 않는다.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      message.value = rm;
    });

    // package info
    enclavePackageInfo = await PackageInfo.fromPlatform();

    // device info
    deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;

    // Sound
    gEnSound = EnclaveSound(); // singleton

    // Menu
    gEnMenu = EnclaveMenu(); // singleton

    // Dialog
    gEnDialog = EnclaveDialog(); // singleton

    // Utility
    gEnUtil = EnclaveUtility(); // singleton

    // Theme
    gEnTheme = EnclaveTheme(); // singleton

    // Repository
    gEnRepo = EnclaveRepository(); // singleton

    // appStorage
    gAppStorage = GetStorage(); // singleton

    // appSetting
    gAppSetting = AppSetting(); // singleton

    // check validity of appSetting. if recentMobilePhone is empty, signOut
    if (gAppSetting.recentMobilePhone.isEmpty) {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    }

    // gRxFsUser is always updated automatically
    gFbAuth.authStateChanges().listen((User? user) async {
      gRxFsUser.value = user;
      if (user == null) {
        loginLogic.myEnclaves.clear();
        mainLogic.isSystem = false;
        mainLogic.isTester = false;
      } else {
        final rokPhoneNumber = gEnUtil.stringToFormalKoreanLocalPhoneNumber(user.phoneNumber ?? '');
        gAppSetting.saveRecentPhoneNumber(rokPhoneNumber);
        mainLogic.isSystem = !testingInvalidSystem && gEnUtil.isSamePhoneNumber(rokPhoneNumber, Constants.systemPhoneNumber);
        mainLogic.isTester = gEnUtil.isSamePhoneNumber(rokPhoneNumber, Constants.testerPhoneNumber);
      }
    });

    // determine loginStage;
    loginLogic.determineLoginStage();

    // initialize currentEnclave
    bool success = await loginLogic.initCurrentEnclave();

    return true;
  }

  Future<bool> initPostApp(BuildContext context) async {
    try {
      // initialize locale
      _initLocalization();

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('initPostApp', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  @override
  onInit() {
    super.onInit();
  }

  @override
  onReady() {
    // player = AudioPlayer();
    super.onReady();
  }

  @override
  onClose() {
    super.onClose();
  }

  /// initialize locale
  void _initLocalization() {
    memberLogic.rxMemberViewTitle.value = 'termMember'.tr;
  }

  /// finish app
  Future<void> finishApp({bool toAsk = false}) async {
    Future<void> _reallyFinishApp() async {
      await Future.delayed(const Duration(milliseconds: 1000), () {
        if (Platform.isAndroid) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // for android
        } else if (Platform.isIOS) {
          exit(0);
        }
      });
    }

    if (toAsk) {
      Get.defaultDialog(
        title: 'titleToExitApp'.tr,
        middleText: 'alertToExitApp'.trParams({'appName': mainLogic.enclavePackageInfo.appName}),
        barrierDismissible: true,
        textConfirm: 'termConfirm'.tr,
        textCancel: 'termCancel'.tr,
        onConfirm: () => {Get.back(), _reallyFinishApp()},
      );
    } else {
      _reallyFinishApp();
    }
  }

  Future<void> checkEnclaveApp() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const playStoreUrl = 'http://play.google.com/store/apps/details?id=com.lgsdiamant.enclave';
      gEnUtil.launchURL(playStoreUrl);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      const appStoreUrl = 'https://apps.apple.com/kr/app/apple-store/id1597855531';
      gEnUtil.launchURL(appStoreUrl);
    }
  }
}

/// shows login Stage
enum LoginStage {
  needFirebaseSignIn,
  enteringAuthCode,
  needEnclaveValidation,
  validationJustCompleted,
  selectingNewEnclave,
}
