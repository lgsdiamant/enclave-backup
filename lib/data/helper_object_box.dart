import 'dart:developer';

import '../../data/helper_firestore.dart';
import '../../data/repository.dart';
import '../main_logic.dart';
import '../objectbox.g.dart';
import 'en_admin.dart';
import 'en_board.dart';
import 'en_data.dart';
import 'en_field.dart';
import 'en_member.dart';
import 'en_poc.dart';
import 'en_term.dart';
import 'en_url.dart';
import 'helper_local.dart';

class ObjectBoxHelper extends Object {
  ObjectBoxHelper({required EnclaveRepository repo, required FirestoreHelper fsHelper, required LocalHelper loHelper})
      : _repo = repo,
        _fsHelper = fsHelper,
        _loHelper = loHelper;

  final EnclaveRepository _repo;
  final FirestoreHelper _fsHelper;
  final LocalHelper _loHelper;

  bool _storeOpened = false;

  // file extension
  String get enclaveCode => _repo.enclaveCode;

  bool get isSystemRepo => _repo.isSystemRepo;

  Store? boxStore;
  
  late Box<EnMember> memberBox;
  late Box<EnTerm> termBox;
  late Box<EnAdmin> adminBox;
  late Box<EnField> fieldBox;
  late Box<EnBoard> boardBox;
  late Box<EnPoc> pocBox;
  late Box<EnUrl> urlBox;

  /// update recent members from last obRefresh. returns the count of recent members
  Future<int> updateRecentFieldValueChangeFromFs() async {
    var recentMembers = await _fsHelper.getRecentlyFieldValueChangedMembers();
    memberBox.putMany(recentMembers);

    // return number of recently changed members
    return (recentMembers.length);
  }

  Box _getProperBox<T extends EnData>() {
    switch (T) {
      case EnField:
        return fieldBox;
      case EnMember:
        return memberBox;
      case EnTerm:
        return termBox;
      case EnAdmin:
        return adminBox;
      case EnBoard:
        return boardBox;
      case EnPoc:
        return pocBox;
      case EnUrl:
        return urlBox;
      default:
        debugger(when: testingStopDebugger);
        throw Exception();
    }
  }

  /// A method that retrieves all the members from the members table.
  List<T> getAll<T extends EnData>() {
    final box = _getProperBox<T>();
    return box.getAll() as List<T>;
  }

  void insertAll<T extends EnData>(List<dynamic> items) {
    final box = _getProperBox<T>();
    box.putMany(items);
  }

  void insert<T extends EnData>(dynamic item) {
    final box = _getProperBox<T>();
    box.put(item);
  }

  /// update given member
  dynamic getItemByIndex<T extends EnData>(int id) {
    final box = _getProperBox<T>();
    box.get(id);
  }

  /// get member by name
  EnMember getMembersByName(String name) {
    // Query<EnMember> query = _memberBox.query(EnMember_.personName.equals(name)).build();
    // List<EnMember> founds = query.find();
    return EnMember.dummyMember;
  }

  /// check objectBox if valid or not
  bool checkObFileValid() {
    return _loHelper.obFileExist();
  }

  bool updateMemberFieldValuesOb(EnMember member) {
    memberBox.put(member);
    return true;
  }

  void openDb() {
    if (_storeOpened) return;

    _storeOpened = true;
    // open store. could be new or existing
    if (boxStore == null) {
      final boxStoreOpened = Store(getObjectBoxModel(), directory: _loHelper.locPathEnclave);

      // open boxes
      memberBox = boxStoreOpened.box<EnMember>();
      fieldBox = boxStoreOpened.box<EnField>();
      termBox = boxStoreOpened.box<EnTerm>();
      adminBox = boxStoreOpened.box<EnAdmin>();
      boardBox = boxStoreOpened.box<EnBoard>();
      pocBox = boxStoreOpened.box<EnPoc>();
      urlBox = boxStoreOpened.box<EnUrl>();

      boxStore = boxStoreOpened;
    }
  }

  void closeDb() {
    if (!_storeOpened) return;

    _storeOpened = false;

    if (boxStore != null) {
      boxStore!.close();
      boxStore = null;
    }
  }
}
