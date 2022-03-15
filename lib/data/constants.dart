import 'package:flutter/material.dart';

import '../pages/setting/setting_logic.dart';
import 'en_member.dart';

///
/// Defines all constant values
///
class Constants {
  // for System
  static const String systemPhoneNumber = '0-1-0-8-9-5-9-8-1-4-7';
  static const String testerPhoneNumber = '+1-6-5-0-5-5-5-1-2-3-4';
  static const String demoEnclavePrefix = 'demo-';
  static const String devEnclavePrefix = 'dev-';

  // searchBar width in memberPage appBar
  static const double cSearchBarSize = 240.0;

  // font size
  static var defaultProfileSize = 400;

  static double swipeSensitivity = 10;

  static double cTinyTinyAvatarSize = 20.0;
  static double cTinySmallAvatarSize = 30.0;
  static double cTinyAvatarSize = 40.0;
  static double cSmallAvatarSize = 60.0;
  static double cMediumAvatarSize = 80.0;

  static double cTinyTinyFontSizeFIx = 10.0;

  static double get cTinyTinyFontSize => cTinyTinyFontSizeFIx * gAppSetting.rxPrefFontScale.value;

  static double cTinyFontSizeFix = 12.0;

  static double get cTinyFontSize => cTinyFontSizeFix * gAppSetting.rxPrefFontScale.value;

  static double cSmallFontSizeFix = 14.0;

  static double get cSmallFontSize => cSmallFontSizeFix * gAppSetting.rxPrefFontScale.value;

  static double cMediumFontSizeFix = 16.0;

  static double get cMediumFontSize => cMediumFontSizeFix * gAppSetting.rxPrefFontScale.value;

  static double cBigFontSizeFix = 20.0;

  static double get cBigFontSize => cBigFontSizeFix * gAppSetting.rxPrefFontScale.value;

  static double cHugeFontSizeFix = 24.0;

  static double get cHugeFontSize => cHugeFontSizeFix * gAppSetting.rxPrefFontScale.value;

  static double cHugeHugeFontSizeFix = 28.0;

  static double get cHugeHugeFontSize => cHugeHugeFontSizeFix * gAppSetting.rxPrefFontScale.value;

  // image size
  static const double cTinyImageSize = 40.0;
  static const double cSmallImageSize = 60.0;
  static const double cMediumImageSize = 80.0;
  static const double cBigImageSize = 100.0;
  static const double cHugeImageSize = 120.0;
  static const double cHugeHugeImageSize = 140.0;

  // icon size
  static const double cTinyIconSize = 16.0;
  static const double cSmallIconSize = 20.0;
  static const double cMediumIconSize = 24.0;
  static const double cBigIconSize = 28.0;
  static const double cHugeIconSize = 32.0;
  static const double cHugeHugeIconSize = 40.0;

  // padding size
  static const double cTinyTinyGap = 2.0;
  static const double cTinyGap = 6.0;
  static const double cSmallGap = 10.0;
  static const double cMediumGap = 16.0;
  static const double cBigGap = 20.0;
  static const double cHugeGap = 24.0;
  static const double cHugeHugeGap = 28.0;
  static const double cHugeHugeHugeGap = 40.0;
  static const double cHugeHugeHugeHugeGap = 80.0;

  ///
  /// assets folder
  ///
  static const String assetBase = 'assets';
  static const String assetAudio = 'assets/audio';
  static const String assetIcon = 'assets/icon';
  static const String assetImage = 'assets/image';

  static const String imageFileNameEnclaveLogo = 'enclave_logo.png';
  static const String imageFileNameKADIS = 'KADIS_FIT.png';
  static const String imageFileNameKMA = 'KMA_FIT.png';
  static const String imageFileNameKPC = 'KPC_FIT.png';
  static const String imageFileNameProfile = 'profile.png';

  static const String iconNameEnclaveIconColor = 'enclave_icon_color.png';

  ///
  /// Menu
  ///
  static const String firebaseProjectUrl = 'https://enclave-development-8381f.firebaseapp.com';

