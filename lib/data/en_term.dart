import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../objectbox.g.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';

@Entity()
class EnTerm extends EnData {
  static const id_ = Constants.keyIndex;
  static const term_ = 'term';
  static const displayTerm_ = 'displayTerm';

  @override
  int get getIndex => id;

  @Id(assignable: true)
  int id;
  String term;
  String displayTerm;

//<editor-fold desc="Data Methods">

  EnTerm({
    required this.id,
    required this.term,
    required this.displayTerm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EnTerm && runtimeType == other.runtimeType && id == other.id && term == other.term && displayTerm == other.displayTerm);

  @override
  int get hashCode => id.hashCode ^ term.hashCode ^ displayTerm.hashCode;

  @override
  String toString() {
    return 'EnTerm{' + ' $id_: $id,' + ' $term_: $term,' + ' $displayTerm_: $displayTerm,' + '}';
  }

  EnTerm copyWith({
    int? id,
    String? term,
    String? displayTerm,
  }) {
    return EnTerm(
      id: id ?? this.id,
      term: term ?? this.term,
      displayTerm: displayTerm ?? this.displayTerm,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    return {
      id_: id,
      term_: term,
      displayTerm_: displayTerm,
    };
  }

  factory EnTerm.fromMap(MapDynamic map) {
    return EnTerm(
      id: map[id_] as int,
      term: map[term_] as String,
      displayTerm: map[displayTerm_] as String,
    );
  }

//</editor-fold>
}
