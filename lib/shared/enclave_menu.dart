import 'package:enclave/data/constants.dart';
import 'package:enclave/data/en_bulletin_message.dart';
import 'package:enclave/pages/bulletin/message_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/en_enclave.dart';
import '../data/repository.dart';
import '../enclave_app.dart';
import 'animated_search_bar.dart';
import 'enclave_dialog.dart';
import 'enclave_sound.dart';
import 'enclave_theme.dart';

late EnclaveMenu gEnMenu;

class EnclaveMenu {
  /// for singleton access
  static EnclaveMenu? _instance;

  EnclaveMenu._();

  factory EnclaveMenu() => _instance ??= EnclaveMenu._();

  /// default option menu
  var optionPopupMenuDefault = PopupMenuButton<IconMenuItem>(
    icon: const Icon(MdiIcons.dotsVertical),
    onSelected: (IconMenuItem item) async {
      await gEnMenu.onClickOptionMenu(item);
    },
    itemBuilder: (BuildContext context) => IconMenuItem.optionMenu()
        .map((item) => PopupMenuItem<IconMenuItem>(
              value: item,
              child: Row(
                children: [
                  Icon(item.iconData, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Constants.cSmallGap),
                  Text(item.name),
                ],
              ),
            ))
        .toList(),
  );

  //---------------------------------------------------------------------------
  var systemPopupMenu = PopupMenuButton<IconMenuItem>(
    icon: const Icon(
      MdiIcons.accountReactivateOutline,
      size: Constants.cBigIconSize,
    ),
    onSelected: (IconMenuItem item) async {
      await gEnMenu.onClickSystemMenu(item);
    },
    itemBuilder: (BuildContext context) => IconMenuItem.systemMenu()
        .map((item) => PopupMenuItem<IconMenuItem>(
              value: item,
              child: Row(
                children: [
                  Icon(item.iconData, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: Constants.cSmallGap),
                  Text(item.name),
                ],
              ),
            ))
        .toList(),
  );

  /// option menu actions
  Future<void> onClickOptionMenu(IconMenuItem menuItem) async {
    if (!memberLogic.finishEditable()) return;

    switch (menuItem.id) {
      case Constants.exitAppItemId:
        await mainLogic.finishApp();
        break;

      case Constants.signOutItemId:
        await loginLogic.signOutFirebase();
        break;

      case Constants.changeThemeItemId:
        gEnTheme.switchTheme(toggle: true);
        break;

      case Constants.soundOnOffItemId:
        gEnSound.toggleSound();
        break;

      case Constants.updateAppItemId:
        mainLogic.checkEnclaveApp();
        break;

      default:
        break;
    }

    /// system menu actions
    Future<void> onClickSystemMenu(IconMenuItem menuItem) async {
      switch (menuItem.id) {
        case Constants.systemClearSharedPrefItemId:
          await systemLogic.clearSharedPref();
          gEnDialog.simpleAlert(title: 'titleClearedSharedPref', message: 'noticeClearedSharedPref');
          break;

        case Constants.systemRefreshObItemId:
          gEnDialog.showLinearProgressDialog(
            title: 'titleRefreshDatabase'.tr,
            middleText: 'noticeRefreshingDatabase'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
          );
          await systemLogic.refreshEnclaveObUser();
          gEnDialog.hideLinearProgressDialog();
          break;

        case Constants.systemRefreshDataFileItemId:
          gEnDialog.showLinearProgressDialog(
            title: 'titleRefreshDatabase'.tr,
            middleText: 'noticeRefreshingDataFile'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
          );
          await systemLogic.refreshEnclaveDataFileUser();
          gEnDialog.hideLinearProgressDialog();
          break;

        case Constants.systemUploadExcelItemId:
          if (await systemLogic.excelFileExistInStorage()) {
            gEnDialog.showLinearProgressDialog(
              title: 'titleUploadDatabase'.tr,
              middleText: 'noticeUploadingDatabase'.trParams({'enclaveCode': systemLogic.repositorySystem.enclaveCode}),
            );
            await systemLogic.uploadFirestoreFromExcelStorage();
            gEnDialog.hideLinearProgressDialog();
          } else {
            gEnDialog.simpleAlert(title: 'File not exist', message: 'Excel file not exist in storage');
          }
          break;

        default:
          break;
      }
    }
  }