  // contextMenu Item Id
  static const int exitAppItemId = 1;
  static const int signOutItemId = 2;
  static const int changeThemeItemId = 3;
  static const int soundOnOffItemId = 4;
  static const int updateAppItemId = 5;


  // systemUserMenu Item Id
  static const int systemClearSharedPrefItemId = 1;
  static const int systemRefreshObItemId = 2;
  static const int systemRefreshDataFileItemId = 3;
  static const int systemUploadExcelItemId = 4;

  // bulletinMenu Item Id
  static const int bulletinMoveToNoticeItemId = 1;
  static const int bulletinMoveToMessageItemId = 2;
  static const int bulletinEditMessageItemId = 3;
  static const int bulletinDeleteItemId = 4;

  ///
  /// mandatory constants for Database
  ///
  // common db keys
  static const String keyIndex = 'id';

  static const String keyPersonName = 'personName';
  static const String keyMobilePhone = 'mobilePhone';
  static const String keyCompanyName = 'companyName';
  static const String keyBoardTitle = 'boardTitle';

  static const String keyJobTitle = 'jobTitle';

  static const String keyFieldName = 'fieldName';
  static const String keyEmail = 'email';

  static const String keyTextUnknown = '?';
  static const String keyTextNotApplicable = 'N/A';

  // for DataGrid
  static const String keyField = 'field';
  static const String keyValue = 'value';

  // regulation
  static const String fsKeyPdfUrl = 'pdfUrl';

  // for firebase data
  static const String fsKeyUploadTime = 'uploadTime';
  static const String fsKeyDownTime = 'downloadTime';

  static const String locSystemDirectoryName = 'enclaveSystem'; // directory for system
  static const String locUserDirectoryName = 'enclaveUser'; // directory for user

  //region: assets && storage
  //===========================================================

  static String memberJpgFileName(EnMember member) => '${member.personName}.jpg';

  static String memberPngFileName(EnMember member) => '${member.personName}.png';

  static String memberIdJpgFileName(EnMember member) => '${member.personName}_${member.getIndex.toString()}.jpg';

  static String memberIdPngFileName(EnMember member) => '${member.personName}_${member.getIndex.toString()}.png';

  static const String stRefImage = 'image';
  static const String stRefLiveData = 'liveData'; // place to save live data

  static const String stRefImageMembersFull = 'membersFull';
  static const String stRefImageMembersProfile = 'membersProfile';

  static const String stRefDistinct = 'distinct';

  static const String stRefPdf = 'pdf';
  static const String stDocPdfBoard = 'board';
  static const String stDocPdfRegulation = 'regulation';

//===========================================================
//endregion: assets

  // TextStyle
  static get textStyleSpanned => TextStyle(fontWeight: FontWeight.normal, fontSize: cMediumFontSize, height: 1.2);

  static get textStyleValue => TextStyle(fontWeight: FontWeight.normal, fontSize: cMediumFontSize);

  static get textStyleSpannedSelected => TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: cMediumFontSize,
        decoration: TextDecoration.underline,
      );

  // Divider
  static const dividerThickness = 1.0;
  static const dividerField = Divider(height: cSmallGap, thickness: dividerThickness, indent: 0, endIndent: 0);

  static const cProfileHeight = 100.0; // for person profile image

  // constant Widget
  static Widget get circularPI => const Center(child: SizedBox(child: CircularProgressIndicator(), height: Constants.cHugeHugeGap, width: Constants.cHugeHugeGap));

  // Phone & Grep Pattern
  static const countryCodeKorea = '+82';
  static const phoneNumberPattern = '(\\+[0-9]+[\\.\\s\\-]*)?[0-9]+([\\-\\.\\s]*[0-9]+)+';
  static const localNumberPattern = '[0-9]+([\\-\\.\\s]*[0-9]+)+';

  // Url & Grep Pattern

  static final regExpUrl = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
  static final regExpPhoneNumber = RegExp(r'^(\+{1}[0-9]+[\.\s\-]*){0,1}[0-9]+([\-\.\s]*[0-9]+)+$');
  static final regExpLocalPhoneNumber = RegExp(r'[0-9]+([\-\.\s]*[0-9]+)+');
}
