import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repository/drawing_room_repository.dart';
import '../../model/drawing_point.dart';
import '../../model/drawing_room.dart';

enum DrawingCanvasState { idle, loading, drawing, error }

class DrawingCanvasViewModel extends ChangeNotifier {
  final DrawingRoomRepository _repository;
  final String roomId;

  DrawingCanvasViewModel({
    required DrawingRoomRepository repository,
    required this.roomId,
  }) : _repository = repository {
    initialize();
  }

  DrawingCanvasState _state = DrawingCanvasState.idle;
  String? _errorMessage;

  // Drawing related fields
  List<DrawingPoint> _drawingPoints = [];
  List<DrawingPoint> _historyDrawingPoints = [];
  DrawingPoint? _currentDrawingPoint;

  List<DrawingPoint> _userDrawingHistory = [];
  List<DrawingPoint> _userUndoHistory = [];
  String? _currentUserId;

  // Room related fields
  DrawingRoom? _currentRoom;

  Color _selectedColor = Colors.black;
  double _selectedWidth = 2.0;
  DrawingTool _selectedTool = DrawingTool.pen;

  // Stream subscriptions
  StreamSubscription<List<DrawingPoint>>? _drawingSubscription;

  // Getters
  DrawingCanvasState get state => _state;
  String? get errorMessage => _errorMessage;
  List<DrawingPoint> get drawingPoints => _drawingPoints;
  List<DrawingPoint> get historyDrawingPoints => _historyDrawingPoints;
  DrawingPoint? get currentDrawingPoint => _currentDrawingPoint;
  List<DrawingPoint> get userDrawingHistory => _userDrawingHistory;
  List<DrawingPoint> get userUndoHistory => _userUndoHistory;
  String? get currentUserId => _currentUserId;
  Color get selectedColor => _selectedColor;
  double get selectedWidth => _selectedWidth;
  DrawingTool get selectedTool => _selectedTool;
  DrawingRoom? get currentRoom => _currentRoom;

  bool get isLoading => _state == DrawingCanvasState.loading;
  bool get hasError => _state == DrawingCanvasState.error;
  bool get canUndo => _userDrawingHistory.isNotEmpty;
  bool get canRedo => _userUndoHistory.isNotEmpty;

  // Available colors for the palette
  final List<Color> availableColors = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  Future<void> initialize() async {
    _setState(DrawingCanvasState.loading);

    try {
      _currentUserId = await _getCurrentUserId();

      // Load room data
      await _loadRoomData();

      // Start listening to drawings and room updates
      await _startListeningToDrawings();

      _setState(DrawingCanvasState.idle);
    } catch (e) {
      _setError('Failed to initialize canvas: ${e.toString()}');
    }
  }

  // Room related methods
  Future<void> _loadRoomData() async {
    try {
      _currentRoom = await _repository.getRoom(roomId);
      if (_currentRoom == null) {
        _setError('Room not found');
      }
    } catch (e) {
      _setError('Failed to load room data: ${e.toString()}');
    }
  }

  // Drawing related methods
  void startDrawing(Offset position) {
    if (_currentUserId == null) return;

    _setState(DrawingCanvasState.drawing);

    _currentDrawingPoint = EmbeddedDrawingPoint.create(
      offsets: [position],
      color: _selectedColor,
      width: _selectedWidth,
      tool: _selectedTool,
      userId: _currentUserId,
    );

    if (_currentDrawingPoint != null) {
      // Create a temporary copy for local display
      final tempPoints = List<DrawingPoint>.from(_drawingPoints);
      tempPoints.add(_currentDrawingPoint!);
      _drawingPoints = tempPoints;
      notifyListeners();
    }
  }

  void updateDrawing(Offset position) {
    if (_currentDrawingPoint == null) return;

    if (_currentDrawingPoint!.isShape) {
      _currentDrawingPoint = _currentDrawingPoint?.copyWith(
        offsets: [_currentDrawingPoint!.offsets.first, position],
      );
    } else {
      _currentDrawingPoint = _currentDrawingPoint?.copyWith(
        offsets: _currentDrawingPoint!.offsets..add(position),
      );
    }

    final tempPoints = List<DrawingPoint>.from(_drawingPoints);
    tempPoints.last = _currentDrawingPoint!;
    _drawingPoints = tempPoints;
    notifyListeners();
  }

