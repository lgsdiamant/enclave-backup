///
/// keys for sharedPref
///
enum PrefKey {
  soundOn, // bool
  darkTheme,
  fontScale,
  showTutorial,
  hideEmptyData,

  // enclaveMember specific
  recentEnclaveCode, // String
  recentMobilePhone, // String
  enclaveValidated, // bool

  loginCount, // int
  lastLoginTime, // int

  // repository specific
  obRefreshTime, // int
  dataFileRefreshTime, // int
}

extension PrefExtension on PrefKey {
  String enclaveKey(String enclaveCode) {
    return '${name}_$enclaveCode';
  }
}
