import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enclave/data/en_bulletin_message.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../data/repository.dart';
import '../../shared/enclave_dialog.dart';
import '../../shared/enclave_utility.dart';
import '../enclave_app.dart';
import '../main_logic.dart';
import '../shared/common_ui.dart';
import 'constants.dart';
import 'en_admin.dart';
import 'en_board.dart';
import 'en_comment.dart';
import 'en_data.dart';
import 'en_enclave.dart';
import 'en_field.dart';
import 'en_member.dart';
import 'en_poc.dart';
import 'en_term.dart';
import 'en_url.dart';
import 'firebase.dart';

class FirestoreHelper extends Object {
  FirestoreHelper({required EnclaveRepository repo}) : _repo = repo;

  static FirebaseFirestore get fbStore => FirebaseFirestore.instance;
  final EnclaveRepository _repo;

  bool get isSystemRepo => _repo.isSystemRepo;

  String get enclaveCode => _repo.enclaveCode;
  String enclaveNameFull = '';
  String enclaveNameShort = '';
  String enclaveNameSub = '';
  String enclaveMemberCalling = '';
  int enclaveMembersCount = 0;

  // firestore references for general

  // firestore references for enclave
  CollectionReference get fsCollEnclave => fbStore.collection(FsId.enclaves.name);

  DocumentReference get fsDocEnclave => fsCollEnclave.doc(enclaveCode);

  CollectionReference get fsCollMembers => fsDocEnclave.collection(FsId.members.name);

  CollectionReference get fsCollTerms => fsDocEnclave.collection(FsId.terms.name);

  CollectionReference get fsCollBoards => fsDocEnclave.collection(FsId.boards.name);

  CollectionReference get fsCollPocs => fsDocEnclave.collection(FsId.pocs.name);

  CollectionReference get fsCollFields => fsDocEnclave.collection(FsId.fields.name);

  CollectionReference get fsCollAdmins => fsDocEnclave.collection(FsId.admins.name);

  CollectionReference get fsCollUrls => fsDocEnclave.collection(FsId.urls.name);

  DocumentReference fsDocMember(EnMember member) => fsCollMembers.doc(_indexToDocName(member.id));

  /// A method that retrieves all the members from the members table.
  Future<List<EnMember>> getAllMembersFs() async {
    try {
      // Query the table for all The Members.
      QuerySnapshot<Object?> snapShot = await fsCollMembers.get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnMember.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllMembersFs', e);
      debugger(when: testingStopDebugger);
      return []; // failed
    }
  }

  Future<bool> insertAllFs<T extends EnData>(List<T> items, CollectionReference collRef) async {
    // Insert the All the data
    try {
      for (var item in items) {
        await insertFs<T>(item, collRef);
      }
      return true; // success
    } on Exception catch (e) {
      gEnDialog.showExceptionError('insertAllFs', e);
      debugger(when: testingStopDebugger);
      return false; // failed
    }
  }

  // convert integer index to fs doc name
  String _indexToDocName(int index) {
    return index.toString().padLeft(10, '0');
  }

  /// Define a function that inserts data into the firebase database
  Future<bool> insertFs<T extends EnData>(T item, CollectionReference collRef, {List<String>? extFieldNames}) async {
    try {
      var index = item.getIndex;
      DocumentReference docRef = collRef.doc(_indexToDocName(index));
      docRef.set(item.toMap(extFieldNames: extFieldNames));
      return true; // success
    } on Exception catch (e) {
      gEnDialog.showExceptionError('insertFs', e);
      debugger(when: testingStopDebugger);
      return false; // failed
    }
  }

