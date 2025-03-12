import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/auth/login_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/components/sheet_works_dialog.dart';
import 'package:flutter_rpg_audiodrama/ui/sheet/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'domain/models/sheet_model.dart';
import 'ui/sheet/view/sheet_view_model.dart';

class AppRouter {
  static const String home = "/";
  static const String auth = "/auth";
  static const String sheet = "/sheet";

  static final GoRouter router = GoRouter(
    redirect: (context, state) {
      bool loggedIn = FirebaseAuth.instance.currentUser != null;
      if (!loggedIn) {
        return auth;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: "/auth",
        builder: (context, state) => LoginScreen(),
        redirect: (context, state) {
          bool loggedIn = FirebaseAuth.instance.currentUser != null;
          if (loggedIn) {
            return home;
          }
          return null;
        },
      ),
      GoRoute(
        path: "/:username/sheet/:sheetId",
        builder: (context, state) {
          String id = state.pathParameters["sheetId"] ?? "";
          String username = state.pathParameters["username"] ?? "";

          Provider.of<SheetViewModel>(context, listen: false).updateCredentials(
            id: id,
            username: username,
          );

          return SheetScreen(
            key: UniqueKey(),
          );
        },
      ),
      GoRoute(
        path: "/:username/sheet/:sheetId/works",
        builder: (context, state) {
          String id = state.pathParameters["sheetId"] ?? "";
          String username = state.pathParameters["username"] ?? "";

          Provider.of<SheetViewModel>(context, listen: false).updateCredentials(
            id: id,
            username: username,
          );

          return SheetWorksDialog(isPopup: true);
        },
      ),
    ],
  );

  goHome({required BuildContext context}) {
    GoRouter.of(context).go(AppRouter.home);
  }

  goAuth({required BuildContext context}) {
    GoRouter.of(context).go(AppRouter.auth);
  }

  goSheet({
    required BuildContext context,
    required String username,
    required Sheet sheet,
  }) {
    GoRouter.of(context).go("/$username${AppRouter.sheet}/${sheet.id}");
  }
}
