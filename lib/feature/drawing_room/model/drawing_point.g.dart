// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_point.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDrawingPointCollection on Isar {
  IsarCollection<DrawingPoint> get drawingPoints => this.collection();
}

const DrawingPointSchema = CollectionSchema(
  name: r'DrawingPoint',
  id: -4643661256797113870,
  properties: {
    r'colorValue': PropertySchema(
      id: 0,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(
      id: 2,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isShape': PropertySchema(
      id: 3,
      name: r'isShape',
      type: IsarType.bool,
    ),
    r'offsetsX': PropertySchema(
      id: 4,
      name: r'offsetsX',
      type: IsarType.doubleList,
    ),
    r'offsetsY': PropertySchema(
      id: 5,
      name: r'offsetsY',
      type: IsarType.doubleList,
    ),
    r'roomId': PropertySchema(
      id: 6,
      name: r'roomId',
      type: IsarType.long,
    ),
    r'tool': PropertySchema(
      id: 7,
      name: r'tool',
      type: IsarType.byte,
      enumMap: _DrawingPointtoolEnumValueMap,
    ),
    r'width': PropertySchema(
      id: 8,
      name: r'width',
      type: IsarType.double,
    )
  },
  estimateSize: _drawingPointEstimateSize,
  serialize: _drawingPointSerialize,
  deserialize: _drawingPointDeserialize,
  deserializeProp: _drawingPointDeserializeProp,
  idName: r'id',
  indexes: {
    r'roomId': IndexSchema(
      id: -3609232324653216207,
      name: r'roomId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'roomId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _drawingPointGetId,
  getLinks: _drawingPointGetLinks,
  attach: _drawingPointAttach,
  version: '3.1.0+1',
);

int _drawingPointEstimateSize(
  DrawingPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.offsetsX.length * 8;
  bytesCount += 3 + object.offsetsY.length * 8;
  return bytesCount;
}

void _drawingPointSerialize(
  DrawingPoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorValue);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.hashCode);
  writer.writeBool(offsets[3], object.isShape);
  writer.writeDoubleList(offsets[4], object.offsetsX);
  writer.writeDoubleList(offsets[5], object.offsetsY);
  writer.writeLong(offsets[6], object.roomId);
  writer.writeByte(offsets[7], object.tool.index);
  writer.writeDouble(offsets[8], object.width);
}

DrawingPoint _drawingPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DrawingPoint(
    colorValue: reader.readLong(offsets[0]),
    createdAt: reader.readDateTime(offsets[1]),
    id: id,
    offsetsX: reader.readDoubleList(offsets[4]) ?? [],
    offsetsY: reader.readDoubleList(offsets[5]) ?? [],
    roomId: reader.readLongOrNull(offsets[6]),
    tool: _DrawingPointtoolValueEnumMap[reader.readByteOrNull(offsets[7])] ??
        DrawingTool.pen,
    width: reader.readDouble(offsets[8]),
  );
  return object;
}

P _drawingPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 5:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (_DrawingPointtoolValueEnumMap[reader.readByteOrNull(offset)] ??
          DrawingTool.pen) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DrawingPointtoolEnumValueMap = {
  'pen': 0,
  'eraser': 1,
  'circle': 2,
  'rectangle': 3,
  'square': 4,
};
const _DrawingPointtoolValueEnumMap = {
  0: DrawingTool.pen,
  1: DrawingTool.eraser,
  2: DrawingTool.circle,
  3: DrawingTool.rectangle,
  4: DrawingTool.square,
};

Id _drawingPointGetId(DrawingPoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _drawingPointGetLinks(DrawingPoint object) {
  return [];
}

void _drawingPointAttach(
    IsarCollection<dynamic> col, Id id, DrawingPoint object) {}

extension DrawingPointQueryWhereSort
    on QueryBuilder<DrawingPoint, DrawingPoint, QWhere> {
  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhere> anyRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'roomId'),
      );
    });
  }
}

extension DrawingPointQueryWhere
    on QueryBuilder<DrawingPoint, DrawingPoint, QWhereClause> {
  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'roomId',
        value: [null],
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause>
      roomIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'roomId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdEqualTo(
      int? roomId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'roomId',
        value: [roomId],
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdNotEqualTo(
      int? roomId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomId',
              lower: [],
              upper: [roomId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomId',
              lower: [roomId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomId',
              lower: [roomId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'roomId',
              lower: [],
              upper: [roomId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdGreaterThan(
    int? roomId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'roomId',
        lower: [roomId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdLessThan(
    int? roomId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'roomId',
        lower: [],
        upper: [roomId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterWhereClause> roomIdBetween(
    int? lowerRoomId,
    int? upperRoomId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'roomId',
        lower: [lowerRoomId],
        includeLower: includeLower,
        upper: [upperRoomId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DrawingPointQueryFilter
    on QueryBuilder<DrawingPoint, DrawingPoint, QFilterCondition> {
  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      colorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      colorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      isShapeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isShape',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offsetsX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offsetsX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offsetsX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offsetsX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsXLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsX',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offsetsY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offsetsY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offsetsY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offsetsY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      offsetsYLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'offsetsY',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      roomIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'roomId',
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      roomIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'roomId',
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> roomIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomId',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      roomIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roomId',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      roomIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roomId',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> roomIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roomId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> toolEqualTo(
      DrawingTool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tool',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      toolGreaterThan(
    DrawingTool value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tool',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> toolLessThan(
    DrawingTool value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tool',
        value: value,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> toolBetween(
    DrawingTool lower,
    DrawingTool upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tool',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> widthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition>
      widthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> widthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterFilterCondition> widthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension DrawingPointQueryObject
    on QueryBuilder<DrawingPoint, DrawingPoint, QFilterCondition> {}

extension DrawingPointQueryLinks
    on QueryBuilder<DrawingPoint, DrawingPoint, QFilterCondition> {}

extension DrawingPointQuerySortBy
    on QueryBuilder<DrawingPoint, DrawingPoint, QSortBy> {
  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy>
      sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByIsShape() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShape', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByIsShapeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShape', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension DrawingPointQuerySortThenBy
    on QueryBuilder<DrawingPoint, DrawingPoint, QSortThenBy> {
  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy>
      thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByIsShape() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShape', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByIsShapeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isShape', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomId', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tool', Sort.desc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QAfterSortBy> thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension DrawingPointQueryWhereDistinct
    on QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> {
  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByIsShape() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isShape');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByOffsetsX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offsetsX');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByOffsetsY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offsetsY');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomId');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tool');
    });
  }

  QueryBuilder<DrawingPoint, DrawingPoint, QDistinct> distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension DrawingPointQueryProperty
    on QueryBuilder<DrawingPoint, DrawingPoint, QQueryProperty> {
  QueryBuilder<DrawingPoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DrawingPoint, int, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<DrawingPoint, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DrawingPoint, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<DrawingPoint, bool, QQueryOperations> isShapeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isShape');
    });
  }

  QueryBuilder<DrawingPoint, List<double>, QQueryOperations>
      offsetsXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offsetsX');
    });
  }

  QueryBuilder<DrawingPoint, List<double>, QQueryOperations>
      offsetsYProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offsetsY');
    });
  }

  QueryBuilder<DrawingPoint, int?, QQueryOperations> roomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomId');
    });
  }

  QueryBuilder<DrawingPoint, DrawingTool, QQueryOperations> toolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tool');
    });
  }

  QueryBuilder<DrawingPoint, double, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}
