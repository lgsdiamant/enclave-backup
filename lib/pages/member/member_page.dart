import 'dart:developer';
import 'dart:math';

import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/pages/distinct/distinct_page.dart';
import 'package:enclave/pages/setting/setting_logic.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/constants.dart';
import '../../data/en_field.dart';
import '../../data/en_member.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../main_logic.dart';
import '../../router/router.dart';
import '../../shared/common_ui.dart';
import '../../shared/distinct_selector.dart';
import '../../shared/enclave_avatar.dart';
import '../../shared/enclave_dialog.dart';
import '../../shared/enclave_drawer.dart';
import '../../shared/enclave_menu.dart';
import '../../shared/enclave_sound.dart';
import '../../shared/enclave_theme.dart';
import '../../shared/enclave_utility.dart';
import '../../shared/image_viewer.dart';
import 'member_logic.dart';
import 'member_state.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final MemberLogic logic = Get.find<MemberLogic>();
  final MemberState state = Get.find<MemberLogic>().state;

  @override
  Widget build(BuildContext context) {
    logic.contextMember = context;
    // WillPopScope for handling back button
    return WillPopScope(
      onWillPop: () {
        final canPop = Navigator.canPop(context);
        if (!canPop) {
          mainLogic.finishApp(toAsk: true);
        }
        return Future.value(canPop);
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: InkWell(
            onLongPress: () {
              browseLogic.routeToBrowseAll();
            },
            child: Obx(() => Text(logic.rxMemberViewTitle.value)),
          ),
          actions: gEnMenu.enclaveActionMenuForMemberPage(context: context, isMemberBrowsePage: false),
        ),
        drawer: (mainLogic.isSystem) ? enclaveDrawerSystem(context) : ((gCurrentEnclave.isAdmin) ? enclaveDrawerAdmin(context) : enclaveDrawerUser(context)),
        onDrawerChanged: (isOpen) {
          if (!memberLogic.finishEditable()) return;
        },
        body: const SafeArea(
          child: MemberDisplayHolder(),
        ),
        // body: const MemberDisplayHolder(),
      ),
    );
  }
}

class MemberDisplayHolder extends StatelessWidget {
  const MemberDisplayHolder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: memberLogic.initMemberPageAsync(),
              builder: (context, snapshot) {
                // Error in initMemberPageAsync
                if (snapshot.hasError) {
                  return Center(child: Text('errorMemberInitialization'.tr + '\n' + snapshot.error.toString()));
                }

                // initMemberPageAsync Success
                if (snapshot.connectionState == ConnectionState.done) {
                  gCurrentEnclave.isDataReady = true;

                  final refreshGap = gCurrentEnclave.obRefreshGap; // if positive, it is not recent
                  if (refreshGap > 0) {
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => gEnDialog.askDatabaseRefresh(refreshGap: refreshGap, onConfirm: () => gEnRepo.forceRefreshDatabaseFromFirebase()),
                    );
                  }
                  return Obx(() => memberLogic.isEditable ? const MemberEditView() : const MemberDataView());
                  // return Obx(() => _memberDisplay(context));
                }

