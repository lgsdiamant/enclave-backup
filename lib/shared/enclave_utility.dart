import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:enclave/data/en_enclave.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/constants.dart';
import '../../shared/enclave_dialog.dart';

/// utility functions, etc

class DayHourMinuteSecond {
  DayHourMinuteSecond({this.day = 0, this.hour = 0, this.minute = 0, this.second = 0});

  int day;
  int hour;
  int minute;
  int second;
}

const int oneDayMillis = 86400000; // 86400000 mills = 1 day
const int oneHourMillis = 3600000; // 3600000 mills = 1 hour
const int oneMinuteMillis = 60000; // 60000 mills = 1 minute
const int oneSecondMillis = 1000; // 1000 mills = 1 second

late EnclaveUtility gEnUtil;

class EnclaveUtility {
  /// for singleton access
  static EnclaveUtility? _instance;

  EnclaveUtility._();

  factory EnclaveUtility() => _instance ??= EnclaveUtility._();

  //region: String
  //===========================================================

  /// from any string, extract phone number. if korean-international, returns only local starting with '0'
  /// for +82.010.1234.5678 -> +821012345678
  String stringToFormalKoreanLocalPhoneNumber(String numberString) {
    bool isInternational = false;
    bool isKorean = false;

    // extract all non digit character except plus
    String numbers = numberString.replaceAll(RegExp(r'[^0-9+]'), '');

    // check if it start with '+' for international phone number
    if (numbers.startsWith('+')) {
      isInternational = true;
      numbers = numbers.replaceAll('+', ''); // no '+' at all
      if (numbers.startsWith('82')) {
        // '82' means korean
        isKorean = true;
        numbers = numbers.substring(2); // remove '82'
        if (numbers.startsWith('0')) {
          numbers = numbers.substring(1); // remove extra '0'
        }
        numbers = '0' + numbers; // now local number starting with 0
      }
    }

    if (isInternational && !isKorean) {
      numbers = '+' + numbers; // if not korean but international, its international number
    }

    return numbers;
  }

  /// from any string, make international phone number. if korean starting with '+82' with no leading '0'
  String stringToFormalInternationalPhoneNumber(String numberString) {
    String numbers = stringToFormalKoreanLocalPhoneNumber(numberString);
    if (!numbers.startsWith('+')) {
      if (numbers.startsWith('0')) {
        numbers = numbers.substring(1); // remove leading '0'
      }
      numbers = Constants.countryCodeKorea + numbers;
    }

    return numbers;
  }

  /// from any string, make Korean style local phone number
  String stringToFormalKoreanLocalPhoneNumberDisplay(String formalPhoneNumber, {bool hidden = false}) {
    // formalPhoneNumber should be formal Korean Local number or formal international number
    String numberString = stringToFormalKoreanLocalPhoneNumber(formalPhoneNumber);

    // for Korean local phone number. otherwise no change
    if (numberString.startsWith('0')) {
      if (numberString.length == 11) {
        // Korean Mobile phone: 01012345678 -> 010-1234-5678
        numberString = numberString.substring(0, 3) + '-' + (hidden ? '****' : numberString.substring(3, 7)) + '-' + numberString.substring(7);
      } else if (numberString.length == 10) {
        // Korean Home Phone: 0321234567 -> 032-123-4567
        numberString = numberString.substring(0, 3) + '-' + (hidden ? '***' : numberString.substring(3, 6)) + '-' + numberString.substring(6);
      } else if (numberString.length == 9 && numberString.startsWith('02')) {
        // Korean Home Phone: 021234567 -> 02-123-5678
        numberString = numberString.substring(0, 2) + '-' + (hidden ? '***' : numberString.substring(2, 5)) + '-' + numberString.substring(5);
      }
    }
    // for US, use the display form as '+16505550001' -> '+1 650 555 0001'
    else if (numberString.startsWith('+1') && numberString.length == 12) {
      numberString = numberString.substring(0, 2) + ' ' + (hidden ? '***' : numberString.substring(2, 5)) + ' ' + numberString.substring(5, 8) + ' ' + numberString.substring(8);
    }

    return numberString;
  }

  /// comparing two phone numbers
  bool isSamePhoneNumber(String number1, String number2) {
    number1 = stringToFormalKoreanLocalPhoneNumber(number1);
    number2 = stringToFormalKoreanLocalPhoneNumber(number2);
    return (number1 == number2);
  }

  bool isValidKoreanMobilePhoneNumber(String numberString) {
    String numbers = stringToFormalKoreanLocalPhoneNumber(numberString);
    if (numbers.startsWith('+')) {
      return true; // do not care any international number
    }
    if (numbers.length != 11 || !numbers.startsWith('0')) {
      return false; // 01012345678
    }
    return true;
  }

  /// generate color from string with given darkness
  Color stringToColor(String text) {
    List<int> cBytes = [0x80, 0x80, 0x80];
    List<int> bytes = utf8.encode(text);
    final minLength = min(3, bytes.length);
    for (var i = 0; i < minLength; i++) {
      cBytes[i] = bytes[i];
    }

    final colorA = Color.fromARGB(255, bytes[0], bytes[1], bytes[2]);

    return colorA;
  }

