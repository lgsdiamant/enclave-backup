import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/constants.dart';
import '../../pages/member/member_page.dart';
import '../data/en_member.dart';
import '../enclave_app.dart';
import '../pages/setting/setting_logic.dart';
import 'common_ui.dart';
import 'enclave_sound.dart';
import 'enclave_utility.dart';

class DistinctSelector extends StatelessWidget {
  final List<EnMember> members;
  final String distinctTerm;
  final String distinctValue;

  const DistinctSelector({
    Key? key,
    required this.members,
    required this.distinctTerm,
    required this.distinctValue,
  }) : super(key: key);

  /// handle click on person name
  void onClickMemberName(EnMember member) async {
    memberLogic.routeToMemberPage(selectedMember: member);
  }

  TextSpan singleMemberSpanSelectedNoClick(EnMember member) {
    return TextSpan(
      text: member.personName,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: Constants.cMediumFontSize,
        decoration: TextDecoration.underline,
        color: Theme.of(memberLogic.contextMember).colorScheme.secondary,
      ),
    );
  }

  TextSpan singleMemberSpanOnClick(EnMember member, {VoidCallbackGeneric<EnMember>? onClick}) {
    return TextSpan(
      text: member.personName,
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          if (!memberLogic.finishEditable()) return;
          if (onClick != null) onClick(member);
        },
      style: Constants.textStyleSpanned,
    );
  }

  /// TextSpan for given single person_name
  /// onClick, the member page will be changed for the specific member
  TextSpan singleMemberSpan(EnMember member) {
    final selected = memberLogic.selectedMember;
    if ((selected != EnMember.dummyMember) && member.getIndex == selected.getIndex) {
      return singleMemberSpanSelectedNoClick(member);
    }
    return singleMemberSpanOnClick(member, onClick: onClickMemberName);
  }

  /// span just text
  TextSpan justTextSpan(String text) {
    return TextSpan(
      text: text,
      style: Constants.textStyleSpanned,
    );
  }

  /// spans members name with selected
  List<TextSpan> membersNameSpans(List<EnMember> members, {EnMember? selected}) {
    List<TextSpan> memberNameSpans = [singleMemberSpan(members[0])];

    for (var i = 1; i < members.length; i++) {
      memberNameSpans.add(justTextSpan(', '));
      memberNameSpans.add(singleMemberSpan(members[i]));
    }
    return memberNameSpans;
  }

  @override
  Widget build(BuildContext context) {
    final _rxPadLeft = Rx<double>(Constants.cSmallGap);
    final _rxPadRight = Rx<double>(0.0);
    double deltaSum = 0;
    bool activated = false;

    //----------------------------------------------------------
    _backToPadding() {
      _rxPadLeft.value = Constants.cSmallGap;
      _rxPadRight.value = 0.0;
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (!activated) {
          _backToPadding();
        }
      },
      onLongPress: () {
        if (memberLogic.finishEditable()) {
          browseLogic.routeToBrowseSubgroup(distinctTerm: distinctTerm, distinctValue: distinctValue, members: members);
        }
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.delta.dx;
        if (delta < 0) {
          deltaSum += delta / 2;
        }
        final offset = max(deltaSum, -Constants.cSmallGap);
        _rxPadLeft.value = Constants.cSmallGap + offset;
        _rxPadRight.value = -offset;
        if (deltaSum <= 0) {
          activated = offset == -Constants.cSmallGap;
        }

        if (activated) {
          if (memberLogic.finishEditable()) {
            if (gAppSetting.canVibrate) {
              Vibrate.feedback(FeedbackType.selection);
            }
            gEnSound.playAudio(AudioKind.backwardSelection);
            browseLogic.routeToBrowseSubgroup(distinctTerm: distinctTerm, distinctValue: distinctValue, members: members);
          }
        }
      },
      child: Obx(() {
        return Padding(
          padding: EdgeInsets.only(left: _rxPadLeft.value, right: _rxPadRight.value),
          child: Card(
            shadowColor: Theme.of(context).colorScheme.background,
            elevation: Constants.cMediumGap,
            margin: const EdgeInsets.only(top: Constants.cTinyGap, bottom: Constants.cTinyGap),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(Constants.cTinyGap),
              child: SingleChildScrollView(
                child: Obx(() {
                  return SelectableText.rich(
                    TextSpan(
                      children: membersNameSpans(members),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// displays single of distinctField
Widget viewDistinctField({required String distinctValue, required List<EnMember> members}) {
  return gEnUtil.isDummyDataString(distinctValue)
      ? const SizedBox.shrink()
      : Column(
          children: <Widget>[
            memberFieldDisplay(fieldDisplayTerm: distinctValue, fieldValue: '${members.length.toString()} ${"termCountPersons".tr}', hideEmptyData: false),
            Row(
              children: <Widget>[
                const SizedBox(width: Constants.cBigGap),
                Expanded(
                  child: DistinctSelector(
                    members: members,
                    distinctTerm: distinctLogic.currentDistinct.displayTerm,
                    distinctValue: distinctValue,
                  ),
                )
              ],
            ),
          ],
        );
}

/// displays list of distinctFieldView based on distinctViewModel
Widget viewDistinctList() {
  return Container(
    padding: const EdgeInsets.only(left: Constants.cSmallGap, right: Constants.cTinyGap),
    child: ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: distinctLogic.distinctMembersList.length,
      itemBuilder: (BuildContext context, int index) {
        return viewDistinctField(
          distinctValue: distinctLogic.distinctValues[index],
          members: distinctLogic.distinctMembersList[index],
        );
      },
    ),
  );
}