  /// system menu actions
  Future<void> onClickSystemMenu(IconMenuItem menuItem) async {
    switch (menuItem.id) {
      case Constants.systemClearSharedPrefItemId:
        await systemLogic.clearSharedPref();
        gEnDialog.simpleAlert(title: 'titleClearedSharedPref', message: 'noticeClearedSharedPref');
        break;

      case Constants.systemRefreshObItemId:
        gEnDialog.showLinearProgressDialog(
          title: 'titleRefreshDatabase'.tr,
          middleText: 'noticeRefreshingDatabase'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
        );
        await systemLogic.refreshEnclaveObUser();
        gEnDialog.hideLinearProgressDialog();
        break;

      case Constants.systemRefreshDataFileItemId:
        gEnDialog.showLinearProgressDialog(
          title: 'titleRefreshDatabase'.tr,
          middleText: 'noticeRefreshingDataFile'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
        );
        await systemLogic.refreshEnclaveDataFileUser();
        gEnDialog.hideLinearProgressDialog();
        break;

      case Constants.systemUploadExcelItemId:
        if (await systemLogic.excelFileExistInStorage()) {
          gEnDialog.showLinearProgressDialog(
            title: 'titleUploadDatabase'.tr,
            middleText: 'noticeUploadingDatabase'.trParams({'enclaveCode': systemLogic.repositorySystem.enclaveCode}),
          );
          await systemLogic.uploadFirestoreFromExcelStorage();
          gEnDialog.hideLinearProgressDialog();
        } else {
          gEnDialog.simpleAlert(title: 'File not exist', message: 'Excel file not exist in storage');
        }
        break;

      default:
        break;
    }
  }

  /// default action menu for enclave appBar
  List<Widget> actionsDefault() {
    return <Widget>[
      // default option menu
      gEnMenu.optionPopupMenuDefault,
    ];
  }

  /// default action menu for enclave appBar
  late AnimatedSearchBar gAnimatedSearchBar;

  //----------------------------------------------------------------------
  List<Widget> enclaveActionMenuForMemberPage({
    required BuildContext context,
    required bool isMemberBrowsePage,
  }) {
    gAnimatedSearchBar = AnimatedSearchBar(
        width: Constants.cSearchBarSize,
        autoFocus: true,
        rtl: false,
        closeSearchOnSuffixTap: true,
        color: const Color(0x20000000),
        textController: _searchMemberController,
        helpText: 'hintSearchMember'.tr,
        onSuffixTap: () {
          memberLogic.searchMemberByField(_searchMemberController.text);
          // _searchMemberController.clear();
        });

    return <Widget>[
      // searchBar. if isEditable, no searchBar
      Obx(
        () => (memberLogic.isEditable) ? const SizedBox.shrink() : gAnimatedSearchBar,
      ),

      // edit member info. if admin or mySelf, show editIcon
      (((gCurrentEnclave.isAdmin || memberLogic.isMySelf)) && !isMemberBrowsePage)
          ? Row(
              children: [
                const SizedBox(width: Constants.cSmallGap),
                IconButton(
                    icon: Icon((memberLogic.isEditable) ? MdiIcons.pencilOutline : MdiIcons.pencilOffOutline, color: Colors.white),
                    highlightColor: Colors.grey,
                    iconSize: Constants.cMediumIconSize,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      memberLogic.toggleEditable();
                    }),
                const SizedBox(width: Constants.cSmallGap),
              ],
            )
          : const SizedBox.shrink(),

      // default option menu
      gEnMenu.optionPopupMenuDefault,
    ];
  }

  //----------------------------------------------------------------------
  List<Widget> enclaveActionMenuForBulletinEdit() {
    return <Widget>[
      Obx(
        () => (bulletinLogic.isMessageChanged)
            ? IconButton(
                icon: const Icon(MdiIcons.contentSaveCheckOutline, color: Colors.white),
                iconSize: Constants.cMediumIconSize,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await bulletinLogic.saveMessage();

                  // return to BulletinPage
                  Get.back();
                })
            : const SizedBox.shrink(),
      ),

      // default option menu
      gEnMenu.optionPopupMenuDefault,
    ];
  }

  /// Bulletin menu actions
  Future<void> onClickBulletinMenu(IconMenuItem menuItem, {required EnBulletinMessage message}) async {
    switch (menuItem.id) {
      case Constants.bulletinMoveToNoticeItemId:
        message.modified = DateTime.now().millisecondsSinceEpoch;
        message.isNotice = true;
        gEnRepo.saveBulletinMessage(message);
        break;

      case Constants.bulletinMoveToMessageItemId:
        message.modified = DateTime.now().millisecondsSinceEpoch;
        message.isNotice = false;
        gEnRepo.saveBulletinMessage(message);
        break;

      case Constants.bulletinEditMessageItemId:
        Get.to(() => MessageEditPage(message: message));
        break;

      case Constants.bulletinDeleteItemId:
        gEnRepo.deleteBulletinMessage(message);
        break;

      default:
        break;
    }
  }
}

