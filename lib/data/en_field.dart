import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../objectbox.g.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';

@Entity()
class EnField extends EnData {
  static const id_ = Constants.keyIndex;
  static const fieldName_ = Constants.keyFieldName;
  static const displayTerm_ = 'displayTerm';
  static const isDistinct_ = 'isDistinct';
  static const isPhone_ = 'isPhone';
  static const isUrl_ = 'isUrl';
  static const isEmail_ = 'isEmail';
  static const adminEditable_ = 'adminEditable';
  static const memberEditable_ = 'memberEditable';
  static const memberHidable_ = 'memberHidable';
  static const thumbViewable_ = 'thumbViewable';
  static const maxLines_ = 'maxLines';

  @override
  int get getIndex => id;

  @Id(assignable: true)
  int id;
  String fieldName;
  String displayTerm;
  bool isDistinct;
  bool isPhone;
  bool isUrl;
  bool isEmail;
  bool adminEditable;
  bool memberEditable;
  bool memberHidable;
  bool thumbViewable;
  int maxLines;

//<editor-fold desc="Data Methods">

  EnField({
    required this.id,
    required this.fieldName,
    required this.displayTerm,
    required this.isDistinct,
    required this.isPhone,
    required this.isUrl,
    required this.isEmail,
    required this.adminEditable,
    required this.memberEditable,
    required this.memberHidable,
    required this.thumbViewable,
    required this.maxLines,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnField &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fieldName == other.fieldName &&
          displayTerm == other.displayTerm &&
          isDistinct == other.isDistinct &&
          isPhone == other.isPhone &&
          isUrl == other.isUrl &&
          isEmail == other.isEmail &&
          adminEditable == other.adminEditable &&
          memberEditable == other.memberEditable &&
          memberHidable == other.memberHidable &&
          thumbViewable == other.thumbViewable &&
          maxLines == other.maxLines);

  @override
  int get hashCode =>
      id.hashCode ^
      fieldName.hashCode ^
      displayTerm.hashCode ^
      isDistinct.hashCode ^
      isPhone.hashCode ^
      isUrl.hashCode ^
      isEmail.hashCode ^
      adminEditable.hashCode ^
      memberEditable.hashCode ^
      memberHidable.hashCode ^
      thumbViewable.hashCode ^
      maxLines.hashCode;

  @override
  String toString() {
    return 'EnField{' +
        ' $id_: $id,' +
        ' $fieldName_: $fieldName,' +
        ' $displayTerm_: $displayTerm,' +
        ' $isDistinct_: $isDistinct,' +
        ' $isPhone_: $isPhone,' +
        ' $isUrl_: $isUrl,' +
        ' $isEmail_: $isEmail,' +
        ' $adminEditable_: $adminEditable,' +
        ' $memberEditable_: $memberEditable,' +
        ' $memberHidable_: $memberHidable,' +
        ' $thumbViewable_: $thumbViewable,' +
        ' $maxLines_: $maxLines,' +
        '}';
  }

  EnField copyWith({
    int? id,
    String? fieldName,
    String? displayName,
    bool? isDistinct,
    bool? isPhone,
    bool? isUrl,
    bool? isEmail,
    bool? adminEditable,
    bool? memberEditable,
    bool? memberHidable,
    bool? thumbViewable,
    int? maxLines,
  }) {
    return EnField(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      displayTerm: displayName ?? this.displayTerm,
      isDistinct: isDistinct ?? this.isDistinct,
      isPhone: isPhone ?? this.isPhone,
      isUrl: isUrl ?? this.isUrl,
      isEmail: isEmail ?? this.isEmail,
      adminEditable: adminEditable ?? this.adminEditable,
      memberEditable: memberEditable ?? this.memberEditable,
      memberHidable: memberHidable ?? this.memberHidable,
      thumbViewable: thumbViewable ?? this.thumbViewable,
      maxLines: maxLines ?? this.maxLines,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    return {
      id_: id,
      fieldName_: fieldName,
      displayTerm_: displayTerm,
      isDistinct_: isDistinct,
      isPhone_: isPhone,
      isUrl_: isUrl,
      isEmail_: isEmail,
      adminEditable_: adminEditable,
      memberEditable_: memberEditable,
      memberHidable_: memberHidable,
      thumbViewable_: thumbViewable,
      maxLines_: maxLines,
    };
  }

  factory EnField.fromMap(MapDynamic map) {
    return EnField(
      id: map[id_] as int,
      fieldName: map[fieldName_] as String,
      displayTerm: map[displayTerm_] as String,
      isDistinct: map[isDistinct_] as bool,
      isPhone: map[isPhone_] as bool,
      isUrl: map[isUrl_] as bool,
      isEmail: map[isEmail_] as bool,
      adminEditable: map[adminEditable_] as bool,
      memberEditable: map[memberEditable_] as bool,
      memberHidable: map[memberHidable_] as bool,
      thumbViewable: map[thumbViewable_] as bool,
      maxLines: map[maxLines_] as int,
    );
  }

//</editor-fold>
}
