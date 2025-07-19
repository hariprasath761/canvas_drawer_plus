import 'package:canvas_drawer_plus/consts.dart';
import 'package:canvas_drawer_plus/core/theme/material_theme.dart';
import 'package:canvas_drawer_plus/env/env.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/model/drawing_room.dart';
import 'package:canvas_drawer_plus/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'core/route/app_route.dart';
import 'core/route/app_route_name.dart';
import 'feature/drawing_room/data/repository/drawing_room_repository.dart';
import 'feature/drawing_room/data/datasource/drawing_room_remote_datasource.dart';
import 'feature/drawing_room/data/datasource/drawing_room_local_datasource.dart';
import 'feature/drawing_room/presentation/viewmodel/drawing_room_viewmodel.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Global Isar instance
late Isar isar;

final logger = Logger();

void main() async {
  Gemini.init(apiKey: Env.geminiAPIKey);
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([DrawingRoomSchema], directory: dir.path);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DrawingRoomViewModel>(
          create:
              (context) =>
                  DrawingRoomViewModel(repository: _createRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Flutter Drawing Apps",
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        initialRoute: AppRouteName.authWrapper,
        onGenerateRoute: AppRoute.generate,
        navigatorObservers: [routeObserver],
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
