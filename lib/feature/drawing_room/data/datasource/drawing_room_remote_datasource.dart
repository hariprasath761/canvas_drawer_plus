import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/drawing_room.dart';
import '../../model/drawing_point.dart';

abstract class DrawingRoomRemoteDataSource {
  Future<DrawingRoom> createRoom({
    required String roomName,
    String? password,
    int maxParticipants = 10,
  });

  Future<void> addDrawing(String roomId, EmbeddedDrawingPoint point);
  Future<void> addDrawings(String roomId, List<EmbeddedDrawingPoint> points);
  Future<void> clearDrawings(String roomId);
  Future<DrawingRoom?> getRoom(String roomId);
  Stream<DrawingRoom> getRoomUpdates(String roomId);
  Future<List<DrawingRoom>> getUserRooms();
  Future<DrawingRoom> joinRoom(String roomId, {String? password});
  Future<void> leaveRoom(String roomId);
  Future<void> syncRoom(DrawingRoom room);
  Future<void> removeDrawingPoint(String roomId, String pointId);
}

class FirebaseDrawingRoomDataSource implements DrawingRoomRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
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
      drawingPoints: [],
    );

    await _firestore.collection('drawing_rooms').doc(roomId).set(room.toJson());

    return room;
  }

  @override
  Future<void> addDrawing(String roomId, EmbeddedDrawingPoint point) async {
    await _firestore.collection('drawing_rooms').doc(roomId).update({
      'drawingPoints': FieldValue.arrayUnion([point.toJson()]),
      'lastModified': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> addDrawings(
    String roomId,
    List<EmbeddedDrawingPoint> points,
  ) async {
    if (points.isEmpty) return;

    final pointsJson = points.map((p) => p.toJson()).toList();
    await _firestore.collection('drawing_rooms').doc(roomId).update({
      'drawingPoints': FieldValue.arrayUnion(pointsJson),
      'lastModified': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> clearDrawings(String roomId) async {
    await _firestore.collection('drawing_rooms').doc(roomId).update({
      'drawingPoints': [],
      'lastModified': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<DrawingRoom?> getRoom(String roomId) async {
    final roomDoc =
        await _firestore.collection('drawing_rooms').doc(roomId).get();

    if (roomDoc.exists) {
      return DrawingRoom.fromJson(roomDoc.data()!);
    }
    return null;
  }

  @override
  Stream<DrawingRoom> getRoomUpdates(String roomId) {
    return _firestore
        .collection('drawing_rooms')
        .doc(roomId)
        .snapshots()
        .where((snapshot) => snapshot.exists)
        .map((snapshot) => DrawingRoom.fromJson(snapshot.data()!));
  }

  @override
  Future<List<DrawingRoom>> getUserRooms() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final query =
        await _firestore
            .collection('drawing_rooms')
            .where('participants', arrayContains: user.uid)
            .where('isActive', isEqualTo: true)
            .get();

    return query.docs.map((doc) => DrawingRoom.fromJson(doc.data())).toList();
  }

  @override
  Future<DrawingRoom> joinRoom(String roomId, {String? password}) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final roomDoc =
        await _firestore.collection('drawing_rooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Room not found');

    final room = DrawingRoom.fromJson(roomDoc.data()!);

    if (room.isPasswordProtected && room.password != password) {
      throw Exception('Incorrect password');
    }

    if (!room.canUserJoin(user.uid)) {
      throw Exception('Cannot join room');
    }

    final updatedRoom = room.addParticipant(user.uid);

    await _firestore
        .collection('drawing_rooms')
        .doc(roomId)
        .update(updatedRoom.toJson());

    return updatedRoom;
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    final roomDoc =
        await _firestore.collection('drawing_rooms').doc(roomId).get();
    if (!roomDoc.exists) return;

    final room = DrawingRoom.fromJson(roomDoc.data()!);
    final updatedRoom = room.removeParticipant(user.uid);

    await _firestore
        .collection('drawing_rooms')
        .doc(roomId)
        .update(updatedRoom.toJson());
  }

  @override
  Future<void> syncRoom(DrawingRoom room) async {
    await _firestore
        .collection('drawing_rooms')
        .doc(room.roomId)
        .set(room.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> removeDrawingPoint(String roomId, String pointId) async {
    final roomDoc =
        await _firestore.collection('drawing_rooms').doc(roomId).get();
    if (!roomDoc.exists) return;

    final data = roomDoc.data()!;
    final drawingPointsData = data['drawingPoints'] as List<dynamic>? ?? [];

    final updatedPoints =
        drawingPointsData
            .where((point) => point['pointId'] != pointId)
            .toList();

    await _firestore.collection('drawing_rooms').doc(roomId).update({
      'drawingPoints': updatedPoints,
      'lastModified': DateTime.now().toIso8601String(),
    });
  }

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
