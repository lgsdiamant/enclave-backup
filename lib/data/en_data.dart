import '../shared/common_ui.dart';

abstract class EnData {
  int get getIndex;

  MapDynamic toMap({List<String>? extFieldNames});
}
