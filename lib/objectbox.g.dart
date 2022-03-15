// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'data/en_admin.dart';
import 'data/en_board.dart';
import 'data/en_field.dart';
import 'data/en_member.dart';
import 'data/en_poc.dart';
import 'data/en_term.dart';
import 'data/en_url.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 7187183267458213962),
      name: 'EnAdmin',
      lastPropertyId: const IdUid(5, 2669680085190594451),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5788958423044726213),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 5812627185923108440),
            name: 'isMain',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 141181934719245825),
            name: 'personName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 5762077165316870626),
            name: 'mobilePhone',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 2669680085190594451),
            name: 'email',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(2, 5436227338917221730),
      name: 'EnBoard',
      lastPropertyId: const IdUid(5, 54900813849247124),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 3334358835952382233),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 7461178395802149410),
            name: 'boardTitle',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 6141843203331277251),
            name: 'personName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 1179410592844837856),
            name: 'mobilePhone',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 54900813849247124),
            name: 'email',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(3, 4869442814838137858),
      name: 'EnMember',
      lastPropertyId: const IdUid(17, 4848491494901352075),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 3787361899978391512),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(7, 2699924386844197680),
            name: 'personName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 6615687450958295100),
            name: 'mobilePhone',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 5743418513371203710),
            name: 'fieldValues',
            type: 30,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 7040886064405686201),
            name: 'lastFieldValueChanged',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(14, 8999559001868078828),
            name: 'lastFullImageChanged',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(15, 8271550908458450241),
            name: 'lastProfileImageChanged',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(16, 374728678307877224),
            name: 'storageDocProfileImage',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(17, 4848491494901352075),
            name: 'storageDocFullImage',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(5, 673941242796280038),
      name: 'EnPoc',
      lastPropertyId: const IdUid(5, 4739967624339059596),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 7320642411645203891),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 6117512970514426283),
            name: 'boardTitle',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 1011055479748994393),
            name: 'personName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 5089835824418652050),
            name: 'mobilePhone',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 4739967624339059596),
            name: 'email',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(6, 5980223006355388632),
      name: 'EnTerm',
      lastPropertyId: const IdUid(3, 3292261121966577974),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 2448612381880281395),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 5874727293580059190),
            name: 'term',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 3292261121966577974),
            name: 'displayTerm',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(7, 7999344748895732531),
      name: 'EnUrl',
      lastPropertyId: const IdUid(4, 1151382343130307201),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 6433329058985063113),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 7668391491956406050),
            name: 'title',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 7865753926379470656),
            name: 'address',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 1151382343130307201),
            name: 'description',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(8, 7354943905839322380),
      name: 'EnField',
      lastPropertyId: const IdUid(13, 8902913224504232047),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 2353061578105105232),
            name: 'id',
            type: 6,
            flags: 129),
        ModelProperty(
            id: const IdUid(2, 9060233389112597378),
            name: 'fieldName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 4435874965641172982),
            name: 'isDistinct',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 527004546555030727),
            name: 'isPhone',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 9145940399941631855),
            name: 'isUrl',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 5699418316106754506),
            name: 'isEmail',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 990088651495142203),
            name: 'adminEditable',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 6962090498799523950),
            name: 'memberEditable',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 225750685023622616),
            name: 'memberHidable',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(11, 4552284413952812992),
            name: 'thumbViewable',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(12, 6277064110487980320),
            name: 'maxLines',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(13, 8902913224504232047),
            name: 'displayTerm',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Open an ObjectBox store with the model declared in this file.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(8, 7354943905839322380),
      lastIndexId: const IdUid(0, 0),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [5753447025777262262],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        5668580988109365044,
        3805453618052193611,
        1570209675609348287,
        4290005978425452609,
        3523587056584268485,
        4603950754830115050,
        5259439042091450437,
        8788550569784654141,
        5715443830768221861,
        1285293886135312919,
        4287103933090011208,
        7700039451723380046,
        4630865486973681769,
        1083478646112366745,
        5624098247966504271,
        5703911407809906685,
        1549119732520770140,
        7020471117687623662,
        5198772753135196615,
        7155106865483675208,
        5257380455920900378
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    EnAdmin: EntityDefinition<EnAdmin>(
        model: _entities[0],
        toOneRelations: (EnAdmin object) => [],
        toManyRelations: (EnAdmin object) => {},
        getId: (EnAdmin object) => object.id,
        setId: (EnAdmin object, int id) {
          object.id = id;
        },
        objectToFB: (EnAdmin object, fb.Builder fbb) {
          final personNameOffset = fbb.writeString(object.personName);
          final mobilePhoneOffset = fbb.writeString(object.mobilePhone);
          final emailOffset = fbb.writeString(object.email);
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addBool(1, object.isMain);
          fbb.addOffset(2, personNameOffset);
          fbb.addOffset(3, mobilePhoneOffset);
          fbb.addOffset(4, emailOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnAdmin(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              isMain:
                  const fb.BoolReader().vTableGet(buffer, rootOffset, 6, false),
              personName: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              mobilePhone: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              email: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, ''));

          return object;
        }),
    EnBoard: EntityDefinition<EnBoard>(
        model: _entities[1],
        toOneRelations: (EnBoard object) => [],
        toManyRelations: (EnBoard object) => {},
        getId: (EnBoard object) => object.id,
        setId: (EnBoard object, int id) {
          object.id = id;
        },
        objectToFB: (EnBoard object, fb.Builder fbb) {
          final boardTitleOffset = fbb.writeString(object.boardTitle);
          final personNameOffset = fbb.writeString(object.personName);
          final mobilePhoneOffset = fbb.writeString(object.mobilePhone);
          final emailOffset = fbb.writeString(object.email);
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, boardTitleOffset);
          fbb.addOffset(2, personNameOffset);
          fbb.addOffset(3, mobilePhoneOffset);
          fbb.addOffset(4, emailOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnBoard(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              boardTitle: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              personName: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              mobilePhone: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              email: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, ''));

          return object;
        }),
    EnMember: EntityDefinition<EnMember>(
        model: _entities[2],
        toOneRelations: (EnMember object) => [],
        toManyRelations: (EnMember object) => {},
        getId: (EnMember object) => object.id,
        setId: (EnMember object, int id) {
          object.id = id;
        },
        objectToFB: (EnMember object, fb.Builder fbb) {
          final personNameOffset = fbb.writeString(object.personName);
          final mobilePhoneOffset = fbb.writeString(object.mobilePhone);
          final fieldValuesOffset = fbb.writeList(
              object.fieldValues.map(fbb.writeString).toList(growable: false));
          final storageDocProfileImageOffset =
              fbb.writeString(object.storageDocProfileImage);
          final storageDocFullImageOffset =
              fbb.writeString(object.storageDocFullImage);
          fbb.startTable(18);
          fbb.addInt64(0, object.id);
          fbb.addOffset(6, personNameOffset);
          fbb.addOffset(7, mobilePhoneOffset);
          fbb.addOffset(8, fieldValuesOffset);
          fbb.addInt64(11, object.lastFieldValueChanged);
          fbb.addInt64(13, object.lastFullImageChanged);
          fbb.addInt64(14, object.lastProfileImageChanged);
          fbb.addOffset(15, storageDocProfileImageOffset);
          fbb.addOffset(16, storageDocFullImageOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnMember(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              personName: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 16, ''),
              mobilePhone: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 18, ''),
              fieldValues: const fb.ListReader<String>(fb.StringReader(asciiOptimization: true), lazy: false)
                  .vTableGet(buffer, rootOffset, 20, []),
              lastFieldValueChanged:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 26, 0),
              lastProfileImageChanged:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 32, 0),
              lastFullImageChanged:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 30, 0),
              storageDocProfileImage: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 34, ''),
              storageDocFullImage: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 36, ''));

          return object;
        }),
    EnPoc: EntityDefinition<EnPoc>(
        model: _entities[3],
        toOneRelations: (EnPoc object) => [],
        toManyRelations: (EnPoc object) => {},
        getId: (EnPoc object) => object.id,
        setId: (EnPoc object, int id) {
          object.id = id;
        },
        objectToFB: (EnPoc object, fb.Builder fbb) {
          final boardTitleOffset = fbb.writeString(object.boardTitle);
          final personNameOffset = fbb.writeString(object.personName);
          final mobilePhoneOffset = fbb.writeString(object.mobilePhone);
          final emailOffset = fbb.writeString(object.email);
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, boardTitleOffset);
          fbb.addOffset(2, personNameOffset);
          fbb.addOffset(3, mobilePhoneOffset);
          fbb.addOffset(4, emailOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnPoc(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              boardTitle: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              personName: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              mobilePhone: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''),
              email: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 12, ''));

          return object;
        }),
    EnTerm: EntityDefinition<EnTerm>(
        model: _entities[4],
        toOneRelations: (EnTerm object) => [],
        toManyRelations: (EnTerm object) => {},
        getId: (EnTerm object) => object.id,
        setId: (EnTerm object, int id) {
          object.id = id;
        },
        objectToFB: (EnTerm object, fb.Builder fbb) {
          final termOffset = fbb.writeString(object.term);
          final displayTermOffset = fbb.writeString(object.displayTerm);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, termOffset);
          fbb.addOffset(2, displayTermOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnTerm(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              term: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              displayTerm: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''));

          return object;
        }),
    EnUrl: EntityDefinition<EnUrl>(
        model: _entities[5],
        toOneRelations: (EnUrl object) => [],
        toManyRelations: (EnUrl object) => {},
        getId: (EnUrl object) => object.id,
        setId: (EnUrl object, int id) {
          object.id = id;
        },
        objectToFB: (EnUrl object, fb.Builder fbb) {
          final titleOffset = fbb.writeString(object.title);
          final addressOffset = fbb.writeString(object.address);
          final descriptionOffset = fbb.writeString(object.description);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, titleOffset);
          fbb.addOffset(2, addressOffset);
          fbb.addOffset(3, descriptionOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnUrl(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              title: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              address: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, ''),
              description: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 10, ''));

          return object;
        }),
    EnField: EntityDefinition<EnField>(
        model: _entities[6],
        toOneRelations: (EnField object) => [],
        toManyRelations: (EnField object) => {},
        getId: (EnField object) => object.id,
        setId: (EnField object, int id) {
          object.id = id;
        },
        objectToFB: (EnField object, fb.Builder fbb) {
          final fieldNameOffset = fbb.writeString(object.fieldName);
          final displayTermOffset = fbb.writeString(object.displayTerm);
          fbb.startTable(14);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, fieldNameOffset);
          fbb.addBool(3, object.isDistinct);
          fbb.addBool(4, object.isPhone);
          fbb.addBool(5, object.isUrl);
          fbb.addBool(6, object.isEmail);
          fbb.addBool(7, object.adminEditable);
          fbb.addBool(8, object.memberEditable);
          fbb.addBool(9, object.memberHidable);
          fbb.addBool(10, object.thumbViewable);
          fbb.addInt64(11, object.maxLines);
          fbb.addOffset(12, displayTermOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = EnField(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              fieldName: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, ''),
              displayTerm: const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 28, ''),
              isDistinct: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 10, false),
              isPhone: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 12, false),
              isUrl: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 14, false),
              isEmail: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 16, false),
              adminEditable: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 18, false),
              memberEditable: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 20, false),
              memberHidable: const fb.BoolReader().vTableGet(buffer, rootOffset, 22, false),
              thumbViewable: const fb.BoolReader().vTableGet(buffer, rootOffset, 24, false),
              maxLines: const fb.Int64Reader().vTableGet(buffer, rootOffset, 26, 0));

          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [EnAdmin] entity fields to define ObjectBox queries.
