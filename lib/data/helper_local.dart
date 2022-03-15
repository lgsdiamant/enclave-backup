import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../data/helper_firestore.dart';
import '../../data/helper_storage.dart';
import '../../data/repository.dart';
import '../../shared/enclave_dialog.dart';
import '../main_logic.dart';
import 'constants.dart';
import 'en_member.dart';

class LocalHelper extends Object {
  LocalHelper({required EnclaveRepository repo, required FirestoreHelper fsHelper, required StorageHelper stHelper})
      : _repo = repo,
        _fsHelper = fsHelper,
        _stHelper = stHelper {
    asyncInit();
  }

  Future<void> asyncInit() async {
    pathAppDirectory = await getApplicationDocumentsDirectory();
  }

  EnclaveRepository _repo;
  final StorageHelper _stHelper;
  final FirestoreHelper _fsHelper;

  // file extension
  String get enclaveCode => _repo.enclaveCode;

  bool get isSystemRepo => _repo.isSystemRepo;

  String get obFileName => _repo.obFileName;

  String get excelFileName => _repo.excelFileName;

  String get zipFileName => _repo.zipFileName;

  // local path
  static late Directory pathAppDirectory; // will be initializes in getInstance()

  String get locPathEnclaveData => path.join(pathAppDirectory.path, isSystemRepo ? Constants.locSystemDirectoryName : Constants.locUserDirectoryName);

  String get locPathEnclave => path.join(locPathEnclaveData, enclaveCode); // app/enclave_code

  String get locDocObFile => path.join(locPathEnclave, obFileName);

  String get locDocExcelFile => path.join(locPathEnclave, excelFileName);

  String get locDocDataZip => path.join(locPathEnclave, zipFileName);

  String get locPathImage => path.join(locPathEnclave, Constants.stRefImage);

  String get locPathMembersImageFull => path.join(locPathImage, Constants.stRefImageMembersFull); // ~/image/membersFull

  String get locPathMembersImageProfile => path.join(locPathImage, Constants.stRefImageMembersProfile); // ~/image/membersProfile

  // full image
  String locDocMemberFullJpg(EnMember member) => path.join(locPathMembersImageFull, Constants.memberJpgFileName(member));

  String locDocMemberIdFullJpg(EnMember member) => path.join(locPathMembersImageFull, Constants.memberIdJpgFileName(member));

  String locDocMemberFullPng(EnMember member) => path.join(locPathMembersImageFull, Constants.memberPngFileName(member));

  String locDocMemberIdFullPng(EnMember member) => path.join(locPathMembersImageFull, Constants.memberIdPngFileName(member));

  // profile image
  String locDocMemberProfileJpg(EnMember member) => path.join(locPathMembersImageProfile, Constants.memberJpgFileName(member));

  String locDocMemberIdProfileJpg(EnMember member) => path.join(locPathMembersImageProfile, Constants.memberIdJpgFileName(member));

  String locDocMemberProfilePng(EnMember member) => path.join(locPathMembersImageProfile, Constants.memberPngFileName(member));

  String locDocMemberIdProfilePng(EnMember member) => path.join(locPathMembersImageProfile, Constants.memberIdPngFileName(member));

  String get locPathDistinct => path.join(locPathEnclave, Constants.stRefDistinct);

  String locDocDistinctImageJpg(String fieldName, String fieldValue) => path.join(locPathDistinct, fieldName, fieldValue + '.jpg');

  String locDocDistinctImagePng(String fieldName, String fieldValue) => path.join(locPathDistinct, fieldName, fieldValue + '.png');

  String get locPathPdf => path.join(locPathEnclave, Constants.stRefPdf);

  String get locDocBoardPdf => path.join(locPathPdf, Constants.stDocPdfBoard + '.pdf');

  String get locDocRegulationPdf => path.join(locPathPdf, Constants.stDocPdfRegulation + '.pdf');

