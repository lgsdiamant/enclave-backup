/// Generated by Flutter GetX Starter on 2022-01-23 03:19
import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/data/en_member.dart';
import 'package:enclave/enclave_app.dart';
import 'package:enclave/router/router.dart';
import 'package:enclave/shared/enclave_drawer.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'browse_state.dart';

class BrowseLogic extends GetxController {
  final state = BrowseState();
  late BuildContext contextBrowse;

  final rxMembers = Rx<List<EnMember>>([]);

  List<EnMember> get members => rxMembers.value;
  final rxBrowseTitle = Rx<String>('Browse'.tr);
  final rxSelectedIndex = Rx<int>(0);
  final rxSelectedMember = Rx<EnMember>(EnMember.dummyMember);
  bool membersInitialized = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void assignMembers(List<EnMember> members, {EnMember? selected, String? title}) {
    rxMembers.value = members;
    rxSelectedMember.value = selected ?? memberLogic.selectedMember;
    final index = members.indexOf(rxSelectedMember.value);
    rxSelectedIndex.value = (index == -1) ? 0 : index;

    title ??= 'titleBrowseMembers'.trParams({'count': members.length.toString()});
    rxBrowseTitle.value = title;
    membersInitialized = true;
  }

  Future<bool> initBrowsePageAsync() async {
    if (!membersInitialized) {
      final title = 'titleBrowseAllMember'.trParams({'memberCalling': gCurrentEnclave.memberCalling, 'count': gCurrentEnclave.members.length.toString()});
      assignMembers(gCurrentEnclave.members, title: title);
    }
    return true;
  }

  /// route to browse page with all members
  void routeToBrowseAll() {
    final title = 'titleBrowseAllMember'.trParams({'memberCalling': gCurrentEnclave.memberCalling, 'count': gCurrentEnclave.members.length.toString()});
    assignMembers(gCurrentEnclave.members, title: title);
    Get.toNamed(browseRoute);
  }

  /// route to browse page with subgroup members
  void routeToBrowseSubgroup({required String distinctTerm, required String distinctValue, required List<EnMember> members}) {
    final title = 'titleBrowseFieldAndValue'.trParams({'field': distinctTerm, 'value': distinctValue, 'count': members.length.toString()});
    browseLogic.assignMembers(members, title: title);
    Get.toNamed(browseRoute);
  }
}
