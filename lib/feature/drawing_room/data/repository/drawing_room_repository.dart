import 'package:canvas_drawer_plus/feature/auth/model/user_model.dart';

import '../datasource/drawing_room_remote_datasource.dart';
import '../datasource/drawing_room_local_datasource.dart';
import '../../model/drawing_room.dart';
import '../../model/drawing_point.dart';
import 'package:flutter/material.dart';

abstract class DrawingRoomRepository {
  Future<DrawingRoom> createRoom({
    required String roomName,
    String? password,
    int maxParticipants = 10,
  });

  Future<void> addDrawing({
    required String roomId,
    required List<Offset> offsets,
    required Color color,
    required double width,
    required DrawingTool tool,
    String? userId,
  });

  Future<void> addDrawings({
    required String roomId,
    required List<EmbeddedDrawingPoint> points,
  });

  Future<void> clearDrawings(String roomId);

  Future<DrawingRoom?> getRoom(String roomId);

  Stream<DrawingRoom> getRoomUpdates(String roomId);

  Future<List<DrawingRoom>> getUserRooms();

  Future<DrawingRoom> joinRoom(String roomId, {String? password});

  Future<void> leaveRoom(String roomId);

  Future<void> syncOfflineDrawings();

  Future<List<UserModel>> getParticipantData(List<String> uid);

  // Backward compatibility methods
  Stream<List<DrawingPoint>> getDrawingUpdates(String roomId);
  Future<void> addDrawingPoint(String roomId, DrawingPoint point);
  Future<void> removeDrawingPoint(String roomId, String pointId);
  List<DrawingPoint> getUserDrawingPoints(
    List<DrawingPoint> allPoints,
    String userId,
  );

  // AI Enhancement methods
  Future<String?> analyzeDrawingWithAI({
    required String roomId,
    required String analysisPrompt,
    String? apiKey,
  });
}

class DrawingRoomRepositoryImpl implements DrawingRoomRepository {
  final DrawingRoomRemoteDataSource _remoteDataSource;
  final DrawingRoomLocalDataSource _localDataSource;

