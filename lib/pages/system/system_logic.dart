import 'dart:async';

import 'package:enclave/data/en_enclave.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../data/repository.dart';
import '../../pages/system/system_state.dart';
import '../setting/setting_logic.dart';

///
/// Controller for Admin
///

class SystemLogic extends GetxController {
  final state = SystemState();
  late BuildContext contextSystem;

  late EnclaveRepository repositorySystem;

  bool isFirstVisit = true;

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

  void assignSystemEnclaveCode(String enclaveCode) {
    repositorySystem.assignSystemEnclaveCode(enclaveCode);
  }

  Future<bool> uploadFirestoreFromExcelStorage() async {
    bool success = await repositorySystem.uploadFirestoreFromExcelStorage();
    return true;
  }

  Future<bool> refreshEnclaveObUser() async {
    return await gEnRepo.forceRefreshDatabaseFromFirebase();
  }

  Future<bool> refreshEnclaveDataFileUser() async {
    return await gEnRepo.forceRefreshDataFileFromStorage();
  }

  Future<bool> clearSharedPref() async {
    return await gAppSetting.clearSharedPref();
  }

  void invalidateDatabase() {
    gCurrentEnclave.saveDatabaseRefreshTimeInvalid();
  }

  void invalidateDataFile() async {
    gCurrentEnclave.saveDataFileRefreshTimeInvalid();
  }

  void initSystemRepository() {
    repositorySystem = EnclaveRepository.system(); // singleton
  }

  Future<bool> excelFileExistInStorage() async {
    return await repositorySystem.excelFileExistInStorage();
  }

  Future<bool> initSystemPageAsync() async {
    return true;
  }
}
