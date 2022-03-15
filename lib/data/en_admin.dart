import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';

@Entity()
class EnAdmin extends EnData {
  static const id_ = Constants.keyIndex;
  static const isMain_ = 'isMain';
  static const personName_ = Constants.keyPersonName;
  static const mobilePhone_ = Constants.keyMobilePhone;
  static const email_ = Constants.keyEmail;

  @override
  int get getIndex => id;

  @Id(assignable: true)
  int id;
  bool isMain;
  String personName;
  String mobilePhone;
  String email;

//<editor-fold desc="Data Methods">

  EnAdmin({
    required this.id,
    required this.isMain,
    required this.personName,
    required this.mobilePhone,
    required this.email,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnAdmin &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isMain == other.isMain &&
          personName == other.personName &&
          mobilePhone == other.mobilePhone &&
          email == other.email);

  @override
  int get hashCode => id.hashCode ^ isMain.hashCode ^ personName.hashCode ^ mobilePhone.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'EnAdmin{' + ' $id_: $id,' + ' $isMain_: $isMain,' + ' $personName_: $personName,' + ' $mobilePhone_: $mobilePhone,' + ' $email_: $email,' + '}';
  }

  EnAdmin copyWith({
    int? id,
    bool? isMain,
    String? personName,
    String? mobilePhone,
    String? email,
  }) {
    return EnAdmin(
      id: id ?? this.id,
      isMain: isMain ?? this.isMain,
      personName: personName ?? this.personName,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      email: email ?? this.email,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    return {
      id_: id,
      isMain_: isMain,
      personName_: personName,
      mobilePhone_: mobilePhone,
      email_: email,
    };
  }

  @override
  factory EnAdmin.fromMap(MapDynamic map) {
    return EnAdmin(
      id: map[id_] as int,
      isMain: map[isMain_] as bool,
      personName: map[personName_] as String,
      mobilePhone: map[mobilePhone_] as String,
      email: map[email_] as String,
    );
  }

//</editor-fold>
}
