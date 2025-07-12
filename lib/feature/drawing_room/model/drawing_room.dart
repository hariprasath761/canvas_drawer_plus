import 'package:isar/isar.dart';

part 'drawing_room.g.dart';

@collection
class DrawingRoom {
  final Id id;
  final String roomId;
  final String roomName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<String> participants;
  final bool isActive;
  final String? password; // Optional password for private rooms
  final int maxParticipants;

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
      'drawingPoints': [], // Initialize empty drawing points array
    };
  }

  // Create from JSON (Firebase)
  factory DrawingRoom.fromJson(Map<String, dynamic> json) {
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
}
