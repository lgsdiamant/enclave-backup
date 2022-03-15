import 'dart:math' as math;
import 'dart:math';

import 'package:enclave/data/constants.dart';
import 'package:enclave/data/en_enclave.dart';
import 'package:enclave/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../data/constants.dart';
import '../enclave_app.dart';
import '../router/router.dart';

///
/// Enclave Common Drawer
///
Drawer enclaveDrawerUser(BuildContext context) {
  return Drawer(
    child: Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: userDrawerItems(context),
      ),
    ),
  );
}

Drawer enclaveDrawerAdmin(BuildContext context) {
  return Drawer(
    child: Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: adminDrawerItems(context),
      ),
    ),
  );
}

Drawer enclaveDrawerSystem(BuildContext context) {
  return Drawer(
    child: Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: systemDrawerItems(context),
      ),
    ),
  );
}

List<Widget> userDrawerItems(BuildContext context) {
  return <Widget>[
    Obx(() => enclaveDrawerHeader()),
    enclaveDrawerTile(context, Icons.info, 'titleAboutPage'.tr, onClick: () => {Get.toNamed(aboutRoute)}),
    enclaveDrawerTile(context, MdiIcons.accountGroupOutline, 'titleEnclaveLoginPage'.tr, onClick: () => {Get.toNamed(loginRoute)}),
    enclaveDrawerTile(context, MdiIcons.cogOutline, 'titleSettingPage'.tr, onClick: () => {Get.toNamed(settingRoute)}),
    enclaveDrawerTile(context, MdiIcons.bulletinBoard, 'titleBulletinPage'.trParams({'enclave': gCurrentEnclave.nameSub}), onClick: () => {Get.toNamed(bulletinRoute)}),
    enclaveDrawerTile(context, MdiIcons.formatListText, 'titleBrowseAll'.tr, onClick: () => {browseLogic.routeToBrowseAll()}),
    enclaveDrawerTile(context, MdiIcons.accountBoxMultipleOutline, 'titleDistinctPage'.tr, onClick: () => {Get.toNamed(distinctRoute)}),
    enclaveDrawerTile(context, MdiIcons.lan, 'titleBoardPage'.tr, onClick: () => {Get.toNamed(boardRoute)}),
    enclaveDrawerTile(context, MdiIcons.formatListNumbered, 'titleRegulationPage'.tr, onClick: () => {Get.toNamed(regulationRoute)}),
//??    enclaveDrawerTile(context, MdiIcons.accountVoice, 'titleContactPage'.tr, onClick: () => {Get.toNamed(contactRoute)}),
//??    enclaveDrawerTile(context, MdiIcons.web, 'titleUrlPage'.tr, onClick: () => {Get.toNamed(urlRoute)}),
  ];
}

List<Widget> adminDrawerItems(BuildContext context) {
  return <Widget>[
    ...userDrawerItems(context),
    const Divider(thickness: 1.0),
    enclaveDrawerTile(context, MdiIcons.accountCheckOutline, 'titleAdminPage'.tr, onClick: () => {Get.toNamed(adminRoute)}),
  ];
}

List<Widget> systemDrawerItems(BuildContext context) {
  return <Widget>[
    ...adminDrawerItems(context),
    const Divider(thickness: 1.0),
    enclaveDrawerTile(context, MdiIcons.accountSupervisorCircleOutline, 'titleSystemPage'.tr, onClick: () => {Get.toNamed(systemRoute)}),
  ];
}

/// Drawer Header
Widget enclaveDrawerHeader() {
  final String enclaveFullNameStr = gCurrentEnclave.enclaveNameFullAndSub();
  final String personNameStr = gCurrentEnclave.mySelf.personName;
  final String personFullTitleStr = gCurrentEnclave.mySelf.oneLineDescription();

  return EnclaveDrawerHeader(
    // showing current account picture
    personPicture: InkWell(
      onTap: () async {
        memberLogic.routeToMemberPage(selectedMember: gCurrentEnclave.mySelf);
      },
      child: CircleAvatar(
        backgroundImage: gCurrentEnclave.mySelf.profileImage ?? EnclaveRepository.getAssetImageProfile,
      ),
    ),

    // showing enclave picture
    enclavePicture: InkWell(
      onTap: () async {
        // move to loginPage, which will display selectable enclaves
        Get.toNamed(loginRoute);
      },
      child: CircleAvatar(
        backgroundImage: EnclaveRepository.getAssetEnclaveIcon,
      ),
    ),

    // showing enclave full name
    enclaveName: enclaveFullNameStr.isEmpty ? null : Text(enclaveFullNameStr),

    // showing mySelf name
    personName: personNameStr.isEmpty ? null : Text(personNameStr),

    // showing mySelf full title
    personTitle: personFullTitleStr.isEmpty ? null : Text(personFullTitleStr),

    // with decoration
    decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(Constants.cHugeGap),
          bottomRight: Radius.circular(Constants.cHugeGap),
        )),
  );
}

