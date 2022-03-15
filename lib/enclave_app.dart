import 'package:enclave/pages/browse/browse_logic.dart';
import 'package:enclave/pages/bulletin/bulletin_logic.dart';
import 'package:enclave/pages/url/url_logic.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../pages/about/about_logic.dart';
import '../../pages/admin/admin_logic.dart';
import '../../pages/board/board_logic.dart';
import '../../pages/contact/contact_logic.dart';
import '../../pages/distinct/distinct_logic.dart';
import '../../pages/login/login_logic.dart';
import '../../pages/member/member_logic.dart';
import '../../pages/regulation/regulation_logic.dart';
import '../../pages/setting/setting_logic.dart';
import '../../pages/splash/splash_logic.dart';
import '../../pages/system/system_logic.dart';
import '../../router/router.dart';
import '../../shared/common_ui.dart';
import 'locale/app_translation.dart';
import 'main_logic.dart';
import 'shared/enclave_theme.dart';

class EnclaveApp extends StatefulWidget {
  const EnclaveApp({Key? key}) : super(key: key);

  @override
  _EnclaveAppState createState() => _EnclaveAppState();
}

class _EnclaveAppState extends State<EnclaveApp> {
  /// The future is part of the state of our widget.
  /// We should not call `initializeApp` directly inside [build].
  @override
  Widget build(BuildContext context) {
    // put all viewModels
    _putGlobalLogics();

    return FutureBuilder(
      future: mainLogic.initMainAppAsync(), // initialize app parameters before actual App
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text('Error\n${snapshot.error.toString()}'));
        }

        // Once complete, show application
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                currentFocus.unfocus();
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
            child: Obx(() {
              return GetMaterialApp(
                navigatorKey: Get.key,

                // locale with given system locale
                locale: Get.deviceLocale,
                fallbackLocale: AppTranslations.fallbackLocale,
                translations: AppTranslations(),

                debugShowCheckedModeBanner: false,

                title: 'Enclave',

                // default theme
                theme: gEnTheme.rxThemeLight.value,
                darkTheme: gEnTheme.rxThemeDark.value,
                themeMode: gEnTheme.theme,

                // initial route
                initialRoute: (false) ? testRoute : splashRoute,

                // pages
                getPages: appPages(),

                supportedLocales: const [
                  Locale('en', 'US'),
                ],

                localizationsDelegates: const [
                  FormBuilderLocalizations.delegate,
                ],
              );
            }),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: viewWaitingSplash(context));
      },
    );
  }

  //---------------------------------
  /// putting all global-scope GetXControllers
  void _putGlobalLogics() {
    mainLogic = Get.put(MainLogic(), permanent: true);
    mainLogic.contextMain = context; // for general use

    splashLogic = Get.put(SplashLogic(), permanent: true);
    loginLogic = Get.put(LoginLogic(), permanent: true);
    memberLogic = Get.put(MemberLogic(), permanent: true);
    browseLogic = Get.put(BrowseLogic(), permanent: true);

    contactLogic = Get.put(ContactLogic(), permanent: true);
    distinctLogic = Get.put(DistinctLogic(), permanent: true);
    boardLogic = Get.put(BoardLogic(), permanent: true);
    regulationLogic = Get.put(RegulationLogic(), permanent: true);

    settingLogic = Get.put(SettingLogic(), permanent: true);
    aboutLogic = Get.put(AboutLogic(), permanent: true);
    urlLogic = Get.put(UrlLogic(), permanent: true);
    bulletinLogic = Get.put(BulletinLogic(), permanent: true);

    adminLogic = Get.put(AdminLogic(), permanent: true);
    systemLogic = Get.put(SystemLogic(), permanent: true);
  }
}

/// Global Logics
late MainLogic mainLogic;

late SplashLogic splashLogic;
late LoginLogic loginLogic;
late MemberLogic memberLogic;
late BrowseLogic browseLogic;

late ContactLogic contactLogic;
late DistinctLogic distinctLogic;
late BoardLogic boardLogic;
late RegulationLogic regulationLogic;

late SettingLogic settingLogic;
late AboutLogic aboutLogic;
late UrlLogic urlLogic;
late BulletinLogic bulletinLogic;

late AdminLogic adminLogic;
late SystemLogic systemLogic;
