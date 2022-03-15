import 'package:objectbox/objectbox.dart';

import '../../data/constants.dart';
import '../objectbox.g.dart';
import '../shared/common_ui.dart';
import 'en_data.dart';

@Entity()
class EnUrl extends EnData {
  static const id_ = Constants.keyIndex;
  static const title_ = 'title';
  static const address_ = 'address';
  static const description_ = 'description';

  @override
  int get getIndex => id;

  @Id(assignable: true)
  int id;
  String title;
  String address;
  String description;

//<editor-fold desc="Data Methods">

  EnUrl({
    required this.id,
    required this.title,
    required this.address,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnUrl && runtimeType == other.runtimeType && id == other.id && title == other.title && address == other.address && description == other.description);

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ address.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'EnUrl{' + ' $id_: $id,' + ' $title_: $title,' + ' $address_: $address,' + ' $description_: $description,' + '}';
  }

  EnUrl copyWith({
    int? id,
    String? title,
    String? address,
    String? desc,
  }) {
    return EnUrl(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      description: desc ?? this.description,
    );
  }

  @override
  MapDynamic toMap({List<String>? extFieldNames}) {
    return {
      id_: id,
      title_: title,
      address_: address,
      description_: description,
    };
  }

  factory EnUrl.fromMap(MapDynamic map) {
    return EnUrl(
      id: map[id_] as int,
      title: map[title_] as String,
      address: map[address_] as String,
      description: map[description_] as String,
    );
  }

//</editor-fold>
}
