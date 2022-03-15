import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/shared/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/constants.dart';
import '../../shared/enclave_utility.dart';
import '../data/en_field.dart';
import '../data/en_member.dart';
import '../enclave_app.dart';

late EnclaveDialog gEnDialog;

class EnclaveDialog {
  /// for singleton access
  static EnclaveDialog? _instance;

  EnclaveDialog._();

  factory EnclaveDialog() => _instance ??= EnclaveDialog._();

  /// sending sms
  Future<dynamic> sendSms(List<String> toWhomNumbers, String personName) {
    final TextEditingController _smsMessageController = TextEditingController(text: '');
    _smsMessageController.text = '';
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String? _validateSmsMessage(String? value) {
      if (value!.isEmpty) {
        return 'noticeNoSmsMessage'.tr;
      } else {
        return null;
      }
    }

    return Get.defaultDialog(
        title: 'titleSendSms'.tr,
        textCancel: 'termNo'.tr,
        textConfirm: 'termYes'.tr,
        onConfirm: () async {
          if (_formKey.currentState!.validate()) {
            final message = _smsMessageController.text.trim();
            if (message.isNotEmpty) {
              Get.back(result: false);
              if (gCurrentEnclave.isDemo) {
                gEnDialog.simpleAlert(title: 'titleSampleEnclave'.tr, message: 'noticeSampleEnclaveLimitation'.tr);
              } else {
                String _result = await sendSMS(message: message, recipients: toWhomNumbers).catchError((onError) {
                  gEnDialog.simpleAlert(title: 'titleSendSms'.tr, message: 'noticeSmsFailed'.tr);
                });
              }
            }
          }
        },
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: _validateSmsMessage,
                controller: _smsMessageController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'hintSendSms'.trParams({'personName': personName, 'memberCalling': gCurrentEnclave.memberCalling}),
                  hintMaxLines: 1,
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
        radius: 10.0);
  }

  /// calling phone
  Future<dynamic> callPhone(String phoneNumber, String personName) async {
    _callPhone() async {
      Get.back();
      if (gCurrentEnclave.isDemo) {
        gEnDialog.simpleAlert(title: 'titleSampleEnclave'.tr, message: 'noticeSampleEnclaveLimitation'.tr);
      } else {
        bool? result = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      }
    }

    String memberCalling = gCurrentEnclave.memberCalling;
    return Get.defaultDialog(
      title: 'titlePhoneCall'.tr,
      middleText: '\n' + 'contentPhoneCallTo'.trParams({'personName': personName, 'memberCalling': memberCalling}) + '\n',
      textCancel: 'termNo'.tr,
      textConfirm: 'termYes'.tr,
      onConfirm: _callPhone,
    );
  }

  /// search Field
  void findMembersByFieldDialog({required EnField field}) {
    final TextEditingController _searchTermController = TextEditingController(text: '');

    List<EnMember>? foundMembers;

    _searchTermController.text = '';

    Get.defaultDialog(
        title: 'titleSearchField'.trParams({'fieldDisplayTerm': field.displayTerm}),
        textCancel: 'termCancel'.tr,
        textConfirm: 'termSearch'.tr,
        onConfirm: () async {
          final searchTerm = _searchTermController.text.trim();
          if (searchTerm.isNotEmpty) {
            Get.back();
            await memberLogic.searchMemberByField(searchTerm, field: field);
          }
        },
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchTermController,
              keyboardType: TextInputType.text,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'hintSearchField'.tr,
                hintMaxLines: 1,
              ),
            ),
            const SizedBox(
              height: Constants.cMediumGap,
            ),
          ],
        ),
        radius: 10.0);
  }

  /// simple alert dialog
  void simpleAlert({required String title, required String message}) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      barrierDismissible: true,
      textCancel: 'termConfirm'.tr,
    );
  }

  //region: PROGRESS
//===========================================================

  bool onProgressStarted = false;

  void showLinearProgressDialog({required String title, required String middleText}) {
    // if already showing, just return
    if (onProgressStarted) return;

    onProgressStarted = true;

    Get.defaultDialog(
      title: title,
      content: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(middleText),
            const SizedBox(height: Constants.cSmallGap),
            LinearProgressIndicator(color: Theme.of(mainLogic.contextMain).colorScheme.primary),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLinearProgressDialog() {
    if (!onProgressStarted) return;

    onProgressStarted = false;
    Get.back();
  }

  void askDatabaseRefresh({required int refreshGap, required VoidCallback onConfirm}) {
    if (refreshGap <= 0) return;

    var gapDHM = DayHourMinuteSecond();
    gEnUtil.millisToDayHourMinuteSecond(millis: refreshGap, dayHourMinute: gapDHM);
    String timeStr;
    if (gapDHM.day > 0) {
      timeStr = "${gapDHM.day} ${'termDay'.tr}";
    } else if (gapDHM.hour > 0) {
      timeStr = "${gapDHM.hour} ${'termHour'.tr}";
    } else if (gapDHM.minute > 0) {
      timeStr = "${gapDHM.minute} ${'termMinute'.tr}";
    } else {
      timeStr = "${gapDHM.second} ${'termSecond'.tr}";
    }

    Get.defaultDialog(
      title: 'titleRefreshDatabase'.tr,
      middleText: 'noticeRefreshingDatabaseWithGap'.trParams({'refreshGap': timeStr}),
      textCancel: 'termNo'.tr,
      textConfirm: 'termYes'.tr,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
    );
  }

  void showExceptionError(String processName, Exception e) {
    simpleAlert(title: 'Exception in $processName', message: e.toString());
  }
//===========================================================
//endregion: PROGRESS
}
