import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/repositories/action_repository.dart';
import 'data/repositories/condition_repository.dart';
import 'data/repositories/item_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '_core/providers/audio_provider.dart';
import '_core/providers/user_provider.dart';
import 'data/repositories_local/action_repository_local.dart';
import 'data/repositories_local/condition_repository_local.dart';
import 'data/repositories_local/item_repository_local.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'ui/_core/theme.dart';
import 'ui/campaign/view/campaign_view_model.dart';
import 'ui/campaign/view/campaign_visual_novel_view_model.dart';
import 'ui/home/view/home_view_model.dart';
import 'ui/settings/view/settings_provider.dart';
import 'ui/sheet/view/sheet_view_model.dart';
import 'ui/shopping/view/shopping_view_model.dart';
import 'ui/statistics/view/statistics_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FullScreen.ensureInitialized();

  setUrlStrategy(PathUrlStrategy());

  await dotenv.load(fileName: "dotenv");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform.copyWith(
      databaseURL: dotenv.env["FIREBASE_URL"],
    ),
  );

  await Supabase.initialize(
    url: dotenv.env["SUPABASE_URL"]!,
    anonKey: dotenv.env["SUPABASE_ANON_KEY"]!,
  );

  ActionRepository actionRepo = ActionRepositoryLocal();
  await actionRepo.onInitialize();

  ItemRepository itemRepo = ItemRepositoryLocal();
  await itemRepo.onInitialize();

  ConditionRepository conditionRepo = ConditionRepositoryLocal();
  await conditionRepo.onInitialize();

  SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  AudioProvider audioProvider = AudioProvider();
  await audioProvider.onInitialize();

  HomeViewModel homeVM = HomeViewModel();
  SheetViewModel sheetVM = SheetViewModel(
    id: "",
    username: "",
    actionRepo: actionRepo,
    conditionRepo: conditionRepo,
  );
  ShoppingViewModel shoppingVM = ShoppingViewModel(
    sheetVM: sheetVM,
    itemRepo: itemRepo,
  );
  StatisticsViewModel statisticsVM = StatisticsViewModel();
  CampaignViewModel campaignVM = CampaignViewModel();
  CampaignVisualNovelViewModel campaignVisualVM =
      CampaignVisualNovelViewModel(campaignId: "");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => homeVM),
        ChangeNotifierProvider(create: (_) => sheetVM),
        ChangeNotifierProvider(create: (_) => shoppingVM),
        ChangeNotifierProvider(create: (_) => statisticsVM),
        ChangeNotifierProvider(create: (_) => campaignVM),
        ChangeNotifierProvider(create: (_) => campaignVisualVM),
        ChangeNotifierProvider(create: (_) => audioProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _WebScrollBehavior(),
      routerConfig: AppRouter.router,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      supportedLocales: [
        Locale('pt', 'BR'), // Adiciona suporte ao português do Brasil
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // Suporte para iOS também
      ],
    );
  }
}

class _WebScrollBehavior extends MaterialScrollBehavior {
  const _WebScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
