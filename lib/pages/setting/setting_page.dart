import 'package:enclave/pages/setting/setting_state.dart';
import 'package:enclave/shared/enclave_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../data/app_setting.dart';
import '../../data/constants.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../pages/setting/setting_logic.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';

class SettingPage extends StatelessWidget {
  final SettingLogic logic = Get.find<SettingLogic>();
  final SettingState state = Get.find<SettingLogic>().state;

  SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    return Scaffold(
      appBar: AppBar(
        title: Text('titleSettingPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: settingLogic.initSettingPageAsync(), // initialize app parameters
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Center(child: Text('errorSettingInitialization'.tr + '\n' + snapshot.error.toString()));
            }

            // Once complete
            if (snapshot.connectionState == ConnectionState.done) {
              return const SettingView();
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return Center(child: viewWaitingSplash(context));
          },
        ),
      ),
    );
  }
}

class SettingView extends StatefulWidget {
  const SettingView({Key? key}) : super(key: key);

  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingsGroup(
            title: 'termEnclaveSetting'.tr,
            children: <Widget>[
              SwitchSettingsTile(
                settingKey: PrefKey.darkTheme.name,
                defaultValue: false,
                title: 'termDarkMode'.tr,
                enabledLabel: 'noticeUseDarkTheme'.tr,
                disabledLabel: 'noticeUseLightTheme'.tr,
                leading: Icon(MdiIcons.brightness6, color: Theme.of(context).colorScheme.primary),
                onChange: (value) {
                  gAppSetting.rxPrefDarkTheme.value = value;
                  gEnTheme.switchTheme(toggle: false);
                },
              ),
              SwitchSettingsTile(
                settingKey: PrefKey.soundOn.name,
                defaultValue: true,
                title: 'termPlaySound'.tr,
                enabledLabel: 'noticeSoundOn'.tr,
                disabledLabel: 'noticeSoundOff'.tr,
                leading: Icon(MdiIcons.volumeHigh, color: Theme.of(context).colorScheme.primary),
                onChange: (value) {
                  gAppSetting.rxPrefSoundOn.value = value;
                },
              ),
              SwitchSettingsTile(
                settingKey: PrefKey.showTutorial.name,
                defaultValue: true,
                title: 'termShowHelp'.tr,
                enabledLabel: 'noticeUseTutorial'.tr,
                disabledLabel: 'noticeNotUseTutorial'.tr,
                leading: Icon(MdiIcons.tooltipCheckOutline, color: Theme.of(context).colorScheme.primary),
                onChange: (value) {
                  gAppSetting.rxPrefShowTutorial.value = value;
                },
              ),
              SwitchSettingsTile(
                settingKey: PrefKey.hideEmptyData.name,
                defaultValue: true,
                title: 'termHideEmptyItem'.tr,
                enabledLabel: 'noticeHideEmptyData'.tr,
                disabledLabel: 'noticeShowEmptyData'.tr,
                leading: Icon(MdiIcons.checkboxBlankOffOutline, color: Theme.of(context).colorScheme.primary),
                onChange: (value) {
                  gAppSetting.rxPrefHideEmptyData.value = value;
                },
              ),
              SliderSettingsTile(
                settingKey: PrefKey.fontScale.name,
                defaultValue: 1.0,
                title: 'termFontSize'.tr,
                min: 0.49,
                max: 2.01,
                step: 0.1,
                decimalPrecision: 1,
                leading: Icon(MdiIcons.formatSize, color: Theme.of(context).colorScheme.primary),
                onChange: (value) {
                  gAppSetting.rxPrefFontScale.value = value;
                },
              ),
            ],
          ),
          const Divider(height: Constants.cMediumGap, thickness: Constants.cTinyTinyGap),
          SettingsGroup(
            title: 'termUpdateData'.tr,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await gEnRepo.forceRefreshDatabaseFromFirebase();
                    },
                    child: Text('menuRefreshDatabase'.tr),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await gEnRepo.forceRefreshDataFileFromStorage();
                    },
                    child: Text('menuRefreshDataFile'.tr),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
