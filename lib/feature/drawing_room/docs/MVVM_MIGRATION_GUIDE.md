# Drawing Room MVVM Architecture Migration Guide

This guide shows how to migrate from the existing Drawing Room service to the new MVVM architecture.

## 🏗️ Architecture Overview

### Before (Service-based)
```
DrawingRoomScreen 
    ↓
DrawingRoomService (Firebase + Isar mixed)
    ↓
Direct Firebase/Isar calls
```

### After (MVVM)
```
DrawingRoomScreenMVVM 
    ↓
DrawingCanvasViewModel + DrawingRoomViewModel
    ↓
DrawingRoomRepository
    ↓
Firebase DataSource + Isar DataSource
```

## 🔄 Migration Steps

### 1. Update main.dart Provider Setup

Replace your existing main.dart build method:

```dart
// OLD - main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Drawing Apps",
      theme: AppTheme.lightTheme,
      initialRoute: AppRouteName.authWrapper,
      onGenerateRoute: AppRoute.generate,
    );
  }
}
```

```dart
// NEW - main.dart with MVVM
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DrawingRoomViewModel>(
          create: (context) => DrawingRoomViewModel(
            repository: _createRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: "Flutter Drawing Apps",
        theme: AppTheme.lightTheme,
        initialRoute: AppRouteName.authWrapper,
        onGenerateRoute: AppRoute.generate,
      ),
    );
  }

  DrawingRoomRepository _createRepository() {
    return DrawingRoomRepositoryImpl(
      remoteDataSource: FirebaseDrawingRoomDataSource(),
      localDataSource: IsarDrawingRoomDataSource(isar),
    );
  }
}
```

### 2. Update Route Generation

In your `AppRoute.generate` method, add the new MVVM screen:

```dart
// Add to app_route.dart
case AppRouteName.drawingRoom:
  final roomId = settings.arguments as String?;
  return MaterialPageRoute(
    builder: (context) => DrawingRoomScreenMVVM(roomId: roomId),
  );

case AppRouteName.roomList:
  return MaterialPageRoute(
    builder: (context) => const DrawingRoomListScreen(),
  );
```

### 3. Replace Service Calls with ViewModel

#### OLD - Using Service Directly
```dart
class _MyWidgetState extends State<MyWidget> {
  late DrawingRoomService _roomService;
  
  @override
  void initState() {
    super.initState();
    _roomService = DrawingRoomService(isar);
  }
  
  void _createRoom() async {
    final room = await _roomService.createRoom(
      roomName: 'My Room',
      password: 'secret',
    );
  }
  
  void _loadRooms() async {
    final rooms = await _roomService.getUserRooms();
    setState(() {
      _rooms = rooms;
    });
  }
}
```

#### NEW - Using ViewModel
```dart
class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingRoomViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return CircularProgressIndicator();
        }
        
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => _createRoom(viewModel),
              child: Text('Create Room'),
            ),
            ...viewModel.userRooms.map((room) => 
              ListTile(title: Text(room.roomName))
            ),
          ],
        );
      },
    );
  }
  
  void _createRoom(DrawingRoomViewModel viewModel) async {
    await viewModel.createRoom(
      roomName: 'My Room',
      password: 'secret',
    );
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DrawingRoomViewModel>().loadUserRooms();
    });
  }
}
```

### 4. Drawing Canvas Migration

#### OLD - Direct Service Integration
```dart
class _DrawingScreenState extends State<DrawingScreen> {
  late DrawingRoomService _roomService;
  List<DrawingPoint> _drawingPoints = [];
  
  void _addDrawing(Offset position) async {
    final point = DrawingPoint.create(/* ... */);
    await _roomService.addDrawingPoint(roomId, point);
  }
}
```

#### NEW - ViewModel Integration
```dart
class _DrawingScreenState extends State<DrawingScreen> {
  DrawingCanvasViewModel? _canvasViewModel;
  
  @override
  void initState() {
    super.initState();
    _canvasViewModel = DrawingCanvasViewModel(
      repository: context.read<DrawingRoomViewModel>().repository,
      roomId: widget.roomId,
    );
    _canvasViewModel!.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _canvasViewModel!,
      child: Consumer<DrawingCanvasViewModel>(
        builder: (context, canvasViewModel, child) {
          return GestureDetector(
            onPanStart: (details) => canvasViewModel.startDrawing(details.localPosition),
            onPanUpdate: (details) => canvasViewModel.updateDrawing(details.localPosition),
            onPanEnd: (_) => canvasViewModel.endDrawing(),
            child: CustomPaint(
              painter: DrawingPainter(drawingPoints: canvasViewModel.drawingPoints),
            ),
          );
        },
      ),
    );
  }
}
```

## 🔧 Key Benefits

### 1. **Separation of Concerns**
- **UI**: Only handles UI state and user interactions
- **ViewModel**: Handles business logic and state management
- **Repository**: Combines data sources with offline-first approach
- **DataSources**: Handle specific data operations (Firebase/Isar)

### 2. **Testability**
```dart
// Easy to test business logic
test('should create room successfully', () async {
  final mockRepo = MockDrawingRoomRepository();
  final viewModel = DrawingRoomViewModel(repository: mockRepo);
  
  when(mockRepo.createRoom(any)).thenAnswer((_) async => mockRoom);
  
  final result = await viewModel.createRoom(roomName: 'Test');
  
  expect(result, isNotNull);
  expect(viewModel.userRooms.length, 1);
});
```

### 3. **Reactive UI**
```dart
// UI automatically updates when data changes
Consumer<DrawingRoomViewModel>(
  builder: (context, viewModel, child) {
    return Text('Rooms: ${viewModel.userRooms.length}');
  },
)
```

### 4. **Better Error Handling**
```dart
// Centralized error handling
if (viewModel.hasError) {
  return ErrorWidget(viewModel.errorMessage);
}
```

## 🚀 Quick Start

1. **Add Provider dependency** (already done)
2. **Update main.dart** with Provider setup
3. **Replace existing screens** with MVVM versions
4. **Test functionality** to ensure everything works

## 📋 Checklist

- [ ] Updated main.dart with Provider setup
- [ ] Added MVVM screens to routing
- [ ] Replaced service calls with ViewModel calls
- [ ] Tested room creation functionality
- [ ] Tested drawing functionality
- [ ] Tested offline sync
- [ ] Added error handling
- [ ] Updated navigation logic

## 🔄 Backwards Compatibility

The old service-based approach will continue to work alongside the new MVVM architecture until you fully migrate all screens.

You can gradually migrate screens one by one:
1. Start with DrawingRoomListScreen
2. Then migrate DrawingRoomScreen
3. Finally remove old service files

## 📚 Additional Resources

- [Provider Documentation](https://pub.dev/packages/provider)
- [MVVM Pattern in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)
- [Repository Pattern](https://docs.flutter.dev/cookbook/architecture/repository-pattern)
