import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/auth/login_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'ui/sheet/view/sheet_view_model.dart';

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

          final viewModel = Provider.of<SheetViewModel>(context, listen: false);
          viewModel.id = id;
          viewModel.userId = userId;
          // viewModel.updateCredentials(id: id, userId: userId);

          return SheetScreen(
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
