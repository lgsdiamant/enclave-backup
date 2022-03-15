import 'dart:developer';

import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../data/helper_firestore.dart';
import '../../data/repository.dart';
import '../../shared/enclave_dialog.dart';
import '../../shared/enclave_utility.dart';
import '../main_logic.dart';
import '../shared/common_ui.dart';
import 'constants.dart';
import 'en_admin.dart';
import 'en_board.dart';
import 'en_enclave.dart';
import 'en_field.dart';
import 'en_member.dart';
import 'en_poc.dart';
import 'en_term.dart';
import 'en_url.dart';
import 'firebase.dart';
import 'helper_local.dart';

class ExcelHelper extends Object {
  ExcelHelper({required EnclaveRepository repo, required FirestoreHelper fsHelper, required LocalHelper loHelper})
      : _repo = repo,
        _fsHelper = fsHelper,
        _loHelper = loHelper;

  EnclaveRepository _repo;
  final FirestoreHelper _fsHelper;
  final LocalHelper _loHelper;

  late SpreadsheetDecoder _spreadSheet;
  bool _spreadSheetOpened = false; // indicate the db is opened or not. Check this first before using _dtabase

  bool openEnclaveExcel({bool newCreation = false}) {
    try {
      if (_spreadSheetOpened) return true;

      _spreadSheet = _loHelper.createExcelFromExcelFile();
      _spreadSheetOpened = true;

      return true;
    } on Exception catch (e) {
      gEnDialog.showExceptionError('openEnclaveExcel', e);
      debugger(when: testingStopDebugger);
      return false;
    }
  }

  void closeExcelFile() {
    _spreadSheetOpened = false;
  }

