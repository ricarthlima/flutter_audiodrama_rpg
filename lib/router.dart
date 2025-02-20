import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/auth/login_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/home/home_screen.dart';
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

          if (FirebaseAuth.instance.currentUser == null) {
            GoRouter.of(context).go(root);
          }

          if (userId != null &&
              FirebaseAuth.instance.currentUser!.uid != userId) {
            GoRouter.of(context).go(root);
          }

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
