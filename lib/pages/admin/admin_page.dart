import 'package:enclave/data/en_enclave.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../data/constants.dart';
import '../../data/en_member.dart';
import '../../enclave_app.dart';
import '../../shared/common_ui.dart';
import '../../shared/enclave_menu.dart';
import 'admin_logic.dart';
import 'admin_state.dart';

class AdminPage extends StatelessWidget {
  AdminPage({Key? key}) : super(key: key);
  final AdminLogic logic = Get.find<AdminLogic>();
  final AdminState state = Get.find<AdminLogic>().state;

  @override
  Widget build(BuildContext context) {
    logic.contextAdmin = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('titleAdminPage'.tr),
        actions: gEnMenu.actionsDefault(),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: adminLogic.initAdminPageAsync(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('errorAdminInitialization'.tr + '\n' + snapshot.error.toString()));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              final memberDataSource = MemberDataSource();
              return SfDataGrid(
                // data source
                source: memberDataSource,

                // modes
                columnWidthMode: ColumnWidthMode.auto,
                frozenColumnsCount: 1,

                // showing grid lines
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,

                // editing element
                allowEditing: true,
                navigationMode: GridNavigationMode.cell,
                selectionMode: SelectionMode.single,
                editingGestureType: EditingGestureType.tap,

                // swiping element
                allowSwiping: false,
                //TODO: Adding or Deleting members
                swipeMaxOffset: Constants.cHugeIconSize,
                startSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
                  return GestureDetector(
                      onTap: () {
                        memberDataSource.memberGridRows.insert(
                            rowIndex,
                            const DataGridRow(cells: [
                              DataGridCell(value: 1011, columnName: 'id'),
                              DataGridCell(value: 'Tom Bass', columnName: 'name'),
                              DataGridCell(value: 'Developer', columnName: 'designation'),
                              DataGridCell(value: 20000, columnName: 'salary')
                            ]));
                        memberDataSource.updateMemberGridSource();
                      },
                      child: Container(
                          color: Colors.greenAccent,
                          child: const Center(
                            child: Icon(Icons.add),
                          )));
                },
                endSwipeActionsBuilder: (BuildContext context, DataGridRow row, int rowIndex) {
                  return GestureDetector(
                      onTap: () {
                        memberDataSource.memberGridRows.removeAt(rowIndex);
                        memberDataSource.updateMemberGridSource();
                      },
                      child: Container(
                          color: Colors.redAccent,
                          child: const Center(
                            child: Icon(Icons.delete),
                          )));
                },
                columns: gCurrentEnclave.fields
                    .map((field) => GridColumn(
                          columnName: field.displayTerm,
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            alignment: Alignment.center,
                            color: Theme.of(context).colorScheme.background,
                            child: Text(
                              field.displayTerm,
                              style: TextStyle(
                                color: field.adminEditable ? Theme.of(context).colorScheme.secondary : null,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          allowEditing: field.adminEditable,
                        ))
                    .toList(),
              );
            }
            return Center(
              heightFactor: 3.0,
              child: viewWaiting(context, notice: 'noticeUpdatingEnclaveData'.tr),
            );
          },
        ),
      ),
    );
  }
}

/// An object to set the member collection data source to the dataGrid.
/// This is used to map the member data to the dataGrid widget.
class MemberDataSource extends DataGridSource {
  /// Based on the new value we will commit the new value into the corresponding DataGridCell on onCellSubmit method.
  dynamic newCellValue;

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();
  List<DataGridRow> memberGridRows = [];
  List<EnMember> members = adminLogic.members;

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    final dynamic oldValue = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value ?? '';
    final int dataRowIndex = memberGridRows.indexOf(dataGridRow);
    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    final columnName = column.columnName;
    final member = members[dataRowIndex];
    final field = gCurrentEnclave.fields[rowColumnIndex.columnIndex];
    member.updateFieldValue(field: field, fieldValue: newCellValue);
    memberGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] = DataGridCell<String>(columnName: columnName, value: newCellValue);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value?.toString() ?? '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        keyboardType: TextInputType.text,
        onChanged: (String value) {
          if (value.isNotEmpty) {
            newCellValue = value;
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // In Mobile Platform.
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  /// Creates the employee data source class with required details.
  final fields = gCurrentEnclave.fields;

  MemberDataSource() {
    memberGridRows = adminLogic.members
        .map<DataGridRow>((member) => DataGridRow(
              cells: fields
                  .map((field) => DataGridCell<String>(
                        columnName: field.displayTerm,
                        value: member.findFieldDisplayValue(field),
                      ))
                  .toList(),
            ))
        .toList();
  }

  @override
  List<DataGridRow> get rows => memberGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((memberGridCell) {
      bool isFieldId = memberGridCell.columnName == gCurrentEnclave.fieldDisplayTerm(EnMember.id_);
      bool isFieldName = memberGridCell.columnName == gCurrentEnclave.fieldDisplayTerm(EnMember.personName_);
      bool isFieldMobilePhone = memberGridCell.columnName == gCurrentEnclave.fieldDisplayTerm(EnMember.mobilePhone_);

      return Container(
        alignment: (isFieldId || isFieldName || isFieldMobilePhone) ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.all(Constants.cSmallGap),
        color: isFieldName ? Theme.of(adminLogic.contextAdmin).colorScheme.background : null,
        child: Text(
          memberGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
          style: isFieldName ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
      );
    }).toList());
  }

  void updateMemberGridSource() {
    notifyListeners();
  }
}
