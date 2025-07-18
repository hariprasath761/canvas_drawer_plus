import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'drawing_point.g.dart';

enum DrawingTool { pen, eraser, circle, rectangle, square }

typedef DrawingPoint = EmbeddedDrawingPoint;

@embedded
class EmbeddedDrawingPoint {
  final String pointId;
  final List<double> offsetsX;
  final List<double> offsetsY;
  final int colorValue;
  final double width;
  @enumerated
  final DrawingTool tool;
  final DateTime createdAt;
  final String? userId;

  EmbeddedDrawingPoint({
    this.pointId = '',
    this.offsetsX = const [],
    this.offsetsY = const [],
    this.colorValue = 0,
    this.width = 2.0,
    this.tool = DrawingTool.pen,
    this.userId,
  }) : createdAt = DateTime.now();

  // Named constructor for easy creation
  EmbeddedDrawingPoint.create({
    String? pointId,
    List<Offset> offsets = const [],
    Color color = Colors.black,
    this.width = 2,
    this.tool = DrawingTool.pen,
    this.userId,
    DateTime? createdAt,
  }) : pointId =
           pointId ??
           '${DateTime.now().millisecondsSinceEpoch}_${userId ?? 'anonymous'}',
       offsetsX = offsets.map((offset) => offset.dx).toList(),
       offsetsY = offsets.map((offset) => offset.dy).toList(),
       colorValue = color.value,
       createdAt = createdAt ?? DateTime.now();

  @ignore
  List<Offset> get offsets {
    if (offsetsX.length != offsetsY.length) return [];
    return List.generate(
      offsetsX.length,
      (index) => Offset(offsetsX[index], offsetsY[index]),
    );
  }

  @ignore
  Color get color => Color(colorValue);

  @ignore
  Rect get boundingRect {
    if (offsets.length < 2) return Rect.zero;
    final start = offsets.first;
    final end = offsets.last;
    return Rect.fromPoints(start, end);
  }

  bool get isShape => [
    DrawingTool.circle,
    DrawingTool.rectangle,
    DrawingTool.square,
  ].contains(tool);

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'pointId': pointId,
      'offsetsX': offsetsX,
      'offsetsY': offsetsY,
      'colorValue': colorValue,
      'width': width,
      'tool': tool.index,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from JSON (Firebase)
  factory EmbeddedDrawingPoint.fromJson(Map<String, dynamic> json) {
    final point = EmbeddedDrawingPoint(
      pointId: json['pointId'] ?? '',
      offsetsX: List<double>.from(json['offsetsX'] ?? []),
      offsetsY: List<double>.from(json['offsetsY'] ?? []),
      colorValue: json['colorValue'] ?? 0,
      width: (json['width'] ?? 2.0).toDouble(),
      tool: DrawingTool.values[json['tool'] ?? 0],
      userId: json['userId'],
    );

    // Manually set createdAt from JSON if available
    if (json['createdAt'] != null) {
      return EmbeddedDrawingPoint(
        pointId: point.pointId,
        offsetsX: point.offsetsX,
        offsetsY: point.offsetsY,
        colorValue: point.colorValue,
        width: point.width,
        tool: point.tool,
        userId: point.userId,
      );
    }

    return point;
  }

  // Helper method for creating a copy with updated offsets
  EmbeddedDrawingPoint copyWith({
    String? pointId,
    List<Offset>? offsets,
    Color? color,
    double? width,
    DrawingTool? tool,
    String? userId,
    DateTime? createdAt,
  }) {
    final newOffsets = offsets ?? this.offsets;
    return EmbeddedDrawingPoint(
      pointId: pointId ?? this.pointId,
      offsetsX: newOffsets.map((offset) => offset.dx).toList(),
      offsetsY: newOffsets.map((offset) => offset.dy).toList(),
      colorValue: color?.value ?? this.colorValue,
      width: width ?? this.width,
      tool: tool ?? this.tool,
      userId: userId ?? this.userId,
    );
  }

  // Helper method to add a point (returns new instance for immutability)
  EmbeddedDrawingPoint addOffset(Offset offset) {
    final newOffsetsX = [...offsetsX, offset.dx];
    final newOffsetsY = [...offsetsY, offset.dy];

    return EmbeddedDrawingPoint(
      pointId: pointId,
      offsetsX: newOffsetsX,
      offsetsY: newOffsetsY,
      colorValue: colorValue,
      width: width,
      tool: tool,
      userId: userId,
    );
  }

  // Helper method to update last offset (returns new instance for immutability)
  EmbeddedDrawingPoint updateLastOffset(Offset offset) {
    if (offsetsX.isEmpty || offsetsY.isEmpty) return this;

    final newOffsetsX = [...offsetsX];
    final newOffsetsY = [...offsetsY];
    newOffsetsX.last = offset.dx;
    newOffsetsY.last = offset.dy;

    return EmbeddedDrawingPoint(
      pointId: pointId,
      offsetsX: newOffsetsX,
      offsetsY: newOffsetsY,
      colorValue: colorValue,
      width: width,
      tool: tool,
      userId: userId,
    );
  }

  @override
  String toString() {
    return 'EmbeddedDrawingPoint(pointId: $pointId, tool: $tool, color: $color, width: $width, points: ${offsets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmbeddedDrawingPoint && other.pointId == pointId;
  }

  @override
  int get hashCode => pointId.hashCode;
}
