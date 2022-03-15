import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enclave/data/en_bulletin_message.dart';
import 'package:enclave/data/en_comment.dart';
import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/enclave_app.dart';
import 'package:enclave/pages/bulletin/view_text_images.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/constants.dart';
import '../../data/en_member.dart';
import '../../data/repository.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';
import '../../shared/enclave_utility.dart';
import 'bulletin_logic.dart';
import 'bulletin_state.dart';

///

class MessageBrowsePage extends StatelessWidget {
  MessageBrowsePage({required this.message, Key? key}) : super(key: key);

  final BulletinLogic logic = Get.find<BulletinLogic>();
  final BulletinState state = Get.find<BulletinLogic>().state;

  final EnBulletinMessage message;

  @override
  Widget build(BuildContext context) {
    bulletinLogic.assignBulletinMessage(message: message);

    final title = message.isNotice ? 'termBrowsePublicNotice'.tr : 'termBrowseBulletinMessage'.tr;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.cTinyGap),
          child: _viewBulletinBrowse(context),
        ),
      ),
    );
  }

  Widget _viewBulletinBrowse(BuildContext context) {
    final EnMember messageOwner = gEnRepo.getMemberByNameId(message.personName, message.personId);

    final commentStream = bulletinLogic.getCommentStream(message);
    final itemScrollController = ItemScrollController();

    List<Widget> contentWidgets = [];
    if (message.content.isNotEmpty) {
      contentWidgets = message.content
          .map((item) => textImageItem(
                item: item,
                readOnly: false,
                context: logic.contextBulletin,
              ))
          .toList();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    profileAvatar(member: messageOwner, size: Constants.cSmallAvatarSize),
                    const SizedBox(width: Constants.cTinyGap),

                    // personName
                    Text(
                      message.personName,
                      style: TextStyle(fontSize: Constants.cSmallFontSize),
                    ),
                    const SizedBox(width: Constants.cTinyGap),
                  ],
                ),

                // time
                Text(
                  gEnUtil.timeAgoToString(thenTime: message.modified),
                  style: TextStyle(fontSize: Constants.cTinyFontSize, color: Colors.grey),
                ),
              ],
            ),

            // if not empty Title
            if (message.title.isNotEmpty) const Divider(thickness: 1, height: 2),
            if (message.title.isNotEmpty)
              Text(
                message.title,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: Constants.cSmallFontSize),
                maxLines: 1,
              ),
            if (message.content.isNotEmpty) const Divider(thickness: 1, height: 2),
            if (contentWidgets.isNotEmpty) ...contentWidgets,

            // if not empty Title
            // if (message.content.isNotEmpty) const Divider(thickness: 1, height: 2),
            // if (message.content.isNotEmpty)
            //   Text(
            //     message.content,
            //     style: TextStyle(fontSize: Constants.cSmallFontSize),
            //     overflow: TextOverflow.fade,
            //   ),
          ],
        ),
        const Divider(thickness: 2, height: 6),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: commentStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return (snapshot.data!.docs.isEmpty)
                  ? Text('noticeNoComment'.tr)
                  : ScrollablePositionedList.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemScrollController: itemScrollController,
                      itemBuilder: (context, index) {
                        bulletinLogic.commentCount = snapshot.data!.docs.length;
                        final data = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
                        final comment = EnComment.fromMap(data);
                        return viewComment(context, message: message, comment: comment);
                      },
                    );
            },
          ),
        ),
        EnterCommentLayout(message: message, itemScrollController: itemScrollController),
      ],
    );
  }

  Widget viewComment(BuildContext context, {required EnBulletinMessage message, required EnComment comment}) {
    final commentOwner = gEnRepo.getMemberByNameId(comment.personName, comment.personId);
    final isMyself = commentOwner == gCurrentEnclave.mySelf;

    // check valid image
    // bool hasValidImage = false;
    // CachedNetworkImageProvider? validImage;
    // if (comment.imageUrl.isNotEmpty) {
    //   hasValidImage = true;
    //   validImage = CachedNetworkImageProvider(
    //     comment.imageUrl,
    //     errorListener: () {
    //       hasValidImage = false;
    //     },
    //   );
    // }
    bool hasValidImage = false;
    FirebaseImage? validImage;
    if (comment.imageUrl.isNotEmpty) {
      hasValidImage = true;
      validImage = FirebaseImage(comment.imageUrl);
    }

    return Container(
      padding: const EdgeInsets.all(Constants.cSmallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileAvatar(member: commentOwner, size: Constants.cTinySmallAvatarSize),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: Constants.cTinyGap, right: Constants.cTinyGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.personName,
                        style: TextStyle(fontSize: Constants.cTinyFontSize, color: Theme.of(context).colorScheme.secondary),
                      ),
                      Row(
                        children: [
                          if (isMyself)
                            InkWell(
                              onTap: () {
                                bulletinLogic.deleteComment(message: message, comment: comment);
                              },
                              child: const Icon(MdiIcons.deleteOutline, color: Colors.grey),
                            ),
                          Text(
                            gEnUtil.timeAgoToString(thenTime: comment.generated),
                            style: TextStyle(fontSize: Constants.cTinyFontSize, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (comment.content.isNotEmpty) Text(comment.content, style: TextStyle(fontSize: Constants.cSmallFontSize)),
                  if (hasValidImage) clickableImage(image: validImage!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnterCommentLayout extends StatelessWidget {
  EnterCommentLayout({required this.message, required this.itemScrollController, Key? key}) : super(key: key);
  final ItemScrollController itemScrollController;
  final EnBulletinMessage message;

  final rxActiveSend = Rx<bool>(false);
  final commentController = TextEditingController();
  final rxCommentImage = Rx<FileImage?>(null);
  final rxCommentText = Rx<String>('');

  //--------------------------------------------------------------------
  void _commentChanged() {
    rxCommentText.value = commentController.text.trim();
    rxActiveSend.value = rxCommentText.value.trim().isNotEmpty || (rxCommentImage.value != null);
  }

  @override
  Widget build(BuildContext context) {
    rxCommentText.value = '';

    return Obx(() {
      return Column(
        children: [
          if (rxCommentImage.value != null)
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                SizedBox(
                  height: Constants.cMediumImageSize,
                  child: InkWell(
                    onTap: () {},
                    child: Image(
                      image: rxCommentImage.value!,
                      height: Constants.cMediumImageSize,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(Constants.cTinyGap)),
                  onTap: () async {
                    rxCommentImage.value = null;
                    _commentChanged();
                  },
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: Icon(
                      MdiIcons.close,
                      size: Constants.cMediumIconSize,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(Constants.cTinyGap)),
                onTap: () async {
                  final rxImage = Rx<FileImage?>(null);
                  bool success = await gEnRepo.getImageFromPicker(rxImage);
                  if (success) {
                    var fileImage = rxImage.value;
                    if (fileImage != null) {
                      rxCommentImage.value = rxImage.value;
                      rxActiveSend.value = true;
                    }
                  }
                },
                child: const Icon(
                  MdiIcons.imageOutline,
                  size: Constants.cMediumIconSize,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(Constants.cTinyGap),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer, style: BorderStyle.solid, width: 1),
                  ),
                  child: EditableText(
                    controller: commentController,
                    focusNode: FocusNode(),
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    backgroundCursorColor: Theme.of(context).colorScheme.onBackground,
                    onChanged: (text) => _commentChanged(),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ),
              Visibility(
                visible: rxActiveSend.value,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(Constants.cTinyGap)),
                  onTap: () {
                    if (rxCommentText.value.isNotEmpty || (rxCommentImage.value != null)) {
                      bulletinLogic.addComment(commentText: rxCommentText.value, fileImage: rxCommentImage.value);
                      commentController.clear();
                      rxCommentText.value = '';
                      rxCommentImage.value = null;
                    }
                    final currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    Future.delayed(
                        const Duration(milliseconds: 0),
                        () => {
                              itemScrollController.scrollTo(
                                index: bulletinLogic.commentCount + 1,
                                alignment: 1.0,
                                duration: const Duration(microseconds: 200),
                              )
                            });
                  },
                  child: const Icon(
                    MdiIcons.sendOutline,
                    size: Constants.cMediumIconSize,
                  ),
                ),
              )
            ],
          ),
        ],
      );
    });
  }
}
