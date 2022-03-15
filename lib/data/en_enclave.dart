import 'dart:developer';

import 'package:enclave/data/en_field.dart';
import 'package:enclave/shared/enclave_dialog.dart';
import 'package:enclave/shared/enclave_utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/app_setting.dart';
import '../../data/repository.dart';
import '../enclave_app.dart';
import '../main_logic.dart';
import '../pages/setting/setting_logic.dart';
import '../shared/common_ui.dart';
import 'constants.dart';
import 'en_admin.dart';
import 'en_board.dart';
import 'en_data.dart';
import 'en_member.dart';
import 'en_poc.dart';
import 'en_term.dart';
import 'en_url.dart';

/// global use of current enclave
EnEnclave get gCurrentEnclave => EnEnclave._rxCurrentEnclave.value;

bool get currentEnclaveInitialized => (gCurrentEnclave != EnEnclave.dummyEnclave);

class EnEnclave {
  static const membersCount_ = 'membersCount';
  static const activated_ = 'activated';
  static const code_ = 'code';
  static const memberCalling_ = 'memberCalling';
  static const nameFull_ = 'nameFull';
  static const nameShort_ = 'nameShort';
  static const nameSub_ = 'nameSub';
  static const uploadTime_ = 'uploadTime';

  static EnEnclave dummyEnclave =
      EnEnclave(uploadTime: 0, activated: false, nameSub: 'dummy', membersCount: 0, nameShort: 'dummy', memberCalling: 'member', code: 'dummy', nameFull: 'dummy');
  static final _rxCurrentEnclave = Rx<EnEnclave>(EnEnclave.dummyEnclave);

  static void assignCurrentEnclave(EnEnclave enclave) => _rxCurrentEnclave.value = enclave;

  static void clearCurrentEnclave() => _rxCurrentEnclave.value = EnEnclave.dummyEnclave;

  int membersCount;
  bool activated;
  String code;
  String memberCalling;
  String nameFull;
  String nameShort;
  String nameSub;
  int uploadTime;

  bool isDataReady = false;

//<editor-fold desc="Data Methods">

