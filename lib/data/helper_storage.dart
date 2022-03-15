import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

import '../../data/repository.dart';
import '../../shared/enclave_dialog.dart';
import '../main_logic.dart';
import 'constants.dart';
import 'en_member.dart';
import 'firebase.dart';

class StorageHelper extends Object {
  static firebase_storage.FirebaseStorage get fbStorage => firebase_storage.FirebaseStorage.instance;

  static firebase_storage.Reference get fbStorageRootRef => fbStorage.ref();

  StorageHelper({required EnclaveRepository repo}) : _repo = repo;

  final EnclaveRepository _repo;

  // file extension
  String get enclaveCode => _repo.enclaveCode;

  bool get isSystemRepo => _repo.isSystemRepo;

  String get dbFileName => _repo.dbFileName;

  String get excelFileName => _repo.excelFileName;

  String get zipFileName => _repo.zipFileName;

  // firebase_storage.Reference
  firebase_storage.Reference get _stRefEnclave => fbStorageRootRef.child(FsId.enclaves.name).child(enclaveCode);

  firebase_storage.Reference get _stDocDbFile => _stRefEnclave.child(dbFileName);

  firebase_storage.Reference get _stDocExcelFile => _stRefEnclave.child(excelFileName);

  firebase_storage.Reference get _stDocDataFileZip => _stRefEnclave.child(zipFileName);

  firebase_storage.Reference get _stRefLiveData => _stRefEnclave.child(Constants.stRefLiveData);

  firebase_storage.Reference get _stRefImage => _stRefLiveData.child(Constants.stRefImage);

  firebase_storage.Reference get _stRefMembersFull => _stRefLiveData.child(Constants.stRefImageMembersFull);

  firebase_storage.Reference get _stRefMembersProfile => _stRefLiveData.child(Constants.stRefImageMembersProfile);

  firebase_storage.Reference _stDocMemberFullJpg(EnMember member) => _stRefMembersFull.child(Constants.memberJpgFileName(member));

  firebase_storage.Reference _stDocMemberIdFullJpg(EnMember member) => _stRefMembersFull.child(Constants.memberIdJpgFileName(member));

  firebase_storage.Reference _stDocMemberProfileJpg(EnMember member) => _stRefMembersProfile.child(Constants.memberIdJpgFileName(member));

  firebase_storage.Reference _stDocMemberIdProfileJpg(EnMember member) => _stRefMembersProfile.child(Constants.memberIdJpgFileName(member));

  firebase_storage.Reference get _stRefDistinct => _stRefEnclave.child(Constants.stRefDistinct);

  firebase_storage.Reference _stDocDistinct(String fieldName, String fieldValue) => _stRefDistinct.child(fieldName).child(fieldValue + '.jpg');

  firebase_storage.Reference get _stRefPdf => _stRefLiveData.child(Constants.stRefPdf);

  firebase_storage.Reference get _stDocPdfBoard => _stRefLiveData.child(Constants.stDocPdfBoard + '.pdf');

  firebase_storage.Reference get _stDocPdfRegulation => _stRefLiveData.child(Constants.stDocPdfRegulation + '.pdf');

  // place to save comment image
  firebase_storage.Reference get _stRefComment => _stRefLiveData.child(FsId.comment.name);

  // download zipFile from storage. return the update time in millisecondsSinceEpoch.
  Future<int> downloadZipFile(File locZipFile) async {
    try {
      await _stDocDataFileZip.writeToFile(locZipFile);
      FullMetadata metadata = await _stDocDataFileZip.getMetadata();
      return metadata.updated!.millisecondsSinceEpoch;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadZipFile', e);
      debugger(when: testingStopDebugger);
      return 0;
    }
  }

