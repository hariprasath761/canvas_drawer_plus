import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../model/drawing_room.dart';
import '../model/drawing_point.dart';

class DrawingRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Isar _isar;

  // Stream controllers for real-time updates
  final Map<String, StreamController<List<DrawingPoint>>> _drawingStreams = {};
  final Map<String, StreamController<DrawingRoom>> _roomStreams = {};

  DrawingRoomService(this._isar);

  User? get currentUser => _auth.currentUser;

  // Create a new drawing room
  Future<DrawingRoom> createRoom({
    required String roomName,
    String? password,
    int maxParticipants = 10,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final roomId = _generateRoomId();
    final room = DrawingRoom(
      roomId: roomId,
      roomName: roomName,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      participants: [user.uid],
      password: password,
      maxParticipants: maxParticipants,
    );

    try {
      // Save to Firebase
      await _firestore
          .collection('drawing_rooms')
          .doc(roomId)
          .set(room.toJson());

      // Save to local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingRoom>().put(room);
      });

      return room;
    } catch (e) {
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }

  // Join an existing room
  Future<DrawingRoom> joinRoom(String roomId, {String? password}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get room from Firebase
      final roomDoc =
          await _firestore.collection('drawing_rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Room not found');
      }

      final room = DrawingRoom.fromJson(roomDoc.data()!);

      // Check if room is password protected
      if (room.isPasswordProtected && room.password != password) {
        throw Exception('Incorrect password');
      }

      // Check if user can join
      if (!room.canUserJoin(user.uid)) {
        throw Exception('Cannot join room: either full or already joined');
      }

      // Add user to participants
      final updatedRoom = room.addParticipant(user.uid);

      // Update Firebase
      await _firestore
          .collection('drawing_rooms')
          .doc(roomId)
          .update(updatedRoom.toJson());

      // Update local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingRoom>().put(updatedRoom);
      });

      return updatedRoom;
    } catch (e) {
      throw Exception('Failed to join room: ${e.toString()}');
    }
  }

  // Leave a room
  Future<void> leaveRoom(String roomId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final roomDoc =
          await _firestore.collection('drawing_rooms').doc(roomId).get();
      if (!roomDoc.exists) return;

      final room = DrawingRoom.fromJson(roomDoc.data()!);
      final updatedRoom = room.removeParticipant(user.uid);

      // Update Firebase
      await _firestore
          .collection('drawing_rooms')
          .doc(roomId)
          .update(updatedRoom.toJson());

      // Update local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingRoom>().put(updatedRoom);
      });
    } catch (e) {
      throw Exception('Failed to leave room: ${e.toString()}');
    }
  }

  // Get user's rooms
  Future<List<DrawingRoom>> getUserRooms() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Try to get from Firebase first
      final query =
          await _firestore
              .collection('drawing_rooms')
              .where('participants', arrayContains: user.uid)
              .where('isActive', isEqualTo: true)
              .get();

      final rooms =
          query.docs.map((doc) => DrawingRoom.fromJson(doc.data())).toList();

      // Sort by lastModified locally instead of in Firestore
      rooms.sort((a, b) => b.lastModified.compareTo(a.lastModified));

      // Update local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingRoom>().putAll(rooms);
      });

      return rooms;
    } catch (e) {
      // Fallback to local storage if offline
      return await _isar
          .collection<DrawingRoom>()
          .filter()
          .participantsElementContains(user.uid)
          .and()
          .isActiveEqualTo(true)
          .sortByLastModifiedDesc()
          .findAll();
    }
  }

  // Get room details
  Future<DrawingRoom?> getRoomDetails(String roomId) async {
    try {
      // Try Firebase first
      final roomDoc =
          await _firestore.collection('drawing_rooms').doc(roomId).get();
      if (roomDoc.exists) {
        final room = DrawingRoom.fromJson(roomDoc.data()!);

        // Update local storage
        await _isar.writeTxn(() async {
          await _isar.collection<DrawingRoom>().put(room);
        });

        return room;
      }
    } catch (e) {
      // Fallback to local storage
      final rooms =
          await _isar
              .collection<DrawingRoom>()
              .filter()
              .roomIdEqualTo(roomId)
              .findAll();

      if (rooms.isNotEmpty) {
        return rooms.first;
      }
    }
    return null;
  }

  // Real-time drawing updates
  Stream<List<DrawingPoint>> getDrawingUpdates(String roomId) {
    if (!_drawingStreams.containsKey(roomId)) {
      _drawingStreams[roomId] =
          StreamController<List<DrawingPoint>>.broadcast();

      // Listen to Firebase updates - get drawing points from the room document
      _firestore.collection('drawing_rooms').doc(roomId).snapshots().listen((
        snapshot,
      ) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final drawingPointsData =
              data['drawingPoints'] as List<dynamic>? ?? [];

          final drawings =
              drawingPointsData.map((pointData) {
                final point = Map<String, dynamic>.from(pointData);
                return DrawingPoint(
                  id: point['id'] ?? DateTime.now().millisecondsSinceEpoch,
                  offsetsX: List<double>.from(point['offsetsX'] ?? []),
                  offsetsY: List<double>.from(point['offsetsY'] ?? []),
                  colorValue: point['colorValue'] ?? Colors.black.value,
                  width: (point['width'] ?? 2.0).toDouble(),
                  tool: DrawingTool.values[point['tool'] ?? 0],
                  createdAt: DateTime.parse(
                    point['createdAt'] ?? DateTime.now().toIso8601String(),
                  ),
                  roomId: roomId.hashCode,
                  userId:
                      point['userId'], // Include userId for ownership tracking
                );
              }).toList();

          _drawingStreams[roomId]?.add(drawings);
        }
      });
    }

    return _drawingStreams[roomId]!.stream;
  }

  // Add drawing point
  Future<void> addDrawingPoint(String roomId, DrawingPoint point) async {
    try {
      // Create the drawing point data
      final pointData = {
        'id': point.id,
        'offsetsX': point.offsetsX,
        'offsetsY': point.offsetsY,
        'colorValue': point.colorValue,
        'width': point.width,
        'tool': point.tool.index,
        'createdAt': point.createdAt.toIso8601String(),
        'userId': currentUser?.uid ?? '',
      };

      // Add to Firebase using arrayUnion to append to the drawingPoints array
      await _firestore.collection('drawing_rooms').doc(roomId).update({
        'drawingPoints': FieldValue.arrayUnion([pointData]),
        'lastModified': DateTime.now().toIso8601String(),
      });

      // Add to local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingPoint>().put(
          point.copyWith(roomId: roomId.hashCode),
        );
      });
    } catch (e) {
      // If offline, only save locally
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingPoint>().put(
          point.copyWith(roomId: roomId.hashCode),
        );
      });
    }
  }

  // Remove a specific drawing point by ID (for undo functionality)
  Future<void> removeDrawingPoint(String roomId, int pointId) async {
    try {
      // Get current room data
      final roomDoc =
          await _firestore.collection('drawing_rooms').doc(roomId).get();
      if (!roomDoc.exists) return;

      final data = roomDoc.data()!;
      final drawingPointsData = data['drawingPoints'] as List<dynamic>? ?? [];

      // Remove the specific point
      final updatedPoints =
          drawingPointsData.where((point) => point['id'] != pointId).toList();

      // Update Firebase
      await _firestore.collection('drawing_rooms').doc(roomId).update({
        'drawingPoints': updatedPoints,
        'lastModified': DateTime.now().toIso8601String(),
      });

      // Remove from local storage
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingPoint>().delete(pointId);
      });
    } catch (e) {
      // If offline, only remove locally
      await _isar.writeTxn(() async {
        await _isar.collection<DrawingPoint>().delete(pointId);
      });
    }
  }

  // Get user's own drawing points for undo/redo functionality
  List<DrawingPoint> getUserDrawingPoints(
    List<DrawingPoint> allPoints,
    String userId,
  ) {
    return allPoints.where((point) {
      // Check if this point belongs to the current user
      return point.userId == userId;
    }).toList();
  }

  // Sync offline drawings when online
  Future<void> syncOfflineDrawings() async {
    final user = currentUser;
    if (user == null) return;

    try {
      // Get all local drawings that haven't been synced
      final localDrawings =
          await _isar
              .collection<DrawingPoint>()
              .filter()
              .roomIdIsNotNull()
              .findAll();

      // Group drawings by room ID
      final Map<int, List<DrawingPoint>> drawingsByRoom = {};
      for (final drawing in localDrawings) {
        if (drawing.roomId != null) {
          drawingsByRoom[drawing.roomId!] ??= [];
          drawingsByRoom[drawing.roomId!]!.add(drawing);
        }
      }

      // Sync each room's drawings
      for (final entry in drawingsByRoom.entries) {
        final roomId = entry.key.toString();
        final drawings = entry.value;

        final pointsData =
            drawings
                .map(
                  (drawing) => {
                    'id': drawing.id,
                    'offsetsX': drawing.offsetsX,
                    'offsetsY': drawing.offsetsY,
                    'colorValue': drawing.colorValue,
                    'width': drawing.width,
                    'tool': drawing.tool.index,
                    'createdAt': drawing.createdAt.toIso8601String(),
                    'userId': user.uid,
                  },
                )
                .toList();

        await _firestore.collection('drawing_rooms').doc(roomId).update({
          'drawingPoints': FieldValue.arrayUnion(pointsData),
          'lastModified': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Ignore sync errors - will retry later
    }
  }

  // // Clear all drawings from a room (for testing/admin purposes)
  // Future<void> clearRoomDrawings(String roomId) async {
  //   try {
  //     await _firestore.collection('drawing_rooms').doc(roomId).update({
  //       'drawingPoints': [],
  //       'lastModified': DateTime.now().toIso8601String(),
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to clear drawings: ${e.toString()}');
  //   }
  // }

  // Generate unique room ID
  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Clean up streams
  void dispose() {
    for (final controller in _drawingStreams.values) {
      controller.close();
    }
    for (final controller in _roomStreams.values) {
      controller.close();
    }
    _drawingStreams.clear();
    _roomStreams.clear();
  }
}
