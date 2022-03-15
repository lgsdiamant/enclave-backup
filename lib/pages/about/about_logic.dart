import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'about_state.dart';

///
/// Controller for About
///
class AboutLogic extends GetxController {
  final state = AboutState();

  bool isFromMain = false;

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

  Future<void> initAboutAsync() async {
    // To enter FullScreenMode.EMERSIVE,
    // await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
  }
}
