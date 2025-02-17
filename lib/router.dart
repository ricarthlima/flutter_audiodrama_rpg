import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rpg_audiodrama/f_auth/ui/login_screen.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/ui/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/f_home/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String root = "/";
  static const String home = "/";
  static const String auth = "/auth";
  static const String sheet = "/sheet";

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: "/auth",
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: "/sheet/:sheetId",
        builder: (context, state) {
          String id = state.pathParameters["sheetId"] ?? "";
          String? userId = state.extra as String?;
          return SheetScreen(
            id: id,
            userId: userId,
            key: UniqueKey(),
          );
        },
      ),
      GoRoute(
        path: "/",
        builder: (context, state) => HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      bool loggedIn = FirebaseAuth.instance.currentUser != null;
      if (!loggedIn) {
        return auth;
      }
      return null;
    },
  );
}
