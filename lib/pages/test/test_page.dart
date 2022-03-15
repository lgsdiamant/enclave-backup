import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/helper_asset.dart';
import '../../enclave_app.dart';
import '../../shared/enclave_drawer.dart';
import '../../shared/enclave_menu.dart';
import 'test_logic.dart';

class TestPage extends StatelessWidget {
  TestPage({Key? key}) : super(key: key);

  final logic = Get.put(TestLogic());
  final state = Get.find<TestLogic>().state;

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Test Page'),
          actions: gEnMenu.actionsDefault(),
        ),
        drawer: enclaveDrawerUser(context),
        onDrawerChanged: (isOpen) {
          if (!memberLogic.finishEditable()) return;
        },
        body: const SafeArea(
          child: TestDisplayHolder(),
        ),
        // body: const MemberDisplayHolder(),
      ),
    );
  }
}

class TestDisplayHolder extends StatelessWidget {
  const TestDisplayHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'Flutter is'),
          const TextSpan(text: '\n'),
          WidgetSpan(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image(
                image: AssetHelper.assetImageProfile,
                width: 100,
                height: 100,
              ),
            ),
          ),
          const TextSpan(text: '\n'),
          WidgetSpan(
            child: Image(
              image: AssetHelper.assetImageProfile,
              width: 50,
              height: 50,
            ),
          ),
          const TextSpan(text: '\n'),
          WidgetSpan(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetHelper.assetImageProfile,
                width: 50,
                height: 50,
              ),
            ),
          ),
          const TextSpan(text: '\n'),
          const TextSpan(text: 'the best!'),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
    );
  }
}

// clickableImage(
// image: AssetHelper.assetImageEnclaveLogo,
// )