  /// creating enclave directory if not exist
  bool createEnclaveDirectory() {
    try {
      final Directory dbDirectory = Directory(locPathEnclave);
      final directoryExist = dbDirectory.existsSync();
      if (!directoryExist) {
        dbDirectory.createSync(recursive: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('createEnclaveDirectory', e);
      debugger(when: testingStopDebugger);

      return false;
    }
  }

  /// creating data directory if not exist
  bool createEnclaveDataDirectory() {
    try {
      final Directory dbDirectory = Directory(locPathEnclaveData);
      final directoryExist = dbDirectory.existsSync();
      if (!directoryExist) {
        dbDirectory.createSync(recursive: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('createEnclaveDataDirectory', e);
      debugger(when: testingStopDebugger);

      return false;
    }
  }

  //region: ObjectBox & Excel File
  //===========================================================
  bool deleteObFile() {
    try {
      final excelFile = File(locDocObFile);
      final fileExist = excelFile.existsSync();
      if (fileExist) {
        excelFile.deleteSync(recursive: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('deleteObFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  bool deleteExcelFile() {
    try {
      final excelFile = File(locDocExcelFile);
      final fileExist = excelFile.existsSync();
      if (fileExist) {
        excelFile.deleteSync(recursive: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('deleteExcelFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  // system-only
  Future<bool> downloadExcelFile() async {
    try {
      File excelFile = File(locDocExcelFile);

      // download good excel from firebase storage

      bool success = await _stHelper.downloadExcelFile(excelFile);

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadExcelFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  //===========================================================
  //endregion: ObjectBox & Excel File

  //region: Data file
  //===========================================================

  bool checkZipFileExist() {
    return File(locDocDataZip).existsSync();
  }

  bool _deleteZipFile() {
    try {
      File locZipFile = File(locDocDataZip);
      if (locZipFile.existsSync()) {
        locZipFile.deleteSync();
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('_deleteZipFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  bool _deleteAllDataFiles() {
    try {
      _deleteZipFile();

      _deleteDirectory(locPathMembersImageFull);
      _deleteDirectory(locPathMembersImageProfile);
      _deleteDirectory(locPathPdf);

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('_deleteAllDataFiles', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  bool _deleteDirectory(String dirPath) {
    try {
      Directory dir = Directory(dirPath);
      bool dirExist = dir.existsSync();
      if (dirExist) {
        dir.deleteSync(recursive: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('_deleteDirectory', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  /// download zipFile from storage, returns update time of the doc in storage
  Future<int> downloadAndExtractDataFile() async {
    try {
      File locZipFile = File(locDocDataZip);

      // delete zip file and data files if exist.
      _deleteAllDataFiles();

      // download Zip File from Storage
      int docUpdateTime = await _stHelper.downloadZipFile(locZipFile);

      // Read the Zip file from disk.
      final bytes = locZipFile.readAsBytesSync();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // extract ZIP file
      for (final file in archive) {
        final filename = file.name;
        final filePath = path.join(locPathEnclave, filename);
        if (file.isFile) {
          final data = file.content as List<int>;
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(filePath).create(recursive: true);
        }
      }

      // delete zip-file
      locZipFile.deleteSync();

      return docUpdateTime;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('downloadAndExtractDataFile', e);
      debugger(when: testingStopDebugger);
      return 0;
    }
  }

  //===========================================================
  //endregion: ZIP file

  bool removeEnclaveData() {
    // system & user methods

    try {
      final dataDir = Directory(locPathEnclave);
      final dirExist = dataDir.existsSync();
      if (dirExist) {
        dataDir.deleteSync(recursive: true);
      }

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('removeEnclaveData', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  File getBoardPdfFile() {
    return File(locDocBoardPdf);
  }

  File getRegulationPdfFile() {
    return File(locDocRegulationPdf);
  }

  SpreadsheetDecoder createExcelFromExcelFile() {
    try {
      var bytes = File(locDocExcelFile).readAsBytesSync();
      final archive = SpreadsheetDecoder.decodeBytes(bytes, update: true);
      return archive;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('createExcelFromExcelFile', e);
      debugger(when: testingStopDebugger);
      rethrow;
    }
  }

  bool obFileExist() {
    return File(locDocObFile).existsSync();
  }

  bool deleteProfileImageFile(EnMember member) {
    // check profile-with_id file first
    var profileIdFile = File(locDocMemberIdProfileJpg(member));
    var fExist = profileIdFile.existsSync();
    if (fExist) {
      profileIdFile.deleteSync();
      return true;
    }

    // check profile-without_id file next. JPG
    var profileFile = File(locDocMemberProfileJpg(member));
    fExist = profileFile.existsSync();
    if (fExist) {
      profileFile.deleteSync();
      return true;
    }

    // check profile-with_id file first. PNG
    profileIdFile = File(locDocMemberIdProfilePng(member));
    fExist = profileIdFile.existsSync();
    if (fExist) {
      profileIdFile.deleteSync();
      return true;
    }

    // check profile-without_id file next. PNG
    profileFile = File(locDocMemberProfilePng(member));
    fExist = profileFile.existsSync();
    if (fExist) {
      profileFile.deleteSync();
      return true;
    }

    return false;
  }

  bool deleteFullImageFile(EnMember member) {
    // check full-with_id file first
    var fullIdFile = File(locDocMemberIdFullJpg(member));
    var fExist = fullIdFile.existsSync();
    if (fExist) {
      fullIdFile.deleteSync();
      return true;
    }

    // check profile-without_id file next. JPG
    var profileFile = File(locDocMemberFullJpg(member));
    fExist = profileFile.existsSync();
    if (fExist) {
      profileFile.deleteSync();
      return true;
    }

    // check profile-with_id file first. PNG
    fullIdFile = File(locDocMemberIdFullPng(member));
    fExist = fullIdFile.existsSync();
    if (fExist) {
      fullIdFile.deleteSync();
      return true;
    }

    // check profile-without_id file next. PNG
    profileFile = File(locDocMemberFullPng(member));
    fExist = profileFile.existsSync();
    if (fExist) {
      profileFile.deleteSync();
      return true;
    }

    return false;
  }

  File? updateProfileJpgFileFromMemberProfile(EnMember member) {
    final imageToSave = member.rxProfileImage.value;
    if (imageToSave == null) return null;

    if (imageToSave is FileImage) {
      var profileIdFile = File(locDocMemberIdProfileJpg(member));
      var imageData = img.decodeImage(imageToSave.file.readAsBytesSync());
      if ((imageData != null) && (imageData.width > Constants.defaultProfileSize)) {
        imageData = img.copyResize(imageData, width: Constants.defaultProfileSize);
      }
      if (imageData != null) {
        deleteProfileImageFile(member);
        final jpgData = img.encodeJpg(imageData);
        profileIdFile.writeAsBytesSync(jpgData);
        return profileIdFile;
      }
    }
    return null;
  }

  Future<bool> updateMemberPersonNameFiles(EnMember member) async {
    // profileImage file name should be changed
    if (member.profileImage is FileImage) {
      final oldProfileFile = (member.profileImage as FileImage).file;
      final newProfilePath = locDocMemberIdProfileJpg(member);

      oldProfileFile.renameSync(newProfilePath);

      // update profile image reference
      member.rxProfileImage.value = FileImage(File(newProfilePath));
    }

    // fullImage file name should be changed
    if (member.fullImage is FileImage) {
      final oldFullFile = (member.fullImage as FileImage).file;
      final newFullPath = locDocMemberIdFullJpg(member);

      oldFullFile.renameSync(newFullPath);

      // update full image reference
      member.rxFullImage.value = FileImage(File(newFullPath));
    }

    return true;
  }
}
