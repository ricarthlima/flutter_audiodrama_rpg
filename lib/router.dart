import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_audiodrama/ui/_core/user_provider.dart';
import 'package:flutter_rpg_audiodrama/ui/auth/login_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/campaign_screen.dart';
import 'package:flutter_rpg_audiodrama/ui/campaign/utils/campaign_subpages.dart';
import 'package:flutter_rpg_audiodrama/ui/home/view/home_view_model.dart';
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
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen();
        },
      ),
      GoRoute(
        path: "/sheets",
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen(page: HomeSubPages.sheets);
        },
      ),
      GoRoute(
        path: "/campaigns",
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen(page: HomeSubPages.campaigns);
        },
      ),
      GoRoute(
        path: "/profile",
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen(page: HomeSubPages.profile);
        },
      ),
      GoRoute(
        path: "/auth",
        builder: (context, state) => LoginScreen(),
        redirect: (context, state) {
          disposeListeners(context);

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
          disposeListeners(context);

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
          disposeListeners(context);

          String id = state.pathParameters["sheetId"] ?? "";
          String username = state.pathParameters["username"] ?? "";

          Provider.of<SheetViewModel>(context, listen: false).updateCredentials(
            id: id,
            username: username,
          );

          return SheetWorksDialog(isPopup: true);
        },
      ),
      GoRoute(
        path: "/campaign/:campaignId",
        builder: (context, state) {
          disposeListeners(context);

          String id = state.pathParameters["campaignId"] ?? "";

          // Provider.of<CampaignViewModel>(context).campaignId = id;
          context.read<UserProvider>().initializeCampaign(
                context: context,
                campaignId: id,
              );

          return CampaignScreen();
        },
      ),
      GoRoute(
        path: "/campaign/:campaignId/:subpage",
        builder: (context, state) {
          disposeListeners(context);

          String id = state.pathParameters["campaignId"] ?? "";
          String subPage = state.pathParameters["subpage"] ?? "";

          context.read<UserProvider>().initializeCampaign(
                context: context,
                campaignId: id,
              );

          return CampaignScreen(
            subPage: CampaignSubPages.values.firstWhere(
              (e) => e.name == subPage,
              orElse: () => CampaignSubPages.sheets,
            ),
          );
        },
      ),
    ],
  );

  static disposeListeners(context) {
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    userProvider.disposeCampaign();
  }

  goHome({required BuildContext context, HomeSubPages? subPage}) {
    if (subPage != null) {
      GoRouter.of(context).go("/${subPage.name}");
    } else {
      GoRouter.of(context).go(AppRouter.home);
    }
  }

  goAuth({required BuildContext context}) {
    GoRouter.of(context).go(AppRouter.auth);
  }

  goSheet({
    required BuildContext context,
    required String username,
    required Sheet sheet,
    bool isPushing = false,
  }) async {
    if (isPushing) {
      GoRouter.of(context).push("/$username${AppRouter.sheet}/${sheet.id}");
    } else {
      GoRouter.of(context).go("/$username${AppRouter.sheet}/${sheet.id}");
    }
  }

  goCampaign({
    required BuildContext context,
    required String campaignId,
    CampaignSubPages? subPage,
  }) {
    if (subPage != null) {
      GoRouter.of(context).go("/campaign/$campaignId/${subPage.name}");
    } else {
      GoRouter.of(context).go("/campaign/$campaignId");
    }
  }
}