class EnAdmin_ {
  /// see [EnAdmin.id]
  static final id = QueryIntegerProperty<EnAdmin>(_entities[0].properties[0]);

  /// see [EnAdmin.isMain]
  static final isMain =
      QueryBooleanProperty<EnAdmin>(_entities[0].properties[1]);

  /// see [EnAdmin.personName]
  static final personName =
      QueryStringProperty<EnAdmin>(_entities[0].properties[2]);

  /// see [EnAdmin.mobilePhone]
  static final mobilePhone =
      QueryStringProperty<EnAdmin>(_entities[0].properties[3]);

  /// see [EnAdmin.email]
  static final email = QueryStringProperty<EnAdmin>(_entities[0].properties[4]);
}

/// [EnBoard] entity fields to define ObjectBox queries.
class EnBoard_ {
  /// see [EnBoard.id]
  static final id = QueryIntegerProperty<EnBoard>(_entities[1].properties[0]);

  /// see [EnBoard.boardTitle]
  static final boardTitle =
      QueryStringProperty<EnBoard>(_entities[1].properties[1]);

  /// see [EnBoard.personName]
  static final personName =
      QueryStringProperty<EnBoard>(_entities[1].properties[2]);

  /// see [EnBoard.mobilePhone]
  static final mobilePhone =
      QueryStringProperty<EnBoard>(_entities[1].properties[3]);

