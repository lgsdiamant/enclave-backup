import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../data/repository.dart';
import '../../shared/enclave_menu.dart';
import 'board_logic.dart';
import 'board_state.dart';

///
/// Page for Board
///

class BoardPage extends StatelessWidget {
  final BoardLogic logic = Get.find<BoardLogic>();
  final BoardState state = Get.find<BoardLogic>().state;

  BoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titleBoardPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: SfPdfViewer.file(gEnRepo.getBoardPdfFile(), canShowPaginationDialog: false),
      ),
    );
  }
}
