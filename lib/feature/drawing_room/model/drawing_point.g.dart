// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_point.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const EmbeddedDrawingPointSchema = Schema(
  name: r'EmbeddedDrawingPoint',
  id: -6000503459860875225,
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
    r'pointId': PropertySchema(
      id: 6,
      name: r'pointId',
      type: IsarType.string,
    ),
    r'tool': PropertySchema(
      id: 7,
      name: r'tool',
      type: IsarType.byte,
      enumMap: _EmbeddedDrawingPointtoolEnumValueMap,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    ),
    r'width': PropertySchema(
      id: 9,
      name: r'width',
      type: IsarType.double,
    )
  },
  estimateSize: _embeddedDrawingPointEstimateSize,
  serialize: _embeddedDrawingPointSerialize,
  deserialize: _embeddedDrawingPointDeserialize,
  deserializeProp: _embeddedDrawingPointDeserializeProp,
);

int _embeddedDrawingPointEstimateSize(
  EmbeddedDrawingPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.offsetsX.length * 8;
  bytesCount += 3 + object.offsetsY.length * 8;
  bytesCount += 3 + object.pointId.length * 3;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _embeddedDrawingPointSerialize(
  EmbeddedDrawingPoint object,
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
  writer.writeString(offsets[6], object.pointId);
  writer.writeByte(offsets[7], object.tool.index);
  writer.writeString(offsets[8], object.userId);
  writer.writeDouble(offsets[9], object.width);
}

EmbeddedDrawingPoint _embeddedDrawingPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmbeddedDrawingPoint(
    colorValue: reader.readLongOrNull(offsets[0]) ?? 0,
    offsetsX: reader.readDoubleList(offsets[4]) ?? const [],
    offsetsY: reader.readDoubleList(offsets[5]) ?? const [],
    pointId: reader.readStringOrNull(offsets[6]) ?? '',
    tool: _EmbeddedDrawingPointtoolValueEnumMap[
            reader.readByteOrNull(offsets[7])] ??
        DrawingTool.pen,
    userId: reader.readStringOrNull(offsets[8]),
    width: reader.readDoubleOrNull(offsets[9]) ?? 2.0,
  );
  return object;
}

P _embeddedDrawingPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? const []) as P;
    case 5:
      return (reader.readDoubleList(offset) ?? const []) as P;
    case 6:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 7:
      return (_EmbeddedDrawingPointtoolValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DrawingTool.pen) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset) ?? 2.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _EmbeddedDrawingPointtoolEnumValueMap = {
  'pen': 0,
  'eraser': 1,
  'circle': 2,
  'rectangle': 3,
  'square': 4,
};
const _EmbeddedDrawingPointtoolValueEnumMap = {
  0: DrawingTool.pen,
  1: DrawingTool.eraser,
  2: DrawingTool.circle,
  3: DrawingTool.rectangle,
  4: DrawingTool.square,
};

extension EmbeddedDrawingPointQueryFilter on QueryBuilder<EmbeddedDrawingPoint,
    EmbeddedDrawingPoint, QFilterCondition> {
  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> colorValueGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> colorValueLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> colorValueBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> hashCodeGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> hashCodeLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> hashCodeBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> isShapeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isShape',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXElementEqualTo(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXElementGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXElementLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXElementBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXLengthEqualTo(int length) {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXIsEmpty() {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXIsNotEmpty() {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXLengthLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXLengthGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsXLengthBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYElementEqualTo(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYElementGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYElementLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYElementBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYLengthEqualTo(int length) {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYIsEmpty() {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYIsNotEmpty() {
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYLengthLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYLengthGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> offsetsYLengthBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pointId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
          QAfterFilterCondition>
      pointIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
          QAfterFilterCondition>
      pointIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pointId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pointId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> pointIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pointId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> toolEqualTo(DrawingTool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tool',
        value: value,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> toolGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> toolLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> toolBetween(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> widthEqualTo(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> widthGreaterThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> widthLessThan(
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

  QueryBuilder<EmbeddedDrawingPoint, EmbeddedDrawingPoint,
      QAfterFilterCondition> widthBetween(
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

extension EmbeddedDrawingPointQueryObject on QueryBuilder<EmbeddedDrawingPoint,
    EmbeddedDrawingPoint, QFilterCondition> {}
