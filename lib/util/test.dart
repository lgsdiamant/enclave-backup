import 'dart:developer';

import '../../shared/enclave_utility.dart';

void runTest() {
  String aStr = "석";
  String bStr = "서";
  String haString = "이";
  String eString = "T";

  bool result = gEnUtil.isKorean(haString);
  result = gEnUtil.isKorean(eString);

  result = gEnUtil.checkBottomConsonant(aStr);
  result = gEnUtil.checkBottomConsonant(bStr);

  debugger(when: true);
}

void runTest2() {
  String number1 = '''010-1234-5678''';
  String number2 = '''+82.010.1234.5678''';
  bool result = gEnUtil.isSamePhoneNumber(number1, number2);

  debugger(when: true);
}

void runTest1() {
  String numberStr = '''---+++- - - - - -     - - - .. . . . . . . . sdkfsdlfs. +010+-8++++959-8147''';
  String result = gEnUtil.stringToFormalKoreanLocalPhoneNumber(numberStr);

  numberStr = '''---+++- - - - - -     - - - .. . . . . . . . sdkfsdlfs. +010+-8++++959-8147''';
  result = gEnUtil.stringToFormalInternationalPhoneNumber(numberStr);

  numberStr = '''031)123-1234-----''';
  result = gEnUtil.stringToFormalInternationalPhoneNumber(numberStr);

  numberStr = '''+1 650 555 0001ml;ksmd;fls''';
  result = gEnUtil.stringToFormalInternationalPhoneNumber(numberStr);

  numberStr = '''+++++1---650.555...0001ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''+++++0---82.1012345678ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''+++++0---82.3112345678ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''+++++0---82.1089598147ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''sdfsdf010-8959.8147ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''032123.1234ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  numberStr = '''0212-3.1234ml;ksmd;fls''';
  result = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(numberStr);

  print(result);

  debugger(when: true);
}
