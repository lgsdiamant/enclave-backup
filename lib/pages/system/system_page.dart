import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/shared/enclave_drawer.dart';
import 'package:enclave/shared/enclave_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../data/constants.dart';
import '../../enclave_app.dart';
import '../../pages/system/system_logic.dart';
import '../../pages/system/system_state.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_dialog.dart';

///
/// Page for System: Developer
///

class SystemPage extends StatelessWidget {
  SystemPage({Key? key}) : super(key: key);
  final SystemLogic logic = Get.find<SystemLogic>();
  final SystemState state = Get.find<SystemLogic>().state;

  @override
  Widget build(BuildContext context) {
    systemLogic.initSystemRepository();
    logic.contextSystem = context;

    return Scaffold(
      appBar: AppBar(
        title: Text('titleSystemPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      drawer: (mainLogic.isSystem) ? enclaveDrawerSystem(context) : ((gCurrentEnclave.isAdmin) ? enclaveDrawerAdmin(context) : enclaveDrawerUser(context)),
      onDrawerChanged: (isOpen) {
        if (!memberLogic.finishEditable()) return;
      },
      body: SafeArea(
        child: FutureBuilder(
          future: logic.initSystemPageAsync(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('errorSystemInitialization'.tr + '\n' + snapshot.error.toString()));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return SystemForm();
            }
            return Center(child: viewWaiting(context, notice: 'noticeInitializingLogin'.tr));
          },
        ),
      ),
    );
  }
}

class SystemForm extends StatelessWidget {
  SystemForm({
    Key? key,
  }) : super(key: key);

  final systemFormBuilderKey = GlobalKey<FormBuilderState>();
  final TextEditingController _systemEnclaveCodeController = TextEditingController(
    text: (currentEnclaveInitialized ? gCurrentEnclave.code : ''),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.cMediumGap),
      color: Theme.of(context).colorScheme.background,
      child: FormBuilder(
        key: systemFormBuilderKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FormBuilderTextField(
              name: 'system',
              controller: _systemEnclaveCodeController,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                prefixIcon: const Icon(MdiIcons.accountGroup, size: 18),
                filled: true,
                isDense: true,
                border: const OutlineInputBorder(),
                labelText: 'termEnclaveCode'.tr,
                hintText: 'hintEnclaveCode'.tr,
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context, errorText: 'noticeFieldRequired'.tr),
              ]),
            ),
            const SizedBox(height: Constants.cSmallGap),
            ElevatedButton(
              onPressed: () async {
                systemFormBuilderKey.currentState!.save();
                if (systemFormBuilderKey.currentState!.validate()) {
                  final code = _systemEnclaveCodeController.text.trim();
                  systemLogic.assignSystemEnclaveCode(code);
                  if (await systemLogic.excelFileExistInStorage()) {
                    Get.defaultDialog(
                      textConfirm: 'OK',
                      onConfirm: () => {Get.back()},
                      title: "EnclaveCode assigned",
                      middleText: _systemEnclaveCodeController.text.trim(),
                      backgroundColor: Colors.green,
                      titleStyle: const TextStyle(color: Colors.white),
                      middleTextStyle: const TextStyle(color: Colors.white),
                    );
                  } else {
                    gEnDialog.simpleAlert(title: 'File not exist', message: 'Excel file not exist in storage');
                  }
                } else {
                  print("validation failed");
                }
              },
              child: const Text("Assign System EnclaveCode"),
            ),
            Row(
              children: [
                gEnMenu.systemPopupMenu,
                const Text('System Actions'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
