import 'dart:async';
import 'dart:convert';
import 'package:canvas_drawer_plus/feature/ai_service/ai_config.dart';
import 'package:canvas_drawer_plus/feature/ai_service/gemini_service.dart';
import 'package:canvas_drawer_plus/feature/ai_service/openrouter_service.dart';
import 'package:canvas_drawer_plus/feature/gemma/download_model.dart';
import 'package:canvas_drawer_plus/feature/gemma/downloader_datasource.dart';
import 'package:canvas_drawer_plus/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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

  final _downloaderDataSource = GemmaDownloaderDataSource(
    model: DownloadModel(
      modelUrl:
          'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task',
      modelFilename: 'gemma-3n-E4B-it-int4.task',
    ),
  );

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

  bool get isModelInitializing => _isModelInitializing;
  double? get modelDownloadProgress => _modelDownloadProgress;
  String? get modelLoadingMessage => _modelLoadingMessage;

  // AI Model initialization state
  final bool _isModelInitializing = false;
  double? _modelDownloadProgress;
  String? _modelLoadingMessage;

  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';

  // OpenRouter service for enhanced AI capabilities
  OpenRouterService? _openRouterService;

  // Initialize OpenRouter service with API key
  void initializeOpenRouter(String apiKey) {
    _openRouterService = OpenRouterService(apiKey: apiKey);
  }

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

      _initSpeech();

      initializeOpenRouter(AIConfig.openRouterApiKey);
      logger.i(
        'OpenRouter initialized with API key: ${AIConfig.openRouterApiKey}',
      );

      _setState(DrawingCanvasState.idle);
    } catch (e) {
      _setError('Failed to initialize canvas: ${e.toString()}');
    }
  }

  void clearLastWords() {
    lastWords = '';
    notifyListeners();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    speechEnabled = await speechToText.initialize();
  }

  /// Each time to start a speech recognition session
  void startListeningAudio() async {
    await speechToText.listen(onResult: _onSpeechResult);
    notifyListeners();
  }

  void stopListeningAudio() async {
    await speechToText.stop();
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    lastWords = result.recognizedWords;
    notifyListeners();
  }

  // Public method to trigger AI generation (can be called from UI)
  Future<void> enhanceDrawingWithAI() async {
    if (_drawingPoints.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please draw something first before using AI enhancement',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    final result = await generateDrawingFromGemma();

    if (result != null && result.isNotEmpty) {
      Fluttertoast.showToast(
        msg: 'AI enhanced your drawing with ${result.length} new elements!',
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'AI could not enhance the drawing. Try drawing more elements.',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<List<DrawingPoint>?> generateDrawingFromGemma() async {
    _setState(DrawingCanvasState.loading);

    final drawingDescription = _convertDrawingPointsToDescription(
      _drawingPoints,
    );

    // Create a comprehensive prompt for Gemma
    final prompt = _createDrawingPrompt(drawingDescription);

    String? response;

    try {
      response = await GeminiService.sendTextMessage(message: prompt);
      logger.e('Error generating drawing from Gemma: $response');
      // response = await analyzeDrawingImageWithOpenRouter(
      //   analysisPrompt: prompt,
      //   model: OpenRouterModels.geminiPro,
      // );
      // apiCall = await gemini.prompt(parts: [Part.text(prompt)]);
    } catch (e) {
      logger.e('Error generating drawing from Gemma: $e');
      _setError('Failed to get response from Gemma: ${e.toString()}');
      _setState(DrawingCanvasState.idle);
      notifyListeners();
      return null;
    }

    if (response == null) {
      _setError('Failed to get response from Gemma');
      _setState(DrawingCanvasState.idle);
      notifyListeners();
      return null;
    }

    logger.i('Gemma response: $response');
    if (response.isNotEmpty) {
      final generatedPoints = _parseGemmaResponseToDrawingPoints(response);

      if (generatedPoints.isNotEmpty) {
        // Add the generated points to the canvas
        for (final point in generatedPoints) {
          await _addDrawingPoint(point);
        }

        // Update local drawing points immediately
        _drawingPoints = [..._drawingPoints, ...generatedPoints];

        // Add to user's drawing history
        if (_currentUserId != null) {
          _userDrawingHistory.addAll(generatedPoints);
          _userUndoHistory
              .clear(); // Clear redo history when new AI drawings are added
        }
      }

      Fluttertoast.showToast(
        msg: 'Created drawing ',
        toastLength: Toast.LENGTH_LONG,
      );

      _setState(DrawingCanvasState.idle);
      notifyListeners();

      return generatedPoints;
    }

    _setState(DrawingCanvasState.idle);
    notifyListeners();

    return null;
  }

  Future<void> convertTextToDrawing(String text) async {
    logger.i('Converting text to drawing: $text');
    if (text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter some text to convert to drawing',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    _setState(DrawingCanvasState.loading);

    final prompt = _createTextToDrawingPrompt(text);

    String? response;

    try {
      response = await analyzeDrawingImageWithOpenRouter(
        analysisPrompt: prompt,
        model: OpenRouterModels.geminiPro,
      );
      // apiCall = await gemini.prompt(parts: [Part.text(prompt)]);
    } catch (e) {
      _setError('Failed to get response from Gemma: ${e.toString()}');
      _setState(DrawingCanvasState.idle);
      notifyListeners();
    }

    if (response == null) {
      _setError('Failed to get response from Gemma');
      _setState(DrawingCanvasState.idle);
      notifyListeners();
    }

    logger.i('Gemma response: $response');
    if (response != null && response.isNotEmpty) {
      final generatedPoints = _parseGemmaResponseToDrawingPoints(response);

      if (generatedPoints.isNotEmpty) {
        // Add the generated points to the canvas
        for (final point in generatedPoints) {
          await _addDrawingPoint(point);
        }

        // Update local drawing points immediately
        _drawingPoints = [..._drawingPoints, ...generatedPoints];

        // Add to user's drawing history
        if (_currentUserId != null) {
          _userDrawingHistory.addAll(generatedPoints);
          _userUndoHistory
              .clear(); // Clear redo history when new AI drawings are added
        }
      }
    }
  }

  // Public method for speech to drawing conversion (placeholder)
  Future<void> convertSpeechToDrawing() async {
    Fluttertoast.showToast(
      msg: 'Speech to drawing feature coming soon!',
      toastLength: Toast.LENGTH_LONG,
    );
    // TODO: Implement speech recognition and conversion to drawing
    // This would typically involve:
    // 1. Recording audio input
    // 2. Converting speech to text using speech recognition
    // 3. Using the text-to-drawing conversion method above
  }

  String _createTextToDrawingPrompt(String text) {
    return """
You are an AI assistant that creates drawings based on text descriptions. The user wants to draw: "$text"

Please create drawing elements that represent this text visually. Respond ONLY in the following JSON format:

{
  "identified_object": "what you're drawing based on the text",
  "confidence": "high/medium/low",
  "suggestions": [
    {
      "type": "rectangle/circle/pen",
      "color": "black/red/blue/green/brown/amber",
      "x1": 100,
      "y1": 150,
      "x2": 200,
      "y2": 250,
      "description": "what this element represents"
    }
  ]
}

For pen tool, provide multiple points as an array:
{
  "type": "pen",
  "color": "black",
  "points": [{"x": 100, "y": 150}, {"x": 105, "y": 155}, {"x": 110, "y": 160}],
  "description": "what this line represents"
}

Create a complete drawing that visually represents "$text". Use appropriate shapes and lines to form recognizable objects. Place elements in a logical arrangement on the canvas (use coordinates between 50-800 for x and 100-600 for y).
""";
  }

  String _convertDrawingPointsToDescription(List<DrawingPoint> points) {
    if (points.isEmpty) {
      return "No drawing points available";
    }

    final buffer = StringBuffer();

    buffer.writeln(
      "In my flutter application I've made a canvas screen for drawing. where the canvas coordinates are stored in the format of the following json: ${points.first.toJson()}",
    );

    buffer.writeln(
      "Current drawing contains ${points.length} drawing elements combined it together makes a single room drawing now need to enhance the drawing to next level with this points:",
    );

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final tool = point.tool.toString().split('.').last;
      final color = _colorToName(point.color);

      buffer.writeln(
        "${i + 1}. $tool in $color color with ${point.offsets.length} points",
      );

      buffer.writeln(
        "The following points are used for this drawing element: in the format of (x, y)",
      );

      for (var offset in point.offsets) {
        buffer.writeln("   (${offset.dx.toInt()}, ${offset.dy.toInt()})");
      }
    }

    return buffer.toString();
  }

  String _createDrawingPrompt(String drawingDescription) {
    return """
You are an AI assistant that helps complete and enhance drawings. Based on the current drawing elements provided, identify what the user might be trying to draw (like animals, fruits, objects, etc.) and provide suggestions to complete or enhance the drawing.

$drawingDescription

Please analyze this drawing and:
1. Identify what you think the user is trying to draw (animal, fruit, object, etc.)
2. Suggest additional drawing elements to complete or enhance the drawing
3. Respond ONLY in the following JSON format:

{
  "identified_object": "name of what you think is being drawn",
  "confidence": "high/medium/low",
  "suggestions": [
    {
      "type": "rectangle/circle/pen",
      "color": "black/red/blue/green/brown/amber",
      "x1": 100,
      "y1": 150,
      "x2": 200,
      "y2": 250,
      "description": "what this element represents"
    }
  ]
}

For pen tool, provide multiple points as an array:
{
  "type": "pen",
  "color": "black",
  "points": [{"x": 100, "y": 150}, {"x": 105, "y": 155}, {"x": 110, "y": 160}],
  "description": "what this line represents"
}

Important: Provide coordinates that work well with the existing drawing elements. Use colors from: black, red, blue, green, brown, amber.
""";
  }

  List<DrawingPoint> _parseGemmaResponseToDrawingPoints(String response) {
    try {
      // Extract JSON from response if it contains other text
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        print('No valid JSON found in response');
        return [];
      }

      final jsonString = response.substring(jsonStart, jsonEnd + 1);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      final identifiedObject =
          data['identified_object'] as String? ?? 'unknown';

      print('AI identified: $identifiedObject');

      final drawingPoints = <DrawingPoint>[];

      for (final suggestion in suggestions) {
        final suggestionMap = suggestion as Map<String, dynamic>;
        final type = suggestionMap['type'] as String;
        final colorName = suggestionMap['color'] as String;
        final color = _nameToColor(colorName);

        DrawingPoint? drawingPoint;

        switch (type.toLowerCase()) {
          case 'rectangle':
            final x1 = (suggestionMap['x1'] as num).toDouble();
            final y1 = (suggestionMap['y1'] as num).toDouble();
            final x2 = (suggestionMap['x2'] as num).toDouble();
            final y2 = (suggestionMap['y2'] as num).toDouble();

            drawingPoint = EmbeddedDrawingPoint.create(
              offsets: [Offset(x1, y1), Offset(x2, y2)],
              color: color,
              tool: DrawingTool.rectangle,
              userId: _currentUserId,
            );
            break;

          case 'circle':
            final x1 = (suggestionMap['x1'] as num).toDouble();
            final y1 = (suggestionMap['y1'] as num).toDouble();
            final x2 = (suggestionMap['x2'] as num).toDouble();
            final y2 = (suggestionMap['y2'] as num).toDouble();

            drawingPoint = EmbeddedDrawingPoint.create(
              offsets: [Offset(x1, y1), Offset(x2, y2)],
              color: color,
              tool: DrawingTool.circle,
              userId: _currentUserId,
            );
            break;

          case 'pen':
            final points = suggestionMap['points'] as List<dynamic>? ?? [];
            final offsets =
                points.map((point) {
                  final pointMap = point as Map<String, dynamic>;
                  return Offset(
                    (pointMap['x'] as num).toDouble(),
                    (pointMap['y'] as num).toDouble(),
                  );
                }).toList();

            if (offsets.isNotEmpty) {
              drawingPoint = EmbeddedDrawingPoint.create(
                offsets: offsets,
                color: color,
                tool: DrawingTool.pen,
                userId: _currentUserId,
              );
            }
            break;
        }

        if (drawingPoint != null) {
          drawingPoints.add(drawingPoint);
        }
      }

      return drawingPoints;
    } catch (e) {
      print('Error parsing Gemma response: $e');
      return [];
    }
  }

  String _colorToName(Color color) {
    if (color.value == Colors.black.value) return 'black';
    if (color.value == Colors.red.value) return 'red';
    if (color.value == Colors.blue.value) return 'blue';
    if (color.value == Colors.green.value) return 'green';
    if (color.value == Colors.brown.value) return 'brown';
    if (color.value == Colors.amber.value) return 'amber';
    return 'black'; // default
  }

  Color _nameToColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'brown':
        return Colors.brown;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.black;
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

  // OpenRouter AI Enhancement Methods

  /// Analyze drawing with text description using OpenRouter API
  Future<void> analyzeDrawingWithOpenRouter({
    required String analysisPrompt,
    String model = OpenRouterModels.claude35Sonnet,
  }) async {
    if (_openRouterService == null) {
      Fluttertoast.showToast(
        msg: 'OpenRouter API not initialized. Please set API key first.',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (_drawingPoints.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please draw something first before using AI analysis',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    _setState(DrawingCanvasState.loading);

    try {
      // Convert current drawing points to a descriptive format
      final drawingDescription = _convertDrawingPointsToDescription(
        _drawingPoints,
      );

      final fullPrompt = '''
$analysisPrompt

Current drawing contains:
$drawingDescription

Please analyze this drawing and provide insights about what the user might be trying to create.
''';

      final response = await _openRouterService!.sendTextMessage(
        message: fullPrompt,
        model: model,
        temperature: 0.7,
        maxTokens: 1000,
      );

      Fluttertoast.showToast(
        msg: 'AI Analysis: ${response.text}',
        toastLength: Toast.LENGTH_LONG,
      );

      logger.i('OpenRouter Analysis: ${response.text}');
    } catch (e) {
      _setError('Failed to analyze drawing: ${e.toString()}');
    } finally {
      _setState(DrawingCanvasState.idle);
    }
  }

  /// Enhance drawing with OpenRouter suggestions
  Future<void> enhanceDrawingWithOpenRouter({
    String model = OpenRouterModels.claude35Sonnet,
  }) async {
    if (_openRouterService == null) {
      Fluttertoast.showToast(
        msg: 'OpenRouter API not initialized. Please set API key first.',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (_drawingPoints.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please draw something first before using AI enhancement',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    _setState(DrawingCanvasState.loading);

    try {
      // Convert current drawing points to a descriptive format
      final drawingDescription = _convertDrawingPointsToDescription(
        _drawingPoints,
      );

      final prompt = '''
You are an AI assistant that helps complete and enhance drawings. Based on the current drawing elements provided, identify what the user might be trying to draw and provide suggestions to complete or enhance the drawing.

Current drawing contains:
$drawingDescription

Please analyze this drawing and:
1. Identify what you think the user is trying to draw
2. Suggest additional drawing elements to complete or enhance the drawing
3. Respond ONLY in the following JSON format:

{
  "identified_object": "name of what you think is being drawn",
  "confidence": "high/medium/low",
  "suggestions": [
    {
      "type": "rectangle/circle/pen",
      "color": "black/red/blue/green/brown/amber",
      "x1": 100,
      "y1": 150,
      "x2": 200,
      "y2": 250,
      "description": "what this element represents"
    }
  ]
}

For pen tool, provide multiple points as an array:
{
  "type": "pen",
  "color": "black",
  "points": [{"x": 100, "y": 150}, {"x": 105, "y": 155}, {"x": 110, "y": 160}],
  "description": "what this line represents"
}

Important: Use colors from: black, red, blue, green, brown, amber. Provide coordinates between 50-800 for x and 100-600 for y.
''';

      final response = await _openRouterService!.sendTextMessage(
        message: prompt,
        model: model,
        temperature: 0.8,
        maxTokens: 1500,
      );

      logger.i('OpenRouter Enhancement Response: ${response.text}');

      // Parse the response and convert to DrawingPoints
      final generatedPoints = _parseOpenRouterResponseToDrawingPoints(
        response.text,
      );

      if (generatedPoints.isNotEmpty) {
        // Add the generated points to the canvas
        for (final point in generatedPoints) {
          await _addDrawingPoint(point);
        }

        // Update local drawing points immediately
        _drawingPoints = [..._drawingPoints, ...generatedPoints];

        // Add to user's drawing history
        if (_currentUserId != null) {
          _userDrawingHistory.addAll(generatedPoints);
          _userUndoHistory.clear();
        }

        Fluttertoast.showToast(
          msg:
              'AI enhanced your drawing with ${generatedPoints.length} new elements!',
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'AI could not enhance the drawing. Try drawing more elements.',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      _setError('Failed to enhance drawing with OpenRouter: ${e.toString()}');
    } finally {
      _setState(DrawingCanvasState.idle);
    }
  }

  /// Convert text to drawing using OpenRouter API
  Future<void> convertTextToDrawingWithOpenRouter({
    required String text,
    String model = OpenRouterModels.claude35Sonnet,
  }) async {
    if (_openRouterService == null) {
      Fluttertoast.showToast(
        msg: 'OpenRouter API not initialized. Please set API key first.',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter some text to convert to drawing',
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    _setState(DrawingCanvasState.loading);

    try {
      final prompt = _createTextToDrawingPrompt(text);

      final response = await _openRouterService!.sendTextMessage(
        message: prompt,
        model: model,
        temperature: 0.7,
        maxTokens: 1500,
      );

      logger.i('OpenRouter Text-to-Drawing Response: ${response.text}');

      // Parse the response and convert to DrawingPoints
      final generatedPoints = _parseOpenRouterResponseToDrawingPoints(
        response.text,
      );

      if (generatedPoints.isNotEmpty) {
        // Add the generated points to the canvas
        for (final point in generatedPoints) {
          await _addDrawingPoint(point);
        }

        // Update local drawing points immediately
        _drawingPoints = [..._drawingPoints, ...generatedPoints];

        // Add to user's drawing history
        if (_currentUserId != null) {
          _userDrawingHistory.addAll(generatedPoints);
          _userUndoHistory.clear();
        }

        Fluttertoast.showToast(
          msg:
              'Created drawing from text: "${text.length > 20 ? "${text.substring(0, 20)}..." : text}"',
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Could not create drawing from the provided text',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      _setError(
        'Failed to convert text to drawing with OpenRouter: ${e.toString()}',
      );
    } finally {
      _setState(DrawingCanvasState.idle);
    }
  }

  /// Analyze drawing with image using OpenRouter API (when canvas is exported as image)
  Future<String?> analyzeDrawingImageWithOpenRouter({
    required String analysisPrompt,
    String model = OpenRouterModels.claude35Sonnet,
  }) async {
    if (_openRouterService == null) {
      Fluttertoast.showToast(
        msg: 'OpenRouter API not initialized. Please set API key first.',
        toastLength: Toast.LENGTH_LONG,
      );
      return null;
    }

    _setState(DrawingCanvasState.loading);

    try {
      final response = await _openRouterService!.sendMessageWithImage(
        message: analysisPrompt,
        model: model,
        temperature: 0.7,
        maxTokens: 1000,
      );

      logger.i('OpenRouter Image Analysis: ${response.text}');

      return response.text;
    } catch (e) {
      _setError('Failed to analyze drawing image: ${e.toString()}');
      return null;
    } finally {
      _setState(DrawingCanvasState.idle);
    }
  }

  /// Parse OpenRouter response to drawing points (similar to Gemma parsing)
  List<DrawingPoint> _parseOpenRouterResponseToDrawingPoints(String response) {
    try {
      // Extract JSON from response if it contains other text
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        logger.w('No valid JSON found in OpenRouter response');
        return [];
      }

      final jsonString = response.substring(jsonStart, jsonEnd + 1);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      final identifiedObject =
          data['identified_object'] as String? ?? 'unknown';

      logger.i('OpenRouter identified: $identifiedObject');

      final drawingPoints = <DrawingPoint>[];

      for (final suggestion in suggestions) {
        final suggestionMap = suggestion as Map<String, dynamic>;
        final type = suggestionMap['type'] as String;
        final colorName = suggestionMap['color'] as String;
        final color = _nameToColor(colorName);

        DrawingPoint? drawingPoint;

        switch (type.toLowerCase()) {
          case 'rectangle':
            final x1 = (suggestionMap['x1'] as num).toDouble();
            final y1 = (suggestionMap['y1'] as num).toDouble();
            final x2 = (suggestionMap['x2'] as num).toDouble();
            final y2 = (suggestionMap['y2'] as num).toDouble();

            drawingPoint = EmbeddedDrawingPoint.create(
              offsets: [Offset(x1, y1), Offset(x2, y2)],
              color: color,
              tool: DrawingTool.rectangle,
              userId: _currentUserId,
            );
            break;

          case 'circle':
            final x1 = (suggestionMap['x1'] as num).toDouble();
            final y1 = (suggestionMap['y1'] as num).toDouble();
            final x2 = (suggestionMap['x2'] as num).toDouble();
            final y2 = (suggestionMap['y2'] as num).toDouble();

            drawingPoint = EmbeddedDrawingPoint.create(
              offsets: [Offset(x1, y1), Offset(x2, y2)],
              color: color,
              tool: DrawingTool.circle,
              userId: _currentUserId,
            );
            break;

          case 'pen':
            final points = suggestionMap['points'] as List<dynamic>? ?? [];
            final offsets =
                points.map((point) {
                  final pointMap = point as Map<String, dynamic>;
                  return Offset(
                    (pointMap['x'] as num).toDouble(),
                    (pointMap['y'] as num).toDouble(),
                  );
                }).toList();

            if (offsets.isNotEmpty) {
              drawingPoint = EmbeddedDrawingPoint.create(
                offsets: offsets,
                color: color,
                tool: DrawingTool.pen,
                userId: _currentUserId,
              );
            }
            break;
        }

        if (drawingPoint != null) {
          drawingPoints.add(drawingPoint);
        }
      }

      return drawingPoints;
    } catch (e) {
      logger.e('Error parsing OpenRouter response: $e');
      return [];
    }
  }

  // Lottie animation related properties
  String? _currentLottieAnimation;
  bool _isLottieAnimationVisible = false;

  // Getters for Lottie animation
  String? get currentLottieAnimation => _currentLottieAnimation;
  bool get isLottieAnimationVisible => _isLottieAnimationVisible;

  // Available Lottie animations
  List<String> get availableLottieAnimations => [
    'assets/lottie/confetti.json',
    'assets/lottie/juggling_monkey.json',
    'assets/lottie/cute_boy_running.json',
  ];

  // Get display name for Lottie animation
  String getLottieDisplayName(String path) {
    final fileName = path.split('/').last.replaceAll('.json', '');
    return fileName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Show Lottie animation
  void showLottieAnimation(String animationPath) {
    _currentLottieAnimation = animationPath;
    _isLottieAnimationVisible = true;
    notifyListeners();

    // Auto hide animation after 3 seconds
    Timer(const Duration(seconds: 3), () {
      hideLottieAnimation();
    });
  }

  // Hide Lottie animation
  void hideLottieAnimation() {
    _isLottieAnimationVisible = false;
    _currentLottieAnimation = null;
    notifyListeners();
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