  /// A method that retrieves all the members from the members table.
  Future<List<EnTerm>> getAllTermsFs({CollectionReference? termCollRef}) async {
    try {
      // Query the table for all The Members.
      termCollRef = termCollRef ?? fsCollTerms;
      QuerySnapshot<Object?> snapShot = await termCollRef.orderBy(EnTerm.id_).get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnTerm.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllTermsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// A method that retrieves all the members from the members table.
  Future<List<EnBoard>> getAllBoardsFs({CollectionReference? boardCollRef}) async {
    try {
      // Query the table for all The Members.
      boardCollRef = boardCollRef ?? fsCollBoards;
      QuerySnapshot<Object?> snapShot = await boardCollRef.orderBy(EnBoard.id_).get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnBoard.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllBoardsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// A method that retrieves all the members from the members table.
  Future<List<EnPoc>> getAllPocsFs({CollectionReference? pocCollRef}) async {
    try {
      // Query the table for all The Members.
      pocCollRef = pocCollRef ?? fsCollPocs;
      QuerySnapshot<Object?> snapShot = await pocCollRef.orderBy(EnPoc.id_).get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnPoc.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllPocsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// A method that retrieves all the members from the members table. for non-gCurrentEnclave, use fieldsCollRef
  Future<List<EnField>> getAllFieldsFs({CollectionReference? fieldCollRef}) async {
    try {
      // Query the table for all The Members.
      fieldCollRef = fieldCollRef ?? fsCollFields;
      QuerySnapshot<Object?> snapShot = await fieldCollRef.orderBy(EnField.id_).get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnField.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllFieldsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// A method that retrieves all the members from the members table.
  Future<List<EnAdmin>> getAllAdminsFs({CollectionReference? adminCollRef}) async {
    try {
      // Query the table for all The Members.
      adminCollRef = adminCollRef ?? fsCollAdmins;
      QuerySnapshot<Object?> snapShot = await adminCollRef.get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnAdmin.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllAdminsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// A method that retrieves all the members from the members table.
  Future<List<EnUrl>> getAllUrlsFs({CollectionReference? urlCollRef}) async {
    try {
      // Query the table for all The Members.
      urlCollRef = urlCollRef ?? fsCollUrls;
      QuerySnapshot<Object?> snapShot = await urlCollRef.get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = snapShot.docs;

      return List.generate(docSnaps.length, (i) {
        return EnUrl.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllUrlsFs', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// return member fields names, excluding id, personName, mobilePhone
  Future<List<String>> getMemberFieldNamesFs({CollectionReference? fieldCollRef}) async {
    fieldCollRef = fieldCollRef ?? fsCollFields;

    final fields = await getAllFieldsFs(fieldCollRef: fieldCollRef);
    final fieldNames = fields.map((e) => e.fieldName).toList();

    // we do not need id, personName, and mobilePhone
    fieldNames.remove(EnMember.id_);
    fieldNames.remove(EnMember.personName_);
    fieldNames.remove(EnMember.mobilePhone_);

    return fieldNames;
  }

  /// convert all mobile phone numbers to Formal Format
  Future<bool> convertAllMobileNumbers() async {
    List<String> fsKeys = [FsId.members.name, FsId.boards.name, FsId.pocs.name, FsId.admins.name];

    for (var key in fsKeys) {
      var snaps = await fsCollEnclave.doc(enclaveCode).collection(key).get();
      var docs = snaps.docs;
      for (var doc in docs) {
        final oldPhoneNumber = doc.get(Constants.keyMobilePhone);

        try {
          final formalNumber = gEnUtil.stringToFormalKoreanLocalPhoneNumber(oldPhoneNumber);
          doc.reference.update({Constants.keyMobilePhone: formalNumber});
        } on Exception catch (e) {
          gEnDialog.showExceptionError('convertAllMobileNumbers', e);
          debugger(when: testingStopDebugger);
        }
      }
    }
    return true;
  }

  void saveEnclaveDocData() {
    fsDocEnclave.set({
      EnEnclave.code_: enclaveCode,
      EnEnclave.nameFull_: enclaveNameFull.isEmpty ? enclaveCode : enclaveNameFull,
      EnEnclave.nameShort_: enclaveNameShort.isEmpty ? enclaveCode : enclaveNameShort,
      EnEnclave.nameSub_: enclaveNameSub.isEmpty ? enclaveCode : enclaveNameSub,
      EnEnclave.memberCalling_: enclaveMemberCalling.isEmpty ? 'termMember'.tr : enclaveMemberCalling,
      EnEnclave.membersCount_: enclaveMembersCount,
      EnEnclave.uploadTime_: DateTime.now().millisecondsSinceEpoch,
      EnEnclave.activated_: true, // boolean: activated by default
    });
  }

  void initEnclaveDocData() {
    enclaveNameFull = '';
    enclaveNameShort = '';
    enclaveNameSub = '';
    enclaveMemberCalling = '';
    enclaveMembersCount = 0;
  }

  /// get all enclaves for system
  Future<List<EnEnclave>> getAllSystemEnclaves(String phoneNumber) async {
    try {
      final List<EnEnclave> foundEnclaves = [];

      // gel all activated enclaves
      QuerySnapshot<Object?> enclaveQuerySnap = await fsCollEnclave.where(EnEnclave.activated_, isEqualTo: true).get();
      List<QueryDocumentSnapshot<Object?>> enclaveDocSnaps = enclaveQuerySnap.docs;

      for (var enclaveSnap in enclaveDocSnaps) {
        // find self in the enclave
        final memberSnap = await enclaveSnap.reference.collection(FsId.members.name).where(EnMember.mobilePhone_, isEqualTo: phoneNumber).limit(1).get();
        final members = memberSnap.docs;

        final fieldNames = await getMemberFieldNamesFs(fieldCollRef: enclaveSnap.reference.collection(FsId.fields.name));

        var self = EnMember.dummyMember;
        if (members.isNotEmpty) {
          self = EnMember.fromMap(members[0].data(), extFieldNames: fieldNames);
        }

        final enclave = EnEnclave.fromMap(enclaveSnap.data() as MapDynamic, fieldNames: fieldNames, self: self);

        // decorate enclave for system or tester or sample
        await decorateEnclave(enclave);

        if (enclave.mySelf != EnMember.dummyMember) {
          gEnRepo.getMemberProfileImage(enclave.mySelf, isForced: true);
        }

        // add it to my enclaves
        foundEnclaves.add(enclave);
      }
      return foundEnclaves;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllSystemEnclaves', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// get all enclaves for tester
  Future<List<EnEnclave>> getAllDemoEnclaves(String? testerPhoneNumber) async {
    try {
      final List<EnEnclave> foundEnclaves = [];

      // gel all enclaves
      QuerySnapshot<Object?> enclaveQuerySnap = await fsCollEnclave.where(EnEnclave.activated_, isEqualTo: true).orderBy(EnEnclave.code_).get();
      final enclaveDocSnaps = enclaveQuerySnap.docs;

      for (var enclaveSnap in enclaveDocSnaps) {
        final enclaveData = enclaveSnap.data() as MapDynamic;

        final String enclaveCode = enclaveData[EnEnclave.code_] ?? '';

        // skip all non-tester enclave, taking only demo enclaves
        if (!enclaveCode.startsWith(Constants.demoEnclavePrefix)) continue;

        final fieldNames = await getMemberFieldNamesFs(fieldCollRef: enclaveSnap.reference.collection(FsId.fields.name));

        EnMember self = EnMember.dummyMember;

        // find self in the enclave
        final memberSnap = await enclaveSnap.reference.collection(FsId.members.name).where(Constants.keyMobilePhone, isEqualTo: testerPhoneNumber).limit(1).get();
        final members = memberSnap.docs;
        if (members.isNotEmpty) {
          self = EnMember.fromMap(members[0].data(), extFieldNames: fieldNames);
        }

        final enclave = EnEnclave.fromMap(enclaveSnap.data() as MapDynamic, fieldNames: fieldNames, self: self);

        // if no testerPhoneNumber, the enclave is demo
        enclave.isDemo = (testerPhoneNumber == null);

        // decorate enclave for system or tester or sample
        await decorateEnclave(enclave);

        if (enclave.mySelf != EnMember.dummyMember) {
          gEnRepo.getMemberProfileImage(enclave.mySelf);
        }

        // add it to my enclaves
        foundEnclaves.add(enclave);
      }
      return foundEnclaves;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getAllDemoEnclaves', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  Future<EnMember> getFirstMember(EnEnclave enclave) async {
    // Update the given Member.
    try {
      final docSnaps = await fsCollEnclave.doc(enclave.code).collection(FsId.members.name).orderBy(Constants.keyIndex).limit(1).get();
      final memberDocs = docSnaps.docs;
      return memberDocs.isEmpty ? EnMember.dummyMember : EnMember.fromMap(memberDocs[0].data(), extFieldNames: enclave.fieldNames);
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getFirstMember', e);
      debugger(when: testingStopDebugger);
      return EnMember.dummyMember;
    }
  }

  /// decorate enclave for demo-enclave, and for system, and for tester
  Future<void> decorateEnclave(EnEnclave enclave) async {
    // if demo-enclave or system, let the first member to be mySelf
    if ((enclave.mySelf == EnMember.dummyMember) && (enclave.isDemo || mainLogic.isSystem || mainLogic.isTester)) {
      enclave.mySelf = await gEnRepo.getFirstMemberFs(enclave);
    }
  }

  /// read member column info from firebase
  Future<List<EnField>> readMemberFieldsFromFirebase() async {
    try {
      QuerySnapshot<Object?> memberFields = await fsCollFields.get();
      List<QueryDocumentSnapshot<Object?>> docSnaps = memberFields.docs;

      return List.generate(docSnaps.length, (i) {
        return EnField.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('readMemberFieldsFromFirebase', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// update member data
  Future<bool> updateMemberFieldValuesFs(EnMember member) async {
    try {
      // put timestamp for last field value change
      member.lastFieldValueChanged = DateTime.now().millisecondsSinceEpoch;

      final docRef = fsDocMember(member);
      await docRef.set(member.toMap());
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('updateMemberDataFs', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  /// get all member which has been changed since last obRefresh time
  Future<List<EnMember>> getRecentlyFieldValueChangedMembers() async {
    try {
      // get all member which has been changed since last obRefresh time
      final docSnaps =
          (await fsCollMembers.where(EnMember.lastFieldValueChanged_, isGreaterThan: gCurrentEnclave.databaseRefreshTime).orderBy(EnMember.lastFieldValueChanged_).get()).docs;
      return List.generate(docSnaps.length, (i) {
        return EnMember.fromMap(docSnaps[i].data() as MapDynamic, extFieldNames: gCurrentEnclave.fieldNames);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getRecentlyFieldValueChangedMembers', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// get all member whose profile has been changed since last obRefresh time
  Future<List<EnMember>> getRecentlyProfileChangedMembers() async {
    try {
      // get all member which has been changed since last obRefresh time
      final docSnaps = (await fsCollMembers.where(EnMember.lastProfileImageChanged_, isGreaterThan: gCurrentEnclave.dataFileRefreshTime).get()).docs;
      return List.generate(docSnaps.length, (i) {
        return EnMember.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getRecentlyProfileChangedMembers', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// get all member whose full image has been changed since last obRefresh time
  Future<List<EnMember>> getRecentlyFullImageChangedMembers() async {
    try {
      // get all member which has been changed since last obRefresh time
      final docSnaps = (await fsCollMembers.where(EnMember.lastFullImageChanged_, isGreaterThan: gCurrentEnclave.dataFileRefreshTime).get()).docs;
      return List.generate(docSnaps.length, (i) {
        return EnMember.fromMap(docSnaps[i].data() as MapDynamic);
      });
    } on Exception catch (e) {
      gEnDialog.showExceptionError('getRecentlyFullImageChangedMembers', e);
      debugger(when: testingStopDebugger);
      return [];
    }
  }

  /// record timestamp for last profile change
  Future<bool> updateProfileImageChanged(EnMember member) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await fsDocMember(member).update({EnMember.storageDocProfileImage_: member.storageDocProfileImage});
    await fsDocMember(member).update({EnMember.lastProfileImageChanged_: now});
    member.lastProfileImageChanged = now;
    return true;
  }

  /// record timestamp for last full image change
  Future<bool> updateFullImageChanged(EnMember member) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await fsDocMember(member).update({EnMember.storageDocFullImage_: member.storageDocFullImage});
    await fsDocMember(member).update({EnMember.lastFullImageChanged_: now});
    member.lastFullImageChanged = now;
    return true;
  }

  Future<List<EnMember>> getMembersWithLiveProfileImage({required bool forAll}) async {
    final fieldNames = await getMemberFieldNamesFs();

    final membersSnap = forAll
        ? await fsCollMembers.where(EnMember.storageDocProfileImage_, isNotEqualTo: '').get()
        : await fsCollMembers.where(EnMember.storageDocProfileImage_, isGreaterThan: gCurrentEnclave.dataFileRefreshTime).get();

    final memberDocs = membersSnap.docs;
    return List.generate(memberDocs.length, (i) {
      return EnMember.fromMap(memberDocs[i].data() as MapDynamic, extFieldNames: fieldNames);
    });
  }

  Future<List<EnMember>> getMembersWithLiveFullImage({required bool forAll}) async {
    final membersSnap = forAll
        ? await fsCollMembers.where(EnMember.storageDocFullImage_, isNotEqualTo: '').get()
        : await fsCollMembers.where(EnMember.storageDocFullImage_, isGreaterThan: gCurrentEnclave.dataFileRefreshTime).get();

    final memberDocs = membersSnap.docs;
    return List.generate(memberDocs.length, (i) {
      return EnMember.fromMap(memberDocs[i].data() as MapDynamic);
    });
  }

  //region: Livedata
  //===========================================================
  // livedata
  CollectionReference get fsCollLivedata => fbStore.collection(FsId.livedata.name); // root: livedata

  // livedata.enclaveCode
  DocumentReference get fsDocLivedata => fsCollLivedata.doc(enclaveCode); // livedata.enclaveCode

  // livedata.enclaveCode.bulletin
  CollectionReference get fsCollBulletin => fsDocLivedata.collection(FsId.bulletin.name);

  // livedata.enclaveCode.bulletin.bulletinUUID
  DocumentReference fsDocBulletin(EnBulletinMessage message) => fsDocLivedata.collection(FsId.bulletin.name).doc(message.uuid);

  // livedata.enclaveCode.bulletin.bulletinUUID.comment.comment.UUID
  CollectionReference fsCollComment({required EnBulletinMessage message}) => fsDocBulletin(message).collection(FsId.comment.name);

  DocumentReference fsDocComment({required EnBulletinMessage message, required EnComment comment}) => fsCollComment(message: message).doc(comment.uuid);

  Future<List<EnBulletinMessage>> getPublicNotices() async {
    final messageSnaps = await fsCollBulletin.where(EnBulletinMessage.isNotice_, isEqualTo: true).orderBy(EnBulletinMessage.modified_, descending: true).get();
    final messageDocs = messageSnaps.docs;
    return List.generate(messageDocs.length, (i) {
      return EnBulletinMessage.fromMap(messageDocs[i].data() as MapDynamic);
    });
  }

  Future<List<EnBulletinMessage>> getBulletinMessages() async {
    final messageSnaps = await fsCollBulletin.where(EnBulletinMessage.isNotice_, isEqualTo: false).orderBy(EnBulletinMessage.modified_, descending: true).get();
    final messageDocs = messageSnaps.docs;
    return List.generate(messageDocs.length, (i) {
      return EnBulletinMessage.fromMap(messageDocs[i].data() as MapDynamic);
    });
  }

  Stream<QuerySnapshot<Object?>> getBulletinNoticeStream() {
    return fsCollBulletin.where(EnBulletinMessage.isNotice_, isEqualTo: true).orderBy(EnBulletinMessage.modified_, descending: true).snapshots();
  }

  Stream<QuerySnapshot<Object?>> getBulletinMessageStream() {
    return fsCollBulletin.where(EnBulletinMessage.isNotice_, isEqualTo: false).orderBy(EnBulletinMessage.modified_, descending: true).snapshots();
  }

  Future<void> saveBulletinMessage(EnBulletinMessage newMessage) async {
    await fsCollBulletin.doc(newMessage.uuid).set(newMessage.toMap());
  }

  Future<void> deleteBulletinMessage(EnBulletinMessage newMessage) async {
    await fsCollBulletin.doc(newMessage.uuid).delete();
  }

  Future<void> addComment({required EnBulletinMessage message, required EnComment comment}) async {
    // convert local file to storage file
    fsDocComment(message: message, comment: comment).set(comment.toMap());
  }

  Stream<QuerySnapshot<Object?>> getBulletinCommentStream(EnBulletinMessage message) {
    return fsCollComment(message: message).orderBy(EnComment.generated_, descending: false).snapshots();
  }

  Future<void> deleteComment({required EnBulletinMessage message, required EnComment comment}) async {
    await fsDocComment(message: message, comment: comment).delete();
  }

//===========================================================
//endregion: Livedata

}
