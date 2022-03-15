import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../data/constants.dart';
import '../../data/en_enclave.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../router/router.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';
import 'about_logic.dart';
import 'about_state.dart';

class AboutPage extends StatelessWidget {
  final AboutLogic logic = Get.find<AboutLogic>();
  final AboutState state = Get.find<AboutLogic>().state;

  AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titleAboutPage'.tr, textAlign: TextAlign.center),
        actions: gEnMenu.actionsDefault(),
      ),
      body: FutureBuilder(
        future: aboutLogic.initAboutAsync(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('errorImageInitialization'.tr + '\n' + snapshot.error.toString()),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(children: [
              Expanded(
                child: SfPdfViewer.asset(
                  gEnRepo.getAboutAppPdfPath(),
                  canShowPaginationDialog: true,
                  scrollDirection: PdfScrollDirection.vertical,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                ),
              ),
              const SizedBox(height: Constants.cTinyGap),
              Text('noticeSwipeForHelp'.tr),
              const SizedBox(height: Constants.cTinyGap),
              if (aboutLogic.isFromMain)
                Container(
                  padding: const EdgeInsets.only(left: Constants.cSmallGap, right: Constants.cSmallGap),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: Text('noticeSeeAboutAppMenu'.tr)),
                      ElevatedButton(
                        onPressed: () async {
                          aboutLogic.isFromMain = false;
                          Get.offAllNamed(currentEnclaveInitialized ? memberRoute : loginRoute);
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        child: Text(
                          'termClose'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
            ]);
          }
          return Center(child: viewWaiting(context));
        },
      ),
    );
  }
}
