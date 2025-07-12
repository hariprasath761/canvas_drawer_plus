import 'package:canvas_drawer_plus/feature/drawing_room/model/drawing_point.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/model/drawing_room.dart';
import 'package:canvas_drawer_plus/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/route/app_route.dart';
import 'core/route/app_route_name.dart';
import 'core/theme/app_theme.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Global Isar instance
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([
    DrawingPointSchema,
    DrawingRoomSchema,
  ], directory: dir.path);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Drawing Apps",
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute: AppRouteName.authWrapper,
      onGenerateRoute: AppRoute.generate,
      navigatorObservers: [routeObserver],
    );
  }
}
