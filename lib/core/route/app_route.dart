import 'package:canvas_drawer_plus/feature/drawing_room/presentation/drawing_room_screen.dart';
import 'package:canvas_drawer_plus/feature/drawing_room/presentation/room_list_screen.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/sign_in_screen.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/sign_up_screen.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/auth_wrapper.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/user_profile_screen.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/edit_profile_screen.dart';
import 'package:canvas_drawer_plus/feature/auth/presentation/profile_settings_screen.dart';
import 'package:flutter/material.dart';
import '/core/route/app_route_name.dart';

class AppRoute {
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteName.authWrapper:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );

      case AppRouteName.signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );

      case AppRouteName.signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case AppRouteName.userProfile:
        return MaterialPageRoute(
          builder: (_) => const UserProfileScreen(),
          settings: settings,
        );

      case AppRouteName.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      case AppRouteName.profileSettings:
        return MaterialPageRoute(
          builder: (_) => const ProfileSettingsScreen(),
          settings: settings,
        );

      case AppRouteName.roomList:
        return MaterialPageRoute(
          builder: (_) => const RoomListScreen(),
          settings: settings,
        );

      case AppRouteName.drawingRoom:
        final roomId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DrawingRoomScreen(roomId: roomId),
          settings: settings,
        );

      case "/template":
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const SizedBox(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
    }

    return null;
  }
}
