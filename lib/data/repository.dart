import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enclave/data/en_bulletin_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/constants.dart';
import '../../shared/enclave_dialog.dart';
import '../../shared/enclave_utility.dart';
import '../enclave_app.dart';
import '../main_logic.dart';
import '../pages/setting/setting_logic.dart';
import 'en_admin.dart';
import 'en_board.dart';
import 'en_comment.dart';
import 'en_enclave.dart';
import 'en_field.dart';
import 'en_member.dart';
import 'en_poc.dart';
import 'en_term.dart';
import 'en_url.dart';
import 'firebase.dart';
import 'helper_asset.dart';
import 'helper_excel.dart';
import 'helper_firestore.dart';
import 'helper_local.dart';
import 'helper_object_box.dart';
import 'helper_storage.dart';

///
/// Global Repository
///

late EnclaveRepository gEnRepo;

class EnclaveRepository {
  static EnclaveRepository? _instance;
  static EnclaveRepository? _instanceSystem;

  factory EnclaveRepository() => _instance ??= EnclaveRepository._(isSystem: false);

  factory EnclaveRepository.system() => _instanceSystem ??= EnclaveRepository._(isSystem: true);

  /// for singleton access
  EnclaveRepository._({required bool isSystem}) {
    isSystemRepo = isSystem;
    _initHelpers();
  }

  void _initHelpers() {
    _stHelper = StorageHelper(repo: this);
    _fsHelper = FirestoreHelper(repo: this);
    _asHelper = AssetHelper(repo: this);

    _loHelper = LocalHelper(repo: this, fsHelper: _fsHelper, stHelper: _stHelper);
    _obHelper = ObjectBoxHelper(repo: this, fsHelper: _fsHelper, loHelper: _loHelper);
    _exHelper = ExcelHelper(repo: this, fsHelper: _fsHelper, loHelper: _loHelper);
  }

  late LocalHelper _loHelper;
  late ObjectBoxHelper _obHelper;
  late ExcelHelper _exHelper;
  late FirestoreHelper _fsHelper;
  late StorageHelper _stHelper;
  late AssetHelper _asHelper;

  bool isSystemRepo = false;
  late String _systemEnclaveCode; // for system-only
  String get enclaveCode => isSystemRepo ? _systemEnclaveCode : (currentEnclaveInitialized ? gCurrentEnclave.code : gAppSetting.recentEnclaveCode);

  String get dbFileName => enclaveCode + '.db';

  String get excelFileName => enclaveCode + '.xlsx';

  String get obFileName => 'data.mdb';

  String get zipFileName => enclaveCode + '.zip';

  /// admin-only method
  void assignSystemEnclaveCode(String newEnclaveCode) {
    _systemEnclaveCode = newEnclaveCode;
    _fsHelper.initEnclaveDocData();
  }

  //region: Refresh
  //===========================================================
  /// forcefully refresh objectBox
  Future<bool> forceRefreshDatabaseFromFirebase() async {
    gEnDialog.showLinearProgressDialog(
      title: 'titleRefreshDatabase'.tr,
      middleText: 'noticeRefreshingDatabase'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
    );
    gCurrentEnclave.closeEnclave();
    bool success = await beReadyDatabase(isForced: true);

    gCurrentEnclave.updateCurrentEnclaveMySelf();
    memberLogic.assignSelectedMember(memberLogic.selectedMember, isForced: true);

    gEnDialog.hideLinearProgressDialog();

    return success;
  }

  /// forcefully refresh data file
  Future<bool> forceRefreshDataFileFromStorage() async {
    gEnDialog.showLinearProgressDialog(
      title: 'titleRefreshDataFile'.tr,
      middleText: 'noticeRefreshingDataFile'.trParams({'enclaveName': gCurrentEnclave.nameFull}),
    );

    bool success = await beReadyDataFile(isForced: true);
    memberLogic.assignSelectedMember(memberLogic.selectedMember, isForced: true);

    gEnDialog.hideLinearProgressDialog();

    return success;
  }

