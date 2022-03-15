import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/constants.dart';
import '../../data/en_field.dart';
import '../../data/en_member.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../shared/enclave_utility.dart';
import 'member_page.dart';
import 'member_state.dart';

///
/// Controller for Member
///

class MemberLogic extends GetxController {
  final state = MemberState();
  late BuildContext contextMember;

  // selected member will be displayed in member page
  // initially it is myself. later on I select member, or browse
  final rxSelectedMember = Rx<EnMember>(EnMember.dummyMember);
  final _rxIsEditable = Rx<bool>(false);

  bool get isEditable => _rxIsEditable.value;

  /// profile image has been changed, but not saved
  final rxProfileChanged = Rx<bool>(false);

  bool get profileChanged => rxProfileChanged.value;

  bool get isProfileChanged => rxProfileChanged.value;

  EnMember get selectedMember => rxSelectedMember.value;

  final rxMemberViewTitle = Rx<String>('Member');

  final rxSearching = Rx<bool>(false);

  final _rxIsMyself = Rx<bool>(false);

  bool get isMySelf => _rxIsMyself.value;

  get dummyProfileImage => const Image(
        image: AssetImage('assets/image/profile.png'),
        height: Constants.cProfileHeight,
        fit: BoxFit.scaleDown,
      );

  @override
  onInit() {
    super.onInit();
  }

  @override
  onReady() {
    super.onReady();
  }

  @override
  onClose() {
    super.onClose();
  }

  void assignSelectedMember(EnMember newMember, {bool isForced = false}) {
    if (!isForced) {
      if (newMember == selectedMember) return;
    }

    gEnRepo.getMemberProfileImage(newMember);

    rxSelectedMember.value = newMember;
    _rxIsMyself.value = gEnUtil.isSamePhoneNumber(selectedMember.mobilePhone, gCurrentEnclave.mySelf.mobilePhone);
    if (!isMySelf && isEditable) _rxIsEditable.value = false;

    // update();
  }

  /// make sure the local data, and be ready
  Future<bool> initMemberPageAsync() async {
    /// be ready for database

    if (gCurrentEnclave.isDataReady) return true;

    // first, be ready for data file
    bool successDataFile = await gEnRepo.beReadyDataFile();

    // be ready for database
    bool successDatabase = await gEnRepo.beReadyDatabase();

    // now we have valid data file, database
    if (successDataFile && successDatabase) {
      // get valid mySelf
      gCurrentEnclave.updateCurrentEnclaveMySelf();

      // get terms
      final memberCalling = gCurrentEnclave.memberCalling;

      // preset memberView title
      if (memberCalling.isNotEmpty) {
        rxMemberViewTitle.value = memberCalling;
      }

      // preset default distinct
      gCurrentEnclave.presetDistinct();
    }

    assignSelectedMember(gCurrentEnclave.mySelf);

    loginLogic.loginCompleted();

    return successDataFile && successDatabase;
  }