/// Icon MenuItem
class IconMenuItem {
  final int id;
  final IconData iconData;
  final String name;

  Object? owner;

  IconMenuItem(this.id, this.iconData, this.name);

  static List<IconMenuItem> optionMenu() {
    return <IconMenuItem>[
      IconMenuItem(Constants.exitAppItemId, MdiIcons.exitToApp, 'menuExitApp'.tr),
      IconMenuItem(Constants.signOutItemId, MdiIcons.logout, 'menuSignOutFirebase'.tr),
      IconMenuItem(Constants.changeThemeItemId, MdiIcons.brightness6, 'menuChangeTheme'.tr),
      IconMenuItem(Constants.soundOnOffItemId, MdiIcons.volumeHigh, 'menuSoundOnOff'.tr),
      IconMenuItem(Constants.updateAppItemId, MdiIcons.update, 'menuUpdateApp'.tr),
    ];
  }

  static List<IconMenuItem> systemMenu() {
    return <IconMenuItem>[
      IconMenuItem(Constants.systemClearSharedPrefItemId, MdiIcons.closeCircleMultipleOutline, 'menuClearSharedPref'.tr),
      IconMenuItem(Constants.systemRefreshObItemId, MdiIcons.databaseEditOutline, 'menuRefreshDatabase'.tr),
      IconMenuItem(Constants.systemRefreshDataFileItemId, MdiIcons.fileEditOutline, 'menuRefreshDataFile'.tr),
      IconMenuItem(Constants.systemUploadExcelItemId, MdiIcons.uploadOutline, 'menuUploadExcelFile'.tr),
    ];
  }

  static List<IconMenuItem> bulletinNoticeMenu() {
    return <IconMenuItem>[
      IconMenuItem(Constants.bulletinMoveToMessageItemId, MdiIcons.transferDown, 'menuMoveToMessage'.tr),
      IconMenuItem(Constants.bulletinEditMessageItemId, MdiIcons.noteEditOutline, 'menuModify'.tr),
      IconMenuItem(Constants.bulletinDeleteItemId, MdiIcons.deleteForeverOutline, 'menuDelete'.tr),
    ];
  }

  static List<IconMenuItem> bulletinMessageMenu() {
    return <IconMenuItem>[
      IconMenuItem(Constants.bulletinMoveToNoticeItemId, MdiIcons.transferUp, 'menuMoveToNotice'.tr),
      IconMenuItem(Constants.bulletinEditMessageItemId, MdiIcons.noteEditOutline, 'menuModify'.tr),
      IconMenuItem(Constants.bulletinDeleteItemId, MdiIcons.deleteForeverOutline, 'menuDelete'.tr),
    ];
  }
}

final TextEditingController _searchMemberController = TextEditingController();

class BulletinPopupMenu extends PopupMenuButton<IconMenuItem> {
  BulletinPopupMenu(this.message, {Key? key})
      : super(
          key: key,
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(
            MdiIcons.dotsVertical,
            size: Constants.cSmallIconSize,
          ),
          onSelected: (IconMenuItem item) async {
            await gEnMenu.onClickBulletinMenu(item, message: message);
          },
          itemBuilder: (BuildContext context) => (message.isNotice ? IconMenuItem.bulletinNoticeMenu() : IconMenuItem.bulletinMessageMenu())
              .map((item) => PopupMenuItem<IconMenuItem>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(item.iconData, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: Constants.cSmallGap),
                        Text(item.name),
                      ],
                    ),
                  ))
              .toList(),
        );

  final EnBulletinMessage message;
}
