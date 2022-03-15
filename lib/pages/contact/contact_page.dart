import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../shared/enclave_menu.dart';
import 'contact_logic.dart';
import 'contact_state.dart';

///
/// Page for Contact
///

class ContactPage extends StatelessWidget {
  final ContactLogic logic = Get.find<ContactLogic>();
  final ContactState state = Get.find<ContactLogic>().state;

  ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titleContactPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: _mainForm(context),
        ),
      ),
    );
  }

  ///
  /// Main Form for Contact
  ///
  Form _mainForm(BuildContext context) {
    return Form(
      key: key,
      child: Center(child: Text('contentContactPage'.tr)),
    );
  }
}
