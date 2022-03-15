import 'package:enclave/data/en_member.dart';
import 'package:enclave/shared/enclave_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/constants.dart';
import '../../data/en_enclave.dart';
import '../../enclave_app.dart';
import '../../main_logic.dart';
import '../../router/router.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';
import '../../shared/enclave_utility.dart';
import '../../util/validation.dart';
import '../setting/setting_logic.dart';
import 'login_logic.dart';
import 'login_state.dart';

///
/// Page for Login
///

class LoginPage extends StatelessWidget {
  final LoginLogic logic = Get.find<LoginLogic>();
  final LoginState state = Get.find<LoginLogic>().state;

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titleLoginPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: logic.initCurrentEnclave(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('errorLoginInitialization'.tr + '\n' + snapshot.error.toString()));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (currentEnclaveInitialized) {
                // memberLogic.routeToMemberPage(selectedMember: member);
              }
              return Container(
                color: Theme.of(context).colorScheme.background,
                child: Obx(() => _selectLoginScreen(logic.loginStage)),
              );
            }
            return Center(child: viewWaiting(context, notice: 'noticeInitializingLogin'.tr));
          },
        ),
      ),
    );
  }

  // EnMember Validation
  Widget _selectLoginScreen(LoginStage stage) {
    switch (stage) {
      case LoginStage.needFirebaseSignIn:
        return LoginFirebase();

      case LoginStage.enteringAuthCode:
        return LoginAuthCode();

      case LoginStage.validationJustCompleted:
      case LoginStage.needEnclaveValidation:
      case LoginStage.selectingNewEnclave:
        return const LoginEnclave();
    }
  }
}

class LoginFirebase extends StatelessWidget {
  LoginFirebase({
    Key? key,
  }) : super(key: key);