ListTile enclaveDrawerTile(BuildContext context, IconData icon, String text, {Callback? onClick}) {
  TextStyle _tileTextStyle = TextStyle(
    fontSize: Constants.cMediumFontSizeFix,
  );

  return ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: Constants.cMediumIconSize),
    title: Text(text, style: _tileTextStyle),
    onTap: () {
      // To close the Drawer
      Navigator.pop(context);

      // take an action
      onClick!();
    },
  );
}

class _EnclaveAccountPictures extends StatelessWidget {
  const _EnclaveAccountPictures({
    Key? key,
    this.personPicture,
    this.enclavePicture,
    this.personPictureSize,
    this.enclavePicturesSize,
    required this.enclaveName,
  }) : super(key: key);

  final Widget? personPicture;
  final Widget? enclavePicture;
  final Size? personPictureSize;
  final Size? enclavePicturesSize;
  final Widget? enclaveName;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          end: 0.0,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    DefaultTextStyle(
                      style: theme.primaryTextTheme.bodyText1!,
                      overflow: TextOverflow.ellipsis,
                      child: DefaultTextStyle(
                        style: theme.primaryTextTheme.bodyText1!,
                        overflow: TextOverflow.ellipsis,
                        child: Text(
                          mainLogic.enclaveVersionFullString,
                          style: TextStyle(
                            fontSize: Constants.cTinyFontSizeFix,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      container: true,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: SizedBox.fromSize(
                          size: enclavePicturesSize,
                          child: enclavePicture,
                        ),
                      ),
                    ),
                  ],
                ),
                if (enclaveName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: DefaultTextStyle(
                      style: theme.primaryTextTheme.bodyText1!,
                      overflow: TextOverflow.ellipsis,
                      child: enclaveName!,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          child: Semantics(
            explicitChildNodes: true,
            child: SizedBox.fromSize(
              size: personPictureSize,
              child: personPicture,
            ),
          ),
        ),
      ],
    );
  }
}

class _EnclaveAccountDetails extends StatefulWidget {
  const _EnclaveAccountDetails({
    Key? key,
    required this.personName,
    required this.personTitle,
    this.onTap,
    required this.isOpen,
    this.arrowColor,
  }) : super(key: key);

  final Widget? personName;
  final Widget? personTitle;
  final VoidCallback? onTap;
  final bool isOpen;
  final Color? arrowColor;

  @override
  _EnclaveAccountDetailsState createState() => _EnclaveAccountDetailsState();
}

class _EnclaveAccountDetailsState extends State<_EnclaveAccountDetails> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn.flipped,
    )..addListener(() => setState(() {
          // [animation]'s value has changed here.
        }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_EnclaveAccountDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the state of the arrow did not change, there is no need to trigger the animation
    if (oldWidget.isOpen == widget.isOpen) {
      return;
    }

    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    Widget accountDetails = CustomMultiChildLayout(
      delegate: _EnclaveAccountDetailsLayout(
        textDirection: Directionality.of(context),
      ),
      children: <Widget>[
        if (widget.personName != null)
          LayoutId(
            id: _EnclaveAccountDetailsLayout.personName,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyText1!,
                overflow: TextOverflow.ellipsis,
                child: widget.personName!,
              ),
            ),
          ),
        if (widget.personTitle != null)
          LayoutId(
            id: _EnclaveAccountDetailsLayout.personTitle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyText2!,
                overflow: TextOverflow.ellipsis,
                child: widget.personTitle!,
              ),
            ),
          ),
        if (widget.onTap != null)
          LayoutId(
            id: _EnclaveAccountDetailsLayout.dropdownIcon,
            child: Semantics(
              container: true,
              button: true,
              onTap: widget.onTap,
              child: SizedBox(
                height: _kEnclaveAccountDetailsHeight,
                width: _kEnclaveAccountDetailsHeight,
                child: Center(
                  child: Transform.rotate(
                    angle: _animation.value * math.pi,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: widget.arrowColor,
                      semanticLabel: widget.isOpen ? localizations.hideAccountsLabel : localizations.showAccountsLabel,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.onTap != null) {
      accountDetails = InkWell(
        onTap: widget.onTap,
        excludeFromSemantics: true,
        child: accountDetails,
      );
    }

    return SizedBox(
      height: _kEnclaveAccountDetailsHeight,
      child: accountDetails,
    );
  }
}

const double _kEnclaveAccountDetailsHeight = 56.0;

class _EnclaveAccountDetailsLayout extends MultiChildLayoutDelegate {
  _EnclaveAccountDetailsLayout({required this.textDirection});

  static const String personName = 'personName';
  static const String personTitle = 'personTitle]';
  static const String dropdownIcon = 'dropdownIcon';

  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    Size? iconSize;
    if (hasChild(dropdownIcon)) {
      // place the dropdown icon in bottom right (LTR) or bottom left (RTL)
      iconSize = layoutChild(dropdownIcon, BoxConstraints.loose(size));
      positionChild(dropdownIcon, _offsetForIcon(size, iconSize));
    }

    final String? bottomLine = hasChild(personTitle) ? personTitle : (hasChild(personName) ? personName : null);

    if (bottomLine != null) {
      final Size constraintSize = iconSize == null ? size : Size(size.width - iconSize.width, size.height);
      iconSize ??= const Size(_kEnclaveAccountDetailsHeight, _kEnclaveAccountDetailsHeight);

      // place bottom line center at same height as icon center
      final Size bottomLineSize = layoutChild(bottomLine, BoxConstraints.loose(constraintSize));
      final Offset bottomLineOffset = _offsetForBottomLine(size, iconSize, bottomLineSize);
      positionChild(bottomLine, bottomLineOffset);

      // place account name above account email
      if (bottomLine == personTitle && hasChild(personName)) {
        final Size nameSize = layoutChild(personName, BoxConstraints.loose(constraintSize));
        positionChild(personName, _offsetForName(size, nameSize, bottomLineOffset));
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;

  Offset _offsetForIcon(Size size, Size iconSize) {
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(size.width - iconSize.width, size.height - iconSize.height);
      case TextDirection.rtl:
        return Offset(0.0, size.height - iconSize.height);
    }
  }

  Offset _offsetForBottomLine(Size size, Size iconSize, Size bottomLineSize) {
    final double y = size.height - 0.5 * iconSize.height - 0.5 * bottomLineSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - bottomLineSize.width, y);
    }
  }

  Offset _offsetForName(Size size, Size nameSize, Offset bottomLineOffset) {
    final double y = bottomLineOffset.dy - nameSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - nameSize.width, y);
    }
  }
}

