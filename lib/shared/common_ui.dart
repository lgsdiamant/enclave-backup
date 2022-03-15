import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../data/constants.dart';
import '../data/en_member.dart';
import '../data/repository.dart';
import 'enclave_avatar.dart';
import 'image_viewer.dart';

//region: TYPEDEF
//===========================================================
typedef VoidCallbackGeneric<T> = void Function(T foo);
typedef MapDynamic = Map<String, dynamic>;
//===========================================================
//endregion: TYPEDEF

//region: PROGRESS INDICATOR
//===========================================================
Widget viewWaiting(BuildContext context, {String? notice}) {
  return Column(
    children: [
      SizedBox(
          child: defaultTargetPlatform == TargetPlatform.iOS ? const CupertinoActivityIndicator() : CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          height: Constants.cHugeHugeHugeGap,
          width: Constants.cHugeHugeHugeGap),
      if (notice != null) Text(notice),
    ],
  );
}

Widget viewWaitingSplash(BuildContext context) {
  const logoHeight = 160.0;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Image(image: EnclaveRepository.getAssetEnclaveLogo, height: logoHeight),
      viewWaiting(context),
    ],
  );
}
//===========================================================
//endregion: PROGRESS INDICATOR

//region: UTIL
//===========================================================
Widget viewTipText(String help) {
  return Row(
    children: [
      const Icon(MdiIcons.gestureTap),
      Expanded(
        child: Text(
          help,
          style: TextStyle(fontSize: Constants.cSmallFontSize),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
//===========================================================
//endregion: UTIL

//region: Image
//===========================================================
Widget profileAvatar({required EnMember member, double? size}) {
  size = size ?? Constants.cSmallAvatarSize;
  return InkWell(
    onTap: () {
      Get.to(() => ProfileImageViewer(member: member));
    },
    child: EnclaveAvatar(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      image: member.profileImage,
      size: size,
    ),
  );
}

Widget clickableImage({required ImageProvider image, double? width, double? height}) {
  if ((width == null) && (height == null)) width = 100.0;
  final fit = (width != null) ? BoxFit.fitWidth : BoxFit.fitHeight;

  return InkWell(
    onTap: () {
      Get.to(() => FullImageViewer(image: image));
    },
    child: Image(
      image: image,
      fit: fit,
      width: width,
      height: height,
    ),
  );
}
//===========================================================
//endregion: Image
