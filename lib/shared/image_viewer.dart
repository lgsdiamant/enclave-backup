import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';

import '../data/en_member.dart';
import 'common_ui.dart';

class FullImageViewer extends StatelessWidget {
  const FullImageViewer({Key? key, this.title, required this.image}) : super(key: key);

  final String? title;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'termImage'.tr),
      ),
      body: SafeArea(
        child: (image != null)
            ? PhotoView(
                imageProvider: image,
              )
            : const FittedBox(
                child: Icon(
                  MdiIcons.fileImageRemoveOutline,
                ),
              ),
      ),
    );
  }
}

class ProfileImageViewer extends StatelessWidget {
  const ProfileImageViewer({Key? key, required this.member}) : super(key: key);

  final EnMember member;

  @override
  Widget build(BuildContext context) {
    final title = member.personName;
    final rxIsProfile = Rx<bool>(true);

    return FutureBuilder(
      future: rxIsProfile.value ? member.getProfileImage() : member.getFullImage(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('errorImageInitialization'.tr + '\n' + snapshot.error.toString()),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          final image = rxIsProfile.value ? member.profileImage : member.fullImage;
          return FullImageViewer(title: title, image: image);
        }
        return Center(child: viewWaiting(context));
      },
    );
  }
}
