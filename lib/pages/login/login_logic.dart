import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../data/constants.dart';
import '../../data/en_enclave.dart';
import '../../data/firebase.dart';
import '../../data/repository.dart';
import '../../enclave_app.dart';
import '../../main_logic.dart';
import '../../router/router.dart';
import '../../shared/enclave_utility.dart';
import '../setting/setting_logic.dart';
import 'login_state.dart';

///
/// Controller for Login
///
class LoginLogic extends GetxController {
  final state = LoginState();

  List<EnEnclave> myEnclaves = [];
  bool myEnclaveInitialized = false;
  bool _authCompleted = false;
  bool isLoginReady = false;

  final _rxLoginStage = Rx<LoginStage>(LoginStage.needFirebaseSignIn);

  LoginStage get loginStage => _rxLoginStage.value;

  String verificationId = '';

  Future<bool> initCurrentEnclave() async {
    if (isLoginReady) return true;

    // no recent phone number or no auth, we can not initialize current EnEnclave.
    if (gAppSetting.recentMobilePhone.isEmpty || (gFsUser == null)) return false;

    if (!myEnclaveInitialized) {
      mainLogic.isSystem = !testingInvalidSystem && gEnUtil.isSamePhoneNumber(gAppSetting.recentMobilePhone, Constants.systemPhoneNumber);
      mainLogic.isTester = gEnUtil.isSamePhoneNumber(gAppSetting.recentMobilePhone, Constants.testerPhoneNumber);
      myEnclaves = await gEnRepo.findEnclavesWithPhoneNumber(gAppSetting.recentMobilePhone);
    }
    if (myEnclaves.isNotEmpty && !currentEnclaveInitialized) {
      assignNewCurrentEnclave(myEnclaves[0]);
      gAppSetting.saveRecentEnclaveCode(gCurrentEnclave.code);
    }

    return true;
  }

  /// signIn Start with button clicked
  void signInWithPhoneNumber({required String phoneNumber}) async {
    final _phone = gEnUtil.stringToFormalInternationalPhoneNumber(phoneNumber);

    await gFbAuth.verifyPhoneNumber(
      phoneNumber: _phone,

      // 60 second to enter code
      timeout: const Duration(seconds: 60),

      // Automatic handling of the SMS code on Android devices
      verificationCompleted: (PhoneAuthCredential credential) async {
        _authCompleted = true;
        await _signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException exception) {
        _authCompleted = true;
        // Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
        Get.snackbar("termPhoneNumberError".tr, 'noticePhoneNumberInvalid'.tr + exception.code.toString());
        _rxLoginStage.value = LoginStage.needFirebaseSignIn;
      },

      codeSent: (String verificationId, int? forceResendToken) {
        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code
        _rxLoginStage.value = LoginStage.enteringAuthCode;
        this.verificationId = verificationId;
        Get.snackbar("termPhoneAuth".tr, 'noticeCodeSent'.tr);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        if (_authCompleted) {
          determineLoginStage();
        } else {
          Get.snackbar('termLogin'.tr, 'noticeLoginTimeout'.tr, snackPosition: SnackPosition.BOTTOM, barBlur: 0);
          // Handle a timeout of when automatic SMS code handling fails
          _rxLoginStage.value = LoginStage.needFirebaseSignIn;
        }
        _authCompleted = true;
      },
    );
  }

  // proceed phoneAuth with smsCode
  Future<void> proceedPhoneAuthWithAuthCode(String smsCode) async {
    try {
      // Create a PhoneAuthCredential with the code
      AuthCredential _authCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await _signInWithCredential(_authCredential);
    } on Exception catch (e) {
      Get.snackbar('termLoginErr'.tr, 'noticePhoneAutoError'.tr + e.toString(), snackPosition: SnackPosition.BOTTOM, barBlur: 0);
      _rxLoginStage.value = LoginStage.needFirebaseSignIn;
    }
  }

  Future<void> _signInWithCredential(AuthCredential _authCredential) async {
    _authCompleted = true;
    UserCredential _userCredential = await gFbAuth.signInWithCredential(_authCredential);
    final user = _userCredential.user;

    if (user != null) {
      // now phoneVerified, save this in pref file
      gAppSetting.saveRecentPhoneNumber(gEnUtil.stringToFormalKoreanLocalPhoneNumber(user.phoneNumber ?? ''));

      Get.snackbar('termLogin'.tr, 'noticeLoginCompleted'.tr, snackPosition: SnackPosition.BOTTOM, barBlur: 0);

      if (currentEnclaveInitialized && gCurrentEnclave.enclaveValidated) {
        _rxLoginStage.value = LoginStage.validationJustCompleted;
        memberLogic.routeToMemberPage;
      } else {
        _rxLoginStage.value = LoginStage.needEnclaveValidation;
      }
    }
  }

  // signOut from firebase
  Future<void> signOutFirebase() async {
    if (gFsUser != null) {
      // signOut
      await gFbAuth.signOut();
      gRxFsUser.value = null;

      // close database
      gEnRepo.closeCurrentEnclave();
      gCurrentEnclave.isDataReady = false;

      // invalidate login
      loginLogic.isLoginReady = false;

      // clear myEnclaves
      myEnclaves.clear();
      myEnclaveInitialized = false;

      // set loginStage
      _rxLoginStage.value = LoginStage.needFirebaseSignIn;

      // move to loginPage, fresh
      Get.offAllNamed(loginRoute);
    }
  }

  /// determine proper loginStage based on user & verification level
  void determineLoginStage() {
    gRxFsUser.value = gFbAuth.currentUser;

    // if not selecting new enclave, it means in login process
    if (_rxLoginStage.value != LoginStage.selectingNewEnclave) {
      if (gFsUser == null) {
        // no firebase login yet, we need firebase login
        _rxLoginStage.value = LoginStage.needFirebaseSignIn;
      } else if (gAppSetting.recentEnclaveCodeValidated) {
        // firebase auth is done and enclave is validated, treat as validation just completed
        _rxLoginStage.value = LoginStage.validationJustCompleted;
      } else {
        // firebase auth is done and enclave is not validated, we need enclave validation
        _rxLoginStage.value = LoginStage.needEnclaveValidation;
      }
    }
  }

  void loginCompleted() {
    _rxLoginStage.value = LoginStage.selectingNewEnclave;
  }

  /// phone auth completed, but not verified as enClave member yet.
  void assignNewCurrentEnclave(EnEnclave enclave) async {
    // no change of currentEnclave
    if (currentEnclaveInitialized && (gCurrentEnclave == enclave)) return;

    // if different currentEnclave, close database
    if (currentEnclaveInitialized && (gCurrentEnclave != enclave)) {
      gEnRepo.closeCurrentEnclave();

      //??
      bulletinLogic.releaseBulletinStreams();
    }
    EnEnclave.assignCurrentEnclave(enclave);

    gAppSetting.saveRecentEnclaveCode(gCurrentEnclave.code);
    gAppSetting.saveEnclaveValidated(enclave);

    _rxLoginStage.value = LoginStage.validationJustCompleted;
  }

  @override
  onInit() {
    super.onInit();
  }

  @override
  onReady() {
    // player = AudioPlayer();
    super.onReady();
  }

  @override
  onClose() {
    super.onClose();
  }
}
