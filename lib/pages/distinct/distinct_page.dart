import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/data/en_field.dart';
import 'package:enclave/shared/common_ui.dart';
import 'package:enclave/shared/enclave_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/constants.dart';
import '../../enclave_app.dart';
import '../../pages/member/member_page.dart';
import '../../shared/distinct_selector.dart';
import '../../shared/enclave_menu.dart';
import 'distinct_logic.dart';
import 'distinct_state.dart';

///
/// Page for Distinct
///

class DistinctPage extends StatelessWidget {
  final DistinctLogic logic = Get.find<DistinctLogic>();
  final DistinctState state = Get.find<DistinctLogic>().state;

  DistinctPage({Key? key}) : super(key: key);
  final distincts = gCurrentEnclave.distinctFields;

  Widget _distinctDisplay(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom + 10;

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: <Widget>[
          Expanded(
            child: InteractiveViewer(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: Constants.cTinyTinyGap, right: Constants.cTinyTinyGap, top: Constants.cTinyTinyGap, bottom: bottomPadding),
                child: Obx(() {
                  return FutureBuilder(
                    future: logic.changedSelectedDistinct(logic.selectedDistinct ?? (distincts.isEmpty ? null : distincts[0])),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('errorDistinctInitialization'.tr + '\n' + snapshot.error.toString()));
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        return viewDistinctList();
                      }
                      return viewWaiting(context, notice: 'noticeInitializingDistinct'.tr);
                    },
                  );
                }),
              ),
            ),
          ),
          distinctSlidingChips(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(logic.rxDistinctPageTitle.value)),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: _distinctDisplay(context),
      ),
    );
  }
}

Widget distinctProfile() {
  final distincts = gCurrentEnclave.distinctFields;
  if (distincts.isEmpty) {
    return Text('noticeNoDistinctInEnclave'.tr);
  }

  return Wrap(
    spacing: 2,
    direction: Axis.horizontal,
    children: distinctChips(),
  );
}

List<Widget> distinctChips() {
  final distincts = gCurrentEnclave.distinctFields;
  if (distincts.isEmpty) {
    return [Text('noticeNoDistinctInEnclave'.tr)];
  }

  List<Widget> chips = [];
  for (int i = 0; i < distincts.length; i++) {
    final label = distincts[i].displayTerm;

    Widget item = Padding(
      padding: const EdgeInsets.only(left: Constants.cTinyTinyGap, right: Constants.cTinyTinyGap),
      child: Obx(
        () => ChoiceChip(
          labelPadding: const EdgeInsets.all(0),
          avatar: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(label[0].toUpperCase(), style: TextStyle(color: Colors.black, fontSize: Constants.cMediumFontSize)),
          ),
          label: Text(label, style: const TextStyle(color: Colors.white)),
          backgroundColor: gEnUtil.stringToColor(distincts[i].displayTerm),
          elevation: Constants.cSmallGap,
          shadowColor: Colors.grey[60],
          padding: const EdgeInsets.all(Constants.cTinyGap),
          selected: distincts[i] == distinctLogic.selectedDistinct,
          onSelected: (bool value) {
            onClickDistinctChip(distincts[i]);
          },
          selectedColor: Colors.blue[900],
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
    chips.add(item);
  }
  return chips;
}

List<Widget> buildDistinctChips() {
  List<Widget> result = [];
  final distincts = gCurrentEnclave.distinctFields;
  for (var distinct in distincts) {
    result.add(_buildChip(distinct));
  }
  return result;
}

void onClickDistinctChip(EnField distinct) {
  distinctLogic.assignDistinct(distinct);
}

Widget _buildChip(EnField distinct) {
  final label = distinct.displayTerm;
  Color color = gEnUtil.stringToColor(distinct.displayTerm);

  return ChoiceChip(
    labelPadding: const EdgeInsets.all(Constants.cTinyTinyGap),
    avatar: CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(label[0].toUpperCase(), style: const TextStyle(color: Colors.black)),
    ),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    backgroundColor: color,
    elevation: Constants.cHugeGap,
    shadowColor: Colors.grey[60],
    padding: const EdgeInsets.all(Constants.cTinyGap),
    selected: distinct == distinctLogic.selectedDistinct,
    onSelected: (bool value) {
      onClickDistinctChip(distinct);
    },
  );
}

Widget chipList() {
  final distincts = gCurrentEnclave.distinctFields;
  if (distincts.isEmpty) {
    return Text('noticeNoDistinctInEnclave'.tr);
  }

  return Wrap(
    spacing: 6.0,
    runSpacing: 6.0,
    children: buildDistinctChips(),
  );
}
