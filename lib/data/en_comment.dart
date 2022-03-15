import 'package:objectbox/objectbox.dart';

import '../objectbox.g.dart';
import 'en_data.dart';

@Entity()
class EnComment extends EnData {
  static const uuid_ = 'uuid';
  static const content_ = 'content';
  static const imageUrl_ = 'imageUrl';
  static const personName_ = 'personName';
  static const personId_ = 'personId';
  static const generated_ = 'generated';

  @override
  int get getIndex => -1;

  @Id(assignable: true)
  String uuid;
  String content;
  String imageUrl;
  String personName;
  int personId;
  int generated;

  EnComment({
    required this.uuid,
    required this.content,
    String? imageUrl = '',
    required this.personName,
    required this.personId,
    required this.generated,
  }) : imageUrl = imageUrl!;

  @override
  Map<String, dynamic> toMap({List<String>? extFieldNames}) {
    return {
      uuid_: uuid,
      content_: content,
      imageUrl_: imageUrl,
      personName_: personName,
      personId_: personId,
      generated_: generated,
    };
  }

  factory EnComment.fromMap(Map<String, dynamic> map) {
    return EnComment(
      uuid: map[uuid_] as String,
      content: map[content_] as String,
      imageUrl: map[imageUrl_] ?? '',
      personName: map[personName_] as String,
      personId: map[personId_] as int,
      generated: map[generated_] as int,
    );
  }
}
