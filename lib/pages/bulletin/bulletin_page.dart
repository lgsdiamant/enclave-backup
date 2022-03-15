import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enclave/data/en_bulletin_message.dart';
import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/pages/bulletin/message_edit_page.dart';
import 'package:enclave/pages/bulletin/view_text_images.dart';
import 'package:enclave/shared/enclave_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../data/constants.dart';
import '../../data/en_member.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';
import 'bulletin_logic.dart';
import 'bulletin_state.dart';
import 'message_browse_page.dart';

///
/// Page for System: Developer
///

class BulletinPage extends StatelessWidget {
  BulletinPage({Key? key}) : super(key: key);
  final BulletinLogic logic = Get.find<BulletinLogic>();
  final BulletinState state = Get.find<BulletinLogic>().state;

  @override
  Widget build(BuildContext context) {
    bulletinLogic.contextBulletin = context;
    bulletinLogic.initBulletinStreams();

    return Scaffold(
      appBar: AppBar(
        title: Text('titleBulletinPage'.trParams({'enclave': gCurrentEnclave.nameSub})),
        actions: gEnMenu.actionsDefault(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: viewBulletinList(),
      ),
    );
  }

  //-------------------------------------------------------------------------------------------
  Widget viewBulletinList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Constants.cSmallGap, right: Constants.cSmallGap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('termPublicNotice'.tr),
              IconButton(
                onPressed: () {
                  Get.to(() => MessageEditPage(isNotice: true));
                },
                constraints: BoxConstraints.tight(const Size(Constants.cHugeIconSize, Constants.cHugeIconSize)),
                tooltip: 'helpAddNewPublicNotice'.tr,
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: StreamBuilder<QuerySnapshot>(
            stream: bulletinLogic.noticeStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return (snapshot.data!.docs.isEmpty)
                  ? Text('noticeNoPublicNotice'.tr)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        final message = EnBulletinMessage.fromMap(data);
                        return noticeCard(message, snapshot.data!.docs.length);
                      }).toList(),
                    );
            },
          ),
        ),
        const Divider(thickness: 2.0),
        Padding(
          padding: const EdgeInsets.only(left: Constants.cSmallGap, right: Constants.cSmallGap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('termBulletinMessage'.tr),
              IconButton(
                onPressed: () {
                  bulletinLogic.assignBulletinMessage(isNotice: false); // empty message
                  Get.to(() => MessageEditPage());
                },
                constraints: BoxConstraints.tight(const Size(Constants.cHugeIconSize, Constants.cHugeIconSize)),
                tooltip: 'helpAddNewPublicNotice'.tr,
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: bulletinLogic.messageStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return (snapshot.data!.docs.isEmpty)
                  ? Text('noticeNoBulletinMessage'.tr)
                  : ScrollablePositionedList.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: false,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final map = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
                        final message = EnBulletinMessage.fromMap(map);
                        return messageCard(message);
                      });
            },
          ),
        )
      ],
    );
  }

  bool _hasMessageAuthority(message) {
    // owns message was generated by mySelf
    final mySelf = gCurrentEnclave.mySelf;

    if (gCurrentEnclave.isAdmin) return true;

    return ((message.personName == mySelf.personName) && (message.personId == mySelf.getIndex));
  }

  Widget noticeCard(EnBulletinMessage notice, int countNotice) {
    bool hasAuthority = _hasMessageAuthority(notice);
    double fullWidth = MediaQuery.of(bulletinLogic.contextBulletin).size.width;
    double minWidth = fullWidth / countNotice - Constants.cSmallGap;
    double width = max(minWidth, min(fullWidth * 0.6, 300));

    final EnMember messageOwner = gEnRepo.getMemberByNameId(notice.personName, notice.personId);

    return Card(
      shadowColor: Theme.of(bulletinLogic.contextBulletin).colorScheme.background,
      elevation: Constants.cMediumGap,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black38, width: 1),
        borderRadius: BorderRadius.circular(Constants.cTinyGap),
      ),
      borderOnForeground: true,
      child: InkWell(
        onTap: () {
          Get.to(() => MessageBrowsePage(message: notice));
        },
        child: SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.only(left: Constants.cTinyGap, right: Constants.cTinyGap, bottom: Constants.cSmallGap),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        profileAvatar(member: messageOwner, size: Constants.cTinySmallAvatarSize),
                        const SizedBox(width: Constants.cTinyGap),

                        // personName
                        Text(
                          notice.personName,
                          style: TextStyle(fontSize: Constants.cSmallFontSize),
                        ),
                        const SizedBox(width: Constants.cTinyGap),

                        // time
                        Text(
                          gEnUtil.timeAgoToString(thenTime: notice.modified),
                          style: TextStyle(fontSize: Constants.cTinyFontSize),
                        ),
                      ],
                    ),

                    // popupMenu
                    if (hasAuthority) BulletinPopupMenu(notice),
                  ],
                ),
                const Divider(thickness: 1, height: 2),
                Text(
                  notice.title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: Constants.cSmallFontSize),
                  maxLines: 1,
                ),
                const Divider(thickness: 1, height: 2),
                Text(
                  notice.content.isEmpty ? '' : notice.content[0],
                  style: TextStyle(fontSize: Constants.cSmallFontSize),
                  overflow: TextOverflow.fade,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget messageCard(EnBulletinMessage message) {
    bool hasAuthority = _hasMessageAuthority(message);
    final EnMember messageOwner = gEnRepo.getMemberByNameId(message.personName, message.personId);

    return Card(
      shadowColor: Theme.of(bulletinLogic.contextBulletin).colorScheme.background,
      elevation: Constants.cMediumGap,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black38, width: 1),
        borderRadius: BorderRadius.circular(Constants.cTinyGap),
      ),
      borderOnForeground: true,
      child: InkWell(
        onTap: () {
          Get.to(() => MessageBrowsePage(message: message));
        },
        child: Container(
          padding: const EdgeInsets.only(left: Constants.cTinyGap, right: Constants.cTinyGap, bottom: Constants.cSmallGap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      profileAvatar(member: messageOwner, size: Constants.cTinyAvatarSize),
                      const SizedBox(width: Constants.cTinyGap),
                      Text(message.personName),
                      const SizedBox(width: Constants.cTinyGap),
                      Text(
                        gEnUtil.timeAgoToString(thenTime: message.modified),
                        style: TextStyle(fontSize: Constants.cTinyFontSize),
                      ),
                    ],
                  ),
                  // popupMenu
                  if (hasAuthority) BulletinPopupMenu(message),
                ],
              ),
              const Divider(thickness: 1, height: 2),
              Text(
                message.title,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: Constants.cMediumFontSize),
              ),
              const Divider(thickness: 1, height: 2),
              if (message.content.isNotEmpty)
                textImageItem(
                  item: message.content[0],
                  readOnly: false,
                  context: bulletinLogic.contextBulletin,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

///----------------------------------------------------------------------------
class MessageReplyTab extends StatelessWidget {
  const MessageReplyTab({required this.message, Key? key}) : super(key: key);

  final EnBulletinMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.cTinyGap),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(MdiIcons.thumbUpOutline),
              ),
              const SizedBox(width: Constants.cTinyGap),
              const Text('0'),
              const SizedBox(width: Constants.cSmallGap),
              IconButton(
                onPressed: () {},
                icon: const Icon(MdiIcons.thumbDownOutline),
              ),
              const SizedBox(width: Constants.cTinyGap),
              const Text('0'),
            ]),
            Row(
              children: [
                const Text('0'),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(MdiIcons.messageReplyTextOutline),
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          ],
        ),
      ]),
    );
  }
}