  /// find by text give in search bar. text could be part of name or mobile phone
  Future<bool> searchMemberByField(String searchTerm, {EnField? field}) async {
    // if search term is empty, just do not search.
    searchTerm = searchTerm.trim();
    if (searchTerm.isEmpty) {
      return false;
    }

    List<EnMember> foundMembers = [];
    String memberCalling = gCurrentEnclave.memberCalling;

    Future<bool> _searchByPhone() async {
      String exNumbers = searchTerm.replaceAll(RegExp(r'[0-9+\s\-\.]'), ''); // exclude all numbers and etc.
      if (exNumbers.isNotEmpty) {
        Get.defaultDialog(
          title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
          middleText: 'noticeNotAllDigitsForPhoneSearch'.trParams({'searchTerm': searchTerm}),
          textCancel: 'termConfirm'.tr,
        );
        return false;
      }

      String allNumbers = searchTerm.replaceAll(RegExp(r'[^0-9]'), ''); // keep only numbers

      // less than 3 digits is not good for phone search. should at least 3 digits
      if (allNumbers.length < 3) {
        Get.defaultDialog(
          title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
          middleText: 'noticeTooShortDigitsForPhoneSearch'.trParams({'searchTerm': allNumbers}),
          textCancel: 'termConfirm'.tr,
        );
        return false;
      }

      if (allNumbers == '010') {
        Get.defaultDialog(
          title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
          middleText: 'notice010NotGoodForPhoneSearch'.tr,
          textCancel: 'termConfirm'.tr,
        );
        return false;
      }
      // now start searching with phone Numbers
      foundMembers.addAll(gEnRepo.getMembersByFieldRoughValue(field: gCurrentEnclave.findFieldByName(EnMember.mobilePhone_)!, searchTerm: allNumbers));
      return true;
    }

    Future<bool> _searchByPersonName() async {
      foundMembers.addAll(gEnRepo.getMembersByFieldRoughValue(field: gCurrentEnclave.findFieldByName(EnMember.personName_)!, searchTerm: searchTerm));
      return true;
    }

    Future<bool> _searchByOtherField({required EnField field}) async {
      if (field.displayTerm.length < 2) {
        Get.defaultDialog(
          title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
          middleText: 'noticeTooShortDigitsForPhoneSearch'.trParams({'searchTerm': searchTerm}),
          textCancel: 'termConfirm'.tr,
        );
        return false;
      }
      foundMembers.addAll(gEnRepo.getMembersByFieldRoughValue(field: field, searchTerm: searchTerm));
      return true;
    }

    if (field == null) {
      // if term is only digits and white space, dash, dot, then search for mobile phone
      String exNumbers = searchTerm.replaceAll(RegExp(r'[0-9+\s\-\.]'), ''); // exclude all numbers and etc.
      if (exNumbers.isEmpty) {
        bool success = await _searchByPhone();
        field = gCurrentEnclave.findFieldByName(EnMember.mobilePhone_);
        if (!success) return false;
      } else {
        bool success = await _searchByPersonName();
        field = gCurrentEnclave.findFieldByName(EnMember.personName_);
        if (!success) return false;
      }
    } else if (field.fieldName == EnMember.mobilePhone_) {
      bool success = await _searchByPhone();
      if (!success) return false;
    } else if (field.fieldName == EnMember.personName_) {
      bool success = await _searchByPersonName();
      if (!success) return false;
    } else {
      bool success = await _searchByOtherField(field: field);
      if (!success) return false;
    }

    if (foundMembers.isEmpty) {
      // no one found
      Get.defaultDialog(
        title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
        middleText: 'noticeNoMemberMatching'.trParams({'memberCalling': memberCalling, 'searchTerm': searchTerm}),
        textConfirm: 'termConfirm'.tr,
        onConfirm: () => Get.back(),
      );
      return false;
    } else if (foundMembers.length == 1) {
      // only one found
      memberLogic.assignSelectedMember(foundMembers[0]);
    } else {
      // multiple found
      Get.defaultDialog(
        radius: Constants.cMediumGap,
        title: 'termMemberSearch'.trParams({'memberCalling': memberCalling}),
        content: displayFoundMembers(field: field!, searchTerm: searchTerm, members: foundMembers),
        middleText: 'noticeNoMemberMatching'.trParams({'memberCalling': memberCalling, 'searchTerm': searchTerm}),
        textConfirm: 'termClose'.tr,
        onConfirm: () => Get.back(),
      );
    }

    return true;
  }

  /// finish edit mode. return true for continue, return false for stop
  bool finishEditable() {
    if (!isEditable) return true;

    toggleEditable();
    return false;
  }

  /// toggle edit mode
  Future<bool> toggleEditable() async {
    if (isEditable && profileChanged) {
      bool success = await gEnRepo.updateProfileChanged(selectedMember);
      rxProfileChanged.value = false;
    }

    _rxIsEditable.value = !isEditable;
    return isEditable;
  }

  Future<void> changeProfileImageFromPicker() async {
    final rxImage = Rx<ImageProvider?>(null);
    bool success = await gEnRepo.getProfileFromPicker(rxImage);
    if (success) {
      var fileImage = rxImage.value;
      if (fileImage != null) {
        selectedMember.setProfileImage(fileImage);
      }
      rxProfileChanged.value = true;
    }
  }

  /// back to member page
  void routeToMemberPage({EnMember? selectedMember}) {
    if (selectedMember != null) {
      assignSelectedMember(selectedMember);
    }
    Get.offAllNamed(memberRoute);
  }
}
