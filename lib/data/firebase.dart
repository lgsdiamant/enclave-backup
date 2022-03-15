import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// Global Firebase Instances
FirebaseAuth get gFbAuth => FirebaseAuth.instance;

/// Global Firebase User Variable
final gRxFsUser = Rx<User?>(null); // will be updated with listener in mainController
User? get gFsUser => gRxFsUser.value; // always updated

bool get gIsValidFsUser => gFsUser != null; // always updated

String get gFsUserUid => gIsValidFsUser ? gFsUser!.uid : ''; // always updated

enum FsId {
  /// for enclave
  enclaves, // enclaves

  members, // enclave-currentEnclaveCode-members
  fields, // enclave-currentEnclaveCode-fields
  terms, // enclave-currentEnclaveCode-terms
  admins, // enclave-currentEnclaveCode-admins
  boards, // enclave-currentEnclaveCode-boards
  pocs, // enclave-currentEnclaveCode-pocs
  urls, // enclave-currentEnclaveCode-urls

  notices, // enclave-currentEnclaveCode-notices
  changes, // enclave-currentEnclaveCode-changes

  /// for live data
  livedata, // livedata
  bulletin, // bulletin

  comment, // for each bulletin message
}
