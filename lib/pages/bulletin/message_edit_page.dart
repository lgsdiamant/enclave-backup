import 'package:enclave/data/en_bulletin_message.dart';
import 'package:enclave/enclave_app.dart';
import 'package:enclave/pages/bulletin/view_text_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/constants.dart';
import '../../shared/enclave_menu.dart';
import 'bulletin_logic.dart';
import 'bulletin_state.dart';

///
/// Page for Bulletin Message Edit
///

class MessageEditPage extends StatelessWidget {
  MessageEditPage({this.message, this.isNotice, Key? key})
      : assert(((message == null) && (isNotice != null)) || ((message != null) && (isNotice == null))),
        super(key: key);

  final BulletinLogic logic = Get.find<BulletinLogic>();
  final BulletinState state = Get.find<BulletinLogic>().state;

  final bool? isNotice;
  final EnBulletinMessage? message;

  bool get _isNotice => isNotice ?? message!.isNotice;

  bool get _isNew => message == null;

  final _bulletinFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    bulletinLogic.assignBulletinMessage(message: message, isNotice: isNotice);

    final title = _isNotice ? ((_isNew) ? 'termNewPublicNotice'.tr : 'termEditPublicNotice'.tr) : ((_isNew) ? 'termNewBulletinMessage'.tr : 'termEditBulletinMessage'.tr);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: gEnMenu.enclaveActionMenuForBulletinEdit(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.cTinyGap),
          child: _viewBulletinEdit(context),
        ),
      ),
    );
  }

  Widget _viewBulletinEdit(BuildContext context) {
    final titleEditController = TextEditingController(text: _isNew ? '' : message!.title);

    final enabled = bulletinLogic.ownsMessage();

    return FormBuilder(
      key: _bulletinFormKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'title',
            enabled: enabled,
            controller: titleEditController,
            decoration: InputDecoration(
              labelText: 'termTitle'.tr,
            ),
            onChanged: bulletinLogic.onChangedTitle,
            // valueTransformer: (text) => num.tryParse(text),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(context),
            ]),
            keyboardType: TextInputType.text,
          ),
          _isNew
              ? const Text('new')
              : textImageItem(
                  item: message!.content[0],
                  readOnly: false,
                  context: context,
                ),
        ],
      ),
    );
/*
    return FormBuilder(
      key: _bulletinFormKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'title',
            enabled: enabled,
            controller: titleEditController,
            decoration: InputDecoration(
              labelText: 'termTitle'.tr,
            ),
            onChanged: bulletinLogic.onChangedTitle,
            // valueTransformer: (text) => num.tryParse(text),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(context),
            ]),
            keyboardType: TextInputType.text,
          ),
          Expanded(
            child: FormBuilderTextField(
              name: 'content',
              enabled: enabled,
              controller: contentEditController,
              minLines: 1,
              maxLines: 100,
              decoration: InputDecoration(
                labelText: 'termContent'.tr,
              ),
              onChanged: bulletinLogic.onChangedContent,
              // valueTransformer: (text) => num.tryParse(text),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context),
              ]),
              keyboardType: TextInputType.multiline,
            ),
          ),
        ],
      ),
    );
*/
  }
}
