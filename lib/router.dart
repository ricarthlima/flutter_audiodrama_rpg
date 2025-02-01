import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rpg_audiodrama/f_auth/ui/login_screen.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/models/sheet_model.dart';
import 'package:flutter_rpg_audiodrama/f_sheets/ui/sheet_screen.dart';
import 'package:flutter_rpg_audiodrama/f_user/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String root = "/";
  static const String home = "/home";
  static const String auth = "/auth";
  static const String sheet = "/sheet";

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: "/auth",
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: "/sheet/:id",
        builder: (context, state) => SheetScreen(
          sheet: SheetModel(
            characterName: "Angus Silvana",
            listActionValue: [],
          ),
        ),
      ),
      GoRoute(
        path: "/home",
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
