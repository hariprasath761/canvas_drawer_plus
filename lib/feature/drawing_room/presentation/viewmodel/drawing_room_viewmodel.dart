import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repository/drawing_room_repository.dart';
import '../../model/drawing_room.dart';
import '../../model/drawing_point.dart';

enum DrawingRoomState { idle, loading, success, error }

class DrawingRoomViewModel extends ChangeNotifier {
  final DrawingRoomRepository _repository;

  DrawingRoomViewModel({required DrawingRoomRepository repository})
    : _repository = repository;

  DrawingRoomState _state = DrawingRoomState.idle;
  String? _errorMessage;

  // Data
  List<DrawingRoom> _userRooms = [];
  DrawingRoom? _currentRoom;
  List<DrawingPoint> _currentDrawings = [];

  // Streams
  StreamSubscription? _roomUpdateSubscription;
  StreamSubscription? _drawingUpdateSubscription;

  // Getters
  DrawingRoomState get state => _state;
  String? get errorMessage => _errorMessage;
  List<DrawingRoom> get userRooms => _userRooms;
  DrawingRoom? get currentRoom => _currentRoom;
  List<DrawingPoint> get currentDrawings => _currentDrawings;
  bool get isLoading => _state == DrawingRoomState.loading;
  bool get hasError => _state == DrawingRoomState.error;
  DrawingRoomRepository get repository => _repository;

  // Create Room
  Future<DrawingRoom?> createRoom({
    required String roomName,
    String? password,
    int maxParticipants = 10,
  }) async {
    _setState(DrawingRoomState.loading);

    try {
      final room = await _repository.createRoom(
        roomName: roomName,
        password: password,
        maxParticipants: maxParticipants,
      );

      // Add to user rooms list
      _userRooms.insert(0, room);

      _setState(DrawingRoomState.success);
      return room;
    } catch (e) {
      _setError('Failed to create room: ${e.toString()}');
      return null;
    }
  }

  // Load User Rooms
  Future<void> loadUserRooms() async {
    _setState(DrawingRoomState.loading);

    try {
      _userRooms = await _repository.getUserRooms();
      _setState(DrawingRoomState.success);
    } catch (e) {
      _setError('Failed to load rooms: ${e.toString()}');
    }
  }

  // Join Room
  Future<bool> joinRoom(String roomId, {String? password}) async {
    _setState(DrawingRoomState.loading);

    try {
      final room = await _repository.joinRoom(roomId, password: password);

      // Add to user rooms if not already there
      final existingIndex = _userRooms.indexWhere((r) => r.roomId == roomId);
      if (existingIndex != -1) {
        _userRooms[existingIndex] = room;
      } else {
        _userRooms.insert(0, room);
      }

      _setState(DrawingRoomState.success);
      return true;
    } catch (e) {
      _setError('Failed to join room: ${e.toString()}');
      return false;
    }
  }

  // Leave Room
  Future<bool> leaveRoom(String roomId) async {
    _setState(DrawingRoomState.loading);

    try {
      await _repository.leaveRoom(roomId);

      // Remove from user rooms
      _userRooms.removeWhere((room) => room.roomId == roomId);

      // Clear current room if it's the one we left
      if (_currentRoom?.roomId == roomId) {
        _currentRoom = null;
        _currentDrawings.clear();
        _stopListeningToRoom();
      }

      _setState(DrawingRoomState.success);
      return true;
    } catch (e) {
      _setError('Failed to leave room: ${e.toString()}');
      return false;
    }
  }

  // Enter Room (Start listening to updates)
  Future<void> enterRoom(String roomId) async {
    _setState(DrawingRoomState.loading);

    try {
      // Stop previous subscriptions
      _stopListeningToRoom();

      // Get initial room data
      final room = await _repository.getRoom(roomId);
      if (room == null) {
        _setError('Room not found');
        return;
      }

      _currentRoom = room;

      _roomUpdateSubscription = _repository
          .getRoomUpdates(roomId)
          .listen(
            (updatedRoom) {
              _currentRoom = updatedRoom;
              notifyListeners();
            },
            onError: (error) {
              _setError('Room update error: ${error.toString()}');
            },
          );

      // Start listening to drawing updates
      _drawingUpdateSubscription = _repository
          .getDrawingUpdates(roomId)
          .listen(
            (drawings) {
              _currentDrawings = drawings;
              notifyListeners();
            },
            onError: (error) {
              _setError('Drawing update error: ${error.toString()}');
            },
          );

      _setState(DrawingRoomState.success);
    } catch (e) {
      _setError('Failed to enter room: ${e.toString()}');
    }
  }

  void exitRoom() {
    _currentRoom = null;
    _currentDrawings.clear();
    _stopListeningToRoom();
    _setState(DrawingRoomState.idle);
  }

  // Add Drawing
  Future<void> addDrawing({
    required String roomId,
    required List<Offset> offsets,
    required Color color,
    required double width,
    required DrawingTool tool,
  }) async {
    try {
      await _repository.addDrawing(
        roomId: roomId,
        offsets: offsets,
        color: color,
        width: width,
        tool: tool,
      );
    } catch (e) {
      _setError('Failed to add drawing: ${e.toString()}');
    }
  }

  // Add Drawing Point (Backward compatibility)
  Future<void> addDrawingPoint(String roomId, DrawingPoint point) async {
    try {
      await _repository.addDrawingPoint(roomId, point);
    } catch (e) {
      _setError('Failed to add drawing point: ${e.toString()}');
    }
  }

  // Remove Drawing Point
  Future<void> removeDrawingPoint(String roomId, int pointId) async {
    try {
      await _repository.removeDrawingPoint(roomId, pointId);
    } catch (e) {
      _setError('Failed to remove drawing point: ${e.toString()}');
    }
  }

  // Clear All Drawings
  Future<void> clearDrawings(String roomId) async {
    try {
      await _repository.clearDrawings(roomId);
    } catch (e) {
      _setError('Failed to clear drawings: ${e.toString()}');
    }
  }

  // Get User's Drawing Points
  List<DrawingPoint> getUserDrawingPoints(String userId) {
    return _repository.getUserDrawingPoints(_currentDrawings, userId);
  }

  // Sync Offline Drawings
  Future<void> syncOfflineDrawings() async {
    try {
      await _repository.syncOfflineDrawings();
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    if (_state == DrawingRoomState.error) {
      _setState(DrawingRoomState.idle);
    }
  }

  // Private Methods
  void _setState(DrawingRoomState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(DrawingRoomState.error);
  }

  void _stopListeningToRoom() {
    _roomUpdateSubscription?.cancel();
    _drawingUpdateSubscription?.cancel();
    _roomUpdateSubscription = null;
    _drawingUpdateSubscription = null;
  }

  @override
  void dispose() {
    _stopListeningToRoom();
    super.dispose();
  }
}