  /// see [EnBoard.email]
  static final email = QueryStringProperty<EnBoard>(_entities[1].properties[4]);
}

/// [EnMember] entity fields to define ObjectBox queries.
class EnMember_ {
  /// see [EnMember.id]
  static final id = QueryIntegerProperty<EnMember>(_entities[2].properties[0]);

  /// see [EnMember.personName]
  static final personName =
      QueryStringProperty<EnMember>(_entities[2].properties[1]);

  /// see [EnMember.mobilePhone]
  static final mobilePhone =
      QueryStringProperty<EnMember>(_entities[2].properties[2]);

  /// see [EnMember.fieldValues]
  static final fieldValues =
      QueryStringVectorProperty<EnMember>(_entities[2].properties[3]);

  /// see [EnMember.lastFieldValueChanged]
  static final lastFieldValueChanged =
      QueryIntegerProperty<EnMember>(_entities[2].properties[4]);

  /// see [EnMember.lastFullImageChanged]
  static final lastFullImageChanged =
      QueryIntegerProperty<EnMember>(_entities[2].properties[5]);

  /// see [EnMember.lastProfileImageChanged]
  static final lastProfileImageChanged =
      QueryIntegerProperty<EnMember>(_entities[2].properties[6]);

  /// see [EnMember.storageDocProfileImage]
  static final storageDocProfileImage =
      QueryStringProperty<EnMember>(_entities[2].properties[7]);