  /// check if the string is null or empty
  bool isNotEmptyString(dynamic value) {
    return ((value != null) && value.toString().trim().isNotEmpty);
  }

  /// returns if null->'', string otherwise
  String nullToEmptyString(dynamic value) {
    return (value == null) ? '' : value.toString();
  }

  /// returns if null,empty->false, notEmpty->true
  bool nullToFalseBoolean(dynamic value) {
    return (value == null) ? false : value.toString().trim().isNotEmpty;
  }

  /// check if the string can be a valid integer. If not, return -1;
  int makeSureInteger(dynamic value) {
    if (value == null) return -1;
    if (value is int) return value;
    if (value is double) return value.toInt();

    if (value is String) {
      try {
        final intValue = int.parse(value);
        return intValue;
      } on Exception catch (e) {
        return -1;
      }
    }
    return -1;
  }

  /// check if it is meaningful data or not
  bool isDummyDataString(String? valueString) {
    if (valueString == null) return true;

    valueString = valueString.trim();
    return (valueString.isEmpty || (valueString == Constants.keyTextUnknown) || (valueString == Constants.keyTextNotApplicable));
  }

  //===========================================================
  //endregion: String

  //region: HANGUL
  //===========================================================

  /// 종성이 받침인지 아닌지 판단하는 로직
  bool checkBottomConsonant(String input) {
    bool result = false;
    if (isKorean(input)) {
      result = ((input.runes.first - 0xAC00) / (28 * 21)) < 0 ? false : (((input.runes.first - 0xAC00) % 28 != 0) ? true : false);
    }
    return result;
  }

  /// 한글인지 아닌지 확인
  bool isKorean(String input) {
    bool isKorean = false;
    int inputToUniCode = input.codeUnits[0];

    isKorean = (inputToUniCode >= 12593 && inputToUniCode <= 12643)
        ? true
        : (inputToUniCode >= 44032 && inputToUniCode <= 55203)
            ? true
            : false;

    return isKorean;
  }

  //===========================================================
  //endregion: HANGUL

  //region: URL
  //===========================================================
  Future<void> launchURL(String urlAddress) async {
    const httpHeader = 'http://';
    const httpsHeader = 'https://';

    String? urlHttp;
    String? urlHttps;
    String? goodUrl;

    if (urlAddress.startsWith(httpHeader)) {
      urlHttp = urlAddress;
    } else if (urlAddress.startsWith(httpsHeader)) {
      urlHttps = urlAddress;
    } else {
      urlHttp = '$httpHeader$urlAddress';
      urlHttps = '$httpsHeader$urlAddress';
    }

    if (urlHttp != null && await canLaunch(urlHttp)) {
      goodUrl = urlHttp;
    } else if (urlHttps != null && await canLaunch(urlHttps)) {
      goodUrl = urlHttps;
    }

    if (goodUrl != null) {
      if (gCurrentEnclave.isDemo) {
        gEnDialog.simpleAlert(title: 'titleSampleEnclave'.tr, message: 'noticeSampleEnclaveLimitation'.tr);
      } else {
        await launch(
          goodUrl,
          forceSafariVC: true,
          forceWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
        );
      }
    } else {
      gEnDialog.simpleAlert(
        title: 'titleBrowseInternet'.tr,
        message: 'noticeCanNotBrowseInternet'.trParams({'urlAddress': urlAddress}),
      );
    }
  }

  //===========================================================
  //endregion: URL

  //region: TIME
  //===========================================================
  void millisToDayHourMinuteSecond({
    required int millis,
    required DayHourMinuteSecond dayHourMinute,
  }) {
    if(millis<0) millis = 0;

    dayHourMinute.day = (millis / oneDayMillis).floor();
    final _hourMillis = millis - dayHourMinute.day * oneDayMillis;
    dayHourMinute.hour = (_hourMillis / oneHourMillis).floor();
    final _minuteMillis = _hourMillis - dayHourMinute.hour * oneHourMillis;
    dayHourMinute.minute = (_minuteMillis / oneMinuteMillis).floor();
    final _secondMillis = _minuteMillis - dayHourMinute.minute * oneMinuteMillis;
    dayHourMinute.second = (_secondMillis / oneSecondMillis).floor();
  }

  /// express time ago
  String timeAgoToString({
    required int thenTime,
  }) {
    int timeGap = DateTime.now().millisecondsSinceEpoch - thenTime;
    final dayHourMinute = DayHourMinuteSecond();
    millisToDayHourMinuteSecond(millis: timeGap, dayHourMinute: dayHourMinute);

    if (dayHourMinute.day > 30) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(thenTime);
      final inputFormat = DateFormat('dd/MM/yyyy');
      return inputFormat.format(date);
    }
    if (dayHourMinute.day > 1) {
      return '${dayHourMinute.day}' + 'termDay'.tr + 'termAgo'.tr;
    }
    if (dayHourMinute.hour > 1) {
      return '${dayHourMinute.hour}' + 'termHour'.tr + 'termAgo'.tr;
    }
    if (dayHourMinute.minute > 1) {
      return '${dayHourMinute.minute}' + 'termMinute'.tr + 'termAgo'.tr;
    }
    return '${dayHourMinute.second}' + 'termSecond'.tr + 'termAgo'.tr;
  }

  void printDebug(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

//===========================================================
//endregion: TIME
}
