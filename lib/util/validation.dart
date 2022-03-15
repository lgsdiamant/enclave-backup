import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/constants.dart';
import '../../shared/enclave_utility.dart';

/// phone number format: should be +082[.- ]
String? validatePhoneNumber(String? value) {
  //   'phoneNumberPattern': '(\\+[0-9]{ 1, 4 }[-.\s]?)?[0-9]{ 1, 4 }[-.\s]?[0-9]{3,4}[-.\s]?[0-9]{4}', // +82.010-1234-5678
  if (value!.isEmpty) {
    return 'noticeEnterPhoneNumber'.tr;
  }

  if (!Constants.regExpPhoneNumber.hasMatch(value)) {
    return 'noticeInvalidPhoneNumber'.tr;
  }

  if (!gEnUtil.isValidKoreanMobilePhoneNumber(value)) {
    return 'noticeInvalidMobilePhoneNumber'.tr;
  }

  return null;
}
