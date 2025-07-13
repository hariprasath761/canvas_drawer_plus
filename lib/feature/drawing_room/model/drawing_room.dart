import 'package:isar/isar.dart';
import 'drawing_point.dart';

part 'drawing_room.g.dart';

@collection
class DrawingRoom {
   Id id;
  final String roomId;
  final String roomName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<String> participants;
  final bool isActive;
  final String? password; // Optional password for private rooms
  final int maxParticipants;

  // Embedded drawing points - matches Firebase structure
  final List<EmbeddedDrawingPoint> drawingPoints;

  DrawingRoom({
    this.id = Isar.autoIncrement,
    required this.roomId,
    required this.roomName,
    required this.createdBy,
    required this.createdAt,
    required this.lastModified,
    required this.participants,
    this.isActive = true,
    this.password,
    this.maxParticipants = 10,
    this.drawingPoints = const [],
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'participants': participants,
      'isActive': isActive,
      'password': password,
      'maxParticipants': maxParticipants,
      'drawingPoints': drawingPoints.map((point) => point.toJson()).toList(),
    };
  }

  // Create from JSON (Firebase)
  factory DrawingRoom.fromJson(Map<String, dynamic> json) {
    final drawingPointsData = json['drawingPoints'] as List<dynamic>? ?? [];
    final points =
        drawingPointsData
            .map((pointData) => EmbeddedDrawingPoint.fromJson(pointData))
            .toList();

    return DrawingRoom(
      roomId: json['roomId'] ?? '',
      roomName: json['roomName'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      participants: List<String>.from(json['participants'] ?? []),
      isActive: json['isActive'] ?? true,
      password: json['password'],
      maxParticipants: json['maxParticipants'] ?? 10,
      drawingPoints: points,
    );
  }

  // Copy with method
  DrawingRoom copyWith({
    Id? id,
    String? roomId,
    String? roomName,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastModified,
    List<String>? participants,
    bool? isActive,
    String? password,
    int? maxParticipants,
    List<EmbeddedDrawingPoint>? drawingPoints,
  }) {
    return DrawingRoom(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      participants: participants ?? this.participants,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      drawingPoints: drawingPoints ?? this.drawingPoints,
    );
  }

  // Helper methods
  bool get isPasswordProtected => password != null && password!.isNotEmpty;
  bool get isFull => participants.length >= maxParticipants;

  bool hasUser(String userId) => participants.contains(userId);

  bool canUserJoin(String userId) {
    return isActive && !isFull && !hasUser(userId);
  }

  DrawingRoom addParticipant(String userId) {
    if (!hasUser(userId) && !isFull) {
      return copyWith(
        participants: [...participants, userId],
        lastModified: DateTime.now(),
      );
    }
    return this;
  }

  DrawingRoom removeParticipant(String userId) {
    if (hasUser(userId)) {
      return copyWith(
        participants: participants.where((id) => id != userId).toList(),
        lastModified: DateTime.now(),
      );
    }
    return this;
  }

  // Helper methods for drawing points
  DrawingRoom addDrawingPoint(EmbeddedDrawingPoint point) {
    return copyWith(
      drawingPoints: [...drawingPoints, point],
      lastModified: DateTime.now(),
    );
  }

  DrawingRoom addDrawingPoints(List<EmbeddedDrawingPoint> points) {
    if (points.isEmpty) return this;

    // Filter out duplicate points based on pointId
    final existingIds = drawingPoints.map((p) => p.pointId).toSet();
    final newPoints =
        points.where((p) => !existingIds.contains(p.pointId)).toList();

    if (newPoints.isEmpty) return this;

    return copyWith(
      drawingPoints: [...drawingPoints, ...newPoints],
      lastModified: DateTime.now(),
    );
  }

  DrawingRoom removeDrawingPoint(String pointId) {
    final updatedPoints =
        drawingPoints.where((p) => p.pointId != pointId).toList();
    return copyWith(drawingPoints: updatedPoints, lastModified: DateTime.now());
  }

  DrawingRoom clearDrawingPoints() {
    return copyWith(drawingPoints: [], lastModified: DateTime.now());
  }

  DrawingRoom replaceDrawingPoints(List<EmbeddedDrawingPoint> points) {
    return copyWith(drawingPoints: points, lastModified: DateTime.now());
  }

  List<DrawingPoint> getDrawingPointsAsRegular() {
    return drawingPoints
        .map((embedded) => embedded.toDrawingPoint(roomId: id))
        .toList();
  }

  bool hasDrawingPoint(String pointId) {
    return drawingPoints.any((p) => p.pointId == pointId);
  }

  // Get drawing point by ID
  EmbeddedDrawingPoint? getDrawingPoint(String pointId) {
    try {
      return drawingPoints.firstWhere((p) => p.pointId == pointId);
    } catch (e) {
      return null;
    }
  }
}