  Future<void> endDrawing() async {
    if (_currentDrawingPoint == null) return;

    try {
      // Save the drawing point
      await _addDrawingPoint(_currentDrawingPoint!);

      // Update user's drawing history
      if (_currentUserId != null &&
          _currentUserId == _currentDrawingPoint?.userId) {
        _userDrawingHistory.add(_currentDrawingPoint!);
        // Clear redo history when a new drawing is added
        _userUndoHistory.clear();
      }

      _currentDrawingPoint = null;
      _setState(DrawingCanvasState.idle);
    } catch (e) {
      _setError('Failed to save drawing: ${e.toString()}');

      _currentDrawingPoint = null;
      _setState(DrawingCanvasState.idle);
    }
  }

  void selectColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void selectTool(DrawingTool tool) {
    _selectedTool = tool;
    notifyListeners();
  }

  void updateWidth(double width) {
    _selectedWidth = width;
    notifyListeners();
  }

  Future<void> undoLastDrawing() async {
    if (_userDrawingHistory.isEmpty) return;

    try {
      _setState(DrawingCanvasState.loading);

      final lastPoint = _userDrawingHistory.removeLast();

      await _repository.removeDrawingPoint(roomId, lastPoint.pointId);

      _userUndoHistory.add(lastPoint);

      // Update the local drawing points immediately for better UX
      _drawingPoints =
          _drawingPoints
              .where((point) => point.pointId != lastPoint.pointId)
              .toList();

      _setState(DrawingCanvasState.idle);
      notifyListeners();
    } catch (e) {
      _setError('Failed to undo: ${e.toString()}');
    }
  }

  Future<void> redoLastDrawing() async {
    if (_userUndoHistory.isEmpty) return;

    try {
      _setState(DrawingCanvasState.loading);

      // Get the last undone drawing point
      final pointToRedo = _userUndoHistory.removeLast();

      // Add back to repository
      await _repository.addDrawingPoint(roomId, pointToRedo);

      // Add back to user's drawing history
      _userDrawingHistory.add(pointToRedo);

      // Update local drawing points immediately for better UX
      // Make sure we don't add duplicate points
      if (!_drawingPoints.any(
        (point) => point.pointId == pointToRedo.pointId,
      )) {
        _drawingPoints = [..._drawingPoints, pointToRedo];
      }

      _setState(DrawingCanvasState.idle);
      notifyListeners();
    } catch (e) {
      _setError('Failed to redo: ${e.toString()}');
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == DrawingCanvasState.error) {
      _setState(DrawingCanvasState.idle);
    }
  }

  Future<String?> _getCurrentUserId() async {
    // Get current user ID from Firebase Auth
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      return user?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<void> _startListeningToDrawings() async {
    try {
      _drawingSubscription = _repository
          .getDrawingUpdates(roomId)
          .listen(
            (drawings) {
              _drawingPoints = drawings;
              _historyDrawingPoints = List.of(drawings);

              // Update user drawing history based on current drawings
              if (_currentUserId != null) {
                final userDrawings =
                    drawings
                        .where((point) => point.userId == _currentUserId)
                        .toList();

                // Initialize user drawing history if empty
                if (_userDrawingHistory.isEmpty) {
                  _userDrawingHistory = List.of(userDrawings);
                } else {
                  // Synchronize drawing history with current drawings
                  // by keeping only points that still exist in the current drawings
                  _userDrawingHistory =
                      _userDrawingHistory
                          .where(
                            (historyPoint) => drawings.any(
                              (point) => point.pointId == historyPoint.pointId,
                            ),
                          )
                          .toList();

                  // Add any new user points that aren't already in the history
                  for (final point in userDrawings) {
                    if (!_userDrawingHistory.any(
                      (p) => p.pointId == point.pointId,
                    )) {
                      _userDrawingHistory.add(point);
                    }
                  }
                }

                // Also update undo history to remove points that no longer exist
                _userUndoHistory =
                    _userUndoHistory
                        .where(
                          (undoPoint) =>
                              !drawings.any(
                                (point) => point.pointId == undoPoint.pointId,
                              ),
                        )
                        .toList();
              }

              notifyListeners();
            },
            onError: (error) {
              _setError('Error loading drawings: ${error.toString()}');
            },
          );
    } catch (e) {
      _setError('Error starting drawing stream: ${e.toString()}');
    }
  }

  Future<void> _addDrawingPoint(DrawingPoint point) async {
    try {
      await _repository.addDrawingPoint(roomId, point);
    } catch (e) {
      // Handle offline mode - drawing is already added locally
      throw Exception('Failed to add drawing: ${e.toString()}');
    }
  }

  void _setState(DrawingCanvasState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(DrawingCanvasState.error);
  }

  // Clean up all subscriptions
  void _stopListening() {
    _drawingSubscription?.cancel();

    _drawingSubscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