  Future<bool> downloadMemberProfileImageFile({required EnMember member, required File locMemberProfileFile}) async {
    try {
      final docExist = await storageDocExist(member.storageDocProfileImage);
      if (docExist) {
        final docProfile = fbStorage.ref(member.storageDocProfileImage);
        await docProfile.writeToFile(locMemberProfileFile);
        return true;
      }
      return false;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadMemberProfileImageFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  Future<bool> downloadMemberFullImageFile({required EnMember member, required File locMemberFullImageFile}) async {
    try {
      final docExist = await storageDocExist(member.storageDocFullImage);
      if (docExist) {
        final docFull = fbStorageRootRef.child(member.storageDocFullImage);
        await docFull.writeToFile(locMemberFullImageFile);
        return true;
      }
      return false;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadMemberFullImageFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  Future<bool> downloadExcelFile(File locExcelFile) async {
    try {
      await _stDocExcelFile.writeToFile(locExcelFile);
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadExcelFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  Future<bool> excelFileExistInStorage() async {
    return (await storageDocExist(_stDocExcelFile.fullPath));
  }

  /// delete storage doc if exist.
  Future<bool> _deleteDocRef(firebase_storage.Reference docRef) async {
    final docExist = await storageDocExist(docRef.fullPath);
    if (docExist) {
      await docRef.delete();
      return true;
    }
    return false;
  }

  /// upload profile image file from local to firestore
  Future<bool> saveProfileImageToStorage(EnMember member) async {
    final imageToSave = member.rxProfileImage.value;
    if (imageToSave is! FileImage) return false;

    try {
      // file references
      String fileName = path.basename(imageToSave.file.path);
      File imageFile = imageToSave.file;

      // get doc reference
      final newProfileDocRef = _stDocMemberIdProfileJpg(member);

      // file metadata
      final metadata = firebase_storage.SettableMetadata(contentType: 'image/jpeg', customMetadata: {'picked-file-path': fileName});

      // check if the old doc exist or not. if exist, delete it
      if (member.storageDocProfileImage.isNotEmpty) {
        final oldProfileDocRef = fbStorage.ref(member.storageDocProfileImage);
        bool success = await _deleteDocRef(oldProfileDocRef);
      }

      // assign new doc reference
      member.storageDocProfileImage = newProfileDocRef.fullPath;

      // upload file to storage
      firebase_storage.UploadTask uploadTask = newProfileDocRef.putFile(imageFile, metadata);
      await Future.value(uploadTask);

      Future.value(uploadTask)
          .then((value) => {print("Upload file path ${value.ref.fullPath}")})
          .onError((error, stackTrace) => {print("Upload file path error ${error.toString()} ")});

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('uploadProfileImageToFirebase', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  /// check if file exist or not
  Future<bool> storageDocExist(String docPath) async {
    var parts = docPath.split('/');
    var path = parts.sublist(0, parts.length - 1).join('/');

    final refDir = fbStorage.ref(path);
    var listResult = await refDir.list();

    return listResult.items.any((element) => element.fullPath == docPath);
  }

  /// save comment file image, and return doc ref
  Future<String> uploadCommentFileImage({required String uuid, required FileImage fileImage}) async {
    try {
      // file references
      String fileName = path.basename(fileImage.file.path);
      String fileExt = path.extension(fileName);
      final uuidExt = path.setExtension(uuid, fileExt);
      final newCommentDocRef = _stRefComment.child(uuidExt);

      // file metadata
      final metadata = firebase_storage.SettableMetadata(contentType: 'image/jpeg', customMetadata: {'picked-file-path': fileName});

      // assign new doc reference
      final fullRefPath = newCommentDocRef.fullPath;

      // upload file to storage
      await newCommentDocRef.putFile(fileImage.file, metadata);
      String bucketPath = 'gs://${newCommentDocRef.bucket}/${newCommentDocRef.fullPath}';

      var dowUrl = await newCommentDocRef.getDownloadURL();

      //
      // firebase_storage.UploadTask uploadTask = newCommentDocRef.putFile(fileImage.file, metadata);
      // var dowUrl = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
      //
      // await Future.value(uploadTask);
      //
      // Future.value(uploadTask)
      //     .then((value) => {print("Upload file path ${value.ref.fullPath}")})
      //     .onError((error, stackTrace) => {print("Upload file path error ${error.toString()} ")});

      return bucketPath;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('uploadProfileImageToFirebase', e);
      debugger(when: testingStopDebugger);
      return '';
    }
  }

  /// delete storage file with bucket url: 'gs://~'
  void deleteBucketStorageFile({required String gsBucketUrl}) {
    final docRef = fbStorage.refFromURL(gsBucketUrl);
    try {
      docRef.delete();
    } on Exception catch (e) {
      debugPrint('file not exist: ${docRef.fullPath}');
    }
  }
}