  final firebaseFormBuilderKey = GlobalKey<FormBuilderState>();
  final TextEditingController _mobilePhoneController = TextEditingController(text: gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(gAppSetting.recentMobilePhone));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.cSmallGap),
      child: FormBuilder(
        key: firebaseFormBuilderKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: Constants.cHugeGap),
            Text(
              'termPhoneAuthLogin'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Constants.cHugeFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Constants.cHugeGap),
            FormBuilderTextField(
              name: 'phoneNumber',
              validator: validatePhoneNumber,
              keyboardType: TextInputType.phone,
              controller: _mobilePhoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(MdiIcons.cellphone),
                border: const OutlineInputBorder(),
                labelText: 'termMobilePhone'.tr,
                hintText: 'hintMobilePhone'.tr,
              ),
            ),
            const SizedBox(height: Constants.cSmallGap),
            Text('noticePhoneNumberFormat'.tr),
            const SizedBox(height: Constants.cSmallGap),
            MaterialButton(
              onPressed: () {
                if (firebaseFormBuilderKey.currentState!.validate()) {
                  loginLogic.signInWithPhoneNumber(phoneNumber: _mobilePhoneController.text.trim());
                }
              },
              shape: const StadiumBorder(),
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  'termLogin'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginEnclave extends StatelessWidget {
  const LoginEnclave({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _avatarEnclave(EnEnclave enclave) {
      String nameAvatar = (enclave.nameFull.length < 2) ? ' ' : enclave.nameFull.substring(0, 2);
      return CircleAvatar(
        child: Text(nameAvatar),
        backgroundColor: gEnUtil.stringToColor(enclave.nameFull),
      );
    }

    //---------------------------------------------------------------------
    Widget _widgetTitle(EnEnclave enclave) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(enclave.nameFull, style: TextStyle(fontSize: Constants.cBigFontSize)),
          ),
          if (enclave.admin != null) const Icon(MdiIcons.accountCheckOutline, color: Colors.blue, size: Constants.cBigIconSize),
        ],
      );
    }

    //---------------------------------------------------------------------
    Widget _widgetSubTitle(EnEnclave enclave) {
      return Text(
        "${enclave.nameSub} (${enclave.membersCount}) - ${(enclave.mySelf == EnMember.dummyMember) ? 'termNotAMember'.tr : enclave.mySelf.personName}",
        style: TextStyle(fontSize: Constants.cMediumFontSize),
      );
    }

    //---------------------------------------------------------------------
    void onTapEnclave(int index) {
      gEnSound.playAudio(AudioKind.tap);

      loginLogic.assignNewCurrentEnclave(loginLogic.myEnclaves[index]);
      distinctLogic.rxSelectedDistinct.value = null;

      memberLogic.routeToMemberPage();
    }

    final enclaveScrollController = ItemScrollController();

    // scroll to current selected member
    // Future.delayed(const Duration(milliseconds: 0), () => {enclaveScrollController.scrollTo(index: 0, alignment: 0.5, duration: const Duration(microseconds: 500))});

    // return enclave selection display
    return Column(
      children: [
        FutureBuilder(
          future: loginLogic.initCurrentEnclave(), // initialize app parameters before actual App
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Center(child: Text('Error\n${snapshot.error.toString()}'));
            }

            // Once complete, show application
            if (snapshot.connectionState == ConnectionState.done) {
              loginLogic.isLoginReady = true;

              final _foundEnclaves = loginLogic.myEnclaves;
              // if no myEnclave, try login again or explore sample enclave
              if (_foundEnclaves.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'noticeNoValidEnclave'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Constants.cBigFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await loginLogic.signOutFirebase();
                      },
                      child: Text('buttonLoginWithDifferentNumber'.tr),
                    ),
                    if (mainLogic.isSystem)
                      ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.pink)),
                        onPressed: () {
                          Get.toNamed(systemRoute);
                        },
                        child: Text('buttonMoveToSystemView'.tr),
                      ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: Constants.cMediumGap),
                    Text(
                      (_foundEnclaves[0].isDemo) ? 'noticeNoValidEnclaveTrySample'.tr : 'termEnclaveSelection'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Constants.cHugeFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Constants.cMediumGap),
                    ScrollablePositionedList.separated(
                      itemCount: _foundEnclaves.length,
                      scrollDirection: Axis.vertical,
                      itemScrollController: enclaveScrollController,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 3),
                      itemBuilder: (builder, index) {
                        final enclave = _foundEnclaves[index];

                        return InkWell(
                          child: Card(
                            elevation: Constants.cMediumGap,
                            child: ListTile(
                              onTap: () => onTapEnclave(index),
                              title: _widgetTitle(enclave),
                              subtitle: _widgetSubTitle(enclave),
                              leading: _avatarEnclave(enclave), // updated
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            // Otherwise, show something whilst waiting for initialization to complete
            return Center(child: viewWaiting(context));
          },
        ),
      ],
    );
  }
}

class LoginAuthCode extends StatelessWidget {
  LoginAuthCode({
    Key? key,
  }) : super(key: key);

  final authFormBuilderKey = GlobalKey<FormBuilderState>();
  final TextEditingController _authCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.cSmallGap),
      child: FormBuilder(
        key: authFormBuilderKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: Constants.cHugeGap),
            FormBuilderTextField(
              name: 'authCode',
              controller: _authCodeController,
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context, errorText: 'noticeAuthCode6'.tr),
              ]),
              decoration: InputDecoration(
                prefixIcon: const Icon(MdiIcons.numeric6CircleOutline),
                border: const OutlineInputBorder(),
                labelText: 'termAuthCode'.tr,
                hintText: 'hintEnterAuthCode'.tr,
              ),
            ),
            const SizedBox(height: Constants.cSmallGap),
            Text('noticeEnterAuthCode'.tr),
            const SizedBox(height: Constants.cSmallGap),
            MaterialButton(
              onPressed: () {
                if (authFormBuilderKey.currentState!.validate()) {
                  loginLogic.proceedPhoneAuthWithAuthCode(_authCodeController.text.trim());
                }
              },
              shape: const StadiumBorder(),
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Text(
                  'termSend'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
