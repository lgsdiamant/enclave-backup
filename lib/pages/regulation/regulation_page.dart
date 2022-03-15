import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../data/repository.dart';
import '../../pages/regulation/regulation_logic.dart';
import '../../pages/regulation/regulation_state.dart';
import '../../shared/enclave_menu.dart';

///
/// Page for Board
///

class RegulationPage extends StatelessWidget {
  final RegulationLogic logic = Get.find<RegulationLogic>();
  final RegulationState state = Get.find<RegulationLogic>().state;

  RegulationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titleRegulationPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: SfPdfViewer.file(gEnRepo.getRegulationPdfFile(), canShowPaginationDialog: true),
      ),
    );
  }
}
