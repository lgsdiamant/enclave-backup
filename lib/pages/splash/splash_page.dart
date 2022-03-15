import 'package:enclave/pages/splash/splash_logic.dart';
import 'package:enclave/pages/splash/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/constants.dart';
import '../../data/en_enclave.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../router/router.dart';
import '../../shared/common_ui.dart';
import '../setting/setting_logic.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashLogic logic = Get.find<SplashLogic>();
  final SplashState state = Get.find<SplashLogic>().state;

  @override
  Widget build(BuildContext context) {
    // now starting splash stuff
    final fullHeight = MediaQuery.of(context).size.height;

    final iconHeight = fullHeight * 0.3;
    final logoHeight = fullHeight * 0.08;

    //-------------------------------------------------------------------------
    void moveNextPage() {
      bool showTutorial = false;
      if (gAppSetting.rxPrefShowTutorial.value) {
        if (gAppSetting.loginCount < 3) {
          // if login less than 3, shows tutorial
          showTutorial = true;
        } else if ((gAppSetting.loginCount % 50) == 0) {
          // shows tutorial once after 50 times login
          showTutorial = true;
        }
      }

      if (showTutorial) {
        aboutLogic.isFromMain = true;
        Get.offAllNamed(aboutRoute);
      } else {
        Get.offAllNamed(currentEnclaveInitialized ? memberRoute : loginRoute);
      }
    }

    //--------------------------------------------------------------------------
    // Future<bool> checkAppUpdate(Callback moveNextPage) async {
    //   try {
    //     final newVersion = NewVersion();
    //     final status = await newVersion.getVersionStatus();
    //     if (status != null) {
    //       debugPrint(status.releaseNotes);
    //       debugPrint(status.appStoreLink);
    //       debugPrint(status.localVersion);
    //       debugPrint(status.storeVersion);
    //       debugPrint(status.canUpdate.toString());
    //
    //       if (status.canUpdate) {
    //         newVersion.showUpdateDialog(
    //             context: context,
    //             versionStatus: status,
    //             dialogTitle: 'titleUpdateApp'.tr,
    //             dialogText: 'contentUpdateApp'.trParams({'localVersion': status.localVersion, 'storeVersion': status.storeVersion}),
    //             updateButtonText: 'termUpdate'.tr,
    //             dismissButtonText: 'termUpdateLater'.tr,
    //             dismissAction: () => moveNextPage());
    //       } else {
    //         moveNextPage();
    //       }
    //     }
    //     return true;
    //   } on Exception catch (e) {
    //     moveNextPage();
    //     return false;
    //   }
    // }

    return WillPopScope(
      onWillPop: () {
        final canPop = Navigator.canPop(context);
        if (!canPop) {
          mainLogic.finishApp(toAsk: true);
        }
        return Future.value(canPop);
      },
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: mainLogic.initPostApp(context), // initialize app parameters
            builder: (context, snapshot) {
              // Check for errors
              if (snapshot.hasError) {
                return Center(child: Text('Error\n${snapshot.error.toString()}'));
              }

              // Once complete
              if (snapshot.connectionState == ConnectionState.done) {
                Future.delayed(const Duration(seconds: 0), () => moveNextPage());

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('noticeClickToStart'.tr, style: TextStyle(fontSize: Constants.cBigFontSize)),
                          Image(
                            image: EnclaveRepository.getAssetEnclaveLogo,
                            height: iconHeight,
                          ),

                          // logo for k-damp
                          if ((currentEnclaveInitialized && gCurrentEnclave.code == 'k-damp') || (currentEnclaveInitialized && gCurrentEnclave.code == 'test-damp'))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image(
                                  image: EnclaveRepository.getAssetImageKPC,
                                  height: logoHeight,
                                ),
                                Image(
                                  image: EnclaveRepository.getAssetImageKADIS,
                                  height: logoHeight,
                                ),
                              ],
                            ),

                          // logo for k-damp
                          if (currentEnclaveInitialized && gCurrentEnclave.code == 'kma-39')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image(
                                  image: EnclaveRepository.getAssetImageKMA,
                                  height: logoHeight,
                                ),
                              ],
                            ),
                        ],
                      ),
                    )
                  ],
                );
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return Center(child: viewWaitingSplash(context));
            },
          ),
        ),
      ),
    );
  }
}
