import 'dart:developer';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/constants.dart';
import '../../data/en_enclave.dart';
import '../../data/en_field.dart';
import '../../data/en_member.dart';
import '../../data/repository.dart';
import '../../main_logic.dart';
import '../../shared/enclave_dialog.dart';
import 'distinct_state.dart';

///
/// Controller for Criteria
///
class DistinctLogic extends GetxController {
  final state = DistinctState();

  final rxSelectedDistinct = Rx<EnField?>(null);

  EnField? get selectedDistinct => rxSelectedDistinct.value;

  late EnField currentDistinct;
  bool selectedDistinctInitialized = false;

  final rxDistinctPageTitle = Rx<String>('titleDistinctPage'.trParams({'distinctName': ''}));

  late List<String> distinctValues;
  late List<List<EnMember>> distinctMembersList;

  Future<bool> changedSelectedDistinct(EnField? distinct) async {
    // if no distinct field, just return false
    if (distinct == null) return false;

    try {
      if (selectedDistinctInitialized && (currentDistinct == distinct)) {
        return false;
      }
      currentDistinct = distinct;
      selectedDistinctInitialized = true;

      distinctValues = gCurrentEnclave.getDistinctValuesBySingleField(currentDistinct);
      distinctValues.sort((a, b) => (a.compareTo(b)));
      distinctMembersList = gCurrentEnclave.getDistinctMembersList(field: currentDistinct, distinctValues: distinctValues);

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('changedSelectedDistinct', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  String getSelectedDistinctFieldName() {
    return selectedDistinctInitialized ? currentDistinct.fieldName : '';
  }

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

  void assignDistinct(EnField distinct) {
    rxSelectedDistinct.value = distinct;
    try {
      rxDistinctPageTitle.value = 'titleDistinctPageBy'.trParams({'distinctName': distinct.displayTerm});
    } on Exception catch (e) {
      gEnDialog.showExceptionError('onClickDistinctChip', e);
      debugger(when: testingStopDebugger);
    }
  }
}
