import 'package:enclave/data/en_enclave.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../../data/repository.dart';
import '../../objectbox.g.dart';
import '../../shared/enclave_utility.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';
import 'en_field.dart';

@Entity()
class EnMember extends EnData {
  static const id_ = Constants.keyIndex;
  static const personName_ = Constants.keyPersonName;
  static const mobilePhone_ = Constants.keyMobilePhone;
  static const fieldValues_ = 'fieldValues';
  static const lastFieldValueChanged_ = 'lastFieldValueChanged';
  static const lastProfileImageChanged_ = 'lastProfileChanged';
  static const lastFullImageChanged_ = 'lastFullImageChanged';
  static const storageDocProfileImage_ = 'storageDocProfileImage';
  static const storageDocFullImage_ = 'storageDocFullImage';

  /// static object 'dummyMember' is used for unknown member
  @Transient()
  static EnMember dummyMember = EnMember(
    id: 0,
    personName: 'dummy',
    mobilePhone: '000-0000-0000',
    fieldValues: <String>[],
    lastFieldValueChanged: 0,
    lastProfileImageChanged: 0,
    lastFullImageChanged: 0,
    storageDocFullImage: '',
    storageDocProfileImage: '',
  );

  @Transient()
  static List<String> fieldNames = []; // field names excluding id, personName, mobilePhone

  @override
  int get getIndex => id;

  // basic fields from excel data
  @Id(assignable: true)
  int id;
  String personName;
  String mobilePhone;

  // generated fields
  List<String> fieldValues = []; // field values in order, excluding id, personName, mobilePhone
  int lastFieldValueChanged = 0; // timestamp for field value change
  int lastProfileImageChanged = 0; // timestamp for profile change
  int lastFullImageChanged = 0; // timestamp for full image change
  String storageDocProfileImage = ''; // doc reference for profileImage in storage
  String storageDocFullImage = ''; // doc reference for fullImage in storage

//<editor-fold desc="Data Methods">