/// A material design [Drawer] header that identifies the app's user.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [DrawerHeader], for a drawer header that doesn't show user accounts.
///  * <https://material.io/design/components/navigation-drawer.html#anatomy>
class EnclaveDrawerHeader extends StatefulWidget {
  /// Creates a material design drawer header.
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const EnclaveDrawerHeader({
    Key? key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.personPicture,
    this.enclavePicture,
    this.personPictureSize = const Size.square(72.0),
    this.enclavePictureSize = const Size.square(40.0),
    required this.enclaveName,
    required this.personName,
    required this.personTitle,
    this.onDetailsPressed,
    this.arrowColor = Colors.white,
  }) : super(key: key);

  /// The header's background. If decoration is null then a [BoxDecoration]
  /// with its background color set to the current theme's primaryColor is used.
  final Decoration? decoration;

  /// The margin around the drawer header.
  final EdgeInsetsGeometry? margin;

  /// A widget placed in the upper-left corner that represents the current
  /// user's account. Normally a [CircleAvatar].
  final Widget? personPicture;

  /// A list of widgets that represent the current user's other accounts.
  /// Up to three of these widgets will be arranged in a row in the header's
  /// upper-right corner. Normally a list of [CircleAvatar] widgets.
  final Widget? enclavePicture;

  /// The size of the [personPicture].
  final Size personPictureSize;

  /// The size of each widget in [enclavePictureSize].
  final Size enclavePictureSize;

  /// A widget that represents the user's current account name. It is
  /// displayed on the left, below the [personPicture].
  final Widget? enclaveName;

  /// A widget that represents the user's current account name. It is
  /// displayed on the left, below the [personPicture].
  final Widget? personName;

  /// A widget that represents the email address of the user's current account.
  /// It is displayed on the left, below the [personName].
  final Widget? personTitle;

  /// A callback that is called when the horizontal area which contains the
  /// [personName] and [personTitle] is tapped.
  final VoidCallback? onDetailsPressed;

  /// The [Color] of the arrow icon.
  final Color arrowColor;

  @override
  State<EnclaveDrawerHeader> createState() => _EnclaveDrawerHeaderState();
}

class _EnclaveDrawerHeaderState extends State<EnclaveDrawerHeader> {
  bool _isOpen = false;

  void _handleDetailsPressed() {
    setState(() {
      _isOpen = !_isOpen;
    });
    widget.onDetailsPressed!();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return Semantics(
      container: true,
      label: MaterialLocalizations.of(context).signedInLabel,
      child: DrawerHeader(
        decoration: widget.decoration ??
            BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
        margin: widget.margin,
        padding: const EdgeInsetsDirectional.only(top: 16.0, start: 16.0),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16.0),
                  child: _EnclaveAccountPictures(
                    personPicture: widget.personPicture,
                    enclavePicture: widget.enclavePicture,
                    personPictureSize: widget.personPictureSize,
                    enclavePicturesSize: widget.enclavePictureSize,
                    enclaveName: widget.enclaveName,
                  ),
                ),
              ),
              _EnclaveAccountDetails(
                personName: widget.personName,
                personTitle: widget.personTitle,
                isOpen: _isOpen,
                onTap: widget.onDetailsPressed == null ? null : _handleDetailsPressed,
                arrowColor: widget.arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Offset utility extension.
extension OffsetUtils on Offset {
  /// Returns Offset based on [angle] and [radius].
  static Offset angleToOffset(double angle, {double radius = 0.0}) {
    return Offset(
      radius * sin(pi * 2 * angle / 360) + radius,
      radius * -cos(pi * 2 * angle / 360) + radius,
    );
  }
}
