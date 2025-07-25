import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '_core/providers/audio_provider.dart';
import '_core/providers/user_provider.dart';
import 'domain/models/sheet_model.dart';
import 'ui/_core/widgets/circular_progress_indicator.dart';
import 'ui/auth/login_screen.dart';
import 'ui/campaign/campaign_screen.dart';
import 'ui/campaign/utils/campaign_subpages.dart';
import 'ui/campaign/view/campaign_view_model.dart';
import 'ui/home/home_screen.dart';
import 'ui/home/utils/home_tabs.dart';
import 'ui/sheet/components/sheet_works_dialog.dart';
import 'ui/sheet/sheet_screen.dart';
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
          return HomeScreen(page: HomeTabs.sheets);
        },
      ),
      GoRoute(
        path: "/campaigns",
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen(page: HomeTabs.campaigns);
        },
      ),
      GoRoute(
        path: "/profile",
        builder: (context, state) {
          disposeListeners(context);
          return HomeScreen(page: HomeTabs.profile);
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

          return SheetSettingsPage(isPopup: true);
        },
      ),
      GoRoute(
        path: "/campaign/:campaignId",
        builder: (context, state) {
          String id = state.pathParameters["campaignId"] ?? "";

          return FutureBuilder(
            future: context.read<UserProvider>().initializeCampaign(
                  context: context,
                  campaignId: id,
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return ScaffoldCenterCPI();
              }
              return CampaignScreen(key: ValueKey(id));
            },
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

    AudioProvider audioProvider = Provider.of<AudioProvider>(
      context,
      listen: false,
    );
    audioProvider.onDispose();

    CampaignViewModel campaignVM = Provider.of<CampaignViewModel>(
      context,
      listen: false,
    );
    campaignVM.hasInteractedDisable();
  }

  goHome({required BuildContext context, HomeTabs? subPage}) {
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
    CampaignTabs? subPage,
  }) {
    if (subPage != null) {
      GoRouter.of(context).go("/campaign/$campaignId/${subPage.name}");
    } else {
      GoRouter.of(context).go("/campaign/$campaignId");
    }
  }
}