                // Waiting
                return Center(
                  heightFactor: 3.0,
                  child: viewWaiting(context, notice: 'noticeUpdatingEnclaveData'.tr),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// member data edit mode display
class MemberEditView extends StatelessWidget {
  const MemberEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memberInfoSource = MemberInfoSource();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: <Widget>[
          memberProfile(context: context),
          const SizedBox(
            height: Constants.cTinyGap,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(Constants.cTinyGap),
            child: SfDataGrid(
              // data source
              source: memberInfoSource,

              // modes
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              frozenColumnsCount: 1,

              // showing grid lines
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,

              // editing element
              allowEditing: true,
              navigationMode: GridNavigationMode.cell,
              selectionMode: SelectionMode.single,
              editingGestureType: EditingGestureType.tap,

              columns: [
                GridColumn(
                  columnName: Constants.keyField,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.background,
                    child: Text(
                      'termField'.tr,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  allowEditing: false,
                  columnWidthMode: ColumnWidthMode.fitByCellValue,
                ),
                GridColumn(
                  columnName: Constants.keyValue,
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    alignment: Alignment.center,
                    color: Theme.of(context).colorScheme.background,
                    child: Text(
                      'termValue'.tr,
                      style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  allowEditing: true,
                  columnWidthMode: ColumnWidthMode.lastColumnFill,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// member data mode display
class MemberDataView extends StatelessWidget {
  const MemberDataView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom + 10;

    return Column(
      children: <Widget>[
        Obx(() {
          return memberProfile(context: context);
        }),
        const SizedBox(
          height: Constants.cTinyGap,
        ),
        Expanded(
          child: InteractiveViewer(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(left: Constants.cTinyTinyGap, right: Constants.cTinyTinyGap, top: Constants.cTinyTinyGap, bottom: bottomPadding),
                child: Column(
                  children: <Widget>[
                    Obx(() {
                      return memberFieldListView(hideEmptyData: gAppSetting.rxPrefHideEmptyData.value);
                    }),
                  ],
                )),
          ),
        ),
        if (!memberLogic.isEditable) distinctSlidingChips(),
      ],
    );
  }
}

/// Text Field View: Field Name & Text Value
Widget memberFieldDisplay({EnField? field, String? fieldDisplayTerm, String? fieldValue, required bool hideEmptyData}) {
  // note: if field==null, then fieldName & fieldValue are required
  // note: if field!=null, then fieldName & fieldValue are null

  fieldDisplayTerm = fieldDisplayTerm ?? field!.displayTerm;
  fieldValue = fieldValue ?? memberLogic.selectedMember.findFieldValue(field!);

  if (hideEmptyData && gEnUtil.isDummyDataString(fieldValue)) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(top: Constants.cTinyGap),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        fieldTitleBox(field: field, title: fieldDisplayTerm),
        const SizedBox(width: Constants.cSmallGap),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ((field != null) && field.isUrl)
                    ? browsableText(fieldValue.toString())
                    : SelectableText(
                        fieldValue.toString(),
                        style: Constants.textStyleValue,
                        minLines: 1,
                        maxLines: (field == null) ? 1 : field.maxLines,
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// small title-box showing field display name. if distinct, use different color and onClick callback
Widget fieldTitleBox({EnField? field, String? title}) {
  // one of field & title should be null
  _onClickTitle() async {
    if (!memberLogic.finishEditable()) return;

    if (field != null) {
      if (!field.isDistinct) {
        gEnDialog.findMembersByFieldDialog(field: field);
      } else {
        distinctLogic.rxSelectedDistinct.value = field;
        try {
          distinctLogic.rxDistinctPageTitle.value = 'titleDistinctPageBy'.trParams({'distinctName': field.displayTerm});
        } on Exception catch (e) {
          gEnDialog.showExceptionError('fieldTitleBox', e);
          debugger(when: testingStopDebugger);
        }

        Get.toNamed(distinctRoute);
      }
    }
  }

  title = title ?? field!.displayTerm;
  bool isDistinct = (field != null) && field.isDistinct;

  return Obx(() {
    return InkWell(
      onTap: _onClickTitle,
      child: Container(
        child: Text(
          title!,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: Constants.cSmallFontSize,
            color: Colors.brown,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(Constants.cTinyGap)),
          color: isDistinct ? EnclaveColors.distinctFieldTitle : EnclaveColors.normalFieldTitle,
          border: Border.all(width: 0.5, color: isDistinct ? Colors.red : Colors.black26),
        ),
        padding: const EdgeInsets.only(left: Constants.cTinyGap, right: Constants.cTinyGap, top: 2.0, bottom: 2.0),
      ),
    );
  });
}

Widget mobilePhoneField() {
  final member = memberLogic.selectedMember;
  String valueString = gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(member.mobilePhone, hidden: false);

  if (gAppSetting.rxPrefHideEmptyData.value && gEnUtil.isDummyDataString(valueString)) {
    return const SizedBox.shrink();
  }

  final mobileField = gCurrentEnclave.findFieldByName(EnMember.mobilePhone_);

  return Container(
    margin: const EdgeInsets.only(top: Constants.cTinyGap),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (mobileField != null) fieldTitleBox(field: mobileField),
        const SizedBox(width: Constants.cSmallGap),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  valueString.toString(),
                  style: Constants.textStyleValue,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget memberProfile({required BuildContext context}) {
  final member = memberLogic.selectedMember;

  _onClickProfileImage() async {
    /* show full image*/
    if (memberLogic.isEditable) {
      await memberLogic.changeProfileImageFromPicker();
    } else {
      await Get.to(() => ProfileImageViewer(member: memberLogic.selectedMember));
    }
  }

  final _rxPadLeft = Rx<double>(Constants.cSmallGap);
  final _rxPadRight = Rx<double>(Constants.cSmallGap);
  double deltaSum = 0;
  bool activated = false;

  //----------------------------------------------------------
  _backToPadding() {
    _rxPadLeft.value = Constants.cSmallGap;
    _rxPadRight.value = Constants.cSmallGap;
  }

  return GestureDetector(
    onHorizontalDragEnd: (details) {
      if (!activated) {
        _backToPadding();
      }
    },
    onLongPress: () {
      if (memberLogic.finishEditable()) {
        browseLogic.routeToBrowseAll();
      }
    },
    onHorizontalDragUpdate: (details) {
      final delta = details.delta.dx;
      deltaSum += delta / 2;
      final offset = min(Constants.cSmallGap, max(deltaSum, -Constants.cSmallGap));
      _rxPadLeft.value = Constants.cSmallGap + offset;
      _rxPadRight.value = Constants.cSmallGap - offset;
      activated = (offset == -Constants.cSmallGap) || (offset == Constants.cSmallGap);
      if (activated) {
        if (memberLogic.finishEditable()) {
          gEnSound.playAudio(AudioKind.backwardSelection);
          browseLogic.routeToBrowseAll();
        }
      }
    },
    child: Obx(() {
      return Padding(
        padding: EdgeInsets.only(
          left: _rxPadLeft.value,
          right: _rxPadRight.value,
          top: Constants.cTinyGap,
          bottom: Constants.cTinyGap,
        ),
        child: Card(
            elevation: Constants.cSmallGap,
            child: Padding(
              padding: const EdgeInsets.all(Constants.cTinyGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: memberIdPlate(member, context: context),
                  ),
                  Row(
                    children: [
                      if ((member != gCurrentEnclave.mySelf) && !gEnUtil.isDummyDataString(member.mobilePhone))
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    icon: const Icon(MdiIcons.phoneOutgoingOutline, color: Colors.blueGrey),
                                    highlightColor: Theme.of(context).colorScheme.secondary,
                                    iconSize: Constants.cMediumIconSize,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      await gEnDialog.callPhone(gEnUtil.stringToFormalKoreanLocalPhoneNumber(member.mobilePhone), member.personName);
                                    }),
                                const SizedBox(height: Constants.cSmallGap),
                                IconButton(
                                    icon: const Icon(MdiIcons.phoneMessageOutline, color: Colors.blueGrey),
                                    highlightColor: Theme.of(context).colorScheme.secondary,
                                    iconSize: Constants.cMediumIconSize,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      await gEnDialog.sendSms([member.mobilePhone], member.personName);
                                    }),
                              ],
                            ),
                            const SizedBox(width: Constants.cMediumGap),
                          ],
                        ),
                      InkWell(
                        onTap: _onClickProfileImage,
                        child: Obx(
                          () => memberLogic.isProfileChanged
                              ? EnclaveAvatar(
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  statusColor: Colors.red[200],
                                  image: member.profileImage ?? (member.fullImage ?? EnclaveRepository.getAssetImageProfile),
                                  fit: BoxFit.fitHeight,
                                )
                              : EnclaveAvatar(
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  image: member.profileImage ?? EnclaveRepository.getAssetImageProfile,
                                  fit: BoxFit.fitHeight,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      );
    }),
  );
}

Widget memberIdPlate(EnMember member, {required BuildContext context}) {
  final nameField = gCurrentEnclave.findFieldByName(EnMember.personName_);
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      if (nameField != null)
        memberFieldDisplay(
          field: nameField,
          hideEmptyData: gAppSetting.rxPrefHideEmptyData.value,
        ),
      mobilePhoneField(),
    ],
  );
}

Widget memberFieldListView({required bool hideEmptyData}) {
  final selectedMember = memberLogic.selectedMember;

  //----------------------------------------------------------------------------------------
  List<Widget> displayMemberField(EnField field) {
    final fieldName = field.fieldName;

    // skip index, name & mobilePhone: they are already displayed in profile card, or not needed
    if ((fieldName == Constants.keyIndex) || (fieldName == Constants.keyPersonName) || (fieldName == Constants.keyMobilePhone)) {
      return [const SizedBox.shrink()];
    }

    // empty values are not to be displayed
    final fieldValue = selectedMember.findFieldDisplayValue(field);

    if (hideEmptyData && fieldValue.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final displayFieldName = field.displayTerm;

    //----------------------------------------------------------------------------
    Map<String, List<EnMember>?> distinctMap = {};
    List<EnMember>? distinctMembers;
    Future<EnField?> _getDistinctMembers(String fieldName, String fieldValue) async {
      final distinct = gCurrentEnclave.findDistinct(fieldName);
      if (distinct != null) {
        distinctMembers = gCurrentEnclave.getMembersByFieldExactValue(fieldName: fieldName, exactValue: fieldValue);
        distinctMap[fieldName] = distinctMembers;
      }
      return distinct;
    }

    return <Widget>[
      Obx(() {
        return memberFieldDisplay(field: field, hideEmptyData: hideEmptyData);
      }),
      // if empty distinct value, do not display distinct members
      if (fieldValue.isNotEmpty)
        FutureBuilder(
          future: _getDistinctMembers(fieldName, fieldValue),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('errorGetDistinct'.tr + '\n' + snapshot.error.toString()));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              final members = distinctMap[fieldName];
              if (members == null || members.isEmpty) {
                return const SizedBox.shrink();
              } else {
                return DistinctSelector(
                  distinctValue: fieldValue,
                  distinctTerm: field.displayTerm,
                  members: members,
                );
              }
            }
            return viewWaiting(context);
          },
        ),
    ];
  }
  //----------------------------------------------------------------------------------------

  final memberFields = gCurrentEnclave.fields;

  return Container(
    padding: const EdgeInsets.only(left: Constants.cSmallGap, right: Constants.cTinyGap),
    child: ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: memberFields.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: displayMemberField(memberFields[index]),
        );
      },
    ),
  );
}

/// display found members with span onClick
Column displayFoundMembers({required EnField field, required String searchTerm, required List<EnMember> members}) {
  return Column(
    children: <Widget>[
      viewTipText('noticeClickNameToMove'.tr),
      memberFieldDisplay(fieldDisplayTerm: searchTerm, fieldValue: '(${members.length.toString()} ${"termCountPersons".tr})', hideEmptyData: false),
      DistinctSelector(members: members, distinctTerm: field.displayTerm, distinctValue: searchTerm),
    ],
  );
}

Widget distinctSlidingChips() {
  List<Widget> chips = [];

  if (gCurrentEnclave.distinctFields.isEmpty) {
    debugger(when: testingStopDebugger);
    return const SizedBox.shrink();
  }

  for (int index = 0; index < gCurrentEnclave.distinctFields.length; index++) {
    final distinctField = gCurrentEnclave.distinctFields[index];
    final label = distinctField.displayTerm;

    Widget item = Padding(
      padding: const EdgeInsets.only(left: Constants.cMediumGap, right: Constants.cMediumGap),
      child: Obx(
        () => ChoiceChip(
          labelPadding: const EdgeInsets.all(0),
          avatar: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              label[0].toUpperCase(),
              style: TextStyle(color: Colors.black, fontSize: Constants.cMediumFontSizeFix),
            ),
          ),
          label: Text(label, style: TextStyle(color: Colors.white, fontSize: Constants.cSmallFontSizeFix)),
          backgroundColor: gEnUtil.stringToColor(label),
          elevation: Constants.cSmallGap,
          shadowColor: Colors.grey[60],
          padding: const EdgeInsets.all(Constants.cTinyGap),
          selected: distinctField == distinctLogic.selectedDistinct,
          onSelected: (bool value) {
            if (!memberLogic.finishEditable()) return;
            onClickDistinctChip(distinctField);
            Get.toNamed(distinctRoute);
          },
          selectedColor: Colors.blue[900],
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
    chips.add(item);
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Container(
      color: Colors.black87,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: chips,
      ),
    ),
  );
}

Widget browsableText(String urlAddress) {
  final urlSpan = TextSpan(
    text: urlAddress,
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        if (!memberLogic.finishEditable()) return;
        gEnUtil.launchURL(urlAddress);
      },
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Constants.cMediumFontSize,
      decoration: TextDecoration.underline,
      color: Theme.of(memberLogic.contextMember).colorScheme.secondary,
    ),
  );

  return SelectableText.rich(
    TextSpan(
      children: [urlSpan],
    ),
  );
}

/// An object to set the member collection data source to the dataGrid.
/// This is used to map the member data to the dataGrid widget.
class MemberInfoSource extends DataGridSource {
  /// Based on the new value we will commit the new value into the corresponding DataGridCell on onCellSubmit method.
  dynamic newCellValue;

  TextEditingController editingController = TextEditingController();
  List<DataGridRow> infoGridRows = [];
  final fields = gCurrentEnclave.fields;

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    // find member & field
    final member = memberLogic.selectedMember;
    final field = gCurrentEnclave.fields[rowColumnIndex.rowIndex];

    // check if field value is same or not
    final int dataRowIndex = infoGridRows.indexOf(dataGridRow);
    if (newCellValue == null || member.isFieldValueSame(field: field, newFieldValue: newCellValue)) {
      return;
    }

    // change member's field value
    memberLogic.selectedMember.updateFieldValue(field: field, fieldValue: newCellValue);

    // change member's field value
    infoGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] = DataGridCell<String>(columnName: column.columnName, value: newCellValue);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    final field = gCurrentEnclave.fields[rowColumnIndex.rowIndex];

    // Text going to display on editable widget
    final String displayText = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value?.toString() ?? '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: field.isPhone ? TextInputType.phone : TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            newCellValue = value;
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // In Mobile Platform.
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  MemberInfoSource() {
    final member = memberLogic.selectedMember;
    infoGridRows = fields
        .map<DataGridRow>((field) => DataGridRow(cells: [
              DataGridCell<String>(
                columnName: Constants.keyField,
                value: field.displayTerm,
              ),
              DataGridCell<String>(
                columnName: Constants.keyValue,
                value: member.findFieldDisplayValue(field),
              ),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => infoGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((memberGridCell) {
      bool isFieldName = memberGridCell.columnName == Constants.keyField;

      return Container(
        alignment: isFieldName ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.all(Constants.cSmallGap),
        color: isFieldName ? Theme.of(memberLogic.contextMember).colorScheme.background : null,
        child: Text(
          memberGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
          style: isFieldName ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
      );
    }).toList());
  }

  void updateMemberGridSource() {
    notifyListeners();
  }
}