  EnEnclave({
    required this.membersCount,
    required this.activated,
    required this.code,
    required this.memberCalling,
    required this.nameFull,
    required this.nameShort,
    required this.nameSub,
    required this.uploadTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnEnclave &&
          runtimeType == other.runtimeType &&
          membersCount == other.membersCount &&
          activated == other.activated &&
          code == other.code &&
          memberCalling == other.memberCalling &&
          nameFull == other.nameFull &&
          nameShort == other.nameShort &&
          nameSub == other.nameSub &&
          uploadTime == other.uploadTime);

  @override
  int get hashCode =>
      membersCount.hashCode ^ activated.hashCode ^ code.hashCode ^ memberCalling.hashCode ^ nameFull.hashCode ^ nameShort.hashCode ^ nameSub.hashCode ^ uploadTime.hashCode;

  @override
  String toString() {
    return 'EnEnclave{' +
        ' $membersCount_: $membersCount,' +
        ' $activated_: $activated,' +
        ' $code_: $code,' +
        ' $memberCalling_: $memberCalling,' +
        ' $nameFull_: $nameFull,' +
        ' $nameShort_: $nameShort,' +
        ' $nameSub_: $nameSub,' +
        ' $uploadTime_: $uploadTime,' +
        '}';
  }

  MapDynamic toMap() {
    return {
      membersCount_: membersCount,
      activated_: activated,
      code_: code,
      memberCalling_: memberCalling,
      nameFull_: nameFull,
      nameShort_: nameShort,
      nameSub_: nameSub,
      uploadTime_: uploadTime,
    };
  }

  factory EnEnclave.fromMap(MapDynamic map, {required List<String> fieldNames, required EnMember self}) {
    final _enclave = EnEnclave(
      membersCount: map[membersCount_] as int,
      activated: map[activated_] as bool,
      code: map[code_] as String,
      memberCalling: map[memberCalling_] as String,
      nameFull: map[nameFull_] as String,
      nameShort: map[nameShort_] as String,
      nameSub: map[nameSub_] as String,
      uploadTime: map[uploadTime_] as int,
    );
    _enclave.fieldNames = fieldNames;
    _enclave.mySelf = self;

    _enclave._readObRefreshTime();
    _enclave._readDataFileRefreshTime();

    return _enclave;
  }

//</editor-fold>

  // extra fields
  bool enclaveValidated = false;
  bool dbSetupInitialized = false;
  bool isDemo = false;

  int databaseRefreshTime = 0;
  int dataFileRefreshTime = 0;

  EnAdmin? admin; // administrator

  bool get isAdmin => (admin != null) || mainLogic.isSystem;

  final logoImage = Rx<ImageProvider?>(null);

  bool get isLocalDataFileReady => (dataFileRefreshTime > 0);

  bool _enclaveOpened = false;

  List<EnMember> members = [];
  List<EnTerm> terms = [];
  List<EnAdmin> admins = [];
  List<EnField> fields = [];
  List<EnBoard> boards = [];
  List<EnPoc> pocs = [];
  List<EnUrl> urls = [];

  EnMember mySelf = EnMember.dummyMember;
  List<String> fieldNames = [];
  List<EnField> browsableFields = [];
  List<EnField> distinctFields = [];

  bool get isLocalDatabaseReady => (databaseRefreshTime > 0);

  int get obRefreshGap => (uploadTime - databaseRefreshTime);

  /// combined term for Full And Sub
  String enclaveNameFullAndSub() {
    if (nameFull.isNotEmpty && nameSub.isNotEmpty) {
      return '$nameFull $nameSub';
    }
    if (nameFull.isNotEmpty) {
      return nameFull;
    }
    if (nameSub.isNotEmpty) {
      return nameSub;
    }
    return '';
  }

  void _readObRefreshTime() {
    databaseRefreshTime = gAppStorage.read<int>(PrefKey.obRefreshTime.enclaveKey(code)) ?? 0;
  }

  void _readDataFileRefreshTime() {
    dataFileRefreshTime = gAppStorage.read<int>(PrefKey.dataFileRefreshTime.enclaveKey(code)) ?? 0;
  }

  void saveDatabaseRefreshTimeValid({int? refreshTime}) {
    refreshTime ??= DateTime.now().millisecondsSinceEpoch;

    if (refreshTime < uploadTime) {
      refreshTime = uploadTime + 1;
    }

    gAppStorage.write(PrefKey.obRefreshTime.enclaveKey(code), refreshTime);
    databaseRefreshTime = refreshTime;
  }

  void saveDataFileRefreshTimeValid({int? refreshTime}) {
    // error handling of time mismatch
    refreshTime ??= DateTime.now().millisecondsSinceEpoch;

    if (refreshTime < uploadTime) {
      refreshTime = uploadTime + 1;
    }
    gAppStorage.write(PrefKey.dataFileRefreshTime.enclaveKey(code), refreshTime);
    dataFileRefreshTime = refreshTime;
  }

  void saveDatabaseRefreshTimeInvalid() {
    gAppStorage.write(PrefKey.obRefreshTime.enclaveKey(code), 0);
    databaseRefreshTime = 0;
  }

  void saveDataFileRefreshTimeInvalid() {
    gAppStorage.write(PrefKey.dataFileRefreshTime.enclaveKey(code), 0);
    dataFileRefreshTime = 0;
  }

  void assignAdmin(EnAdmin admin) {
    this.admin = admin;
  }

  Future<bool> openEnclave({required bool newCreation}) async {
    if (_enclaveOpened) return true;

    gEnRepo.openOb();

    if (newCreation) {
      // transfer all from firebase
      await gEnRepo.transferEnclaveDataFromFirebase();

      // it is most-update now
      saveDatabaseRefreshTimeValid();
    } else {
      // update recently changed members to objectBox
      int count = await gEnRepo.updateRecentFieldChangesFromFs();

      // it is most-update now
      if (count > 0) {
        saveDatabaseRefreshTimeValid();
      }

      // transfer all from updated store
      gEnRepo.transferEnclaveDataFromStore();
    }

    // setup distinct from fields
    distinctFields = [];
    for (var field in fields) {
      if (field.isDistinct) {
        distinctFields.add(field);
      }
    }

    // setup browsable fields
    browsableFields = [];
    for (var field in fields) {
      if (field.thumbViewable && (field.fieldName != EnMember.personName_)) {
        browsableFields.add(field);
      }
    }

    // initialize member's profile
    for (final member in members) {
      await member.getProfileImage();
    }

    // now, we can call it "opened"
    _enclaveOpened = true;

    return true;
  }

  /// close store
  bool closeEnclave({bool deleteFile = false}) {
    try {
      if (!_enclaveOpened) return false;
      isDataReady = false;

      // close enclave objectBox
      gEnRepo.closeOb();

      // clear all enclave data
      fieldNames.clear();

      members.clear();
      fields.clear();
      terms.clear();
      admins.clear();
      boards.clear();
      pocs.clear();
      urls.clear();

      distinctFields.clear();
      browsableFields.clear();

      EnMember.assignFieldNames([]);

      if (deleteFile) {
        gEnRepo.deleteObFile();
      }

      // now, we can call it "closed"
      _enclaveOpened = false;

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('closeStore', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  /// find member field for give fieldName
  EnField? findFieldByName(String fieldName) {
    for (var field in fields) {
      if (field.fieldName == fieldName) {
        return (field);
      }
    }
    return null;
  }

  List<EnData> _getProperEnclaveData<T extends EnData>() {
    switch (T) {
      case EnMember:
        return members;
      case EnField:
        return fields;
      case EnTerm:
        return terms;
      case EnAdmin:
        return admins;
      case EnBoard:
        return boards;
      case EnPoc:
        return pocs;
      case EnUrl:
        return urls;
      default:
        debugger(when: testingStopDebugger);
        throw Exception('invalid enclave data');
    }
  }

  /// update given member
  dynamic getItemByIndex<T extends EnData>(int id) {
    final aData = _getProperEnclaveData<T>();
    final found = aData.firstWhere((e) => (e.getIndex == id));
    return found;
  }

  /// get member by name
  List<EnMember> getMembersByName(String name) {
    final founds = members.where((e) => (e.personName == name)).toList();
    return founds;
  }

  /// get member by name
  List<EnMember> getMembersByNameAndPhone(String name, String phoneNumber) {
    final founds = members.where((e) => (e.personName == name) && (e.mobilePhone == phoneNumber)).toList();
    return founds;
  }

  /// get member by name alike
  List<EnMember> getMembersByRoughName(String name) {
    final founds = members.where((e) => e.personName.contains(name)).toList();
    return founds;
  }

  /// find distinct values for given filedName & ordered by given field with ascending
  List<String> getDistinctValuesBySingleField(EnField field) {
    final fieldName = field.fieldName;

    final index = EnMember.fieldNames.indexOf(fieldName);
    if (index == -1) return [];

    Set<String> values = {};
    String found;

    for (final member in members) {
      if (fieldName == Constants.keyIndex) {
        found = member.id.toString();
      } else if (fieldName == Constants.keyPersonName) {
        found = member.personName;
      } else {
        found = (index < member.fieldValues.length) ? member.fieldValues[index] : '';
      }
      values.add(found);
    }
    final aList = values.toList();
    aList.sort((a, b) => (a.compareTo(b)));
    return aList;
  }

  /// find members matching mobile phone with like pattern
  List<EnMember> findMembersWithRoughPhoneNumber(String allNumbers) {
    final founds = members.where((e) => e.mobilePhone.contains(allNumbers)).toList();
    return founds;
  }

  /// find members matching given field with like pattern
  List<EnMember> getMembersByFieldRoughValue({required EnField field, required String roughValue}) {
    List<EnMember> aMembers = [];
    String found = '';
    for (final member in members) {
      switch (field.fieldName) {
        case Constants.keyIndex:
          found = member.id.toString();
          break;
        case Constants.keyPersonName:
          found = member.personName;
          break;
        case Constants.keyMobilePhone:
          found = gEnUtil.stringToFormalKoreanLocalPhoneNumber(member.mobilePhone);
          break;
        default:
          final index = EnMember.fieldNames.indexOf(field.fieldName);
          if (index == -1) return [];
          found = member.fieldValues[index];
          break;
      }

      if (found.contains(roughValue)) aMembers.add(member);
    }
    aMembers.sort((a, b) => (a.personName.compareTo(b.personName)));
    return aMembers;
  }

  /// get members for given field & value, ordered by [person_name] ascending
  List<EnMember> getMembersByFieldExactValue({required String fieldName, required String exactValue}) {
    final index = EnMember.fieldNames.indexOf(fieldName);
    if (index == -1) throw Exception('invalid field name for member');

    List<EnMember> aMembers = [];
    dynamic found;
    for (final member in members) {
      if (fieldName == Constants.keyIndex) {
        found = member.id;
      } else if (fieldName == Constants.keyPersonName) {
        found = member.personName;
      } else {
        found = (index < member.fieldValues.length) ? member.fieldValues[index] : '';
      }
      if (found == exactValue) aMembers.add(member);
    }
    aMembers.sort((a, b) => (a.personName.compareTo(b.personName)));
    return aMembers;
  }

  EnMember getFirstMember() {
    return members.first;
  }

  /// check if the given field is phone number or not
  bool isFieldPhone(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? false : field.isPhone;
  }

  bool fieldEditable({required bool isAdmin, required String fieldName}) {
    return isAdmin ? fieldAdminEditable(fieldName) : fieldMemberEditable(fieldName);
  }

  bool isFieldUrl(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? false : field.isUrl;
  }

  bool fieldAdminEditable(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? false : field.adminEditable;
  }

  bool fieldMemberEditable(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? false : field.memberEditable;
  }

  bool fieldMemberHidable(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? false : field.memberHidable;
  }

  int fieldMaxLines(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? 1 : field.maxLines;
  }

  /// find display name for given field name
  String fieldDisplayTerm(String fieldName) {
    final field = findFieldByName(fieldName);

    return (field == null) ? fieldName : field.displayTerm;
  }

  /// find distinct
  EnField? findDistinct(String fieldName) {
    for (var field in distinctFields) {
      if (field.fieldName == fieldName) return field;
    }
    return null;
  }

  /// for given term, find proper displayTerm
  String findDisplayTerm(String givenTerm) {
    try {
      bool found = false;
      for (var term in terms) {
        if (term.term == givenTerm) {
          found = true;
          return term.displayTerm;
        }
      }

      if (!found) {
        if (givenTerm == EnEnclave.memberCalling_) {
          givenTerm = 'termMemberCallingDefault'.tr;
        } else if (givenTerm == Constants.keyPersonName) {
          givenTerm = 'termPersonNameDefault'.tr;
        }
      }

      return givenTerm;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('findDisplayTerm', e);
      debugger(when: testingStopDebugger);
      return givenTerm;
    }
  }

  void updateCurrentEnclaveMySelf() {
    // update mySelf from enData, it could be from firebase data
    final self = getMemberById(mySelf.id);
    mySelf = self;
  }

  void presetDistinct() {
    if (distinctFields.isNotEmpty) {
      distinctLogic.rxDistinctPageTitle.value = 'titleDistinctPageBy'.trParams({'distinctName': distinctFields[0].displayTerm});
    }
  }

  EnMember getMemberById(int id) {
    final found = members.where((e) => e.id == id).toList();
    if (found.isNotEmpty) return found[0];

    return EnMember.dummyMember;
  }

  /// generate list of distinct members based on distinct values
  List<List<EnMember>> getDistinctMembersList({required EnField field, required List<String> distinctValues}) {
    final fieldName = field.fieldName;

    // should be valid field name
    final index = EnMember.fieldNames.indexOf(fieldName);
    if (index == -1) return [];

    // make list of empty member list
    final List<List<EnMember>> distinctMembersList = [];
    for (var distinct in distinctValues) {
      distinctMembersList.add(<EnMember>[]);
    }

    String found;
    for (final member in members) {
      if (fieldName == Constants.keyIndex) {
        found = member.id.toString();
      } else if (fieldName == Constants.keyPersonName) {
        found = member.personName;
      } else {
        found = (index < member.fieldValues.length) ? member.fieldValues[index] : '';
      }

      final distinctIndex = distinctValues.indexOf(found);
      if (distinctIndex == -1) continue;

      distinctMembersList[distinctIndex].add(member);
    }

    // sort members by person name
    for (var aMembers in distinctMembersList) {
      aMembers.sort((a, b) => (a.personName.compareTo(b.personName)));
    }

    return distinctMembersList;
  }
}
