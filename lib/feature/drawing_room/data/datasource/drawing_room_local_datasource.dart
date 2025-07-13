import 'package:isar/isar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/drawing_room.dart';
import '../../model/drawing_point.dart';

abstract class DrawingRoomLocalDataSource {
  Future<void> saveRoom(DrawingRoom room);
  Future<DrawingRoom?> getRoom(String roomId);
  Future<List<DrawingRoom>> getUserRooms();
  Future<void> addDrawingPoint(String roomId, EmbeddedDrawingPoint point);
  Future<void> addDrawingPoints(
    String roomId,
    List<EmbeddedDrawingPoint> points,
  );
  Future<void> removeDrawingPoint(String roomId, String pointId);
  Future<void> clearDrawings(String roomId);
  Future<void> markAsUnsynced(String roomId, String pointId);
  Future<void> markRoomAsSynced(String roomId);
  Future<List<DrawingRoom>> getUnsyncedRooms();
  Future<void> updateRoom(
    String roomId,
    DrawingRoom Function(DrawingRoom) update,
  );
}

class IsarDrawingRoomDataSource implements DrawingRoomLocalDataSource {
  final Isar _isar;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  IsarDrawingRoomDataSource(this._isar);

  User? get currentUser => _auth.currentUser;

  @override
  Future<void> saveRoom(DrawingRoom room) async {
    await _isar.writeTxn(() async {
      // Check if room already exists to preserve the ID
      final existingRoom =
          await _isar.drawingRooms
              .filter()
              .roomIdEqualTo(room.roomId)
              .findFirst();

      if (existingRoom != null) {
        // Preserve the existing Isar ID
        final roomToSave = room.copyWith(id: existingRoom.id);
        await _isar.drawingRooms.put(roomToSave);
      } else {
        await _isar.drawingRooms.put(room);
      }
    });
  }

  @override
  Future<DrawingRoom?> getRoom(String roomId) async {
    return await _isar.drawingRooms.filter().roomIdEqualTo(roomId).findFirst();
  }

  @override
  Future<List<DrawingRoom>> getUserRooms() async {
    final user = currentUser;
    if (user == null) return [];

    return await _isar.drawingRooms
        .filter()
        .participantsElementEqualTo(user.uid)
        .and()
        .isActiveEqualTo(true)
        .findAll();
  }

  @override
  Future<void> addDrawingPoint(
    String roomId,
    EmbeddedDrawingPoint point,
  ) async {
    await updateRoom(roomId, (room) => room.addDrawingPoint(point));
  }

  @override
  Future<void> addDrawingPoints(
    String roomId,
    List<EmbeddedDrawingPoint> points,
  ) async {
    if (points.isEmpty) return;
    await updateRoom(roomId, (room) => room.addDrawingPoints(points));
  }

  @override
  Future<void> removeDrawingPoint(String roomId, String pointId) async {
    await updateRoom(roomId, (room) => room.removeDrawingPoint(pointId));
  }

  @override
  Future<void> clearDrawings(String roomId) async {
    await updateRoom(roomId, (room) => room.clearDrawingPoints());
  }

  @override
  Future<void> updateRoom(
    String roomId,
    DrawingRoom Function(DrawingRoom) update,
  ) async {
    final localRoom =
        await _isar.drawingRooms.filter().roomIdEqualTo(roomId).findFirst();

    if (localRoom != null) {
      final updatedRoom = update(localRoom);

      // Ensure we preserve the original Isar ID to update the same instance
      final roomToSave = updatedRoom.copyWith(id: localRoom.id);

      await _isar.writeTxn(() async {
        await _isar.drawingRooms.put(roomToSave);
      });
    }
  }

  @override
  Future<void> markAsUnsynced(String roomId, String pointId) async {
    // Implementation depends on how you want to track unsynced items
    // For now, we'll use a simple approach by adding metadata to the room
    // You might want to create a separate collection for unsynced items
    print('Marking point $pointId as unsynced for room $roomId');
  }

  @override
  Future<void> markRoomAsSynced(String roomId) async {
    // Implementation depends on your sync tracking strategy
    print('Marking room $roomId as synced');
  }

  @override
  Future<List<DrawingRoom>> getUnsyncedRooms() async {
    // For simplicity, return all rooms for sync
    // In a real implementation, you'd track which rooms have unsynced changes
    return await _isar.drawingRooms.where().findAll();
  }
}