  /// download enclave data(zip) file from firebase to local: user-only method, given gCurrentEnclave
  Future<bool> beReadyDataFile({bool isForced = false}) async {
    // user-only method: SettingUp objectBox, internal method

    if (isForced) {
      gCurrentEnclave.saveDataFileRefreshTimeInvalid();
    }

    int fileCount;

    try {
      if (!gCurrentEnclave.isLocalDataFileReady) {
        // if datafile not ready, download zip file from storage and extract files
        gCurrentEnclave.saveDataFileRefreshTimeInvalid();

        // create user data directory, if not exist.
        bool success = _loHelper.createEnclaveDirectory();

        // local data files are not validated. will be deleted if exist. then download from firebase storage
        int docUpdateTime = await _loHelper.downloadAndExtractDataFile();

        // update all live data based on firestore info
        fileCount = await updateLiveDataFileFromFirestore(forAll: true);

        // save doc update time in sharedPref
        gCurrentEnclave.saveDataFileRefreshTimeValid();
      } else {
        // if datafile is ready, then just update recent live data change based on firestore info
        fileCount = await updateLiveDataFileFromFirestore(forAll: false);
      }

      // save refresh time if files were updated
      if (fileCount > 0) {
        gCurrentEnclave.saveDataFileRefreshTimeValid();
      }

      // forced-update profileImage for mySelf
      if (gCurrentEnclave.mySelf != EnMember.dummyMember) {
        gCurrentEnclave.mySelf.profileImageInitialized = false;
        getMemberProfileImage(gCurrentEnclave.mySelf, isForced: true);
      }
      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('beReadyDataFile', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  /// download enclave database from firebase to local: user-only method, given enclave
  Future<bool> beReadyDatabase({bool isForced = false}) async {
    if (isForced) {
      gCurrentEnclave.saveDatabaseRefreshTimeInvalid();
    }

    try {
      bool newCreation = (!_loHelper.obFileExist() || !gCurrentEnclave.isLocalDatabaseReady);
      bool success = await gCurrentEnclave.openEnclave(newCreation: newCreation);

      return success;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('beReadyEnclaveData', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  //===========================================================
  //endregion: Refresh

  //region: Uploading
  //===========================================================
  /// upload enclave database firebase using Excel file: system-only method, given _systemEnclaveCode
  Future<bool> uploadFirestoreFromExcelStorage() async {
    // system-only
    try {
      // create enclave data file if not exist
      bool success = _loHelper.createEnclaveDirectory();

      // delete excel file if exist
      success = _loHelper.deleteExcelFile();
      _exHelper.closeExcelFile();

      // download excel from storage
      success = await _loHelper.downloadExcelFile();
      if (success) {
        // open downloaded excel
        success = _exHelper.openEnclaveExcel();

        // transfer from all table data to Firestore
        success = await _exHelper.transferLocalExcelToFirestore();

        // record upload time
        // convert all members-board-pocs-admins mobile phone number to formal format: 010-1234-5678 -> 01012345678
        success = await _fsHelper.convertAllMobileNumbers();

        // set enclave doc data
        _fsHelper.saveEnclaveDocData();
      } else {
        gEnDialog.hideLinearProgressDialog();
        gEnDialog.simpleAlert(title: 'titleUploadFailed'.tr, message: 'noticeUploadDatabaseFailed'.tr);
        return false;
      }
      return success;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('uploadFirestoreFromExcelStorage', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  //===========================================================
  //endregion: Uploading

  //region: Image File Handling
  //===========================================================
  /// find member's profile image. for same names, use name with-index: '홍길동-12'
  Future<void> getMemberProfileImage(EnMember member, {bool isForced = false}) async {
    if (!isForced) {
      if (member.profileImageInitialized) return;
      if (member.profileImage != null) return;
    }

    ImageProvider? profileImage;

    // try to find member name_with_Id Jpg file first
    String filePath = _loHelper.locDocMemberIdProfileJpg(member);
    bool fileExist = File(filePath).existsSync();

    // if not exist, try name only Jpg file
    if (!fileExist) {
      filePath = _loHelper.locDocMemberProfileJpg(member);
      fileExist = File(filePath).existsSync();
    }

    // if not exist, try name with_id only Png file
    if (!fileExist) {
      filePath = _loHelper.locDocMemberIdProfilePng(member);
      fileExist = File(filePath).existsSync();
    }

    // if not exist, try name only Png file
    if (!fileExist) {
      filePath = _loHelper.locDocMemberProfilePng(member);
      fileExist = File(filePath).existsSync();
    }

    if (fileExist) {
      profileImage = FileImage(File(filePath));
      member.setProfileImage(profileImage);
    } else {
      profileImage = getAssetImageProfile;
    }

    member.profileImageInitialized = true;
  }

  /// find member's full image. for same names, use name with-index: '홍길동-12'
  Future<void> getMemberFullImage(EnMember member, {bool isForced = false}) async {
    if (!isForced) {
      if (member.fullImageInitialized) return;
      if (member.fullImage != null) return;
    }

    ImageProvider? fullImage;

    // try to find member name_with_Id Jpg file first
    String filePath = _loHelper.locDocMemberIdFullJpg(member);
    bool fileExist = File(filePath).existsSync();

    // if not exist, try name only Jpg file
    if (!fileExist) {
      filePath = _loHelper.locDocMemberFullJpg(member);
      fileExist = File(filePath).existsSync();
    }

    if (fileExist) {
      fullImage = FileImage(File(filePath));
      member.setFullImage(fullImage);
    } else {
      fullImage = null;
    }

    member.fullImageInitialized = true;
  }

  // get profile image from gallery
  Future<bool> getProfileFromPicker(Rx<ImageProvider?> rxImage) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final cropFile = await _cropImageProfile(image.path);
      if (cropFile != null) {
        rxImage.value = FileImage(cropFile);
      } else {
        final imageFile = File(image.path);
        rxImage.value = FileImage(imageFile);
      }
      return true;
    }
    return false;
  }

  // get general image from gallery
  Future<bool> getImageFromPicker(Rx<ImageProvider?> rxImage) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final cropFile = await _cropImageGeneral(image.path);
      if (cropFile != null) {
        rxImage.value = FileImage(cropFile);
      } else {
        final imageFile = File(image.path);
        rxImage.value = FileImage(imageFile);
      }
      return true;
    }
    return false;
  }

  /// Crop Image
  Future<File?> _cropImageProfile(filePath) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      // should be square for profile
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'termCropper'.tr,
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'termCropper'.tr,
      ),
      maxWidth: 1080,
      maxHeight: 1080,
    );
    return croppedImage;
  }

  Future<File?> _cropImageGeneral(filePath) async {
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ]
          : [
              // CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'termCropper'.tr,
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(
        title: 'termCropper'.tr,
      ),
      maxWidth: 1080,
      maxHeight: 1080,
    );
    return croppedImage;
  }

  //===========================================================
  //endregion: Image File Handling

  /// Now closing enclave. Close database, etc
  void closeCurrentEnclave() {
    gCurrentEnclave.closeEnclave();

    EnEnclave.clearCurrentEnclave();

    adminLogic.adminInitialized = false;
  }

  Future<List<EnEnclave>> findEnclavesWithPhoneNumber(String numberString) async {
    final koreaLocalNumber = gEnUtil.stringToFormalKoreanLocalPhoneNumber(numberString);
    final _foundEnclaves = <EnEnclave>[];

    // sub function for adminEnclave
    //-------------------------------------------------------------------------------------------------------
    Future<void> findAdminEnclave() async {
      // find enclave from admins
      final adminSnaps = await FirestoreHelper.fbStore.collectionGroup(FsId.admins.name).where(Constants.keyMobilePhone, isEqualTo: koreaLocalNumber).get();
      for (var adminDoc in adminSnaps.docs) {
        // if it is not in valid root directory, just neglect it.
        final parts = adminDoc.reference.path.split('/');
        if (parts[0] != FsId.enclaves.name) continue;

        // get enclave data
        final enclaveDoc = adminDoc.reference.parent.parent; // doc.reference = enclaves.kma-39.admins.0001, parent.parent = enclaves.kma-39
        final enclaveSnap = await enclaveDoc!.get();
        final enclaveData = enclaveSnap.data() ?? {};

        // find enclave found
        String adminEnclaveCode = enclaveData[EnEnclave.code_];
        EnEnclave? adminEnclave;
        for (var enclave in _foundEnclaves) {
          if (enclave.code == adminEnclaveCode) {
            adminEnclave = enclave;
            break;
          }
        }

        if (adminEnclave == null) {
          final fieldNames = await _fsHelper.getMemberFieldNamesFs(fieldCollRef: enclaveSnap.reference.collection(FsId.fields.name));

          adminEnclave = EnEnclave.fromMap(enclaveData, fieldNames: fieldNames, self: EnMember.dummyMember);
          _foundEnclaves.add(adminEnclave);
        }

        adminEnclave.assignAdmin(EnAdmin.fromMap(adminDoc.data()));
      }
    }
    //-------------------------------------------------------------------------------------------------------

    try {
      closeCurrentEnclave();

      if (mainLogic.isSystem) {
        // for system, access all enclaves including test-enclave
        _foundEnclaves.addAll(await _getAllSystemEnclaves(koreaLocalNumber));
        await findAdminEnclave();
      } else if (mainLogic.isTester) {
        // for tester, access all demo enclaves including test-enclave
        _foundEnclaves.addAll(await _getAllDemoEnclaves(testerPhoneNumber: koreaLocalNumber));
      } else {
        // find enclave from members
        var memberSnap = await FirestoreHelper.fbStore.collectionGroup(FsId.members.name).where(Constants.keyMobilePhone, isEqualTo: koreaLocalNumber).get();
        for (var memberDoc in memberSnap.docs) {
          // if it is not in valid root directory, just neglect it.
          final parts = memberDoc.reference.path.split('/');
          if (parts[0] != FsId.enclaves.name) continue;

          // get enclave data
          final enclaveDoc = memberDoc.reference.parent.parent;
          final enclaveSnap = await enclaveDoc!.get();
          final enclaveData = enclaveSnap.data();

          if (enclaveData != null) {
            final fieldNames = await _fsHelper.getMemberFieldNamesFs(fieldCollRef: enclaveSnap.reference.collection(FsId.fields.name));
            final enclave = EnEnclave.fromMap(enclaveData, fieldNames: fieldNames, self: EnMember.fromMap(memberDoc.data(), extFieldNames: fieldNames));

            // if enclave is demo enclave or dev enclave, just skip.
            final String enclaveCode = enclave.code;
            if (enclaveCode.startsWith(Constants.demoEnclavePrefix)) continue;
            if (enclaveCode.startsWith(Constants.devEnclavePrefix)) continue;

            // if enclave is not activated, just skip.
            if (!enclave.activated) continue;

            // exclude duplicate
            bool added = false;
            for (var fEnclave in _foundEnclaves) {
              if (enclave.code == fEnclave.code) {
                added = true;
                break;
              }
            }
            if (added) continue; // already added.

            _foundEnclaves.add(enclave);
          }
        }

        await findAdminEnclave();

        // if no valid enclave, just use demo enclave
        if (_foundEnclaves.isEmpty) {
          _foundEnclaves.addAll(await _getAllDemoEnclaves());
        }
      }

      // match recent enclave if exist
      for (var enclave in _foundEnclaves) {
        if (enclave.code == gAppSetting.recentEnclaveCode) {
          EnEnclave.assignCurrentEnclave(enclave);
          break;
        }
      }

      // 'myEnclaves found' completed:
      loginLogic.myEnclaveInitialized = true;
      return _foundEnclaves;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('findEnclavesWithPhoneNumber', e);
      debugger(when: testingStopDebugger);
      return <EnEnclave>[];
    }
  }

  //region: get Members
  //===========================================================
  List<EnMember> getMembersByFieldRoughValue({required EnField field, required String searchTerm}) {
    return gCurrentEnclave.getMembersByFieldRoughValue(field: field, roughValue: searchTerm);
  }

  //===========================================================
  //endregion: get Members

  /// get all enclaves
  Future<List<EnEnclave>> _getAllSystemEnclaves(String phoneNumber) async {
    return await _fsHelper.getAllSystemEnclaves(phoneNumber);
  }

  /// get all enclaves
  Future<List<EnEnclave>> _getAllDemoEnclaves({String? testerPhoneNumber}) async {
    return await _fsHelper.getAllDemoEnclaves(testerPhoneNumber);
  }

  //region: Assets
  //===========================================================
  static ImageProvider get getAssetEnclaveLogo => AssetHelper.assetImageEnclaveLogo;

  static ImageProvider get getAssetEnclaveIcon => AssetHelper.assetIconEnclave;

  static ImageProvider get getAssetImageKMA => AssetHelper.assetImageKMA;

  static ImageProvider get getAssetImageKADIS => AssetHelper.assetImageKADIS;

  static ImageProvider get getAssetImageKPC => AssetHelper.assetImageKPC;

  static ImageProvider get getAssetImageProfile => AssetHelper.assetImageProfile;

  Future<EnMember> getFirstMemberFs(EnEnclave enclave) async {
    return await _fsHelper.getFirstMember(enclave);
  }

  /// update member data
  Future<bool> updateMemberFieldValues(EnMember member) async {
    // save updated member data in fireStore
    bool successFs = await _fsHelper.updateMemberFieldValuesFs(member);

    // save updated member data in objectBox
    bool successEn = _obHelper.updateMemberFieldValuesOb(member);

    return successEn && successFs;
  }

  File getBoardPdfFile() {
    return _loHelper.getBoardPdfFile();
  }

  File getRegulationPdfFile() {
    return _loHelper.getRegulationPdfFile();
  }

  Future<bool> excelFileExistInStorage() async {
    return await _stHelper.excelFileExistInStorage();
  }

  Future<int> updateRecentFieldChangesFromFs() async {
    int fieldChangedCount = await _obHelper.updateRecentFieldValueChangeFromFs();
    return fieldChangedCount;
  }

  Future<bool> updateProfileChanged(EnMember member) async {
    try {
      // first, update local profile image data
      final jpgFile = _loHelper.updateProfileJpgFileFromMemberProfile(member);
      if (jpgFile != null) {
        member.rxProfileImage.value = FileImage(jpgFile);
      }

      // second, save image data in firebase storage
      bool success = await _stHelper.saveProfileImageToStorage(member);
      if (success) {
        // lastly, record member's lastProfileChange timestamp
        _fsHelper.updateProfileImageChanged(member);
      }

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('updateProfileImage', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

//===========================================================
// endregion: Assets

  String getEnclaveDirectory() {
    return _loHelper.locPathEnclave;
  }

  bool deleteObFile() {
    return _loHelper.deleteObFile();
  }

  ///
  /// Given local objectBox file, transfer firebase enclave database to local objectBox
  ///
  Future<bool> transferEnclaveDataFromFirebase() async {
    // note: make sure that fresh objectBox file is created, and opened

    try {
      // transfer fields from firebase to box
      gCurrentEnclave.fields = await _fsHelper.getAllFieldsFs();
      _obHelper.fieldBox.putMany(gCurrentEnclave.fields);

      // transfer boards info to local Db
      gCurrentEnclave.terms = await _fsHelper.getAllTermsFs();
      _obHelper.termBox.putMany(gCurrentEnclave.terms);

      // transfer boards info to local Db
      gCurrentEnclave.boards = await _fsHelper.getAllBoardsFs();
      _obHelper.boardBox.putMany(gCurrentEnclave.boards);

      // transfer pocs info to local Db
      gCurrentEnclave.pocs = await _fsHelper.getAllPocsFs();
      _obHelper.pocBox.putMany(gCurrentEnclave.pocs);

      // transfer admins info to firebase
      gCurrentEnclave.admins = await _fsHelper.getAllAdminsFs();
      _obHelper.adminBox.putMany(gCurrentEnclave.admins);

      // transfer urls info to firebase
      gCurrentEnclave.urls = await _fsHelper.getAllUrlsFs();
      _obHelper.urlBox.putMany(gCurrentEnclave.urls);

      // set member fieldNames
      EnMember.assignFieldNames(gCurrentEnclave.fields);

      // transfer members to local Db
      gCurrentEnclave.members = await _fsHelper.getAllMembersFs();
      _obHelper.memberBox.putMany(gCurrentEnclave.members);

      return true; //success
    } on Exception catch (e) {
      gEnDialog.showExceptionError('_transferDataFromFirebase', e);
      debugger(when: testingStopDebugger);
      return false; //fail
    }
  }

  ///
  /// transfer objectBox data to memory
  ///
  bool transferEnclaveDataFromStore() {
    // note: make sure that fresh objectBox file is created, and opened

    try {
      // first of all, get meta data including member fields
      gCurrentEnclave.fields = _obHelper.getAll<EnField>();
      gCurrentEnclave.terms = _obHelper.getAll<EnTerm>();
      gCurrentEnclave.boards = _obHelper.getAll<EnBoard>();
      gCurrentEnclave.pocs = _obHelper.getAll<EnPoc>();
      gCurrentEnclave.admins = _obHelper.getAll<EnAdmin>();
      gCurrentEnclave.urls = _obHelper.getAll<EnUrl>();

      // make EnMember field names valid, excluding id, personName, mobilePhone
      EnMember.assignFieldNames(gCurrentEnclave.fields);

      // fet all members
      gCurrentEnclave.members = _obHelper.getAll<EnMember>();

      return true; //success
    } on Exception catch (e) {
      gEnDialog.showExceptionError('_initAllDataFromStore', e);
      debugger(when: testingStopDebugger);
      return false; //fail
    }
  }

  void openOb() {
    _obHelper.openDb();
  }

  void closeOb() {
    _obHelper.closeDb();
  }

  Future<bool> updateMemberPersonNameFiles(EnMember member) async {
    await _loHelper.updateMemberPersonNameFiles(member);
    return true;
  }

  /// download all profile & full image files from storage
  Future<int> updateLiveDataFileFromFirestore({required bool forAll}) async {
    final profileImageMembers = await _fsHelper.getMembersWithLiveProfileImage(forAll: forAll);
    for (final member in profileImageMembers) {
      final docExist = await _stHelper.storageDocExist(member.storageDocProfileImage);

      // if live data exist, delete local file and download file from storage
      if (docExist) {
        // delete old profile image file in disk
        bool success = _loHelper.deleteProfileImageFile(member);

        // save new profile image file on disk
        success = await _stHelper.downloadMemberProfileImageFile(member: member, locMemberProfileFile: File(_loHelper.locDocMemberIdProfileJpg(member)));
      }
    }

    final fullImageMembers = await _fsHelper.getMembersWithLiveFullImage(forAll: forAll);
    for (final member in fullImageMembers) {
      final docExist = await _stHelper.storageDocExist(member.storageDocFullImage);
      if (docExist) {
        // delete old profile image file in disk
        bool success = _loHelper.deleteFullImageFile(member);
        // save new profile image file on disk
        success = await _stHelper.downloadMemberFullImageFile(member: member, locMemberFullImageFile: File(_loHelper.locDocMemberIdFullJpg(member)));
      }
    }

    return profileImageMembers.length + fullImageMembers.length;
  }

  String getAboutAppPdfPath() {
    return _asHelper.getAboutAppPdfPath();
  }

  Future<void> saveBulletinMessage(EnBulletinMessage newMessage) async {
    await _fsHelper.saveBulletinMessage(newMessage);
  }

  Future<void> deleteBulletinMessage(EnBulletinMessage newMessage) async {
    await _fsHelper.deleteBulletinMessage(newMessage);
  }

  Future<List<EnBulletinMessage>> getPublicNotices() async {
    return await _fsHelper.getPublicNotices();
  }

  Future<List<EnBulletinMessage>> getBulletinMessages() async {
    return await _fsHelper.getBulletinMessages();
  }

  ImageProvider getProfileImageFromMemberNameId(String personName, int personId) {
    final member = getMemberByNameId(personName, personId);
    if (member == EnMember.dummyMember) return getAssetImageProfile;
    return member.profileImage ?? getAssetImageProfile;
  }

  EnMember getMemberByNameId(String personName, int personId) {
    for (final member in gCurrentEnclave.members) {
      if ((member.personName == personName) && (member.getIndex == personId)) return member;
    }
    return EnMember.dummyMember;
  }

  Stream<QuerySnapshot> getBulletinNoticeStream() {
    return _fsHelper.getBulletinNoticeStream();
  }

  Stream<QuerySnapshot> getBulletinMessageStream() {
    return _fsHelper.getBulletinMessageStream();
  }

  Future<void> addComment({required EnBulletinMessage message, required String commentText, FileImage? fileImage}) async {
    final uuid = mainLogic.uuidGen.v4();

    // save file image to storage
    final storageUrl = (fileImage == null) ? '' : await _stHelper.uploadCommentFileImage(uuid: uuid, fileImage: fileImage);

    // save comment with storageUrl
    final member = gCurrentEnclave.mySelf;
    final comment = EnComment(
      uuid: uuid,
      content: commentText,
      imageUrl: storageUrl,
      personName: member.personName,
      personId: member.getIndex,
      generated: DateTime.now().millisecondsSinceEpoch,
    );
    _fsHelper.addComment(message: message, comment: comment);
  }

  Stream<QuerySnapshot<Object?>> getBulletinCommentStream(EnBulletinMessage message) {
    return _fsHelper.getBulletinCommentStream(message);
  }

  void deleteComment({required EnBulletinMessage message, required EnComment comment}) {
    // delete image first
    if (comment.imageUrl.isNotEmpty) {
      _stHelper.deleteBucketStorageFile(gsBucketUrl: comment.imageUrl);
    }

    _fsHelper.deleteComment(message: message, comment: comment);
  }
}