  EnMember({
    // basic fields from excel data
    required this.id,
    required this.personName,
    required this.mobilePhone,
    required this.fieldValues,

    // generated fields
    required this.lastFieldValueChanged,
    required this.lastProfileImageChanged,
    required this.lastFullImageChanged,
    required this.storageDocProfileImage,
    required this.storageDocFullImage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnMember &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          personName == other.personName &&
          mobilePhone == other.mobilePhone &&
          fieldValues == other.fieldValues);

  @override
  int get hashCode => id.hashCode ^ personName.hashCode ^ mobilePhone.hashCode ^ fieldValues.hashCode;

  @override
  String toString() {
    return 'EnMember{' + ' $id_: $id,' + ' $personName_: $personName,' + ' $mobilePhone_: $mobilePhone,' + ' $fieldValues_: $fieldValues,' + '}';
  }

  EnMember copyWith({
    int? id,
    String? personName,
    String? mobilePhone,
    List<String>? fieldValues,
  }) {
    return EnMember(
      // basic fields
      id: id ?? this.id,
      personName: personName ?? this.personName,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      fieldValues: fieldValues ?? this.fieldValues,

      // generated fields
      lastFieldValueChanged: lastFieldValueChanged,
      lastProfileImageChanged: lastProfileImageChanged,
      lastFullImageChanged: lastFullImageChanged,
      storageDocProfileImage: storageDocProfileImage,
      storageDocFullImage: storageDocFullImage,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    assert((extFieldNames != null) || fieldNames.isNotEmpty);

    extFieldNames = extFieldNames ?? fieldNames;
    MapDynamic fieldMaps = {};
    for (int index = 0; index < extFieldNames.length; index++) {
      fieldMaps[extFieldNames[index]] = (index < fieldValues.length) ? fieldValues[index] : '';
    }

    fieldMaps[lastFieldValueChanged_] = lastFieldValueChanged;
    fieldMaps[lastProfileImageChanged_] = lastProfileImageChanged;
    fieldMaps[lastFullImageChanged_] = lastFullImageChanged;

    fieldMaps[storageDocProfileImage_] = storageDocProfileImage;
    fieldMaps[storageDocFullImage_] = storageDocFullImage;

    return {
      'id': id,
      'personName': personName,
      'mobilePhone': mobilePhone,
      ...fieldMaps,
    };
  }

  factory EnMember.fromMap(MapDynamic valueMap, {List<String>? extFieldNames}) {
    assert((extFieldNames != null) || fieldNames.isNotEmpty);

    // id, personName, mobilePhone will be local property
    final _id = valueMap[id_] as int;
    final _personName = valueMap[personName_] as String;
    final _mobilePhone = valueMap[mobilePhone_] as String;

    // save field values in order of fieldNames, which is not including id, personName, mobilePhone
    final _fieldStrings = <String>[];
    extFieldNames ??= fieldNames;

    for (final name in extFieldNames) {
      final value = valueMap[name];
      String valueString = (value.runtimeType == String) ? value as String : ((value == null) ? '' : value.toString());
      _fieldStrings.add(valueString);
    }

    final int _lastFieldValueChanged = valueMap[lastFieldValueChanged_] ?? 0;
    final int _lastProfileImageChanged = valueMap[lastProfileImageChanged_] ?? 0;
    final int _lastFullImageChanged = valueMap[lastFullImageChanged_] ?? 0;
    final String _storageDocProfileImage = valueMap[storageDocProfileImage_] ?? '';
    final String _storageDocFullImage = valueMap[storageDocFullImage_] ?? '';

    return EnMember(
      id: _id,
      personName: _personName,
      mobilePhone: _mobilePhone,
      fieldValues: _fieldStrings,
      lastFieldValueChanged: _lastFieldValueChanged,
      lastProfileImageChanged: _lastProfileImageChanged,
      lastFullImageChanged: _lastFullImageChanged,
      storageDocProfileImage: _storageDocProfileImage,
      storageDocFullImage: _storageDocFullImage,
    );
  }

//</editor-fold>

  @Transient()
  bool isMainAdmin = false; // main administrator
  @Transient()
  bool isSubAdmin = false; // sub administrator

  // profile image
  @Transient()
  final rxProfileImage = Rx<ImageProvider?>(null);
  @Transient()
  bool profileImageInitialized = false;

  ImageProvider? get profileImage => rxProfileImage.value;

  Future<ImageProvider> getProfileImage({bool isForced = false}) async {
    await gEnRepo.getMemberProfileImage(this, isForced: isForced);
    return profileImage ?? EnclaveRepository.getAssetImageProfile;
  }

  // full image
  @Transient()
  final rxFullImage = Rx<ImageProvider?>(null);
  @Transient()
  bool fullImageInitialized = false;

  ImageProvider? get fullImage => rxFullImage.value;

  Future<ImageProvider?> getFullImage({bool isForced = false}) async {
    await gEnRepo.getMemberFullImage(this);
    return fullImage;
  }

  /// find field value for given field name
  dynamic findFieldValue(EnField field) {
    final fieldName = field.fieldName;

    if (fieldName == Constants.keyIndex) return id;
    if (fieldName == Constants.keyPersonName) return personName;
    if (fieldName == Constants.keyMobilePhone) return mobilePhone;

    final index = fieldNames.indexOf(fieldName);
    if (index == -1) return '';
    return (index < fieldValues.length) ? fieldValues[index] : '';
  }

  /// find field value for given field name
  String findFieldDisplayValue(EnField field) {
    final fieldName = field.fieldName;

    if (fieldName == Constants.keyIndex) return id.toString();
    if (fieldName == Constants.keyPersonName) return personName;
    if (fieldName == Constants.keyMobilePhone) return gEnUtil.stringToFormalKoreanLocalPhoneNumberDisplay(mobilePhone);

    final index = fieldNames.indexOf(fieldName);
    if (index == -1) return '';
    final value = (index < fieldValues.length) ? fieldValues[index] : '';
    return gEnUtil.isDummyDataString(value) ? '' : value.toString();
  }

  void setProfileImage(ImageProvider? image) {
    rxProfileImage.value = image;
  }

  void setFullImage(ImageProvider? image) {
    rxFullImage.value = image;
  }

  String oneLineDescription() {
    String description = '';

    if(gCurrentEnclave.isDataReady) {
      final fields = gCurrentEnclave.fields;
      for (final field in fields) {
        if ((field.fieldName == EnMember.id_) || (field.fieldName == EnMember.personName_) || (field.fieldName == EnMember.mobilePhone_)) continue;
        if(field.thumbViewable) {
          final fieldValue = findFieldDisplayValue(field);
          if(gEnUtil.isDummyDataString(fieldValue)) continue;

          description += '${findFieldDisplayValue(field)} - ';
        }
      }
    }

    if(description.isNotEmpty) {
      description = description.substring(0, description.length-3);
    }
    return description;
  }

  static void assignFieldNames(List<EnField> fields) {
    // reset field names
    fieldNames = [];

    for (final field in fields) {
      final fieldName = field.fieldName;

      // skip for id, personName, mobilePhone
      if ((fieldName == Constants.keyIndex) || (fieldName == Constants.keyPersonName) || (fieldName == Constants.keyMobilePhone)) continue;

      fieldNames.add(field.fieldName);
    }
  }

  void updateFieldValue({required EnField field, required String fieldValue}) {
    // note: fieldValue should not be same with current value
    final fieldName = field.fieldName;
    bool isPersonName = false;

    switch (fieldName) {
      case EnMember.id_:
        throw (Exception('Error: member id can not be changed'));
        break;
      case EnMember.personName_:
        isPersonName = true;
        personName = fieldValue;
        break;
      case EnMember.mobilePhone_:
        mobilePhone = gEnUtil.stringToFormalKoreanLocalPhoneNumber(fieldValue);
        break;
      default:
        final index = fieldNames.indexOf(fieldName);
        if ((index >= 0) && (index < fieldValues.length)) {
          fieldValues[index] = fieldValue;
        }
        break;
    }

    // personName change affect member's associated file names
    if (isPersonName) {
      // make sure current image file path
      getProfileImage(isForced: true);
      getFullImage(isForced: true);

      gEnRepo.updateMemberPersonNameFiles(this);
    }

    // update firestore & objectBox
    gEnRepo.updateMemberFieldValues(this);
  }

  bool isFieldValueSame({required EnField field, required String newFieldValue}) {
    final currentFieldValue = findFieldValue(field);

    if (field.isPhone) {
      return gEnUtil.isSamePhoneNumber(newFieldValue, currentFieldValue);
    } else if (gEnUtil.isDummyDataString(newFieldValue) && gEnUtil.isDummyDataString(currentFieldValue)) {
      return true;
    }

    return (newFieldValue == currentFieldValue);
  }
}
