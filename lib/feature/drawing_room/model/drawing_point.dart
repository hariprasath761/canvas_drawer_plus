import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'drawing_point.g.dart';

enum DrawingTool { pen, eraser, circle, rectangle, square }

@collection
class DrawingPoint {
  final Id id;

  // Store Offset coordinates as separate lists
  final List<double> offsetsX;
  final List<double> offsetsY;

  // Store Color as integer value
  final int colorValue;

  final double width;

  // Enum support in Isar
  @enumerated
  final DrawingTool tool;

  // Additional fields for better organization
  final DateTime createdAt;

  // Optional: Room ID to group drawings
  @Index()
  final int? roomId;

  // User ID to track ownership for undo/redo functionality
  final String? userId;

  // Constructor with all required fields
  DrawingPoint({
    this.id = Isar.autoIncrement,
    required this.offsetsX,
    required this.offsetsY,
    required this.colorValue,
    required this.width,
    required this.tool,
    required this.createdAt,
    this.roomId,
    this.userId,
  });

  // Named constructor for easy creation from your original model
  DrawingPoint.create({
    this.id = Isar.autoIncrement,
    List<Offset> offsets = const [],
    Color color = Colors.black,
    this.width = 2,
    this.tool = DrawingTool.pen,
    this.roomId,
    this.userId,
    DateTime? createdAt,
  }) : offsetsX = offsets.map((offset) => offset.dx).toList(),
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

  // CopyWith method for immutable-like updates
  DrawingPoint copyWith({
    Id? id,
    List<Offset>? offsets,
    Color? color,
    double? width,
    DrawingTool? tool,
    int? roomId,
    String? userId,
    DateTime? createdAt,
  }) {
    final newOffsets = offsets ?? this.offsets;
    return DrawingPoint(
      id: id ?? this.id,
      offsetsX: newOffsets.map((offset) => offset.dx).toList(),
      offsetsY: newOffsets.map((offset) => offset.dy).toList(),
      colorValue: color?.value ?? this.colorValue,
      width: width ?? this.width,
      tool: tool ?? this.tool,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods for shapes
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

  // Helper method to add a point (returns new instance for immutability)
  DrawingPoint addOffset(Offset offset) {
    final newOffsetsX = [...offsetsX, offset.dx];
    final newOffsetsY = [...offsetsY, offset.dy];

    return DrawingPoint(
      id: id,
      offsetsX: newOffsetsX,
      offsetsY: newOffsetsY,
      colorValue: colorValue,
      width: width,
      tool: tool,
      createdAt: createdAt,
      roomId: roomId,
      userId: userId,
    );
  }

  // Helper method to update last offset (returns new instance for immutability)
  DrawingPoint updateLastOffset(Offset offset) {
    if (offsetsX.isEmpty || offsetsY.isEmpty) return this;

    final newOffsetsX = [...offsetsX];
    final newOffsetsY = [...offsetsY];
    newOffsetsX.last = offset.dx;
    newOffsetsY.last = offset.dy;

    return DrawingPoint(
      id: id,
      offsetsX: newOffsetsX,
      offsetsY: newOffsetsY,
      colorValue: colorValue,
      width: width,
      tool: tool,
      createdAt: createdAt,
      roomId: roomId,
      userId: userId,
    );
  }

  @override
  String toString() {
    return 'DrawingPoint(id: $id, tool: $tool, color: $color, width: $width, points: ${offsets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawingPoint && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