  DrawingRoomRepositoryImpl({
    required DrawingRoomRemoteDataSource remoteDataSource,
    required DrawingRoomLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<DrawingRoom> createRoom({
    required String roomName,
    String? password,
    int maxParticipants = 10,
  }) async {
    try {
      // Create in remote first
      final room = await _remoteDataSource.createRoom(
        roomName: roomName,
        password: password,
        maxParticipants: maxParticipants,
      );

      // Save to local storage
      await _localDataSource.saveRoom(room);

      return room;
    } catch (e) {
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  @override
  Future<void> addDrawing({
    required String roomId,
    required List<Offset> offsets,
    required Color color,
    required double width,
    required DrawingTool tool,
    String? userId,
  }) async {
    final point = EmbeddedDrawingPoint.create(
      offsets: offsets,
      color: color,
      width: width,
      tool: tool,
      userId: userId,
    );

    // Always save locally first
    await _localDataSource.addDrawingPoint(roomId, point);

    try {
      // Try to sync to remote
      await _remoteDataSource.addDrawing(roomId, point);
    } catch (e) {
      // Mark as unsynced for later sync
      await _localDataSource.markAsUnsynced(roomId, point.pointId);
      rethrow;
    }
  }

  @override
  Future<void> addDrawings({
    required String roomId,
    required List<EmbeddedDrawingPoint> points,
  }) async {
    if (points.isEmpty) return;

    // Save locally first
    await _localDataSource.addDrawingPoints(roomId, points);

    try {
      // Try to sync to remote
      await _remoteDataSource.addDrawings(roomId, points);
    } catch (e) {
      // Mark as unsynced for later sync
      for (final point in points) {
        await _localDataSource.markAsUnsynced(roomId, point.pointId);
      }
      rethrow;
    }
  }

  @override
  Future<void> clearDrawings(String roomId) async {
    try {
      // Clear from remote first
      await _remoteDataSource.clearDrawings(roomId);

      // Clear from local
      await _localDataSource.clearDrawings(roomId);
    } catch (e) {
      // If remote fails, still clear locally and mark for sync
      await _localDataSource.clearDrawings(roomId);
      throw Exception('Failed to clear drawings: ${e.toString()}');
    }
  }

  @override
  Future<DrawingRoom?> getRoom(String roomId) async {
    try {
      // Try remote first
      final room = await _remoteDataSource.getRoom(roomId);
      if (room != null) {
        // Update local cache
        await _localDataSource.saveRoom(room);
        return room;
      }
    } catch (e) {
      // Fall back to local
    }

    return await _localDataSource.getRoom(roomId);
  }

  @override
  Stream<DrawingRoom> getRoomUpdates(String roomId) {
    return _remoteDataSource.getRoomUpdates(roomId);
  }

  @override
  Future<List<DrawingRoom>> getUserRooms() async {
    try {
      // Try remote first
      final rooms = await _remoteDataSource.getUserRooms();

      // Update local cache
      for (final room in rooms) {
        await _localDataSource.saveRoom(room);
      }

      return rooms;
    } catch (e) {
      // Fall back to local
      return await _localDataSource.getUserRooms();
    }
  }

  @override
  Future<DrawingRoom> joinRoom(String roomId, {String? password}) async {
    try {
      // Join on remote
      final room = await _remoteDataSource.joinRoom(roomId, password: password);

      // Update local cache
      await _localDataSource.saveRoom(room);

      return room;
    } catch (e) {
      throw Exception('Failed to join room: ${e.toString()}');
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    try {
      // Leave on remote
      await _remoteDataSource.leaveRoom(roomId);

      // Update local cache
      final localRoom = await _localDataSource.getRoom(roomId);
      if (localRoom != null) {
        await _localDataSource.saveRoom(localRoom);
      }
    } catch (e) {
      throw Exception('Failed to leave room: ${e.toString()}');
    }
  }

  @override
  Future<void> syncOfflineDrawings() async {
    try {
      final unsyncedRooms = await _localDataSource.getUnsyncedRooms();

      for (final room in unsyncedRooms) {
        await _remoteDataSource.syncRoom(room);
        await _localDataSource.markRoomAsSynced(room.roomId);
      }
    } catch (e) {
      // Ignore sync errors - will retry later
      print('Sync error: $e');
    }
  }

  // Backward compatibility methods
  @override
  Stream<List<DrawingPoint>> getDrawingUpdates(String roomId) {
    return getRoomUpdates(roomId).map((room) {
      return room
          .drawingPoints; // Already EmbeddedDrawingPoints, just return them
    });
  }

  @override
  Future<void> addDrawingPoint(String roomId, DrawingPoint point) async {
    await addDrawing(
      roomId: roomId,
      offsets: point.offsets,
      color: point.color,
      width: point.width,
      tool: point.tool,
      userId: point.userId,
    );
  }

  @override
  Future<void> removeDrawingPoint(String roomId, String pointId) async {
    await _localDataSource.removeDrawingPoint(roomId, pointId);

    try {
      await _remoteDataSource.removeDrawingPoint(roomId, pointId);
    } catch (e) {
      // Mark for sync later
      print('Failed to remove drawing point remotely: $e');
    }
  }

  @override
  List<DrawingPoint> getUserDrawingPoints(
    List<DrawingPoint> allPoints,
    String userId,
  ) {
    return allPoints.where((point) => point.userId == userId).toList();
  }

  @override
  Future<String?> analyzeDrawingWithAI({
    required String roomId,
    required String analysisPrompt,
    String? apiKey,
  }) async {
    // This is a placeholder implementation
    // The actual AI analysis is handled in the ViewModel layer
    // This method can be used for future repository-level AI integrations
    try {
      final room = await getRoom(roomId);
      if (room == null || room.drawingPoints.isEmpty) {
        return 'No drawings found to analyze';
      }

      // Return a basic analysis based on drawing count
      return 'Room contains ${room.drawingPoints.length} drawing elements. Use the ViewModel methods for detailed AI analysis.';
    } catch (e) {
      return 'Failed to analyze drawings: $e';
    }
  }
  
  @override
  Future<List<UserModel>> getParticipantData(List<String> uid) {
    return _remoteDataSource.getParticipantData(uid);
  }
}
