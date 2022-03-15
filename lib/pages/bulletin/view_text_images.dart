import 'dart:io';

import 'package:enclave/shared/common_ui.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../enclave_app.dart';

class ViewTextImages extends StatelessWidget {
  ViewTextImages({
    this.textImages,
    this.editable = false,
    Key? key,
  })  : // if not editable, textImages should be given
        assert((!editable) ? (textImages != null) : true),
        super(key: key);

  final bool editable;
  final List<String>? textImages;
  final List<String> newTextImages = [];
  final itemScrollController = ItemScrollController();

  bool get _isNew => (textImages == null);

  @override
  Widget build(BuildContext context) {
    bulletinLogic.assignTextImages(textImages: textImages);

    final List<String> items = _isNew ? newTextImages : textImages!;
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: items.length,
      itemScrollController: itemScrollController,
      itemBuilder: (context, index) {
        final item = items[index];
        return textImageItem(item:item, readOnly: false, context: context);
      },
    );
  }
}

//----------------------------------------------
// return image or text widget
Widget textImageItem({required String item, required bool readOnly, required BuildContext context}) {
  final itemController = TextEditingController(text: item);
  if (bulletinLogic.isImage_(item)) {
    ImageProvider image;
    // it is image
    item = bulletinLogic.getImage_(item);
    if (bulletinLogic.isFile_(item)) {
      // it is file image
      item = bulletinLogic.getImageUrl_(item);
      image = FileImage(File(item));
    } else {
      // it is firebase image
      image = FirebaseImage(item);
    }
    return clickableImage(image: image);
  } else {
    return readOnly
        ? Text(item)
        : EditableText(
            controller: itemController,
            focusNode: FocusNode(),
            cursorColor: Theme.of(context).colorScheme.onBackground,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            backgroundCursorColor: Theme.of(context).colorScheme.onBackground,
            minLines: 1,
            maxLines: 5,
            readOnly: readOnly,
          );
  }
}