  /// see [EnMember.storageDocFullImage]
  static final storageDocFullImage =
      QueryStringProperty<EnMember>(_entities[2].properties[8]);
}

/// [EnPoc] entity fields to define ObjectBox queries.
class EnPoc_ {
  /// see [EnPoc.id]
  static final id = QueryIntegerProperty<EnPoc>(_entities[3].properties[0]);

  /// see [EnPoc.boardTitle]
  static final boardTitle =
      QueryStringProperty<EnPoc>(_entities[3].properties[1]);

  /// see [EnPoc.personName]
  static final personName =
      QueryStringProperty<EnPoc>(_entities[3].properties[2]);

  /// see [EnPoc.mobilePhone]
  static final mobilePhone =
      QueryStringProperty<EnPoc>(_entities[3].properties[3]);

  /// see [EnPoc.email]
  static final email = QueryStringProperty<EnPoc>(_entities[3].properties[4]);
}

/// [EnTerm] entity fields to define ObjectBox queries.
class EnTerm_ {
  /// see [EnTerm.id]
  static final id = QueryIntegerProperty<EnTerm>(_entities[4].properties[0]);

  /// see [EnTerm.term]
  static final term = QueryStringProperty<EnTerm>(_entities[4].properties[1]);

  /// see [EnTerm.displayTerm]
  static final displayTerm =
      QueryStringProperty<EnTerm>(_entities[4].properties[2]);
}

/// [EnUrl] entity fields to define ObjectBox queries.
class EnUrl_ {
  /// see [EnUrl.id]
  static final id = QueryIntegerProperty<EnUrl>(_entities[5].properties[0]);

  /// see [EnUrl.title]
  static final title = QueryStringProperty<EnUrl>(_entities[5].properties[1]);

  /// see [EnUrl.address]
  static final address = QueryStringProperty<EnUrl>(_entities[5].properties[2]);

  /// see [EnUrl.description]
  static final description =
      QueryStringProperty<EnUrl>(_entities[5].properties[3]);
}

/// [EnField] entity fields to define ObjectBox queries.
class EnField_ {
  /// see [EnField.id]
  static final id = QueryIntegerProperty<EnField>(_entities[6].properties[0]);

  /// see [EnField.fieldName]
  static final fieldName =
      QueryStringProperty<EnField>(_entities[6].properties[1]);

  /// see [EnField.isDistinct]
  static final isDistinct =
      QueryBooleanProperty<EnField>(_entities[6].properties[2]);

  /// see [EnField.isPhone]
  static final isPhone =
      QueryBooleanProperty<EnField>(_entities[6].properties[3]);

  /// see [EnField.isUrl]
  static final isUrl =
      QueryBooleanProperty<EnField>(_entities[6].properties[4]);

  /// see [EnField.isEmail]
  static final isEmail =
      QueryBooleanProperty<EnField>(_entities[6].properties[5]);

  /// see [EnField.adminEditable]
  static final adminEditable =
      QueryBooleanProperty<EnField>(_entities[6].properties[6]);

  /// see [EnField.memberEditable]
  static final memberEditable =
      QueryBooleanProperty<EnField>(_entities[6].properties[7]);

  /// see [EnField.memberHidable]
  static final memberHidable =
      QueryBooleanProperty<EnField>(_entities[6].properties[8]);

  /// see [EnField.thumbViewable]
  static final thumbViewable =
      QueryBooleanProperty<EnField>(_entities[6].properties[9]);

  /// see [EnField.maxLines]
  static final maxLines =
      QueryIntegerProperty<EnField>(_entities[6].properties[10]);

  /// see [EnField.displayTerm]
  static final displayTerm =
      QueryStringProperty<EnField>(_entities[6].properties[11]);
}
