import 'package:flutter/cupertino.dart';

import 'en_data.dart';

class EnBulletinMessage extends EnData {
  static const uuid_ = 'uuid';
  static const title_ = 'title';
  static const content_ = 'content';
  static const generated_ = 'generated';
  static const modified_ = 'modified';
  static const personName_ = 'personName';
  static const personId_ = 'personId';
  static const readCount_ = 'readCount';
  static const imageUrl_ = 'imageUrl';
  static const isNotice_ = 'isNotice';

  @override
  int get getIndex => -1;

  String uuid;
  String title;
  List<String> content;
  int generated;
  int modified;
  String personName;
  int personId;
  int readCount;
  String imageUrl;
  bool isNotice;

  // extra
  ImageProvider? image;

  EnBulletinMessage({
    required this.uuid,
    required this.title,
    required this.content,
    required this.generated,
    required this.modified,
    required this.personName,
    required this.personId,
    required this.readCount,
    String? imageUrl = '',
    required this.isNotice,
  }) : imageUrl = imageUrl ?? '';

  @override
  Map<String, dynamic> toMap({List<String>? extFieldNames}) {
    return {
      uuid_: uuid,
      title_: title,
      content_: content,
      generated_: generated,
      modified_: modified,
      personName_: personName,
      personId_: personId,
      readCount_: readCount,
      imageUrl_: imageUrl,
      isNotice_: isNotice,
    };
  }

  factory EnBulletinMessage.fromMap(Map<String, dynamic> map) {
    return EnBulletinMessage(
      uuid: map[uuid_] as String,
      title: map[title_] as String,
      content: map[content_].cast<String>(),
      generated: map[generated_] as int,
      modified: map[modified_] as int,
      personName: map[personName_] as String,
      personId: map[personId_] as int,
      readCount: map[readCount_] as int,
      imageUrl: map[imageUrl_] ?? '',
      isNotice: map[isNotice_] as bool,
    );
  }
}
