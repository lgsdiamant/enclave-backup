import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../objectbox.g.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';

@Entity()
class EnPoc extends EnData {
  static const id_ = Constants.keyIndex;
  static const boardTitle_ = Constants.keyBoardTitle;
  static const personName_ = Constants.keyPersonName;
  static const mobilePhone_ = Constants.keyMobilePhone;
  static const email_ = Constants.keyEmail;

  @override
  int get getIndex => id;

  @Id(assignable: true)
  int id;
  String boardTitle;
  String personName;
  String mobilePhone;
  String email;

//<editor-fold desc="Data Methods">

  EnPoc({
    required this.id,
    required this.boardTitle,
    required this.personName,
    required this.mobilePhone,
    required this.email,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnPoc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          boardTitle == other.boardTitle &&
          personName == other.personName &&
          mobilePhone == other.mobilePhone &&
          email == other.email);

  @override
  int get hashCode => id.hashCode ^ boardTitle.hashCode ^ personName.hashCode ^ mobilePhone.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'EnPoc{' + ' $id_: $id,' + ' $boardTitle_: $boardTitle,' + ' $personName_: $personName,' + ' $mobilePhone_: $mobilePhone,' + ' $email_: $email,' + '}';
  }

  EnPoc copyWith({
    int? id,
    String? boardTitle,
    String? personName,
    String? mobilePhone,
    String? email,
  }) {
    return EnPoc(
      id: id ?? this.id,
      boardTitle: boardTitle ?? this.boardTitle,
      personName: personName ?? this.personName,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      email: email ?? this.email,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    return {
      id_: id,
      boardTitle_: boardTitle,
      personName_: personName,
      mobilePhone_: mobilePhone,
      email_: email,
    };
  }

  factory EnPoc.fromMap(MapDynamic map) {
    return EnPoc(
      id: map[id_] as int,
      boardTitle: map[boardTitle_] as String,
      personName: map[personName_] as String,
      mobilePhone: map[mobilePhone_] as String,
      email: map[email_] as String,
    );
  }

//</editor-fold>
}