  // for system-only
  /// Given local excel file, transfer local excel file data to firebase enclave database
  Future<bool> transferLocalExcelToFirestore() async {
    //------------------------------------------------------------------------
    List<int> _nullToOneIntegerList(List<dynamic> list) => list.map((e) => ((e == null) ? 1 : gEnUtil.makeSureInteger(e))).toList();
    List<String> _nullToEmptyStringList(List<dynamic> list) => list.map((e) => gEnUtil.nullToEmptyString(e)).toList();
    List<bool> _nullToFalseBooleanList(List<dynamic> list) => list.map((e) => gEnUtil.nullToFalseBoolean(e)).toList();
    void _removeTrailingEmptyColumn(List<dynamic> _rowValues) {
      bool removed = true;
      while (removed) {
        final last = _rowValues.last;
        removed = (last == null) || last.toString().trim().isEmpty;
        if (removed) {
          _rowValues.removeLast();
        }
      }
    }
    //------------------------------------------------------------------------

    try {
      bool success = openEnclaveExcel();

      for (var tableKey in _spreadSheet.tables.keys) {
        // skip invalid table
        var table = _spreadSheet.tables[tableKey];
        if (table == null || table.rows.isEmpty) break;

        if (tableKey == FsId.members.name) {
          // handle 'members' table

          Map<String, List<dynamic>> fieldPropertyMap = {}; // initially empty map
          List<String> fieldNames = []; // initially empty field name
          List<String> memberFieldNames = []; // initially empty field name

          for (final rowValues in table.rows) {
            // for index column. make String valid
            final indexString = gEnUtil.nullToEmptyString(rowValues[0]);
            // if the value of first column is empty, ignore the row
            if (indexString.isEmpty) continue;

            // remove first column, which is placed in indexString
            rowValues.removeAt(0);

            // indexString can be number index of meaningful string
            switch (indexString) {
              // string 'id' => field names
              case Constants.keyIndex:
                // remove trailing null or empty field name if exist
                _removeTrailingEmptyColumn(rowValues);
                fieldNames = _nullToEmptyStringList(rowValues);
                for (String name in fieldNames) {
                  if ((name == EnMember.id_) || (name == EnMember.personName_) || (name == EnMember.mobilePhone_)) continue;
                  memberFieldNames.add(name);
                }
                break;

              // display name of field
              case EnField.displayTerm_: // string 'display_term'
                fieldPropertyMap[indexString] = _nullToEmptyStringList(rowValues);
                break;

              // properties of field: boolean
              case EnField.isDistinct_: // string 'isDistinct'
              case EnField.isPhone_: // string 'isPhone'
              case EnField.isEmail_: // string 'isEmail'
              case EnField.isUrl_: // string 'isUrl'
              case EnField.memberEditable_: // string 'memberEditable'
              case EnField.adminEditable_: // string 'adminEditable'
              case EnField.memberHidable_: // string 'memberHidable'
              case EnField.thumbViewable_: // string 'thumbViewable'
                final aBooleanList = _nullToFalseBooleanList(rowValues); // string null,empty => false, notEmpty => true
                fieldPropertyMap[indexString] = aBooleanList;
                break;

              // properties of maxLines: integer >0
              case EnField.maxLines_: // string 'maxLines'
                fieldPropertyMap[indexString] = _nullToOneIntegerList(rowValues);
                break;

              // now, member data
              default:
                if (fieldNames.isEmpty) throw Exception('empty field names');

                // make field map
                final valueInteger = gEnUtil.makeSureInteger(indexString); // can be -1
                final MapDynamic memberValueMap = {EnMember.id_: valueInteger};

                final memberValues = _nullToEmptyStringList(rowValues);
                for (int index = 0; index < fieldNames.length; index++) {
                  memberValueMap[fieldNames[index]] = (index < memberValues.length) ? memberValues[index] : '';
                }
                success = await _fsHelper.insertFs<EnMember>(
                  EnMember.fromMap(memberValueMap, extFieldNames: memberFieldNames),
                  _fsHelper.fsCollMembers,
                  extFieldNames: memberFieldNames,
                );

                // set document doc parameter value: count increased by 1
                ++_fsHelper.enclaveMembersCount;
                break;
            }
          }

          // now, save member field property to firebase
          int id = 0;

          for (final fieldName in fieldNames) {
            MapDynamic propertyMap = {};
            for (final propertyKey in fieldPropertyMap.keys) {
              final valuesList = fieldPropertyMap[propertyKey]!;
              propertyMap[propertyKey] = valuesList[id];
            }
            propertyMap[Constants.keyFieldName] = fieldName;
            propertyMap[Constants.keyIndex] = ++id; // integer for index
            success = await _fsHelper.insertFs<EnField>(EnField.fromMap(propertyMap), _fsHelper.fsCollFields);
          }
        } else if ((tableKey == FsId.terms.name) ||
            (tableKey == FsId.boards.name) ||
            (tableKey == FsId.pocs.name) ||
            (tableKey == FsId.admins.name) ||
            (tableKey == FsId.urls.name)) {
          if (table.rows.isNotEmpty) {
            List<String> tableFieldNames = [];

            for (final rowValues in table.rows) {
              // the value of first column, it can be string or number
              final indexString = gEnUtil.nullToEmptyString(rowValues[0]);
              if (indexString.isEmpty) continue;

              rowValues.removeAt(0);

              switch (indexString) {
                // field names of table
                case Constants.keyIndex: // string 'id'
                  _removeTrailingEmptyColumn(rowValues);

                  // make list of strings
                  tableFieldNames = _nullToEmptyStringList(rowValues);
                  break;

                default:
                  // index column should be added. index can be string or number. if string, convert to integer
                  final indexInteger = gEnUtil.makeSureInteger(indexString);

                  // map to index
                  final MapDynamic valueFieldMap = {Constants.keyIndex: indexInteger};

                  // make all row values to string
                  final listStings = _nullToEmptyStringList(rowValues);

                  // map fieldName to string values
                  for (var index = 0; index < tableFieldNames.length; index++) {
                    valueFieldMap[tableFieldNames[index]] = listStings[index];
                  }

                  // generate each value of the table, and write to firebase
                  if (tableKey == FsId.terms.name) {
                    final term = EnTerm.fromMap(valueFieldMap);

                    // set enclave doc parameters' value
                    if (term.term == EnEnclave.nameFull_) {
                      _fsHelper.enclaveNameFull = term.displayTerm;
                    } else if (term.term == EnEnclave.nameShort_) {
                      _fsHelper.enclaveNameShort = term.displayTerm;
                    } else if (term.term == EnEnclave.nameSub_) {
                      _fsHelper.enclaveNameSub = term.displayTerm;
                    } else if (term.term == EnEnclave.memberCalling_) {
                      _fsHelper.enclaveMemberCalling = term.displayTerm;
                    }

                    success = await _fsHelper.insertFs<EnTerm>(EnTerm.fromMap(valueFieldMap), _fsHelper.fsCollTerms);
                  } else if (tableKey == FsId.boards.name) {
                    success = await _fsHelper.insertFs<EnBoard>(EnBoard.fromMap(valueFieldMap), _fsHelper.fsCollBoards);
                  } else if (tableKey == FsId.pocs.name) {
                    success = await _fsHelper.insertFs<EnPoc>(EnPoc.fromMap(valueFieldMap), _fsHelper.fsCollPocs);
                  } else if (tableKey == FsId.admins.name) {
                    // 'dbKeyIsMainAdmin' is boolean, not string. but here, it string which can be '' for false.
                    final value = valueFieldMap[EnAdmin.isMain_]; // value is string -> bool
                    final bool isMainAdmin = gEnUtil.nullToFalseBoolean(value);
                    valueFieldMap[EnAdmin.isMain_] = isMainAdmin;

                    success = await _fsHelper.insertFs<EnAdmin>(EnAdmin.fromMap(valueFieldMap), _fsHelper.fsCollAdmins);
                  } else if (tableKey == FsId.urls.name) {
                    success = await _fsHelper.insertFs<EnUrl>(EnUrl.fromMap(valueFieldMap), _fsHelper.fsCollUrls);
                  }
              }
            }
          }
        }
      }
      return true;
    } on Exception catch (e) {
      debugger(when: testingStopDebugger);
      gEnUtil.printDebug(e.toString());
      return false;
    }
  }
}
