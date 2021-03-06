/// Generated by Flutter GetX Starter on 2022-02-05 06:44
import 'package:enclave/data/en_enclave.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/en_member.dart';
import 'admin_page.dart';
import 'admin_state.dart';

class AdminLogic extends GetxController {
  final state = AdminState();
  late BuildContext contextAdmin;

  final _rxMembers = Rx<List<EnMember>>([]);

  List<EnMember> get members => _rxMembers.value;
  bool adminInitialized = false;

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

  Future<void> initAdminPageAsync() async {
    if (adminInitialized) return;

    assignAdminMembers(gCurrentEnclave.members);
    adminInitialized = true;
    return;
  }

  void assignAdminMembers(List<EnMember> adminMembers) {
    // use copy of given members
    _rxMembers.value = List.from(adminMembers);
  }
}
